package egovframework.govportal.rbac.web;

import egovframework.govportal.cmmn.exception.ValidationException;
import egovframework.govportal.rbac.model.RoleVO;
import egovframework.govportal.rbac.model.UserRoleAssignmentVO;
import egovframework.govportal.rbac.model.UserVO;
import egovframework.govportal.rbac.service.RbacService;
import egovframework.govportal.security.GovportalUserDetails;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Controller
@RequestMapping("/rbac")
public class RbacAssignmentController {

    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private static final String ADMIN_ROLE_NAME = "ROLE_ADMIN_SUPER";

    @Resource(name = "rbacService")
    private RbacService rbacService;

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.assign')")
    @RequestMapping(value = "/assignments.do", method = RequestMethod.GET)
    public String assignmentsPage(@RequestParam(value = "userId", required = false) String userId,
                                  ModelMap model) {
        List<UserVO> users = rbacService.listUsers();
        List<RoleVO> roles = rbacService.listRoles();
        model.addAttribute("users", users);
        model.addAttribute("roles", roles);

        if (users.isEmpty()) {
            model.addAttribute("selectedUserId", null);
            model.addAttribute("assignments", java.util.Collections.emptyList());
            return "rbac/assignmentList";
        }

        UUID selectedUserId = determineUserId(userId, users.get(0).getId());
        model.addAttribute("selectedUserId", selectedUserId);
        model.addAttribute("assignments", enrichAssignments(selectedUserId, roles));
        return "rbac/assignmentList";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.assign')")
    @RequestMapping(value = "/assignments.do", method = RequestMethod.POST)
    public String assignRole(@ModelAttribute AssignmentCommand command) {
        UUID userId = parseUuid(command.getUserId(), "사용자를 선택하세요.");
        UUID roleId = parseUuid(command.getRoleId(), "역할을 선택하세요.");
        RoleVO role = rbacService.getRole(roleId);
        if (role == null) {
            throw new ValidationException("존재하지 않는 역할입니다.");
        }
        boolean adminRoleSelected = ADMIN_ROLE_NAME.equals(role.getName());

        UserRoleAssignmentVO assignment = new UserRoleAssignmentVO();
        assignment.setUserId(userId);
        assignment.setRoleId(roleId);
        assignment.setTenantId(adminRoleSelected
                ? rbacService.generateUniqueTenantId()
                : parseUuid(command.getTenantId(), "테넌트 ID는 필수입니다."));

        if (isChecked(command.getAutoProjectId())) {
            assignment.setProjectId(UUID.randomUUID());
        } else {
            assignment.setProjectId(parseNullableUuid(command.getProjectId()));
        }

        assignment.setValidFrom(parseNullableDate(command.getValidFrom(), null));
        assignment.setValidTo(parseNullableDate(command.getValidTo(), null));
        assignment.setGrantedBy(currentActorId());

        rbacService.assignRole(assignment);
        return "redirect:/rbac/assignments.do?userId=" + assignment.getUserId();
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.assign')")
    @RequestMapping(value = "/assignments/reset-password.do", method = RequestMethod.POST)
    public String resetPassword(@RequestParam("userId") String userId,
                                @RequestParam("newPassword") String newPassword,
                                @RequestParam("confirmPassword") String confirmPassword,
                                RedirectAttributes redirectAttributes) {
        UUID targetUserId = parseUuid(userId, "사용자를 선택하세요.");
        if (newPassword == null || newPassword.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "새 비밀번호를 입력하세요.");
            return "redirect:/rbac/assignments.do?userId=" + targetUserId;
        }
        if (!newPassword.equals(confirmPassword)) {
            redirectAttributes.addFlashAttribute("errorMessage", "비밀번호가 일치하지 않습니다.");
            return "redirect:/rbac/assignments.do?userId=" + targetUserId;
        }
        try {
            rbacService.resetPassword(targetUserId, newPassword);
            redirectAttributes.addFlashAttribute("successMessage", "비밀번호가 초기화되었습니다.");
        } catch (ValidationException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/rbac/assignments.do?userId=" + targetUserId;
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.assign')")
    @RequestMapping(value = "/assignments/revoke.do", method = RequestMethod.POST)
    public String revoke(@RequestParam("assignmentId") String assignmentId,
                         @RequestParam("userId") String userId) {
        rbacService.revokeAssignment(parseUuid(assignmentId, "잘못된 배정 ID"));
        return "redirect:/rbac/assignments.do?userId=" + userId;
    }

    private UUID determineUserId(String userIdParam, UUID defaultId) {
        try {
            return userIdParam == null || userIdParam.isEmpty()
                    ? defaultId
                    : UUID.fromString(userIdParam);
        } catch (IllegalArgumentException ex) {
            throw new ValidationException("올바른 사용자 ID가 아닙니다.");
        }
    }

    private List<Map<String, Object>> enrichAssignments(UUID userId, List<RoleVO> roles) {
        List<UserRoleAssignmentVO> assignments = rbacService.listAssignments(userId);
        Map<UUID, String> roleNames = new HashMap<>();
        for (RoleVO role : roles) {
            roleNames.put(role.getId(), role.getName());
        }
        java.util.ArrayList<Map<String, Object>> rows = new java.util.ArrayList<>();
        for (UserRoleAssignmentVO a : assignments) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", a.getId());
            row.put("roleName", roleNames.getOrDefault(a.getRoleId(), a.getRoleId().toString()));
            row.put("tenantId", a.getTenantId());
            row.put("projectId", a.getProjectId());
            row.put("validFrom", a.getValidFrom());
            row.put("validTo", a.getValidTo());
            rows.add(row);
        }
        return rows;
    }

    private UUID parseUuid(String value, String message) {
        if (value == null || value.isEmpty()) {
            throw new ValidationException(message);
        }
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException ex) {
            throw new ValidationException(message);
        }
    }

    private UUID parseNullableUuid(String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        try {
            return UUID.fromString(value);
        } catch (IllegalArgumentException ex) {
            throw new ValidationException("UUID 형식이 올바르지 않습니다.");
        }
    }

    private LocalDateTime parseNullableDate(String value, LocalDateTime defaultValue) {
        if (value == null || value.isEmpty()) {
            return defaultValue;
        }
        try {
            return LocalDateTime.parse(value, DATETIME_FORMATTER);
        } catch (Exception ex) {
            throw new ValidationException("날짜 형식이 올바르지 않습니다.");
        }
    }

    private UUID currentActorId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) authentication.getPrincipal()).getUserId();
        }
        return UUID.fromString("00000000-0000-0000-0000-000000002001");
    }

    private boolean isChecked(String value) {
        if (value == null) {
            return false;
        }
        String normalized = value.trim().toLowerCase();
        return "true".equals(normalized) || "on".equals(normalized);
    }

    public static class AssignmentCommand {
        private String userId;
        private String roleId;
        private String tenantId;
        private String projectId;
        private String validFrom;
        private String validTo;
        private String autoProjectId;

        public String getUserId() {
            return userId;
        }

        public void setUserId(String userId) {
            this.userId = userId;
        }

        public String getRoleId() {
            return roleId;
        }

        public void setRoleId(String roleId) {
            this.roleId = roleId;
        }

        public String getTenantId() {
            return tenantId;
        }

        public void setTenantId(String tenantId) {
            this.tenantId = tenantId;
        }

        public String getProjectId() {
            return projectId;
        }

        public void setProjectId(String projectId) {
            this.projectId = projectId;
        }

        public String getValidFrom() {
            return validFrom;
        }

        public void setValidFrom(String validFrom) {
            this.validFrom = validFrom;
        }

        public String getValidTo() {
            return validTo;
        }

        public void setValidTo(String validTo) {
            this.validTo = validTo;
        }

        public String getAutoProjectId() {
            return autoProjectId;
        }

        public void setAutoProjectId(String autoProjectId) {
            this.autoProjectId = autoProjectId;
        }
    }
}
