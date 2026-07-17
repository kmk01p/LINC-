package com.example.egov.controllers;

import com.example.egov.scheduler.EtlRunJob;
import com.example.egov.scheduler.OdkIngestJob;
import com.example.egov.scheduler.PublishKegovJob;
import com.example.egov.scheduler.RetentionJob;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/batch")
public class BatchController {
    private final OdkIngestJob ingestJob;
    private final EtlRunJob etlRunJob;
    private final PublishKegovJob publishKegovJob;
    private final RetentionJob retentionJob;

    public BatchController(OdkIngestJob ingestJob, EtlRunJob etlRunJob, PublishKegovJob publishKegovJob, RetentionJob retentionJob) {
        this.ingestJob = ingestJob;
        this.etlRunJob = etlRunJob;
        this.publishKegovJob = publishKegovJob;
        this.retentionJob = retentionJob;
    }

    @PostMapping("/ingest")
    @PreAuthorize("hasAuthority('proj.manage')")
    @ResponseBody
    public String triggerIngest() {
        ingestJob.execute();
        return "Ingest job triggered";
    }

    @PostMapping("/etl-run")
    @PreAuthorize("hasAuthority('proj.manage')")
    @ResponseBody
    public String triggerEtl() {
        etlRunJob.execute();
        return "ETL job triggered";
    }

    @PostMapping("/publish-kegov")
    @PreAuthorize("hasAuthority('kegov.publish')")
    @ResponseBody
    public String triggerPublish() {
        publishKegovJob.execute();
        return "Publish job triggered";
    }

    @PostMapping("/retention-cleanup")
    @PreAuthorize("hasAuthority('proj.manage')")
    @ResponseBody
    public String triggerCleanup() {
        retentionJob.execute();
        return "Retention cleanup triggered";
    }
}