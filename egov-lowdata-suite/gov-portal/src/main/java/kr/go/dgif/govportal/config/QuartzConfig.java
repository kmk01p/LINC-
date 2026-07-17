package kr.go.dgif.govportal.config;

import kr.go.dgif.govportal.scheduler.EtlRunJob;
import kr.go.dgif.govportal.scheduler.OdkIngestJob;
import kr.go.dgif.govportal.scheduler.PublishKegovJob;
import kr.go.dgif.govportal.scheduler.RetentionJob;
import org.quartz.CronScheduleBuilder;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class QuartzConfig {

    @Bean
    public JobDetail odkIngestJobDetail() {
        return JobBuilder.newJob(OdkIngestJob.class)
            .withIdentity("odkIngestJob")
            .storeDurably()
            .build();
    }

    @Bean
    public Trigger odkIngestTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(odkIngestJobDetail())
            .withIdentity("odkIngestTrigger")
            .withSchedule(CronScheduleBuilder.cronSchedule("0 */15 * * * ?")) // Every 15 minutes
            .build();
    }

    @Bean
    public JobDetail etlRunJobDetail() {
        return JobBuilder.newJob(EtlRunJob.class)
            .withIdentity("etlRunJob")
            .storeDurably()
            .build();
    }

    @Bean
    public Trigger etlRunTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(etlRunJobDetail())
            .withIdentity("etlRunTrigger")
            .withSchedule(CronScheduleBuilder.cronSchedule("0 0 */6 * * ?")) // Every 6 hours
            .build();
    }

    @Bean
    public JobDetail publishKegovJobDetail() {
        return JobBuilder.newJob(PublishKegovJob.class)
            .withIdentity("publishKegovJob")
            .storeDurably()
            .build();
    }

    @Bean
    public Trigger publishKegovTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(publishKegovJobDetail())
            .withIdentity("publishKegovTrigger")
            .withSchedule(CronScheduleBuilder.cronSchedule("0 0 2 * * ?")) // Daily at 2 AM
            .build();
    }

    @Bean
    public JobDetail retentionJobDetail() {
        return JobBuilder.newJob(RetentionJob.class)
            .withIdentity("retentionJob")
            .storeDurably()
            .build();
    }

    @Bean
    public Trigger retentionTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(retentionJobDetail())
            .withIdentity("retentionTrigger")
            .withSchedule(CronScheduleBuilder.cronSchedule("0 0 3 * * ?")) // Daily at 3 AM
            .build();
    }
}
