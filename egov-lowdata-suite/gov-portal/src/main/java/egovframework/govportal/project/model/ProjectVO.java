package egovframework.govportal.project.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.UUID;

public class ProjectVO implements Serializable {

    private UUID id;
    private UUID tenantId;
    private String name;
    private String country;
    private String sector;
    private String languages;
    private String codebook;
    private Long odkProjectId;
    private UUID odkProjectUuid;
    private String odkXmlFormId;
    private String status;
    private LocalDateTime createdAt;
    private UUID createdBy;
    private LocalDateTime deletedAt;
    private UUID deletedBy;

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

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getSector() {
        return sector;
    }

    public void setSector(String sector) {
        this.sector = sector;
    }

    public String getLanguages() {
        return languages;
    }

    public void setLanguages(String languages) {
        this.languages = languages;
    }

    public String getCodebook() {
        return codebook;
    }

    public void setCodebook(String codebook) {
        this.codebook = codebook;
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

    public String getOdkXmlFormId() {
        return odkXmlFormId;
    }

    public void setOdkXmlFormId(String odkXmlFormId) {
        this.odkXmlFormId = odkXmlFormId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public UUID getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(UUID createdBy) {
        this.createdBy = createdBy;
    }

    public LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public UUID getDeletedBy() {
        return deletedBy;
    }

    public void setDeletedBy(UUID deletedBy) {
        this.deletedBy = deletedBy;
    }
}
