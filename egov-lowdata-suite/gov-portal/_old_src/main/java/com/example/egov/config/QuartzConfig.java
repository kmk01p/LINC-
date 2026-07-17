package com.example.egov.config;

import com.example.egov.scheduler.EtlRunJob;
import com.example.egov.scheduler.OdkIngestJob;
import com.example.egov.scheduler.PublishKegovJob;
import com.example.egov.scheduler.RetentionJob;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Quartz configuration simplified using Spring's @Scheduled annotations. In a
 * production environment this could be converted to full Quartz triggers.
 */
@Configuration
@EnableScheduling
public class QuartzConfig {
    // Empty configuration class to enable scheduling
}