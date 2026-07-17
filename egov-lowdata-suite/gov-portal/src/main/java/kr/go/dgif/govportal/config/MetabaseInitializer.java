package kr.go.dgif.govportal.config;

import kr.go.dgif.govportal.adapters.MetabaseClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class MetabaseInitializer {

    private final MetabaseClient metabaseClient;

    @Value("${spring.datasource.url}")
    private String datasourceUrl;

    @Value("${spring.datasource.username}")
    private String datasourceUsername;

    @Value("${spring.datasource.password}")
    private String datasourcePassword;

    private boolean initialized = false;

    @EventListener(ContextRefreshedEvent.class)
    public void initializeMetabase() {
        if (initialized) {
            return;
        }
        initialized = true;
        try {
            log.info("Initializing Metabase database connection...");

            // Parse JDBC URL to extract host, port, and database name
            // Format: jdbc:postgresql://host:port/dbname
            String jdbcUrl = datasourceUrl.replace("jdbc:postgresql://", "");
            String[] parts = jdbcUrl.split("/");
            String hostPort = parts[0];
            String dbName = parts.length > 1 ? parts[1].split("\\?")[0] : "egov";

            String[] hostPortParts = hostPort.split(":");
            String dbHost = hostPortParts[0];
            int dbPort = hostPortParts.length > 1 ? Integer.parseInt(hostPortParts[1]) : 5432;

            log.info("Connecting to database: {}:{}/{}", dbHost, dbPort, dbName);

            Map<String, Object> result = metabaseClient.ensureDatabase(
                dbHost,
                dbPort,
                dbName,
                datasourceUsername,
                datasourcePassword
            );

            log.info("Metabase database initialized successfully: {}", result);

        } catch (Exception e) {
            log.warn("Failed to initialize Metabase database (will retry on demand): {}", e.getMessage());
            // Don't throw exception - this is a non-critical initialization
        }
    }
}
