package com.example.egov.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * RetentionJob periodically deletes raw submissions older than the configured
 * retention period. This implementation only logs; actual deletion should
 * implement proper SQL statements in a service layer.
 */
@Component
public class RetentionJob {
    private static final Logger log = LoggerFactory.getLogger(RetentionJob.class);

    @Scheduled(cron = "0 0 2 * * *") // daily at 02:00
    public void execute() {
        log.info("[RetentionJob] Running retention cleanup");
        // TODO: implement deletion logic
        log.info("[RetentionJob] Completed retention cleanup");
    }
}