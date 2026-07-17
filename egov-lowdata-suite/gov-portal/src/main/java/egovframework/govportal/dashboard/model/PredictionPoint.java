package egovframework.govportal.dashboard.model;

import lombok.Data;

@Data
public class PredictionPoint {
    private String date;
    private double value;
    private boolean projected;
}
