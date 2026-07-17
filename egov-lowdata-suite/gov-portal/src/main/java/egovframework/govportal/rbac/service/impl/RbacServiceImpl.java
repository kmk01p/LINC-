package egovframework.govportal.rbac.service.impl;

import egovframework.govportal.cmmn.logging.AuditLogger;
import egovframework.govportal.rbac.dao.RbacDAO;
import egovframework.govportal.cmmn.exception.ValidationException;
import egovframework.govportal.security.GovportalUserDetails;
import egovframework.govportal.rbac.model.PermissionVO;
import egovframework.govportal.rbac.model.RolePermissionVO;
import egovframework.govportal.rbac.model.RoleVO;
import egovframework.govportal.rbac.model.UserProfileVO;
import egovframework.govportal.rbac.model.UserRoleAssignmentVO;
import egovframework.govportal.rbac.model.UserVO;
import egovframework.govportal.rbac.service.RbacService;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import javax.annotation.Resource;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

@Service("rbacService")
public class RbacServiceImpl extends EgovAbstractServiceImpl implements RbacService {

    private static final UUID SYSTEM_ACTOR = UUID.fromString("00000000-0000-0000-0000-000000002001");
    private static final ZoneId DEFAULT_ZONE = ZoneId.of("Asia/Seoul");

    @Resource(name = "rbacDAO")
    private RbacDAO rbacDAO;

    @Resource(name = "auditLogger")
    private AuditLogger auditLogger;

    @Resource(name = "passwordEncoder")
    private PasswordEncoder passwordEncoder;

    @Override
    public List<RoleVO> listRoles() {
        List<RoleVO> roles = rbacDAO.selectRoles();
        for (RoleVO role : roles) {
            role.setPermissionCodes(rbacDAO.selectPermissionCodesByRole(role.getId()));
        }
        return roles;
    }

    @Override
    public RoleVO getRole(UUID roleId) {
        RoleVO role = rbacDAO.selectRole(roleId);
        if (role != null) {
            role.setPermissionCodes(rbacDAO.selectPermissionCodesByRole(roleId));
        }
        return role;
    }

    @Override
    @Transactional
    public void createRole(RoleVO role, List<UUID> permissionIds, UUID actorId) {
        role.setId(role.getId() == null ? UUID.randomUUID() : role.getId());
        UUID creator = actorId != null ? actorId : currentActor();
        role.setCreatedBy(creator);
        rbacDAO.insertRole(role);
        saveRolePermissions(role.getId(), permissionIds);
        auditLogger.info("ROLE_CREATE", role.getName(), creator);
    }

    @Override
    @Transactional
    public void updateRole(RoleVO role, List<UUID> permissionIds) {
        rbacDAO.updateRole(role);
        saveRolePermissions(role.getId(), permissionIds);
        auditLogger.info("ROLE_UPDATE", role.getName(), currentActor());
    }

    private void saveRolePermissions(UUID roleId, List<UUID> permissionIds) {
        rbacDAO.deleteRolePermissions(roleId);
        if (permissionIds == null) {
            return;
        }
        for (UUID permissionId : permissionIds) {
            RolePermissionVO link = new RolePermissionVO();
            link.setRoleId(roleId);
            link.setPermissionId(permissionId);
            rbacDAO.insertRolePermission(link);
        }
    }

    @Override
    @Transactional
    public void deleteRole(UUID roleId) {
        rbacDAO.deleteRolePermissions(roleId);
        rbacDAO.deleteRole(roleId);
        auditLogger.warn("ROLE_DELETE", roleId.toString(), currentActor());
    }

    @Override
    public List<PermissionVO> listPermissions() {
        return rbacDAO.selectPermissions();
    }

    @Override
    public List<UserVO> listUsers() {
        return rbacDAO.selectUsers();
    }

    @Override
    public List<UserRoleAssignmentVO> listAssignments(UUID userId) {
        return rbacDAO.selectAssignmentsByUser(userId);
    }

    @Override
    @Transactional
    public void assignRole(UserRoleAssignmentVO assignment) {
        if (assignment.getId() == null) {
            assignment.setId(UUID.randomUUID());
        }
        if (assignment.getValidFrom() == null) {
            assignment.setValidFrom(LocalDateTime.now(ZoneOffset.UTC));
        } else {
            assignment.setValidFrom(toUtc(assignment.getValidFrom()));
        }
        if (assignment.getValidTo() != null) {
            assignment.setValidTo(toUtc(assignment.getValidTo()));
        }
        if (assignment.getGrantedBy() == null) {
            assignment.setGrantedBy(SYSTEM_ACTOR);
        }
        rbacDAO.insertUserRoleAssignment(assignment);
        auditLogger.info("ROLE_ASSIGN", assignment.getRoleId().toString(), assignment.getGrantedBy());
    }

    private LocalDateTime toUtc(LocalDateTime localDateTime) {
        return localDateTime.atZone(DEFAULT_ZONE)
                .withZoneSameInstant(ZoneOffset.UTC)
                .toLocalDateTime();
    }

    @Override
    @Transactional
    public void revokeAssignment(UUID assignmentId) {
        rbacDAO.deleteUserRoleAssignment(assignmentId);
        auditLogger.warn("ROLE_REVOKE", assignmentId.toString(), currentActor());
    }

    @Override
    public UUID generateUniqueTenantId() {
        int attempts = 0;
        UUID candidate;
        do {
            candidate = UUID.randomUUID();
            attempts++;
            if (attempts > 50) {
                throw new ValidationException("테넌트 ID를 생성할 수 없습니다. 다시 시도해주세요.");
            }
        } while (rbacDAO.tenantIdExists(candidate));
        return candidate;
    }

    @Override
    @Transactional
    public void resetPassword(UUID userId, String newPassword) {
        String trimmed = newPassword != null ? newPassword.trim() : "";
        if (trimmed.length() < 8) {
            throw new ValidationException("비밀번호는 최소 8자 이상이어야 합니다.");
        }
        int updated = rbacDAO.updateUserPassword(userId, passwordEncoder.encode(trimmed));
        if (updated == 0) {
            throw new ValidationException("사용자를 찾을 수 없습니다.");
        }
        auditLogger.warn("USER_PASSWORD_RESET", userId.toString(), currentActor());
    }

    private UUID currentActor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) authentication.getPrincipal()).getUserId();
        }
        return SYSTEM_ACTOR;
    }

    @Override
    @Transactional
    public UserVO registerUser(String username, String rawPassword, int grade) {
        String trimmedUsername = username != null ? username.trim() : null;
        if (trimmedUsername == null || trimmedUsername.length() < 4) {
            throw new ValidationException("아이디는 최소 4자 이상이어야 합니다.");
        }
        if (rbacDAO.selectUserByUsername(trimmedUsername) != null) {
            throw new ValidationException("이미 사용 중인 아이디입니다.");
        }
        if (rawPassword == null || rawPassword.length() < 8) {
            throw new ValidationException("비밀번호는 최소 8자 이상이어야 합니다.");
        }

        int resolvedGrade = grade;
        if (resolvedGrade <= 0) {
            resolvedGrade = 5;
        }
        if (resolvedGrade != 4 && resolvedGrade != 5 && resolvedGrade != 0) {
            resolvedGrade = 5;
        }

        UserVO user = new UserVO();
        user.setId(UUID.randomUUID());
        user.setUsername(trimmedUsername);
        user.setPassword(passwordEncoder.encode(rawPassword));
        user.setGrade(resolvedGrade);

        rbacDAO.insertUser(user);
        auditLogger.info("USER_REGISTER", trimmedUsername, user.getId());
        return user;
    }

    @Override
    public boolean usernameExists(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        return rbacDAO.selectUserByUsername(username.trim()) != null;
    }

    @Override
    @Transactional
    public void saveUserProfile(UserProfileVO profile) {
        if (profile == null || profile.getUserId() == null) {
            throw new ValidationException("프로필 정보를 저장할 수 없습니다.");
        }
        UserProfileVO existing = rbacDAO.selectProfileByUserId(profile.getUserId());
        if (existing == null) {
            rbacDAO.insertUserProfile(profile);
        } else {
            rbacDAO.updateUserProfile(profile);
        }
    }

    @Override
    public UserProfileVO getUserProfile(UUID userId) {
        return rbacDAO.selectProfileByUserId(userId);
    }

    @Override
    public UserVO findUserByEmailAndName(String fullName, String email, java.time.LocalDate birthDate) {
        return rbacDAO.selectUserForRecovery(fullName, email, birthDate);
    }

    @Override
    public UserVO findUserByPhoneAndName(String fullName, String phoneNumber, java.time.LocalDate birthDate) {
        return rbacDAO.selectUserForRecoveryByPhone(fullName, phoneNumber, birthDate);
    }

    @Override
    public UserVO findUserForPasswordReset(String username, String email) {
        return rbacDAO.selectUserForPasswordReset(username, email);
    }

    @Override
    public UserVO findUserById(UUID userId) {
        return rbacDAO.selectUserById(userId);
    }
}
