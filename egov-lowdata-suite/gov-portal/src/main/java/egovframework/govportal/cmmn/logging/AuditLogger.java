package egovframework.govportal.cmmn.logging;

import egovframework.govportal.audit.dao.AuditLogDAO;
import egovframework.govportal.audit.model.AuditLogVO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.util.UUID;

@Component("auditLogger")
public class AuditLogger {

    private static final Logger LOGGER = LoggerFactory.getLogger("AUDIT");

    @Resource(name = "auditLogDAO")
    private AuditLogDAO auditLogDAO;

    public void info(String action, String detail, UUID actorId) {
        persist("INFO", action, detail, actorId);
    }

    public void warn(String action, String detail, UUID actorId) {
        persist("WARN", action, detail, actorId);
    }

    private void persist(String severity, String action, String detail, UUID actorId) {
        try {
            UUID effectiveActor = actorId != null ? actorId : UUID.fromString("00000000-0000-0000-0000-000000002001");
            AuditLogVO log = new AuditLogVO();
            log.setId(UUID.randomUUID());
            log.setSeverity(severity);
            log.setAction(action);
            log.setDetail(detail);
            log.setActorId(effectiveActor);
            log.setCreatedAt(LocalDateTime.now());
            auditLogDAO.insertLog(log);
        } catch (Exception ex) {
            LOGGER.warn("Failed to persist audit log", ex);
        }
        UUID actor = actorId;
        if (actor == null) {
            actor = UUID.fromString("00000000-0000-0000-0000-000000002001");
        }
        if ("WARN".equals(severity)) {
            LOGGER.warn("action={}, actor={}, detail={}", action, actor, detail);
        } else {
            LOGGER.info("action={}, actor={}, detail={}", action, actor, detail);
        }
    }
}
