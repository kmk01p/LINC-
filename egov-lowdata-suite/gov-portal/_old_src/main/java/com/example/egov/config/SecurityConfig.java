package com.example.egov.config;

import com.example.egov.domain.Permission;
import com.example.egov.domain.Role;
import com.example.egov.domain.RolePermission;
import com.example.egov.domain.User;
import com.example.egov.domain.UserRoleAssignment;
import com.example.egov.domain.dao.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

@Configuration
@EnableMethodSecurity
public class SecurityConfig {
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private UserRoleAssignmentRepository assignmentRepository;
    @Autowired
    private RoleRepository roleRepository;
    @Autowired
    private RolePermissionRepository rolePermissionRepository;
    @Autowired
    private PermissionRepository permissionRepository;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(authz -> authz
                .requestMatchers("/login", "/error", "/css/**", "/js/**").permitAll()
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .permitAll()
            )
            .logout(logout -> logout.logoutUrl("/logout").permitAll())
            .csrf(csrf -> csrf.disable());
        return http.build();
    }

    @Bean
    public UserDetailsService userDetailsService() {
        return username -> {
            User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
            // Determine active assignments
            Instant now = Instant.now();
            List<UserRoleAssignment> assignments = assignmentRepository.findActiveAssignments(user.getId(), now);
            Set<String> authorityCodes = new HashSet<>();
            Set<String> roleNames = new HashSet<>();
            for (UserRoleAssignment ass : assignments) {
                roleRepository.findById(ass.getRoleId()).ifPresent(role -> {
                    roleNames.add(role.getName());
                    // permissions via role_permissions
                    List<RolePermission> rps = rolePermissionRepository.findAll().stream()
                            .filter(rp -> rp.getRoleId().equals(role.getId()))
                            .toList();
                    for (RolePermission rp : rps) {
                        permissionRepository.findById(rp.getPermissionId()).ifPresent(perm -> authorityCodes.add(perm.getCode()));
                    }
                });
            }
            List<GrantedAuthority> authorities = new ArrayList<>();
            // Add role names with prefix ROLE_
            for (String role : roleNames) {
                authorities.add(new SimpleGrantedAuthority(role));
            }
            // Add permission codes as authorities
            for (String perm : authorityCodes) {
                authorities.add(new SimpleGrantedAuthority(perm));
            }
            return new org.springframework.security.core.userdetails.User(user.getUsername(), user.getPassword(), authorities);
        };
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // We store passwords in plain text in data.sql (prefixed with {noop})
        return NoOpPasswordEncoder.getInstance();
    }
}
