package egovframework.govportal.dashboard.service;

import egovframework.govportal.dashboard.model.DailySubmissionStat;
import egovframework.govportal.dashboard.model.PredictionPoint;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Slf4j
@Service
public class PredictionService {

    private static final int DEFAULT_HORIZON_DAYS = 14;

    public Map<String, List<PredictionPoint>> generateForecast(List<DailySubmissionStat> stats) {
        if (stats == null || stats.isEmpty()) {
            return Collections.emptyMap();
        }

        List<DailySubmissionStat> ordered = stats.stream()
            .sorted(Comparator.comparing(DailySubmissionStat::getDate))
            .collect(Collectors.toList());

        double[] x = IntStream.range(0, ordered.size()).asDoubleStream().toArray();
        double[] y = ordered.stream().mapToDouble(DailySubmissionStat::getSubmissions).toArray();
        LocalDate lastDate = LocalDate.parse(ordered.get(ordered.size() - 1).getDate());

        Map<String, List<PredictionPoint>> predictions = new LinkedHashMap<>();
        predictions.put("linearRegression", buildLinearRegression(lastDate, x, y));
        predictions.put("exponentialSmoothing", buildExponentialSmoothing(lastDate, y));
        predictions.put("gradientBoosting", buildGradientBoosting(lastDate, x, y));
        return predictions;
    }

    private List<PredictionPoint> buildLinearRegression(LocalDate lastDate, double[] x, double[] y) {
        if (y.length < 2) {
            return Collections.emptyList();
        }

        double sumX = Arrays.stream(x).sum();
        double sumY = Arrays.stream(y).sum();
        double sumXY = 0;
        double sumXX = 0;
        for (int i = 0; i < x.length; i++) {
            sumXY += x[i] * y[i];
            sumXX += x[i] * x[i];
        }

        double n = x.length;
        double denominator = (n * sumXX) - (sumX * sumX);
        double slope = denominator == 0 ? 0 : ((n * sumXY) - (sumX * sumY)) / denominator;
        double intercept = (sumY - slope * sumX) / n;

        return buildForecastSeries(lastDate, y[y.length - 1], x.length, idx -> slope * idx + intercept);
    }

    private List<PredictionPoint> buildExponentialSmoothing(LocalDate lastDate, double[] values) {
        if (values.length == 0) {
            return Collections.emptyList();
        }
        double alpha = 0.6;
        double smoothed = values[0];
        for (int i = 1; i < values.length; i++) {
            smoothed = alpha * values[i] + (1 - alpha) * smoothed;
        }
        double baseline = smoothed;
        return buildForecastSeries(lastDate, values[values.length - 1], values.length, idx -> baseline);
    }

    private List<PredictionPoint> buildGradientBoosting(LocalDate lastDate, double[] x, double[] y) {
        if (y.length < 3) {
            return Collections.emptyList();
        }
        GradientBoostingRegressor gbr = new GradientBoostingRegressor(0.2, 12);
        gbr.fit(x, y);
        return buildForecastSeries(lastDate, y[y.length - 1], x.length, gbr::predict);
    }

    private List<PredictionPoint> buildForecastSeries(LocalDate lastDate, double lastActual, int startIndex, ForecastFunction function) {
        List<PredictionPoint> points = new ArrayList<>();
        PredictionPoint anchor = new PredictionPoint();
        anchor.setDate(lastDate.toString());
        anchor.setValue(lastActual);
        anchor.setProjected(false);
        points.add(anchor);

        LocalDate cursor = lastDate;
        for (int i = 0; i < DEFAULT_HORIZON_DAYS; i++) {
            cursor = cursor.plusDays(1);
            PredictionPoint point = new PredictionPoint();
            point.setDate(cursor.toString());
            point.setValue(Math.max(0, function.apply(startIndex + i)));
            point.setProjected(true);
            points.add(point);
        }
        return points;
    }

    @FunctionalInterface
    private interface ForecastFunction {
        double apply(double xIndex);
    }

    private static class GradientBoostingRegressor {
        private final double learningRate;
        private final int rounds;
        private double base;
        private final List<DecisionStump> stumps = new ArrayList<>();

        private GradientBoostingRegressor(double learningRate, int rounds) {
            this.learningRate = learningRate;
            this.rounds = rounds;
        }

        void fit(double[] x, double[] y) {
            base = Arrays.stream(y).average().orElse(0);
            double[] predictions = new double[y.length];
            Arrays.fill(predictions, base);

            for (int round = 0; round < rounds; round++) {
                double[] residuals = new double[y.length];
                for (int i = 0; i < y.length; i++) {
                    residuals[i] = y[i] - predictions[i];
                }
                DecisionStump stump = findBestStump(x, residuals);
                if (stump == null) {
                    break;
                }
                stumps.add(stump);
                for (int i = 0; i < x.length; i++) {
                    predictions[i] += learningRate * stump.predict(x[i]);
                }
                if (maxAbs(residuals) < 0.01) {
                    break;
                }
            }
        }

        double predict(double value) {
            double prediction = base;
            for (DecisionStump stump : stumps) {
                prediction += learningRate * stump.predict(value);
            }
            return prediction;
        }

        private DecisionStump findBestStump(double[] x, double[] residuals) {
            double[] unique = Arrays.stream(x).distinct().sorted().toArray();
            if (unique.length <= 1) {
                double mean = Arrays.stream(residuals).average().orElse(0);
                return new DecisionStump(Double.NaN, mean, mean);
            }

            double bestLoss = Double.MAX_VALUE;
            DecisionStump best = null;

            for (int i = 0; i < unique.length - 1; i++) {
                double threshold = (unique[i] + unique[i + 1]) / 2.0;
                DecisionStump candidate = buildStumpForThreshold(x, residuals, threshold);
                if (candidate == null) {
                    continue;
                }
                double loss = computeLoss(x, residuals, candidate);
                if (loss < bestLoss) {
                    bestLoss = loss;
                    best = candidate;
                }
            }
            return best;
        }

        private DecisionStump buildStumpForThreshold(double[] x, double[] residuals, double threshold) {
            double leftSum = 0;
            double rightSum = 0;
            int leftCount = 0;
            int rightCount = 0;

            for (int i = 0; i < x.length; i++) {
                if (x[i] <= threshold) {
                    leftSum += residuals[i];
                    leftCount++;
                } else {
                    rightSum += residuals[i];
                    rightCount++;
                }
            }

            if (leftCount == 0 || rightCount == 0) {
                return null;
            }

            double leftMean = leftSum / leftCount;
            double rightMean = rightSum / rightCount;
            return new DecisionStump(threshold, leftMean, rightMean);
        }

        private double computeLoss(double[] x, double[] residuals, DecisionStump stump) {
            double loss = 0;
            for (int i = 0; i < x.length; i++) {
                double pred = stump.predict(x[i]);
                double diff = residuals[i] - pred;
                loss += diff * diff;
            }
            return loss;
        }

        private double maxAbs(double[] values) {
            double max = 0;
            for (double v : values) {
                max = Math.max(max, Math.abs(v));
            }
            return max;
        }
    }

    private static class DecisionStump {
        private final double threshold;
        private final double leftValue;
        private final double rightValue;

        private DecisionStump(double threshold, double leftValue, double rightValue) {
            this.threshold = threshold;
            this.leftValue = leftValue;
            this.rightValue = rightValue;
        }

        double predict(double value) {
            if (Double.isNaN(threshold)) {
                return leftValue;
            }
            return value <= threshold ? leftValue : rightValue;
        }
    }
}
