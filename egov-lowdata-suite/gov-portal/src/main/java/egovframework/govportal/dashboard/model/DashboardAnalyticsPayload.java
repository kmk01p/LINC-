package egovframework.govportal.dashboard.model;

import lombok.Data;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Data
public class DashboardAnalyticsPayload {
    private List<DailySubmissionStat> dailyStats = new ArrayList<>();
    private List<ProjectContribution> topProjects = new ArrayList<>();
    private List<QualityStatusStat> qualityStats = new ArrayList<>();
    private Map<String, List<PredictionPoint>> predictions = new LinkedHashMap<>();
    private DashboardSummary summary;
}
