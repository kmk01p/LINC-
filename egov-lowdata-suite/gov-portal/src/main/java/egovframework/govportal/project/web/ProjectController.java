package egovframework.govportal.project.web;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import egovframework.govportal.cmmn.exception.ValidationException;
import egovframework.govportal.dashboard.model.DashboardAnalyticsPayload;
import egovframework.govportal.dashboard.service.DashboardAnalyticsService;
import egovframework.govportal.project.model.ProjectVO;
import egovframework.govportal.project.service.ProjectService;
import egovframework.govportal.security.GovportalUserDetails;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import javax.annotation.Resource;
import java.util.UUID;

@Slf4j
@Controller
@RequestMapping("/projects")
public class ProjectController {

    @Resource(name = "projectService")
    private ProjectService projectService;
    @Resource
    private DashboardAnalyticsService dashboardAnalyticsService;
    @Resource
    private ObjectMapper objectMapper;

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.read','PERM_proj.manage')")
    @RequestMapping(value = "/list.do", method = RequestMethod.GET)
    public String list(ModelMap model) {
        model.addAttribute("projects", projectService.listProjects());
        return "project/list";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/create.do", method = RequestMethod.GET)
    public String createForm(ModelMap model) {
        ProjectVO project = new ProjectVO();
        project.setStatus("DRAFT");
        model.addAttribute("project", project);
        model.addAttribute("templates", projectService.listTemplates());
        return "project/create";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/create.do", method = RequestMethod.POST)
    public String create(@ModelAttribute ProjectVO project,
                         @RequestParam(value = "templateId", required = false) String templateIdParam) {
        UUID actor = currentActor();
        project.setCreatedBy(actor);
        if (project.getTenantId() == null) {
            throw new ValidationException("테넌트 ID는 필수입니다.");
        }
        UUID templateId = null;
        if (templateIdParam != null && !templateIdParam.isEmpty()) {
            try {
                templateId = UUID.fromString(templateIdParam);
            } catch (IllegalArgumentException ex) {
                throw new ValidationException("올바른 템플릿 ID가 아닙니다.");
            }
        }
        projectService.createProject(project, templateId);
        return "redirect:/projects/list.do";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.read','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/detail.do", method = RequestMethod.GET)
    public String detail(@PathVariable("id") UUID projectId, ModelMap model) {
        model.addAttribute("project", projectService.getProject(projectId));
        return "project/detail";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.read','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/analytics.do", method = RequestMethod.GET)
    public String analytics(@PathVariable("id") UUID projectId, ModelMap model) {
        ProjectVO project = projectService.getProject(projectId);
        DashboardAnalyticsPayload payload = dashboardAnalyticsService.loadAnalyticsForProject(projectId);
        model.addAttribute("project", project);
        model.addAttribute("analyticsPayload", payload);
        try {
            model.addAttribute("analyticsJson", objectMapper.writeValueAsString(payload));
        } catch (JsonProcessingException e) {
            log.warn("프로젝트 통계 JSON 직렬화 실패 projectId={}", projectId, e);
        }
        return "project/stats";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/delete.do", method = RequestMethod.POST)
    public String delete(@PathVariable("id") UUID projectId) {
        UUID actor = currentActor();
        projectService.deleteProject(projectId, actor);
        return "redirect:/projects/list.do";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/edit.do", method = RequestMethod.GET)
    public String editForm(@PathVariable("id") UUID projectId, ModelMap model) {
        ProjectVO project = projectService.getProject(projectId);
        model.addAttribute("project", project);
        model.addAttribute("templates", projectService.listTemplates());
        return "project/edit";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/edit.do", method = RequestMethod.POST)
    public String edit(@PathVariable("id") UUID projectId, @ModelAttribute ProjectVO project) {
        UUID actor = currentActor();
        project.setId(projectId);
        projectService.updateProject(project, actor);
        return "redirect:/projects/" + projectId + "/detail.do";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.read','PERM_proj.manage')")
    @RequestMapping(value = "/deleted/list.do", method = RequestMethod.GET)
    public String deletedList(ModelMap model) {
        model.addAttribute("projects", projectService.listDeletedProjects());
        return "project/deleted-list";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/restore.do", method = RequestMethod.POST)
    public String restore(@PathVariable("id") UUID projectId) {
        UUID actor = currentActor();
        projectService.restoreProject(projectId, actor);
        return "redirect:/projects/list.do";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_proj.manage')")
    @RequestMapping(value = "/{id}/permanent-delete.do", method = RequestMethod.POST)
    public String permanentDelete(@PathVariable("id") UUID projectId) {
        UUID actor = currentActor();
        projectService.permanentlyDeleteProject(projectId, actor);
        return "redirect:/projects/deleted/list.do";
    }

    private UUID currentActor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) authentication.getPrincipal()).getUserId();
        }
        return UUID.fromString("00000000-0000-0000-0000-000000002001");
    }
}
