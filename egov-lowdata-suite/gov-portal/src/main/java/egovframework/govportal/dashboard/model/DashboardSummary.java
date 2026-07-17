package egovframework.govportal.dashboard.model;

import lombok.Data;

@Data
public class DashboardSummary {
    private long totalProjects;
    private long activeForms;
    private long totalSubmissions;
    private long qualityAlerts;
    private double weekOverWeekGrowth;
    private double forecastedDailyAverage;
}
