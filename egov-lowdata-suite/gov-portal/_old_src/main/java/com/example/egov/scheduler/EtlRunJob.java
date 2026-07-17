package com.example.egov.scheduler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Executes dbt ETL to transform data from staging to ODS to marts. This is a
 * stub that should call the Python scripts in the etl/jobs directory or
 * directly run `dbt run` using a ProcessBuilder.
 */
@Component
public class EtlRunJob {
    private static final Logger log = LoggerFactory.getLogger(EtlRunJob.class);

    @Scheduled(cron = "0 0 */1 * * *") // every hour
    public void execute() {
        log.info("[EtlRunJob] Starting ETL run");
        // TODO: call dbt via subprocess or integration
        log.info("[EtlRunJob] Completed ETL run");
    }
}