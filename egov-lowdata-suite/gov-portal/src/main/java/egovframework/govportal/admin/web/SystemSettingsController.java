package egovframework.govportal.admin.web;

import egovframework.govportal.admin.model.SystemSetting;
import egovframework.govportal.admin.model.SystemSettingsForm;
import egovframework.govportal.admin.service.SystemSettingsService;
import egovframework.govportal.cmmn.logging.AuditLogger;
import egovframework.govportal.security.GovportalUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class SystemSettingsController {

    private final SystemSettingsService systemSettingsService;
    private final AuditLogger auditLogger;

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_sys.manage')")
    @GetMapping("/settings.do")
    public String viewSettings(ModelMap model) {
        model.addAttribute("groupedSettings", systemSettingsService.listGrouped());
        model.addAttribute("settingsList", systemSettingsService.listAll());
        if (!model.containsAttribute("settingsForm")) {
            model.addAttribute("settingsForm", new SystemSettingsForm());
        }
        return "admin/system-settings";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_sys.manage')")
    @PostMapping("/settings.do")
    public String updateSettings(@ModelAttribute("settingsForm") SystemSettingsForm form,
                                 Authentication authentication,
                                 RedirectAttributes redirectAttributes) {
        UUID actor = resolveActor(authentication);
        List<SystemSetting> changed = systemSettingsService.updateSettings(form != null ? form.getSettings() : null, actor);
        if (!changed.isEmpty()) {
            auditLogger.info("SYSTEM_SETTINGS_UPDATE", changed.size() + "개의 시스템 설정이 수정되었습니다.", actor);
        }
        redirectAttributes.addFlashAttribute("settingsSaved", true);
        redirectAttributes.addFlashAttribute("settingsChangedCount", changed.size());
        return "redirect:/admin/settings.do";
    }

    private UUID resolveActor(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) authentication.getPrincipal()).getUserId();
        }
        return UUID.fromString("00000000-0000-0000-0000-000000002001");
    }
}
