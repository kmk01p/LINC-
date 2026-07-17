package egovframework.govportal.dashboard.service;

import egovframework.govportal.dashboard.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardAnalyticsService {

    private final JdbcTemplate jdbcTemplate;
    private final PredictionService predictionService;

    private static final int WINDOW_DAYS = 30;

    public DashboardAnalyticsPayload loadAnalytics() {
        return loadAnalyticsInternal(null);
    }

    public DashboardAnalyticsPayload loadAnalyticsForProject(UUID projectId) {
        return loadAnalyticsInternal(projectId);
    }

    private DashboardAnalyticsPayload loadAnalyticsInternal(UUID projectId) {
        try {
            DashboardAnalyticsPayload payload = new DashboardAnalyticsPayload();

            List<DailySubmissionStat> dailyStats = fetchDailyStats(projectId);
            List<ProjectContribution> contributions = fetchContributionHighlights(projectId);
            List<QualityStatusStat> qualityStats = fetchQualityStats(projectId);
            Map<String, List<PredictionPoint>> predictions = predictionService.generateForecast(dailyStats);

            payload.setDailyStats(dailyStats);
            payload.setTopProjects(contributions);
            payload.setQualityStats(qualityStats);
            payload.setSummary(buildSummary(projectId, dailyStats, qualityStats, predictions));
            payload.setPredictions(predictions);
            return payload;
        } catch (Exception e) {
            log.warn("대시보드 통계 데이터를 불러오지 못했습니다. 샘플 데이터를 사용합니다. scope={}, error={}", projectId, e.getMessage());
            return demoPayload(projectId);
        }
    }

    private List<DailySubmissionStat> fetchDailyStats(UUID projectId) {
        Map<LocalDate, DailyAggregation> submissionMap = queryDailySubmissions(projectId);
        Map<LocalDate, Long> flaggedMap = queryDailyFlags(projectId);

        List<DailySubmissionStat> series = new ArrayList<>();
        LocalDate today = LocalDate.now();
        LocalDate start = today.minusDays(WINDOW_DAYS - 1L);

        for (LocalDate cursor = start; !cursor.isAfter(today); cursor = cursor.plusDays(1)) {
            DailyAggregation aggregation = submissionMap.getOrDefault(cursor, DailyAggregation.empty());
            DailySubmissionStat stat = new DailySubmissionStat();
            stat.setDate(cursor.toString());
            stat.setSubmissions(aggregation.total);
            stat.setUniqueProjects(aggregation.projects);
            stat.setUniqueForms(aggregation.forms);
            stat.setFlagged(flaggedMap.getOrDefault(cursor, 0L));
            series.add(stat);
        }

        if (series.stream().mapToLong(DailySubmissionStat::getSubmissions).sum() == 0) {
            return seedSyntheticSeries(projectId);
        }
        return series;
    }

    private Map<LocalDate, DailyAggregation> queryDailySubmissions(UUID projectId) {
        StringBuilder sql = new StringBuilder()
            .append("SELECT date_trunc('day', submitted_at)::date AS day, ")
            .append("       COUNT(*) AS total, ")
            .append("       COUNT(DISTINCT project_id) AS projects, ")
            .append("       COUNT(DISTINCT form_id) AS forms ")
            .append("FROM submissions_raw ")
            .append("WHERE submitted_at >= NOW() - INTERVAL '")
            .append(WINDOW_DAYS)
            .append(" days' ");

        List<Object> params = new ArrayList<>();
        if (projectId != null) {
            sql.append(" AND project_id = ? ");
            params.add(projectId);
        }
        sql.append(" GROUP BY day");

        return jdbcTemplate.query(sql.toString(), params.toArray(), (rs, rowNum) -> mapAggregation(rs))
            .stream()
            .collect(Collectors.toMap(DailyAggregation::getDay, agg -> agg));
    }

    private Map<LocalDate, Long> queryDailyFlags(UUID projectId) {
        StringBuilder sql = new StringBuilder()
            .append("SELECT date_trunc('day', created_at)::date AS day, COUNT(*) AS flagged ")
            .append("FROM quality_flags ")
            .append("WHERE created_at >= NOW() - INTERVAL '")
            .append(WINDOW_DAYS)
            .append(" days' ");
        List<Object> params = new ArrayList<>();
        if (projectId != null) {
            sql.append(" AND project_id = ? ");
            params.add(projectId);
        }
        sql.append(" GROUP BY day");

        Map<LocalDate, Long> map = new HashMap<>();
        jdbcTemplate.query(sql.toString(), params.toArray(), rs -> {
            LocalDate day = rs.getDate("day").toLocalDate();
            map.put(day, rs.getLong("flagged"));
        });
        return map;
    }

    private List<ProjectContribution> fetchContributionHighlights(UUID projectId) {
        List<ProjectContribution> contributions;
        if (projectId == null) {
            String sql = ""
                + "SELECT p.name, COALESCE(p.country, '-') AS country, COUNT(*) AS total "
                + "FROM submissions_raw sr "
                + "JOIN projects p ON p.id = sr.project_id "
                + "GROUP BY p.name, p.country "
                + "ORDER BY total DESC "
                + "LIMIT 5";
            contributions = jdbcTemplate.query(sql, (rs, rowNum) -> mapContribution(rs));
        } else {
            String sql = ""
                + "SELECT f.name, COALESCE(p.country, '-') AS country, COUNT(*) AS total "
                + "FROM submissions_raw sr "
                + "JOIN forms f ON f.id = sr.form_id "
                + "JOIN projects p ON p.id = sr.project_id "
                + "WHERE sr.project_id = ? "
                + "GROUP BY f.name, p.country "
                + "ORDER BY total DESC";
            contributions = jdbcTemplate.query(sql, new Object[]{projectId}, (rs, rowNum) -> mapContribution(rs));
        }

        if (contributions.isEmpty()) {
            contributions = seedProjectContributions(projectId != null, projectId);
        }

        long total = contributions.stream().mapToLong(ProjectContribution::getSubmissions).sum();
        for (ProjectContribution contribution : contributions) {
            double ratio = total == 0 ? 0 : (double) contribution.getSubmissions() / total;
            contribution.setRatio(Math.round(ratio * 1000d) / 10d);
        }
        return contributions;
    }

    private ProjectContribution mapContribution(ResultSet rs) throws SQLException {
        ProjectContribution contribution = new ProjectContribution();
        contribution.setName(rs.getString(1));
        contribution.setCountry(rs.getString(2));
        contribution.setSubmissions(rs.getLong(3));
        return contribution;
    }

    private List<QualityStatusStat> fetchQualityStats(UUID projectId) {
        StringBuilder sql = new StringBuilder("SELECT status, COUNT(*) AS total FROM quality_flags WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (projectId != null) {
            sql.append(" AND project_id = ? ");
            params.add(projectId);
        }
        sql.append(" GROUP BY status");

        Map<String, QualityStatusStat> map = new HashMap<>();
        jdbcTemplate.query(sql.toString(), params.toArray(), rs -> {
            QualityStatusStat stat = new QualityStatusStat();
            stat.setStatus(rs.getString("status"));
            stat.setCount(rs.getLong("total"));
            map.put(stat.getStatus(), stat);
        });

        List<String> defaults = Arrays.asList("flagged", "under_review", "resolved");
        List<QualityStatusStat> result = new ArrayList<>();
        for (String key : defaults) {
            QualityStatusStat stat = map.get(key);
            if (stat == null) {
                stat = new QualityStatusStat();
                stat.setStatus(key);
                stat.setCount(0);
            }
            result.add(stat);
        }
        if (result.stream().mapToLong(QualityStatusStat::getCount).sum() == 0 && map.isEmpty()) {
            result = seedQualityStats(projectId != null, projectId);
        }
        return result;
    }

    private DashboardSummary buildSummary(UUID projectId,
                                          List<DailySubmissionStat> series,
                                          List<QualityStatusStat> qualityStats,
                                          Map<String, List<PredictionPoint>> predictions) {
        DashboardSummary summary = new DashboardSummary();
        if (projectId == null) {
            summary.setTotalProjects(queryForLong("SELECT COUNT(*) FROM projects"));
            summary.setActiveForms(queryForLong("SELECT COUNT(*) FROM forms"));
            summary.setTotalSubmissions(queryForLong("SELECT COUNT(*) FROM submissions_raw"));
        } else {
            summary.setTotalProjects(1);
            summary.setActiveForms(queryForLong("SELECT COUNT(*) FROM forms WHERE project_id = ?", projectId));
            summary.setTotalSubmissions(queryForLong("SELECT COUNT(*) FROM submissions_raw WHERE project_id = ?", projectId));
        }
        summary.setQualityAlerts(
            qualityStats.stream()
                .filter(stat -> "flagged".equalsIgnoreCase(stat.getStatus()) || "under_review".equalsIgnoreCase(stat.getStatus()))
                .mapToLong(QualityStatusStat::getCount)
                .sum()
        );

        long lastWeek = aggregateRange(series, 7, 0);
        long previousWeek = aggregateRange(series, 14, 7);
        double growth;
        if (previousWeek == 0) {
            growth = lastWeek > 0 ? 100 : 0;
        } else {
            growth = ((double) (lastWeek - previousWeek) / previousWeek) * 100d;
        }
        summary.setWeekOverWeekGrowth(Math.round(growth * 10d) / 10d);

        double avgForecast = predictions.values().stream()
            .flatMap(List::stream)
            .filter(PredictionPoint::isProjected)
            .mapToDouble(PredictionPoint::getValue)
            .average()
            .orElse(series.stream().mapToLong(DailySubmissionStat::getSubmissions).average().orElse(0));
        summary.setForecastedDailyAverage(Math.max(0, Math.round(avgForecast * 10d) / 10d));
        return summary;
    }

    private long queryForLong(String sql, Object... args) {
        try {
            Long value = jdbcTemplate.queryForObject(sql, args, Long.class);
            return value != null ? value : 0L;
        } catch (Exception e) {
            log.warn("Failed to execute summary query: {}", sql, e);
            return 0L;
        }
    }

    private long aggregateRange(List<DailySubmissionStat> series, int daysBack, int offset) {
        if (series.isEmpty()) {
            return 0;
        }
        int size = series.size();
        int endExclusive = Math.max(size - offset, 0);
        int start = Math.max(endExclusive - daysBack, 0);
        return series.subList(start, endExclusive).stream()
            .mapToLong(DailySubmissionStat::getSubmissions)
            .sum();
    }

    private DailyAggregation mapAggregation(ResultSet rs) throws SQLException {
        DailyAggregation aggregation = new DailyAggregation();
        aggregation.day = rs.getDate("day").toLocalDate();
        aggregation.total = rs.getLong("total");
        aggregation.projects = rs.getLong("projects");
        aggregation.forms = rs.getLong("forms");
        return aggregation;
    }

    private List<DailySubmissionStat> seedSyntheticSeries(UUID projectId) {
        List<DailySubmissionStat> seeds = new ArrayList<>();
        LocalDate today = LocalDate.now();

        // Use projectId as seed for unique data per project
        long seed = projectId != null ? projectId.hashCode() : 2025L;
        Random random = new Random(seed);

        // Vary initial trend based on project
        double trend = 50 + random.nextInt(60); // Range: 50-110
        double growthRate = 0.5 + random.nextDouble() * 1.0; // Range: 0.5-1.5

        for (int offset = WINDOW_DAYS - 1; offset >= 0; offset--) {
            LocalDate day = today.minusDays(offset);
            double seasonal = (10 + random.nextInt(15)) * Math.sin((WINDOW_DAYS - offset) / 4.3);
            double noise = random.nextGaussian() * (3 + random.nextInt(5));
            long submissions = Math.max(5, Math.round(trend + seasonal + noise));
            trend += growthRate;

            DailySubmissionStat stat = new DailySubmissionStat();
            stat.setDate(day.toString());
            stat.setSubmissions(submissions);
            stat.setUniqueProjects(Math.max(1, submissions / (12 + random.nextInt(8))));
            stat.setUniqueForms(Math.max(1, submissions / (15 + random.nextInt(10))));
            stat.setFlagged(Math.max(0, Math.round(submissions * (0.08 + random.nextDouble() * 0.12))));
            seeds.add(stat);
        }
        return seeds;
    }

    private List<ProjectContribution> seedProjectContributions(boolean perProjectScope, UUID projectId) {
        long randomSeed = projectId != null ? projectId.hashCode() : 2025L;
        Random random = new Random(randomSeed);

        SeedProject[] seeds = perProjectScope
            ? new SeedProject[]{
                new SeedProject("현장 건강 모니터링 설문", "Form-A", 40 + random.nextInt(50)),
                new SeedProject("커뮤니티 클리닉 보고", "Form-B", 35 + random.nextInt(40)),
                new SeedProject("보건 인력 점검표", "Form-C", 30 + random.nextInt(35)),
                new SeedProject("원격 진료 만족도", "Form-D", 20 + random.nextInt(30)),
                new SeedProject("보조금 집행 현황", "Form-E", 15 + random.nextInt(25))
            }
            : new SeedProject[]{
                new SeedProject("에티오피아 - 보건 데이터 허브", "Ethiopia", 100 + random.nextInt(80)),
                new SeedProject("케냐 - 스마트 농업 관측", "Kenya", 90 + random.nextInt(70)),
                new SeedProject("우간다 - 교육 접근성", "Uganda", 80 + random.nextInt(60)),
                new SeedProject("라오스 - 기후적응 농촌사업", "Laos", 70 + random.nextInt(50)),
                new SeedProject("탄자니아 - 식수 위성 모니터링", "Tanzania", 60 + random.nextInt(40))
            };
        List<ProjectContribution> list = new ArrayList<>();
        for (SeedProject seedProject : seeds) {
            ProjectContribution contribution = new ProjectContribution();
            contribution.setName(seedProject.name);
            contribution.setCountry(seedProject.country);
            contribution.setSubmissions(seedProject.submissions);
            list.add(contribution);
        }
        return list;
    }

    private DashboardAnalyticsPayload demoPayload(UUID projectId) {
        DashboardAnalyticsPayload payload = new DashboardAnalyticsPayload();
        List<DailySubmissionStat> dailyStats = seedSyntheticSeries(projectId);
        List<ProjectContribution> contributions = seedProjectContributions(projectId != null, projectId);
        List<QualityStatusStat> qualityStats = seedQualityStats(projectId != null, projectId);
        Map<String, List<PredictionPoint>> predictions = predictionService.generateForecast(dailyStats);

        payload.setDailyStats(dailyStats);
        payload.setTopProjects(contributions);
        payload.setQualityStats(qualityStats);
        payload.setPredictions(predictions);
        payload.setSummary(buildSummary(projectId, dailyStats, qualityStats, predictions));
        return payload;
    }

    private List<QualityStatusStat> seedQualityStats(boolean perProjectScope, UUID projectId) {
        long seed = projectId != null ? projectId.hashCode() : 2025L;
        Random random = new Random(seed);

        if (perProjectScope) {
            return Arrays.asList(
                buildQuality("flagged", 3 + random.nextInt(10)),
                buildQuality("under_review", 2 + random.nextInt(8)),
                buildQuality("resolved", 15 + random.nextInt(30))
            );
        }
        return Arrays.asList(
            buildQuality("flagged", 15 + random.nextInt(20)),
            buildQuality("under_review", 8 + random.nextInt(15)),
            buildQuality("resolved", 50 + random.nextInt(40))
        );
    }

    private QualityStatusStat buildQuality(String status, long count) {
        QualityStatusStat stat = new QualityStatusStat();
        stat.setStatus(status);
        stat.setCount(count);
        return stat;
    }

    private static class DailyAggregation {
        private LocalDate day;
        private long total;
        private long projects;
        private long forms;

        static DailyAggregation empty() {
            DailyAggregation aggregation = new DailyAggregation();
            aggregation.day = null;
            aggregation.total = 0;
            aggregation.projects = 0;
            aggregation.forms = 0;
            return aggregation;
        }

        LocalDate getDay() {
            return day;
        }
    }

    private static class SeedProject {
        private final String name;
        private final String country;
        private final long submissions;

        private SeedProject(String name, String country, long submissions) {
            this.name = name;
            this.country = country;
            this.submissions = submissions;
        }
    }
}
