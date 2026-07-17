package kr.go.dgif.govportal.domain.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public class JdbcAuditLogDao implements AuditLogDao {

    private final JdbcTemplate jdbcTemplate;

    public JdbcAuditLogDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void logBatchExecution(UUID tenantId,
                                  UUID projectId,
                                  String action,
                                  String status,
                                  String message,
                                  String createdBy) {
        String sql = "INSERT INTO audit_logs "
            + "(tenant_id, project_id, action, status, message, created_by, created_at) "
            + "VALUES (?, ?, ?, ?, ?, ?, NOW())";
        jdbcTemplate.update(sql,
            tenantId,
            projectId,
            action,
            status,
            message,
            createdBy);
    }
}
