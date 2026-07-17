package egovframework.govportal.project.model;

import java.io.Serializable;
import java.util.UUID;

public class FormTemplateVO implements Serializable {

    private UUID id;
    private String name;
    private String description;
    private String jsonSpec;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getJsonSpec() {
        return jsonSpec;
    }

    public void setJsonSpec(String jsonSpec) {
        this.jsonSpec = jsonSpec;
    }
}
