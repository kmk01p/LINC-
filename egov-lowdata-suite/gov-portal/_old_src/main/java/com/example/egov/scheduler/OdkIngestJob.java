package com.example.egov.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Periodically pulls submissions from ODK Central using OData and upserts
 * them into submissions_raw. This implementation is a stub; actual OData
 * interaction should be implemented in OdkClient.
 */
@Component
public class OdkIngestJob {
    private static final Logger log = LoggerFactory.getLogger(OdkIngestJob.class);

    @Scheduled(cron = "0 */15 * * * *") // every 15 minutes
    public void execute() {
        log.info("[OdkIngestJob] Starting ingestion job");
        // TODO: implement OData sync via OdkClient
        log.info("[OdkIngestJob] Completed ingestion job");
    }
}