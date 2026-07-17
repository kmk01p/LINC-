package egovframework.govportal.rbac.web;

import egovframework.govportal.rbac.model.PermissionVO;
import egovframework.govportal.rbac.model.RoleVO;
import egovframework.govportal.rbac.service.RbacService;
import egovframework.govportal.security.GovportalUserDetails;
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
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/rbac")
public class RbacController {

    @Resource(name = "rbacService")
    private RbacService rbacService;

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.role.manage')")
    @RequestMapping(value = "/roles.do", method = RequestMethod.GET)
    public String roles(ModelMap model) {
        List<RoleVO> roles = rbacService.listRoles();
        model.addAttribute("roles", roles);
        model.addAttribute("permissions", rbacService.listPermissions());
        return "rbac/roleList";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.role.manage')")
    @RequestMapping(value = "/roles.do", method = RequestMethod.POST)
    public String createRole(@ModelAttribute RoleVO role,
                             @RequestParam(value = "permissionIds", required = false) List<String> permissionIds) {
        List<UUID> perms = toUuidList(permissionIds);
        rbacService.createRole(role, perms, currentActor());
        return "redirect:/rbac/roles.do";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.role.manage')")
    @RequestMapping(value = "/roles/{roleId}.do", method = RequestMethod.POST)
    public String updateRole(@PathVariable("roleId") UUID roleId,
                             @ModelAttribute RoleVO role,
                             @RequestParam(value = "permissionIds", required = false) List<String> permissionIds) {
        role.setId(roleId);
        rbacService.updateRole(role, toUuidList(permissionIds));
        return "redirect:/rbac/roles.do";
    }

    @PreAuthorize("hasAnyAuthority('ROLE_ADMIN_SUPER','PERM_rbac.role.manage')")
    @RequestMapping(value = "/roles/{roleId}/delete.do", method = RequestMethod.POST)
    public String deleteRole(@PathVariable("roleId") UUID roleId) {
        rbacService.deleteRole(roleId);
        return "redirect:/rbac/roles.do";
    }

    private List<UUID> toUuidList(List<String> ids) {
        if (ids == null) {
            return new ArrayList<>();
        }
        List<UUID> list = new ArrayList<>();
        for (String id : ids) {
            list.add(UUID.fromString(id));
        }
        return list;
    }

    @ModelAttribute("allPermissions")
    public List<PermissionVO> permissions() {
        return rbacService.listPermissions();
    }

    private UUID currentActor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) authentication.getPrincipal()).getUserId();
        }
        return UUID.fromString("00000000-0000-0000-0000-000000002001");
    }
}
