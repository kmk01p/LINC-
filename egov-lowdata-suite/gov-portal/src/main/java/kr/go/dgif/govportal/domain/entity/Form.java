package kr.go.dgif.govportal.domain.entity;

import java.time.Instant;
import java.util.UUID;

public class Form {
    private UUID id;
    private UUID projectId;
    private String xmlFormId;
    private String name;
    private Instant createdAt;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getProjectId() {
        return projectId;
    }

    public void setProjectId(UUID projectId) {
        this.projectId = projectId;
    }

    public String getXmlFormId() {
        return xmlFormId;
    }

    public void setXmlFormId(String xmlFormId) {
        this.xmlFormId = xmlFormId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
