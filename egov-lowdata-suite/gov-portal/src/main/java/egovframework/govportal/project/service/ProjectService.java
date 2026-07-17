package egovframework.govportal.project.service;

import egovframework.govportal.project.model.FormTemplateVO;
import egovframework.govportal.project.model.ProjectVO;

import java.util.List;
import java.util.UUID;

public interface ProjectService {

    List<ProjectVO> listProjects();

    ProjectVO getProject(UUID projectId);

    void createProject(ProjectVO project, UUID templateId);

    void updateProject(ProjectVO project, UUID actorId);

    void deleteProject(UUID projectId, UUID actorId);

    List<ProjectVO> listDeletedProjects();

    void restoreProject(UUID projectId, UUID actorId);

    void permanentlyDeleteProject(UUID projectId, UUID actorId);

    List<FormTemplateVO> listTemplates();
}
