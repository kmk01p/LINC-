package com.example.egov.domain.dao;

import com.example.egov.domain.RolePermission;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface RolePermissionRepository extends JpaRepository<RolePermission, RolePermission.RolePermissionKey> {
}
