package kr.go.dgif.govportal.adapters;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.*;
import java.util.function.Supplier;

@Slf4j
@Component
public class MetabaseClient {
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    
    @Value("${metabase.base-url}")
    private String baseUrl;
    
    @Value("${metabase.embed-secret}")
    private String embedSecret;
    
    @Value("${metabase.session:}")
    private String sessionToken;

    @Value("${metabase.username:}")
    private String metabaseUsername;

    @Value("${metabase.password:}")
    private String metabasePassword;

    @Value("${metabase.embed-external-base-url:}")
    private String embedExternalBaseUrl;

    @Value("${metabase.session-ttl-seconds:3600}")
    private long sessionTtlSeconds;

    private final Object sessionLock = new Object();
    private volatile String cachedSessionToken;
    private volatile Instant cachedSessionExpiry;

    public MetabaseClient(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    public String getSessionToken() {
        if (sessionToken != null && !sessionToken.isEmpty()) {
            return sessionToken;
        }
        synchronized (sessionLock) {
            if (cachedSessionToken != null && cachedSessionExpiry != null
                    && Instant.now().isBefore(cachedSessionExpiry.minusSeconds(60))) {
                return cachedSessionToken;
            }
            cachedSessionToken = requestNewSessionToken();
            long ttlSeconds = sessionTtlSeconds > 0 ? sessionTtlSeconds : 3600L;
            cachedSessionExpiry = Instant.now().plusSeconds(ttlSeconds);
            return cachedSessionToken;
        }
    }

    private String requestNewSessionToken() {
        String username = resolveUsername();
        String password = resolvePassword();
        if (!StringUtils.hasText(username) || !StringUtils.hasText(password)) {
            throw new RuntimeException("Metabase session token not configured and no credentials provided");
        }
        try {
            String url = resolveBaseUrl() + "/api/session";
            Map<String, String> payload = new HashMap<>();
            payload.put("username", username);
            payload.put("password", password);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, String>> request = new HttpEntity<>(payload, headers);

            ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                JsonNode node = objectMapper.readTree(response.getBody());
                if (node.has("id")) {
                    String token = node.get("id").asText();
                    log.info("Obtained new Metabase session token via API login");
                    return token;
                }
            }
            throw new RuntimeException("Metabase login failed with status " + response.getStatusCode());
        } catch (Exception e) {
            log.error("Failed to obtain Metabase session token", e);
            throw new RuntimeException("Metabase session token not configured and automatic login failed", e);
        }
    }

    private String resolveUsername() {
        if (StringUtils.hasText(metabaseUsername)) {
            return metabaseUsername;
        }
        return System.getenv("MB_USERNAME");
    }

    private String resolvePassword() {
        if (StringUtils.hasText(metabasePassword)) {
            return metabasePassword;
        }
        return System.getenv("MB_PASSWORD");
    }

    private String resolveEmbedSecret() {
        String envSecret = System.getenv("MB_EMBED_SECRET");
        if (StringUtils.hasText(envSecret)) {
            return envSecret;
        }
        if (StringUtils.hasText(embedSecret)) {
            return embedSecret;
        }
        return null;
    }

    private byte[] resolveEmbedKeyBytes() {
        String secret = resolveEmbedSecret();
        if (!StringUtils.hasText(secret)) {
            throw new IllegalStateException("Metabase embed secret is not configured");
        }
        return secret.trim().getBytes(StandardCharsets.UTF_8);
    }

    private String resolveBaseUrl() {
        if (StringUtils.hasText(baseUrl) && !baseUrl.contains("${")) {
            return baseUrl;
        }
        String envUrl = System.getenv("MB_BASE_URL");
        if (StringUtils.hasText(envUrl)) {
            return envUrl;
        }
        return "http://metabase:3000";
    }

    private String resolveEmbedBaseUrl() {
        if (StringUtils.hasText(embedExternalBaseUrl) && !embedExternalBaseUrl.contains("${")) {
            return embedExternalBaseUrl;
        }
        String envUrl = System.getenv("MB_EMBED_EXTERNAL_BASE_URL");
        if (StringUtils.hasText(envUrl)) {
            return envUrl;
        }
        return resolveBaseUrl();
    }

    private void invalidateCachedSession() {
        synchronized (sessionLock) {
            cachedSessionToken = null;
            cachedSessionExpiry = null;
        }
    }

    private HttpHeaders buildSessionHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-Metabase-Session", getSessionToken());
        return headers;
    }

    private <T> ResponseEntity<T> executeWithSession(Supplier<ResponseEntity<T>> supplier) {
        for (int attempt = 0; attempt < 2; attempt++) {
            try {
                return supplier.get();
            } catch (HttpClientErrorException e) {
                if (e.getStatusCode() == HttpStatus.UNAUTHORIZED || e.getStatusCode() == HttpStatus.FORBIDDEN) {
                    log.warn("Metabase session invalid ({}), refreshing token", e.getStatusCode());
                    invalidateCachedSession();
                    continue;
                }
                throw e;
            }
        }
        throw new RuntimeException("Metabase request failed after refreshing session");
    }

    public Map<String, Object> ensureDatabase(String dbHost, int dbPort, String dbName, String dbUser, String dbPassword) {
        try {
            // First, check if database already exists
            String checkUrl = resolveBaseUrl() + "/api/database";

            ResponseEntity<String> response = executeWithSession(() -> {
                HttpHeaders headers = buildSessionHeaders();
                HttpEntity<Void> request = new HttpEntity<>(headers);
                return restTemplate.exchange(checkUrl, HttpMethod.GET, request, String.class);
            });

            if (response.getStatusCode() == HttpStatus.OK) {
                JsonNode databases = objectMapper.readTree(response.getBody());
                if (databases.has("data")) {
                    for (JsonNode db : databases.get("data")) {
                        if (db.has("name") && db.get("name").asText().equals("egov-db")) {
                            log.info("Metabase database already exists: {}", db.get("id").asInt());
                            Map<String, Object> result = new HashMap<>();
                            result.put("database_id", db.get("id").asInt());
                            result.put("name", db.get("name").asText());
                            result.put("status", "existing");
                            return result;
                        }
                    }
                }
            }

            // Database doesn't exist, create it
            return createDatabase(dbHost, dbPort, dbName, dbUser, dbPassword);

        } catch (Exception e) {
            log.error("Error ensuring Metabase database", e);
            throw new RuntimeException("Failed to ensure Metabase database", e);
        }
    }

    private Map<String, Object> createDatabase(String dbHost, int dbPort, String dbName, String dbUser, String dbPassword) {
        try {
            String url = resolveBaseUrl() + "/api/database";

            Map<String, Object> details = new HashMap<>();
            details.put("host", dbHost);
            details.put("port", dbPort);
            details.put("dbname", dbName);
            details.put("user", dbUser);
            details.put("password", dbPassword);
            details.put("ssl", false);
            details.put("tunnel-enabled", false);

            Map<String, Object> payload = new HashMap<>();
            payload.put("name", "egov-db");
            payload.put("engine", "postgres");
            payload.put("details", details);
            payload.put("auto_run_queries", true);
            payload.put("is_full_sync", true);

            ResponseEntity<String> response = executeWithSession(() -> {
                HttpHeaders headers = buildSessionHeaders();
                HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(payload, headers);
                return restTemplate.postForEntity(url, requestEntity, String.class);
            });

            if (response.getStatusCode() == HttpStatus.OK) {
                JsonNode node = objectMapper.readTree(response.getBody());
                Map<String, Object> result = new HashMap<>();
                result.put("database_id", node.get("id").asInt());
                result.put("name", node.get("name").asText());
                result.put("status", "created");
                log.info("Created Metabase database: {}", result);
                return result;
            }
            throw new RuntimeException("Failed to create database: " + response.getStatusCode());
        } catch (Exception e) {
            log.error("Error creating Metabase database", e);
            throw new RuntimeException("Metabase database creation failed", e);
        }
    }

    public Map<String, Object> createCollection(String projectName, String projectId) {
        try {
            String url = resolveBaseUrl() + "/api/collection";

            Map<String, Object> payload = new HashMap<>();
            payload.put("name", "Project: " + projectName);
            payload.put("description", "Auto-generated for project " + projectId);
            payload.put("color", "#509EE3");

            ResponseEntity<String> response = executeWithSession(() -> {
                HttpHeaders headers = buildSessionHeaders();
                HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
                return restTemplate.postForEntity(url, request, String.class);
            });

            if (response.getStatusCode() == HttpStatus.OK) {
                JsonNode node = objectMapper.readTree(response.getBody());
                Map<String, Object> result = new HashMap<>();
                result.put("collection_id", node.get("id").asInt());
                result.put("name", node.get("name").asText());
                log.info("Created Metabase collection: {}", result);
                return result;
            }
            throw new RuntimeException("Failed to create collection: " + response.getStatusCode());
        } catch (Exception e) {
            log.error("Error creating Metabase collection", e);
            throw new RuntimeException("Metabase collection creation failed", e);
        }
    }

    public List<Map<String, Object>> createOperationalCards(int collectionId, String projectId, int databaseId) {
        List<Map<String, Object>> cards = new ArrayList<>();
        String[] cardTemplates = {
            "Reach_Ops",
            "Quality_Ops", 
            "Action_List",
            "Diagnosis_Distribution",
            "Attach_Validity",
            "Model_Health"
        };

        for (String cardName : cardTemplates) {
            try {
                Map<String, Object> card = createCard(collectionId, cardName, projectId, databaseId);
                cards.add(card);
            } catch (Exception e) {
                log.error("Failed to create card: {}", cardName, e);
            }
        }
        return cards;
    }

    private Map<String, Object> createCard(int collectionId, String cardName, String projectId, int databaseId) {
        try {
            String url = resolveBaseUrl() + "/api/card";

            Map<String, Object> query = buildQueryForCard(cardName, projectId, databaseId);
            
            Map<String, Object> payload = new HashMap<>();
            payload.put("name", cardName.replace("_", " "));
            payload.put("collection_id", collectionId);
            payload.put("display", getDisplayType(cardName));
            payload.put("visualization_settings", new HashMap<>());
            payload.put("dataset_query", query);

            ResponseEntity<String> response = executeWithSession(() -> {
                HttpHeaders headers = buildSessionHeaders();
                HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
                return restTemplate.postForEntity(url, request, String.class);
            });

            if (response.getStatusCode() == HttpStatus.OK) {
                JsonNode node = objectMapper.readTree(response.getBody());
                Map<String, Object> result = new HashMap<>();
                result.put("card_id", node.get("id").asInt());
                result.put("name", node.get("name").asText());
                log.info("Created Metabase card: {}", result);
                return result;
            }
            throw new RuntimeException("Failed to create card: " + response.getStatusCode());
        } catch (Exception e) {
            log.error("Error creating card: {}", cardName, e);
            throw new RuntimeException("Card creation failed", e);
        }
    }

    private Map<String, Object> buildQueryForCard(String cardName, String projectId, int databaseId) {
        Map<String, Object> query = new HashMap<>();
        query.put("type", "native");
        query.put("database", databaseId);

        Map<String, Object> nativeQuery = new HashMap<>();
        nativeQuery.put("query", getSqlForCard(cardName, projectId));
        query.put("native", nativeQuery);

        return query;
    }

    private String getSqlForCard(String cardName, String projectId) {
        switch (cardName) {
            case "Reach_Ops":
                return String.format("SELECT COUNT(*) as total_submissions FROM submissions_raw WHERE project_id = '%s'", projectId);
            case "Quality_Ops":
                return String.format("SELECT status, COUNT(*) as count FROM quality_flags WHERE project_id = '%s' GROUP BY status", projectId);
            case "Action_List":
                return String.format("SELECT * FROM quality_flags WHERE project_id = '%s' AND status = 'flagged' LIMIT 100", projectId);
            case "Diagnosis_Distribution":
                return String.format("SELECT payload->>'diagnosis' as diagnosis, COUNT(*) FROM submissions_raw WHERE project_id = '%s' GROUP BY diagnosis", projectId);
            case "Attach_Validity":
                return String.format("SELECT COUNT(*) as with_attachments FROM submissions_raw WHERE project_id = '%s' AND media IS NOT NULL", projectId);
            case "Model_Health":
                return String.format("SELECT 'Model Health' as metric, 100 as score");
            default:
                return "SELECT 1";
        }
    }

    private String getDisplayType(String cardName) {
        switch (cardName) {
            case "Reach_Ops":
            case "Attach_Validity":
                return "scalar";
            case "Quality_Ops":
            case "Diagnosis_Distribution":
                return "bar";
            case "Action_List":
                return "table";
            case "Model_Health":
                return "gauge";
            default:
                return "table";
        }
    }

    public String generateEmbedUrl(int cardId, Map<String, Object> params) {
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("resource", Map.of("card", cardId));
            payload.put("params", params);
            payload.put("exp", Instant.now().plusSeconds(600).getEpochSecond());

            SecretKeySpec key = new SecretKeySpec(
                resolveEmbedKeyBytes(),
                SignatureAlgorithm.HS256.getJcaName()
            );

            String token = Jwts.builder()
                .setClaims(payload)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();

            return resolveEmbedBaseUrl() + "/embed/question/" + token + "#bordered=true&titled=true";
        } catch (Exception e) {
            log.error("Error generating embed URL", e);
            throw new RuntimeException("Embed URL generation failed", e);
        }
    }

    public String generateDashboardEmbedUrl(int dashboardId, Map<String, Object> params) {
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("resource", Map.of("dashboard", dashboardId));
            payload.put("params", params);
            payload.put("exp", Instant.now().plusSeconds(600).getEpochSecond());

            SecretKeySpec key = new SecretKeySpec(
                resolveEmbedKeyBytes(),
                SignatureAlgorithm.HS256.getJcaName()
            );

            String token = Jwts.builder()
                .setClaims(payload)
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();

            return resolveEmbedBaseUrl() + "/embed/dashboard/" + token + "#bordered=true&titled=true";
        } catch (Exception e) {
            log.error("Error generating dashboard embed URL", e);
            throw new RuntimeException("Dashboard embed URL generation failed", e);
        }
    }
}
