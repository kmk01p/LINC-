package egovframework.govportal.project.model;

import java.io.Serializable;
import java.util.UUID;

public class IntegrationSettingVO implements Serializable {

    private UUID id;
    private UUID projectId;
    private String type;
    private String payload;

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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getPayload() {
        return payload;
    }

    public void setPayload(String payload) {
        this.payload = payload;
    }
}
