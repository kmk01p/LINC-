package com.example.egov.domain.dao;

import com.example.egov.domain.UserRoleAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface UserRoleAssignmentRepository extends JpaRepository<UserRoleAssignment, UUID> {

    @org.springframework.data.jpa.repository.Query("select ura from UserRoleAssignment ura " +
            "where ura.userId = :userId " +
            "and ura.validFrom <= :now " +
            "and (ura.validTo is null or ura.validTo > :now)")
    List<UserRoleAssignment> findActiveAssignments(UUID userId, Instant now);
}
