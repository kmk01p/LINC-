package com.example.egov.controllers;

import com.example.egov.audit.Auditable;
import com.example.egov.domain.Role;
import com.example.egov.domain.dao.RoleRepository;
import com.example.egov.domain.dao.UserRepository;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequestMapping("/admin")
public class AdminController {
    private final RoleRepository roleRepository;
    private final UserRepository userRepository;

    public AdminController(RoleRepository roleRepository, UserRepository userRepository) {
        this.roleRepository = roleRepository;
        this.userRepository = userRepository;
    }

    @GetMapping("/roles")
    @PreAuthorize("hasAuthority('rbac.role.manage')")
    public String roles(Model model) {
        List<Role> roles = roleRepository.findAll();
        model.addAttribute("roles", roles);
        return "admin_roles";
    }

    @PostMapping("/roles")
    @PreAuthorize("hasAuthority('rbac.role.manage')")
    @Auditable(action = "Create Role")
    public String createRole(@RequestParam String name) {
        Role role = new Role();
        role.setId(java.util.UUID.randomUUID());
        role.setName(name);
        roleRepository.save(role);
        return "redirect:/admin/roles";
    }

    @GetMapping("/assignments")
    @PreAuthorize("hasAuthority('rbac.assign')")
    public String assignments(Model model) {
        model.addAttribute("users", userRepository.findAll());
        model.addAttribute("roles", roleRepository.findAll());
        return "admin_assignments";
    }

    @PostMapping("/assign-role")
    @PreAuthorize("hasAuthority('rbac.assign')")
    @Auditable(action = "Assign Role")
    public String assignRole(@RequestParam("userId") java.util.UUID userId,
                             @RequestParam("roleId") java.util.UUID roleId) {
        // Incomplete: Should create UserRoleAssignment entity
        return "redirect:/admin/assignments";
    }

    @GetMapping("/create-project")
    @PreAuthorize("hasAuthority('proj.manage')")
    public String createProjectForm(Model model) {
        return "admin_create_project";
    }

    @PostMapping("/projects")
    @PreAuthorize("hasAuthority('proj.manage')")
    @Auditable(action = "Create Project")
    public String createProject() {
        // Stub: Should call sidecar to generate XLSX, OdkClient to create project, Metabase bootstrap, etc.
        return "redirect:/";
    }
}