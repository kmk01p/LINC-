package com.example.egov.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Sends aggregated metrics to K-eGov endpoint. Stub implementation logs
 * execution; actual HTTP POST should be implemented in PipelineClient.
 */
@Component
public class PublishKegovJob {
    private static final Logger log = LoggerFactory.getLogger(PublishKegovJob.class);

    @Scheduled(cron = "0 30 */4 * * *") // every 4 hours at half past
    public void execute() {
        log.info("[PublishKegovJob] Publishing aggregated metrics to K-eGov endpoint");
        // TODO: call PipelineClient.publishKegov()
        log.info("[PublishKegovJob] Completed publish job");
    }
}