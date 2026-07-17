package kr.go.dgif.govportal.scheduler;

import kr.go.dgif.govportal.domain.dao.AuditLogDao;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class RetentionJob implements Job {
    private final JdbcTemplate jdbcTemplate;
    private final AuditLogDao auditLogDao;

    @Override
    public void execute(JobExecutionContext context) {
        log.info("Starting Retention Cleanup Job");
        try {
            int deleted = cleanupExpiredData();
            
            auditLogDao.logBatchExecution(
                null, null, "RETENTION_CLEANUP", "SUCCESS",
                "Deleted " + deleted + " expired records", "system"
            );
        } catch (Exception e) {
            log.error("Retention Cleanup Job failed", e);
            auditLogDao.logBatchExecution(
                null, null, "RETENTION_CLEANUP", "FAILED",
                e.getMessage(), "system"
            );
        }
    }

    private int cleanupExpiredData() {
        String sql = "DELETE FROM submissions_raw "
            + "WHERE project_id IN ("
            + "SELECT p.id FROM projects p "
            + "JOIN policies pol ON p.id = pol.project_id "
            + "WHERE submissions_raw.created_at < NOW() - (pol.retention_months || ' months')::INTERVAL"
            + ")";
        
        int deletedCount = jdbcTemplate.update(sql);
        log.info("Deleted {} expired submissions", deletedCount);
        return deletedCount;
    }
}
