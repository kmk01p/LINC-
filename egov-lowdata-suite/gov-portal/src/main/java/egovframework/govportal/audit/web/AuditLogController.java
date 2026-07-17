package egovframework.govportal.audit.web;

import egovframework.govportal.audit.model.AuditLogVO;
import egovframework.govportal.audit.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/admin/audit")
@RequiredArgsConstructor
public class AuditLogController {

    private final AuditLogService auditLogService;

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_audit.read')")
    @GetMapping("/logs.do")
    public String listAuditLogs(@RequestParam(value = "severity", required = false) String severity,
                                @RequestParam(value = "query", required = false) String keyword,
                                @RequestParam(value = "limit", required = false) Integer limit,
                                ModelMap model) {
        List<AuditLogVO> logs = auditLogService.fetchLogs(limit, severity, keyword);
        model.addAttribute("logs", logs);
        model.addAttribute("selectedSeverity", normalizeSeverity(severity));
        model.addAttribute("searchKeyword", keyword);
        model.addAttribute("limit", limit == null ? 100 : limit);
        model.addAttribute("severityStats", aggregateSeverity(logs));
        return "admin/audit-logs";
    }

    private String normalizeSeverity(String severity) {
        if (!StringUtils.hasText(severity)) {
            return null;
        }
        return severity.trim().toUpperCase(Locale.ROOT);
    }

    private Map<String, Long> aggregateSeverity(List<AuditLogVO> logs) {
        Map<String, Long> grouped = logs.stream()
            .collect(Collectors.groupingBy(log -> log.getSeverity() != null ? log.getSeverity() : "INFO",
                Collectors.counting()));
        Map<String, Long> ordered = new LinkedHashMap<>();
        ordered.put("INFO", grouped.getOrDefault("INFO", 0L));
        ordered.put("WARN", grouped.getOrDefault("WARN", 0L));
        return ordered;
    }
}
