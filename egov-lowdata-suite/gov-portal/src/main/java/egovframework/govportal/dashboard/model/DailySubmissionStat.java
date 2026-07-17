package egovframework.govportal.dashboard.model;

import lombok.Data;

@Data
public class DailySubmissionStat {
    private String date;
    private long submissions;
    private long flagged;
    private long uniqueProjects;
    private long uniqueForms;
}
