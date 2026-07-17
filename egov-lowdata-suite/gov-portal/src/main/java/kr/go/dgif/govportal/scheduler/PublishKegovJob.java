package kr.go.dgif.govportal.scheduler;

import kr.go.dgif.govportal.domain.dao.AuditLogDao;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class PublishKegovJob implements Job {
    private final JdbcTemplate jdbcTemplate;
    private final AuditLogDao auditLogDao;
    private final RestTemplate restTemplate;
    
    @Value("${kegov.api-url:http://localhost:9000}")
    private String kegovApiUrl;
    
    @Value("${kegov.api-key:}")
    private String kegovApiKey;

    @Override
    public void execute(JobExecutionContext context) {
        log.info("Starting K-eGov Publish Job");
        try {
            Map<String, Object> aggregates = fetchAggregates();
            publishToKegov(aggregates);
            
            auditLogDao.logBatchExecution(
                null, null, "KEGOV_PUBLISH", "SUCCESS",
                "Published aggregates to K-eGov", "system"
            );
        } catch (Exception e) {
            log.error("K-eGov Publish Job failed", e);
            auditLogDao.logBatchExecution(
                null, null, "KEGOV_PUBLISH", "FAILED",
                e.getMessage(), "system"
            );
        }
    }

    private Map<String, Object> fetchAggregates() {
        String sql = "SELECT "
            + "COUNT(*) as total_submissions, "
            + "COUNT(DISTINCT project_id) as active_projects, "
            + "SUM(CASE WHEN payload->>'status' = 'completed' THEN 1 ELSE 0 END) as completed_count "
            + "FROM submissions_raw "
            + "WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'";
        
        return jdbcTemplate.queryForMap(sql);
    }

    private void publishToKegov(Map<String, Object> aggregates) throws Exception {
        if (kegovApiKey.isEmpty()) {
            log.warn("K-eGov API key not configured, skipping publish");
            return;
        }

        String url = kegovApiUrl + "/api/v1/aggregate";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-API-Key", kegovApiKey);
        
        Map<String, Object> payload = new HashMap<>();
        payload.put("timestamp", System.currentTimeMillis());
        payload.put("source", "LINC_LOWDATA_SUITE");
        payload.put("data", aggregates);
        
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
        ResponseEntity<String> response = restTemplate.postForEntity(url, request, String.class);
        
        if (response.getStatusCode() != HttpStatus.OK && 
            response.getStatusCode() != HttpStatus.ACCEPTED) {
            throw new RuntimeException("K-eGov API returned: " + response.getStatusCode());
        }
        
        log.info("Successfully published to K-eGov: {}", response.getBody());
    }
}
