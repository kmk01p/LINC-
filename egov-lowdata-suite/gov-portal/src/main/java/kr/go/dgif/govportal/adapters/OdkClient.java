package kr.go.dgif.govportal.adapters;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import egovframework.govportal.cmmn.exception.BusinessException;
import egovframework.govportal.cmmn.exception.ValidationException;
import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.util.UriComponentsBuilder;

import javax.annotation.Resource;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Component("odkClient")
public class OdkClient {

    private static final Logger LOGGER = LoggerFactory.getLogger(OdkClient.class);
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    @Resource(name = "restTemplate")
    private RestTemplate restTemplate;

    @Resource(name = "propertyConfigurer")
    private EgovPropertyService propertyService;

    public OdkProjectRef createProject(String name) {
        String url = baseUrl() + "/v1/projects";
        Map<String, Object> payload = new HashMap<>();
        payload.put("name", name);
        payload.put("description", "Auto provisioned by gov-portal");
        HttpHeaders headers = authHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(url, new HttpEntity<>(payload, headers), Map.class);
            if (response.getBody() == null) {
                throw new BusinessException("ODK_ERROR", "ODK 프로젝트 생성 응답이 비어 있습니다.");
            }
            Object idValue = response.getBody().get("id");
            Object acteeIdValue = response.getBody().get("acteeId");
            if (!(idValue instanceof Number) || acteeIdValue == null) {
                throw new BusinessException("ODK_ERROR", "ODK 프로젝트 응답에 필수 필드가 없습니다.");
            }
            long projectId = ((Number) idValue).longValue();
            UUID acteeId = UUID.fromString(acteeIdValue.toString());
            return new OdkProjectRef(projectId, acteeId);
        } catch (Exception ex) {
            LOGGER.error("Failed to create ODK project", ex);
            throw new BusinessException("ODK_ERROR", "ODK 프로젝트 생성 실패");
        }
    }

    public String uploadForm(long odkProjectId, String formId, byte[] xlsBytes) {
        if (xlsBytes == null || xlsBytes.length == 0) {
            throw new ValidationException("XLSForm 데이터가 없습니다.");
        }
        String url = String.format("%s/v1/projects/%d/forms?ignoreWarnings=true", baseUrl(), odkProjectId);
        HttpHeaders headers = authHeaders();
        headers.setContentType(MediaType.parseMediaType(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.set("X-XlsForm-FormId-Fallback", formId);

        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(url, new HttpEntity<>(xlsBytes, headers), Map.class);
            if (response.getBody() == null || response.getBody().get("xmlFormId") == null) {
                throw new BusinessException("ODK_ERROR", "ODK 폼 업로드 실패");
            }
            return response.getBody().get("xmlFormId").toString();
        } catch (HttpClientErrorException ex) {
            String responseBody = ex.getResponseBodyAsString();
            LOGGER.error("Failed to upload ODK form: {}", responseBody, ex);
            String detail = extractOdkError(responseBody);
            throw new BusinessException("ODK_ERROR", "ODK 폼 업로드 실패: " + detail);
        } catch (Exception ex) {
            LOGGER.error("Failed to upload ODK form", ex);
            String message = ex.getMessage() != null ? ex.getMessage() : "알 수 없는 오류";
            throw new BusinessException("ODK_ERROR", "ODK 폼 업로드 중 오류: " + message);
        }
    }

    public void publishForm(long odkProjectId, String xmlFormId) {
        String url = String.format("%s/v1/projects/%d/forms/%s/draft/publish", baseUrl(), odkProjectId, xmlFormId);
        HttpHeaders headers = authHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        // ODK Central expects version in the body, not as query parameter
        Map<String, Object> body = new HashMap<>();
        body.put("version", "v1");

        try {
            restTemplate.postForEntity(url, new HttpEntity<>(body, headers), String.class);
        } catch (HttpClientErrorException ex) {
            LOGGER.error("Failed to publish ODK form: {}", ex.getResponseBodyAsString(), ex);
            throw new BusinessException("ODK_ERROR", "ODK 폼 게시 실패: " + ex.getResponseBodyAsString());
        } catch (Exception ex) {
            LOGGER.error("Failed to publish ODK form", ex);
            throw new BusinessException("ODK_ERROR", "ODK 폼 게시 실패");
        }
    }

    public void deleteProject(long odkProjectId) {
        String url = String.format("%s/v1/projects/%d", baseUrl(), odkProjectId);
        HttpHeaders headers = authHeaders();
        try {
            restTemplate.exchange(url, HttpMethod.DELETE, new HttpEntity<>(headers), String.class);
            LOGGER.info("Deleted ODK project: {}", odkProjectId);
        } catch (Exception ex) {
            LOGGER.error("Failed to delete ODK project {}", odkProjectId, ex);
            throw new BusinessException("ODK_ERROR", "ODK 프로젝트 삭제 실패");
        }
    }

    public AppUserRef createAppUser(long odkProjectId, String displayName) {
        String url = String.format("%s/v1/projects/%d/app-users", baseUrl(), odkProjectId);
        Map<String, Object> payload = new HashMap<>();
        payload.put("displayName", displayName);
        HttpHeaders headers = authHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            ResponseEntity<Map> response = restTemplate.postForEntity(url, new HttpEntity<>(payload, headers), Map.class);
            if (response.getBody() == null) {
                throw new BusinessException("ODK_ERROR", "ODK App User 생성 응답이 비어 있습니다.");
            }
            Object idValue = response.getBody().get("id");
            Object tokenValue = response.getBody().get("token");
            if (idValue == null || tokenValue == null) {
                throw new BusinessException("ODK_ERROR", "ODK App User 응답에 필수 필드가 없습니다.");
            }
            int appUserId = ((Number) idValue).intValue();
            String token = tokenValue.toString();
            LOGGER.info("Created ODK App User: {} in project {}", appUserId, odkProjectId);
            return new AppUserRef(appUserId, token);
        } catch (Exception ex) {
            LOGGER.error("Failed to create ODK App User", ex);
            throw new BusinessException("ODK_ERROR", "ODK App User 생성 실패");
        }
    }

    public void grantFormAccess(long odkProjectId, String xmlFormId, int appUserId) {
        // Grant form access by updating the project with form assignments
        String url = String.format("%s/v1/projects/%d", baseUrl(), odkProjectId);

        // First, get the current project state including forms
        HttpHeaders getHeaders = authHeaders();
        ResponseEntity<Map> projectResponse;
        try {
            projectResponse = restTemplate.exchange(
                url + "?forms=true",
                HttpMethod.GET,
                new HttpEntity<>(getHeaders),
                Map.class
            );
        } catch (Exception ex) {
            LOGGER.error("Failed to fetch ODK project for form access", ex);
            throw new BusinessException("ODK_ERROR", "ODK 프로젝트 조회 실패");
        }

        Map<String, Object> project = projectResponse.getBody();
        if (project == null) {
            throw new BusinessException("ODK_ERROR", "ODK 프로젝트를 찾을 수 없습니다.");
        }

        // Get role ID for app-user (typically 2)
        String rolesUrl = baseUrl() + "/v1/roles";
        ResponseEntity<List> rolesResponse;
        try {
            rolesResponse = restTemplate.exchange(rolesUrl, HttpMethod.GET, new HttpEntity<>(getHeaders), List.class);
        } catch (Exception ex) {
            LOGGER.error("Failed to fetch ODK roles", ex);
            throw new BusinessException("ODK_ERROR", "ODK 역할 조회 실패");
        }

        List<Map<String, Object>> roles = rolesResponse.getBody();
        int appUserRoleId = -1;
        if (roles != null) {
            for (Map<String, Object> role : roles) {
                if ("app-user".equals(role.get("system"))) {
                    appUserRoleId = ((Number) role.get("id")).intValue();
                    break;
                }
            }
        }

        if (appUserRoleId == -1) {
            throw new BusinessException("ODK_ERROR", "ODK app-user 역할을 찾을 수 없습니다.");
        }

        // Build the assignment for this form
        Map<String, Object> assignment = new HashMap<>();
        assignment.put("actorId", appUserId);
        assignment.put("roleId", appUserRoleId);

        // Build the form object with assignment
        Map<String, Object> formUpdate = new HashMap<>();
        formUpdate.put("xmlFormId", xmlFormId);
        formUpdate.put("state", "open");
        formUpdate.put("assignments", Collections.singletonList(assignment));

        // Build the project update payload
        Map<String, Object> updatePayload = new HashMap<>();
        updatePayload.put("name", project.get("name"));
        updatePayload.put("forms", Collections.singletonList(formUpdate));

        HttpHeaders headers = authHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        try {
            restTemplate.exchange(url, HttpMethod.PUT, new HttpEntity<>(updatePayload, headers), String.class);
            LOGGER.info("Granted form access for App User {} to form {} in project {}", appUserId, xmlFormId, odkProjectId);
        } catch (HttpClientErrorException ex) {
            LOGGER.error("Failed to grant form access: {}", ex.getResponseBodyAsString(), ex);
            throw new BusinessException("ODK_ERROR", "ODK 폼 접근 권한 부여 실패: " + ex.getResponseBodyAsString());
        } catch (Exception ex) {
            LOGGER.error("Failed to grant form access", ex);
            throw new BusinessException("ODK_ERROR", "ODK 폼 접근 권한 부여 실패");
        }
    }

    public static class AppUserRef {
        private final int appUserId;
        private final String token;

        public AppUserRef(int appUserId, String token) {
            this.appUserId = appUserId;
            this.token = token;
        }

        public int getAppUserId() {
            return appUserId;
        }

        public String getToken() {
            return token;
        }
    }

    public List<JsonNode> fetchSubmissions(long odkProjectId,
                                           String xmlFormId,
                                           String cursor,
                                           int limit) {
        String endpoint = String.format("%s/v1/projects/%d/forms/%s/submissions", baseUrl(), odkProjectId, xmlFormId);
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(endpoint)
            .queryParam("limit", limit);
        if (cursor != null && !cursor.isEmpty()) {
            builder.queryParam("cursor", cursor);
        }

        HttpEntity<Void> request = new HttpEntity<>(authHeaders());
        try {
            ResponseEntity<JsonNode[]> response = restTemplate.exchange(
                builder.toUriString(),
                HttpMethod.GET,
                request,
                JsonNode[].class
            );
            JsonNode[] body = response.getBody();
            if (body == null || body.length == 0) {
                return Collections.emptyList();
            }
            return Arrays.asList(body);
        } catch (Exception ex) {
            LOGGER.error("Failed to fetch ODK submissions", ex);
            throw new BusinessException("ODK_ERROR", "ODK 제출 조회 실패");
        }
    }

    public static class OdkProjectRef {
        private final long projectId;
        private final UUID acteeId;

        public OdkProjectRef(long projectId, UUID acteeId) {
            this.projectId = projectId;
            this.acteeId = acteeId;
        }

        public long getProjectId() {
            return projectId;
        }

        public UUID getActeeId() {
            return acteeId;
        }
    }

    private String baseUrl() {
        return resolve(propertyService.getString("Globals.Odk.BaseUrl"));
    }

    private HttpHeaders authHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + resolve(propertyService.getString("Globals.Odk.ApiToken")));
        String hostHeader = resolve(propertyService.getString("Globals.Odk.HostHeader"));
        if (hostHeader != null && !hostHeader.isEmpty()) {
            headers.set(HttpHeaders.HOST, hostHeader);
        }
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        headers.setAcceptCharset(Collections.singletonList(StandardCharsets.UTF_8));
        return headers;
    }

    private String extractOdkError(String body) {
        if (body == null || body.isEmpty()) {
            return "상세 오류 없음";
        }
        try {
            JsonNode root = OBJECT_MAPPER.readTree(body);
            if (root.has("details") && root.get("details").has("error")) {
                String detail = root.get("details").get("error").asText();
                return truncate(detail);
            }
            if (root.has("message")) {
                return truncate(root.get("message").asText());
            }
        } catch (Exception ignore) {
            // fall through to return raw body
        }
        return truncate(body);
    }

    private String truncate(String value) {
        if (value == null) {
            return "상세 오류 없음";
        }
        String trimmed = value.trim();
        if (trimmed.length() > 512) {
            return trimmed.substring(0, 512) + "...";
        }
        return trimmed.isEmpty() ? "상세 오류 없음" : trimmed;
    }

    private String resolve(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        if (trimmed.startsWith("${") && trimmed.endsWith("}")) {
            String inner = trimmed.substring(2, trimmed.length() - 1);
            int colonIndex = inner.indexOf(':');
            String envKey = colonIndex >= 0 ? inner.substring(0, colonIndex) : inner;
            String defaultValue = colonIndex >= 0 ? inner.substring(colonIndex + 1) : "";
            String envValue = System.getenv(envKey);
            if (envValue == null || envValue.isEmpty()) {
                envValue = System.getProperty(envKey);
            }
            return (envValue != null && !envValue.isEmpty()) ? envValue : defaultValue;
        }
        return value;
    }
}
