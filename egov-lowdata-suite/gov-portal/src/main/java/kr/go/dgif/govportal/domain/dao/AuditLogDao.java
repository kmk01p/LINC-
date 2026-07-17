package kr.go.dgif.govportal.domain.dao;

import java.util.UUID;

public interface AuditLogDao {
    void logBatchExecution(UUID tenantId,
                           UUID projectId,
                           String action,
                           String status,
                           String message,
                           String createdBy);
}
