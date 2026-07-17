package egovframework.govportal.home.web;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import egovframework.govportal.dashboard.model.DashboardAnalyticsPayload;
import egovframework.govportal.dashboard.service.DashboardAnalyticsService;
import egovframework.govportal.project.model.ProjectVO;
import egovframework.govportal.project.service.ProjectService;
import kr.go.dgif.govportal.adapters.MetabaseClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Controller
@RequiredArgsConstructor
public class DashboardController {

    private final MetabaseClient metabaseClient;
    private final DashboardAnalyticsService analyticsService;
    private final ObjectMapper objectMapper;
    private final ProjectService projectService;

    @Value("${metabase.dashboard-id:0}")
    private int metabaseDashboardId;

    @Value("${metabase.card-ids:}")
    private String metabaseCardIds;

    @Value("${metabase.embed-external-base-url:}")
    private String metabaseExternalBaseUrl;

    @Value("${metabase.base-url:http://localhost:3000}")
    private String metabaseBaseUrl;

    @Value("${metabase.enabled:false}")
    private boolean metabaseEnabled;

    @Value("${odk.external-url:}")
    private String odkExternalUrl;

    @RequestMapping(value = "/dashboard.do", method = RequestMethod.GET)
    public String dashboard(ModelMap model, Authentication authentication,
                            @RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "projectId", required = false) String projectIdParam,
                            javax.servlet.http.HttpSession session) {
        model.addAttribute("username", authentication != null ? authentication.getName() : "게스트");

        Set<String> authorities = extractAuthorities(authentication);
        model.addAttribute("canManageRoles",
                hasAnyAuthority(authorities, "ROLE_ADMIN_SUPER", "PERM_rbac.role.manage"));
        model.addAttribute("canAssignRoles",
                hasAnyAuthority(authorities, "ROLE_ADMIN_SUPER", "PERM_rbac.assign"));
        model.addAttribute("canManageProjects",
                hasAnyAuthority(authorities, "ROLE_ADMIN_SUPER", "PERM_proj.manage"));
        model.addAttribute("canViewProjects",
                hasAnyAuthority(authorities, "ROLE_ADMIN_SUPER", "PERM_proj.manage", "PERM_proj.read"));

        boolean hasAccess = Boolean.TRUE.equals(model.get("canManageRoles"))
                || Boolean.TRUE.equals(model.get("canAssignRoles"))
                || Boolean.TRUE.equals(model.get("canManageProjects"))
                || Boolean.TRUE.equals(model.get("canViewProjects"));
        model.addAttribute("awaitingApproval", !hasAccess);

        List<ProjectVO> projects = projectService.listProjects();
        if (projects == null) {
            projects = Collections.emptyList();
        }
        model.addAttribute("projectOptions", projects);

        UUID scopedProjectId = parseProjectScope(projectIdParam);
        model.addAttribute("selectedProjectId", scopedProjectId);

        String selectedProjectName = scopedProjectId == null ? "전체 프로젝트" :
            projects.stream()
                .filter(project -> scopedProjectId.equals(project.getId()))
                .map(ProjectVO::getName)
                .findFirst()
                .orElse("선택한 프로젝트");
        model.addAttribute("selectedProjectName", selectedProjectName);

        DashboardAnalyticsPayload analyticsPayload = scopedProjectId != null
            ? analyticsService.loadAnalyticsForProject(scopedProjectId)
            : analyticsService.loadAnalytics();
        model.addAttribute("analyticsPayload", analyticsPayload);
        try {
            model.addAttribute("analyticsJson", objectMapper.writeValueAsString(analyticsPayload));
        } catch (JsonProcessingException e) {
            log.warn("대시보드 분석 데이터를 JSON으로 직렬화하지 못했습니다.", e);
        }

        String embedDashboard = null;
        List<String> embedCards = Collections.emptyList();
        if (Boolean.TRUE.equals(metabaseEnabled)) {
            embedDashboard = buildDashboardEmbed();
            embedCards = buildCardEmbeds();
        }
        boolean showMetabase = Boolean.TRUE.equals(metabaseEnabled)
            && (StringUtils.hasText(embedDashboard) || !embedCards.isEmpty());
        model.addAttribute("metabaseDashboardUrl", showMetabase ? embedDashboard : null);
        model.addAttribute("metabaseCardEmbeds", showMetabase ? embedCards : Collections.emptyList());
        model.addAttribute("metabaseConsoleUrl",
                resolveExternalUrl(metabaseExternalBaseUrl, System.getenv("MB_EMBED_EXTERNAL_BASE_URL"), metabaseBaseUrl));
        model.addAttribute("odkExternalUrl",
                resolveExternalUrl(odkExternalUrl, System.getenv("ODK_EXTERNAL_URL"), "http://localhost:8383"));
        log.info("Dashboard embed url present? {} / cards={} ", StringUtils.hasText(embedDashboard), embedCards.size());

        if ("access_denied".equals(error)) {
            String message = (String) session.getAttribute("accessDeniedMessage");
            if (message != null) {
                model.addAttribute("errorMessage", message);
                session.removeAttribute("accessDeniedMessage");
            } else {
                model.addAttribute("errorMessage", "접근 권한이 없습니다.");
            }
        }

        return "home/dashboard";
    }

    private UUID parseProjectScope(String projectIdParam) {
        if (!StringUtils.hasText(projectIdParam)) {
            return null;
        }
        try {
            return UUID.fromString(projectIdParam.trim());
        } catch (IllegalArgumentException ex) {
            log.warn("잘못된 프로젝트 ID가 전달되었습니다. value={}", projectIdParam);
            return null;
        }
    }

    private String resolveExternalUrl(String primary, String envValue, String fallback) {
        if (StringUtils.hasText(primary)) {
            return primary;
        }
        if (StringUtils.hasText(envValue)) {
            return envValue;
        }
        return fallback;
    }

    private String buildDashboardEmbed() {
        int dashboardId = metabaseDashboardId;
        if (dashboardId <= 0) {
            dashboardId = parseInt(System.getenv("MB_EMBED_DASHBOARD_ID"));
        }
        if (dashboardId <= 0) {
            return null;
        }
        try {
            String url = metabaseClient.generateDashboardEmbedUrl(dashboardId, Collections.emptyMap());
            log.debug("Metabase dashboard embed URL generated for id={}", dashboardId);
            return url;
        } catch (Exception e) {
            log.warn("Metabase dashboard embed 생성에 실패했습니다 (id={})", dashboardId, e);
            return null;
        }
    }

    private List<String> buildCardEmbeds() {
        String cardIdString = StringUtils.hasText(metabaseCardIds)
                ? metabaseCardIds
                : System.getenv("MB_EMBED_CARD_IDS");
        if (!StringUtils.hasText(cardIdString)) {
            return Collections.emptyList();
        }
        return Arrays.stream(cardIdString.split(","))
                .map(String::trim)
                .filter(StringUtils::hasText)
                .map(this::safeGenerateCard)
                .filter(StringUtils::hasText)
                .collect(Collectors.toList());
    }

    private String safeGenerateCard(String cardIdValue) {
        try {
            int cardId = Integer.parseInt(cardIdValue);
            String url = metabaseClient.generateEmbedUrl(cardId, Collections.emptyMap());
            log.debug("Metabase card embed URL generated for id={}", cardId);
            return url;
        } catch (Exception e) {
            log.warn("Metabase 카드 임베드 생성에 실패했습니다 (id={})", cardIdValue, e);
            return null;
        }
    }

    private int parseInt(String value) {
        if (!StringUtils.hasText(value)) {
            return 0;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            log.warn("Metabase dashboard/card ID 파싱에 실패했습니다 (value={})", value);
            return 0;
        }
    }

    private Set<String> extractAuthorities(Authentication authentication) {
        if (authentication == null) {
            return new HashSet<>();
        }
        Set<String> authorities = new HashSet<>();
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            authorities.add(authority.getAuthority());
        }
        return authorities;
    }

    private boolean hasAnyAuthority(Set<String> authorities, String... targets) {
        if (authorities.isEmpty()) {
            return false;
        }
        return Arrays.stream(targets).anyMatch(authorities::contains);
    }
}
