package egovframework.govportal.rbac.dao;

import egovframework.govportal.cmmn.mapper.AbstractMapper;
import egovframework.govportal.rbac.model.PermissionVO;
import egovframework.govportal.rbac.model.RolePermissionVO;
import egovframework.govportal.rbac.model.RoleVO;
import egovframework.govportal.rbac.model.UserProfileVO;
import egovframework.govportal.rbac.model.UserRoleAssignmentVO;
import egovframework.govportal.rbac.model.UserVO;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Repository("rbacDAO")
public class RbacDAO extends AbstractMapper {

    private static final String NAMESPACE = "egovframework.govportal.rbac.mapper.RbacMapper.";

    public List<RoleVO> selectRoles() {
        return getSqlSession().selectList(NAMESPACE + "selectRoles");
    }

    public RoleVO selectRole(UUID roleId) {
        return getSqlSession().selectOne(NAMESPACE + "selectRole", roleId);
    }

    public void insertRole(RoleVO role) {
        getSqlSession().insert(NAMESPACE + "insertRole", role);
    }

    public void updateRole(RoleVO role) {
        getSqlSession().update(NAMESPACE + "updateRole", role);
    }

    public void deleteRole(UUID roleId) {
        getSqlSession().delete(NAMESPACE + "deleteRole", roleId);
    }

    public List<PermissionVO> selectPermissions() {
        return getSqlSession().selectList(NAMESPACE + "selectPermissions");
    }

    public List<String> selectPermissionCodesByRole(UUID roleId) {
        return getSqlSession().selectList(NAMESPACE + "selectPermissionCodesByRole", roleId);
    }

    public void insertRolePermission(RolePermissionVO link) {
        getSqlSession().insert(NAMESPACE + "insertRolePermission", link);
    }

    public void deleteRolePermissions(UUID roleId) {
        getSqlSession().delete(NAMESPACE + "deleteRolePermissions", roleId);
    }

    public List<UserVO> selectUsers() {
        return getSqlSession().selectList(NAMESPACE + "selectUsers");
    }

    public void insertUser(UserVO user) {
        getSqlSession().insert(NAMESPACE + "insertUser", user);
    }

    public UserVO selectUserByUsername(String username) {
        return getSqlSession().selectOne(NAMESPACE + "selectUserByUsername", username);
    }

    public UserVO selectUserById(UUID userId) {
        return getSqlSession().selectOne(NAMESPACE + "selectUserById", userId);
    }

    public List<String> selectRoleCodesByUser(UUID userId) {
        return getSqlSession().selectList(NAMESPACE + "selectRoleCodesByUser", userId);
    }

    public List<String> selectPermissionCodesByUser(UUID userId) {
        return getSqlSession().selectList(NAMESPACE + "selectPermissionCodesByUser", userId);
    }

    public List<UserRoleAssignmentVO> selectAssignmentsByUser(UUID userId) {
        return getSqlSession().selectList(NAMESPACE + "selectAssignmentsByUser", userId);
    }

    public void insertUserRoleAssignment(UserRoleAssignmentVO assignment) {
        getSqlSession().insert(NAMESPACE + "insertUserRoleAssignment", assignment);
    }

    public void deleteUserRoleAssignment(UUID assignmentId) {
        getSqlSession().delete(NAMESPACE + "deleteUserRoleAssignment", assignmentId);
    }

    public boolean tenantIdExists(UUID tenantId) {
        Integer count = getSqlSession().selectOne(NAMESPACE + "countAssignmentsByTenant", tenantId);
        return count != null && count > 0;
    }

    public int updateUserPassword(UUID userId, String encodedPassword) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", userId);
        params.put("password", encodedPassword);
        return getSqlSession().update(NAMESPACE + "updateUserPassword", params);
    }

    public void insertUserProfile(UserProfileVO profile) {
        getSqlSession().insert(NAMESPACE + "insertUserProfile", profile);
    }

    public void updateUserProfile(UserProfileVO profile) {
        getSqlSession().update(NAMESPACE + "updateUserProfileContacts", profile);
    }

    public UserProfileVO selectProfileByUserId(UUID userId) {
        return getSqlSession().selectOne(NAMESPACE + "selectProfileByUserId", userId);
    }

    public UserVO selectUserForRecovery(String fullName, String email, java.time.LocalDate birthDate) {
        Map<String, Object> params = new HashMap<>();
        params.put("fullName", fullName);
        params.put("email", email);
        params.put("birthDate", birthDate);
        return getSqlSession().selectOne(NAMESPACE + "selectUserForRecovery", params);
    }

    public UserVO selectUserForRecoveryByPhone(String fullName, String phoneNumber, java.time.LocalDate birthDate) {
        Map<String, Object> params = new HashMap<>();
        params.put("fullName", fullName);
        params.put("phoneNumber", phoneNumber);
        params.put("birthDate", birthDate);
        return getSqlSession().selectOne(NAMESPACE + "selectUserForRecoveryByPhone", params);
    }

    public UserVO selectUserForPasswordReset(String username, String email) {
        Map<String, Object> params = new HashMap<>();
        params.put("username", username);
        params.put("email", email);
        return getSqlSession().selectOne(NAMESPACE + "selectUserForPasswordReset", params);
    }
}
