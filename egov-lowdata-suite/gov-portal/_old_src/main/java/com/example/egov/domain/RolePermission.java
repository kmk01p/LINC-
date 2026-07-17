package com.example.egov.domain;

import jakarta.persistence.*;
import java.io.Serializable;
import java.util.UUID;

@Entity
@Table(name = "app_role_permissions")
@IdClass(RolePermission.RolePermissionKey.class)
public class RolePermission {
    @Id
    @Column(name = "role_id", columnDefinition = "uuid")
    private UUID roleId;
    @Id
    @Column(name = "permission_id", columnDefinition = "uuid")
    private UUID permissionId;

    public RolePermission() {
    }

    public RolePermission(UUID roleId, UUID permissionId) {
        this.roleId = roleId;
        this.permissionId = permissionId;
    }

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

    public static class RolePermissionKey implements Serializable {
        private UUID roleId;
        private UUID permissionId;

        public RolePermissionKey() {}

        public RolePermissionKey(UUID roleId, UUID permissionId) {
            this.roleId = roleId;
            this.permissionId = permissionId;
        }
        // equals/hashCode required
        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof RolePermissionKey)) return false;
            RolePermissionKey that = (RolePermissionKey) o;
            return java.util.Objects.equals(roleId, that.roleId)
                    && java.util.Objects.equals(permissionId, that.permissionId);
        }
        @Override
        public int hashCode() {
            return java.util.Objects.hash(roleId, permissionId);
        }
    }
}
