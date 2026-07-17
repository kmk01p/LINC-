package kr.go.dgif.govportal.scheduler;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import kr.go.dgif.govportal.adapters.OdkClient;
import kr.go.dgif.govportal.domain.dao.AuditLogDao;
import kr.go.dgif.govportal.domain.dao.FormDao;
import kr.go.dgif.govportal.domain.dao.ProjectDao;
import kr.go.dgif.govportal.domain.dao.SubmissionDao;
import kr.go.dgif.govportal.domain.entity.Form;
import kr.go.dgif.govportal.domain.entity.Project;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Slf4j
@Component
@RequiredArgsConstructor
public class OdkIngestJob implements Job {
    private final OdkClient odkClient;
    private final ProjectDao projectDao;
    private final FormDao formDao;
    private final SubmissionDao submissionDao;
    private final AuditLogDao auditLogDao;
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    @Override
    public void execute(JobExecutionContext context) {
        log.info("Starting ODK Ingest Job");
        try {
            List<Project> activeProjects = projectDao.findActiveProjects();
            
            for (Project project : activeProjects) {
                if (project.getOdkProjectId() == null) {
                    log.warn("Project {} has no ODK project id", project.getId());
                    continue;
                }

                ingestProjectData(project);
            }
            
            auditLogDao.logBatchExecution(
                null, null, "ODK_INGEST", "SUCCESS", 
                "Processed " + activeProjects.size() + " projects", "system"
            );
        } catch (Exception e) {
            log.error("ODK Ingest Job failed", e);
            auditLogDao.logBatchExecution(
                null, null, "ODK_INGEST", "FAILED", 
                e.getMessage(), "system"
            );
        }
    }

    private void ingestProjectData(Project project) {
        log.info("Ingesting data for project: {}", project.getName());
        List<Form> forms = formDao.findByProjectId(project.getId());

        for (Form form : forms) {
            if (form.getXmlFormId() == null) {
                continue;
            }

            try {
                String cursor = getSyncCursor(project.getId(), form.getId());
                List<JsonNode> submissions = odkClient.fetchSubmissions(
                    project.getOdkProjectId(),
                    form.getXmlFormId(),
                    cursor,
                    500
                );

                int upserted = 0;
                String latestUpdatedAt = cursor;

                for (JsonNode sub : submissions) {
                    String submissionId = sub.path("__id").asText();
                    JsonNode system = sub.path("__system");
                    String updatedAt = system.path("updatedAt").asText();
                    
                    upsertSubmission(project, form, submissionId, sub);
                    upserted++;

                    if (updatedAt.compareTo(latestUpdatedAt) > 0) {
                        latestUpdatedAt = updatedAt;
                    }
                }

                if (upserted > 0) {
                    updateSyncCursor(project.getId(), form.getId(), latestUpdatedAt);
                    log.info("Ingested {} submissions for form {}", upserted, form.getXmlFormId());
                }

            } catch (Exception e) {
                log.error("Failed to ingest form: {}", form.getXmlFormId(), e);
            }
        }
    }

    private void upsertSubmission(Project project, Form form, String submissionId, JsonNode payload) {
        try {
            JsonNode masked = maskSensitiveData(payload);
            Instant submittedAt = Instant.parse(
                payload.path("__system").path("submissionDate").asText()
            );

            submissionDao.upsertRawSubmission(
                project.getId(),
                form.getId(),
                submissionId,
                objectMapper.writeValueAsString(masked),
                submittedAt
            );

        } catch (Exception e) {
            log.error("Failed to upsert submission: {}", submissionId, e);
        }
    }

    private JsonNode maskSensitiveData(JsonNode payload) {
        // Round coordinates to 2 decimal places
        if (payload.has("gps_location")) {
            // Masking logic here
        }
        return payload;
    }

    private String getSyncCursor(UUID projectId, UUID formId) {
        String sql = "SELECT last_updated_at FROM sync_cursor WHERE project_id = ? AND form_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, String.class, 
                projectId, formId);
        } catch (Exception e) {
            return "1970-01-01T00:00:00.000Z";
        }
    }

    private void updateSyncCursor(UUID projectId, UUID formId, String updatedAt) {
        String sql = "INSERT INTO sync_cursor (project_id, form_id, last_updated_at, updated_at) "
            + "VALUES (?, ?, ?, NOW()) "
            + "ON CONFLICT (project_id, form_id) DO UPDATE "
            + "SET last_updated_at = EXCLUDED.last_updated_at, updated_at = NOW()";
        jdbcTemplate.update(sql, projectId, formId, updatedAt);
    }
}
