package kr.go.dgif.govportal.domain.dao;

import kr.go.dgif.govportal.domain.entity.Project;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ProjectDao {
    List<Project> findActiveProjects();

    Optional<Project> findById(UUID projectId);

    void updateOdkProject(UUID projectId, Long odkProjectId, UUID odkProjectUuid);
}
