package kr.go.dgif.govportal.scheduler;

import kr.go.dgif.govportal.domain.dao.AuditLogDao;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;

@Slf4j
@Component
@RequiredArgsConstructor
public class EtlRunJob implements Job {
    private final AuditLogDao auditLogDao;
    
    @Value("${dbt.profiles-dir:/app/etl}")
    private String dbtProfilesDir;
    
    @Value("${dbt.project-dir:/app/etl}")
    private String dbtProjectDir;

    @Override
    public void execute(JobExecutionContext context) {
        log.info("Starting ETL Run Job (dbt)");
        try {
            // Run quality checks
            runPythonScript("/app/etl/jobs/quality_checks.py");
            
            // Run dbt models
            runDbtModels();
            
            auditLogDao.logBatchExecution(
                null, null, "ETL_RUN", "SUCCESS",
                "dbt models executed successfully", "system"
            );
        } catch (Exception e) {
            log.error("ETL Run Job failed", e);
            auditLogDao.logBatchExecution(
                null, null, "ETL_RUN", "FAILED",
                e.getMessage(), "system"
            );
        }
    }

    private void runDbtModels() throws Exception {
        ProcessBuilder pb = new ProcessBuilder(
            "dbt", "run",
            "--profiles-dir", dbtProfilesDir,
            "--project-dir", dbtProjectDir
        );
        pb.redirectErrorStream(true);
        
        Process process = pb.start();
        
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                log.info("dbt: {}", line);
            }
        }
        
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("dbt run failed with exit code: " + exitCode);
        }
    }

    private void runPythonScript(String scriptPath) throws Exception {
        ProcessBuilder pb = new ProcessBuilder("python3", scriptPath);
        pb.redirectErrorStream(true);
        
        Process process = pb.start();
        
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                log.info("Python: {}", line);
            }
        }
        
        int exitCode = process.waitFor();
        if (exitCode != 0) {
            throw new RuntimeException("Python script failed: " + scriptPath);
        }
    }
}
