package kr.go.dgif.govportal.domain.entity;

import java.time.Instant;
import java.util.UUID;

/**
 * Lightweight aggregate representing the projects table.
 */
public class Project {
    private UUID id;
    private UUID tenantId;
    private String name;
    private String status;
    private Long odkProjectId;
    private UUID odkProjectUuid;
    private Instant createdAt;
    private Instant updatedAt;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getTenantId() {
        return tenantId;
    }

    public void setTenantId(UUID tenantId) {
        this.tenantId = tenantId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getOdkProjectId() {
        return odkProjectId;
    }

    public void setOdkProjectId(Long odkProjectId) {
        this.odkProjectId = odkProjectId;
    }

    public UUID getOdkProjectUuid() {
        return odkProjectUuid;
    }

    public void setOdkProjectUuid(UUID odkProjectUuid) {
        this.odkProjectUuid = odkProjectUuid;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
