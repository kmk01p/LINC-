package egovframework.govportal.dashboard.model;

import lombok.Data;

@Data
public class ProjectContribution {
    private String name;
    private String country;
    private long submissions;
    private double ratio;
}
