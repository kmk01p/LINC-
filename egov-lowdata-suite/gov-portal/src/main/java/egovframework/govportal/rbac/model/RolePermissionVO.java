package egovframework.govportal.rbac.model;

import java.io.Serializable;
import java.util.UUID;

public class RolePermissionVO implements Serializable {

    private UUID roleId;
    private UUID permissionId;

    public UUID getRoleId() {
        return roleId;
    }

    public void setRoleId(UUID roleId) {
        this.roleId = roleId;
    }

    public UUID getPermissionId() {
        return permissionId;
    }

    public void setPermissionId(UUID permissionId) {
        this.permissionId = permissionId;
    }
}
