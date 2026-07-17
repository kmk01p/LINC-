package egovframework.govportal.rbac.service;

import egovframework.govportal.rbac.model.PermissionVO;
import egovframework.govportal.rbac.model.RoleVO;
import egovframework.govportal.rbac.model.UserProfileVO;
import egovframework.govportal.rbac.model.UserRoleAssignmentVO;
import egovframework.govportal.rbac.model.UserVO;

import java.util.List;
import java.util.UUID;

public interface RbacService {

    List<RoleVO> listRoles();

    RoleVO getRole(UUID roleId);

    void createRole(RoleVO role, List<UUID> permissionIds, UUID actorId);

    void updateRole(RoleVO role, List<UUID> permissionIds);

    void deleteRole(UUID roleId);

    List<PermissionVO> listPermissions();

    List<UserVO> listUsers();

    List<UserRoleAssignmentVO> listAssignments(UUID userId);

    void assignRole(UserRoleAssignmentVO assignment);

    void revokeAssignment(UUID assignmentId);

    UserVO registerUser(String username, String rawPassword, int grade);

    boolean usernameExists(String username);

    UUID generateUniqueTenantId();

    void resetPassword(UUID userId, String newPassword);

    void saveUserProfile(UserProfileVO profile);

    UserProfileVO getUserProfile(UUID userId);

    UserVO findUserByEmailAndName(String fullName, String email, java.time.LocalDate birthDate);

    UserVO findUserByPhoneAndName(String fullName, String phoneNumber, java.time.LocalDate birthDate);

    UserVO findUserForPasswordReset(String username, String email);

    UserVO findUserById(UUID userId);
}
