package egovframework.govportal.admin.model;

import java.io.Serializable;
import java.util.LinkedHashMap;
import java.util.Map;

public class SystemSettingsForm implements Serializable {

    private static final long serialVersionUID = 1L;

    private Map<String, String> settings = new LinkedHashMap<>();

    public Map<String, String> getSettings() {
        return settings;
    }

    public void setSettings(Map<String, String> settings) {
        this.settings = settings;
    }
}
