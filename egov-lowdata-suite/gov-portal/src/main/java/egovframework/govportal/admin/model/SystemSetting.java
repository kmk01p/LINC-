package egovframework.govportal.admin.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;
import java.util.UUID;

public class SystemSetting implements Serializable {

    public enum InputType {
        TOGGLE,
        TEXT,
        NUMBER,
        URL
    }

    private static final long serialVersionUID = 1L;

    private String key;
    private String label;
    private String value;
    private String defaultValue;
    private String description;
    private String category;
    private InputType inputType = InputType.TEXT;
    private LocalDateTime updatedAt;
    private UUID updatedBy;

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getDefaultValue() {
        return defaultValue;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public InputType getInputType() {
        return inputType;
    }

    public void setInputType(InputType inputType) {
        this.inputType = inputType;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public UUID getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(UUID updatedBy) {
        this.updatedBy = updatedBy;
    }

    public boolean isToggleEnabled() {
        return "true".equalsIgnoreCase(value) || "on".equalsIgnoreCase(value);
    }

    public boolean hasChanged() {
        return !Objects.equals(defaultValue, value);
    }
}
