package egovframework.govportal.audit.service;

import egovframework.govportal.audit.dao.AuditLogDAO;
import egovframework.govportal.audit.model.AuditLogVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Collections;
import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuditLogService {

    private final AuditLogDAO auditLogDAO;

    public List<AuditLogVO> fetchLogs(Integer limit, String severity, String keyword) {
        int effectiveLimit = (limit == null || limit <= 0) ? 200 : Math.min(limit, 500);
        String normalizedSeverity = null;
        if (StringUtils.hasText(severity)) {
            normalizedSeverity = severity.trim().toUpperCase(Locale.ROOT);
        }
        String trimmedKeyword = StringUtils.hasText(keyword) ? keyword.trim() : null;
        try {
            return auditLogDAO.selectRecentLogs(effectiveLimit, normalizedSeverity, trimmedKeyword);
        } catch (Exception ex) {
            return Collections.emptyList();
        }
    }
}
