package egovframework.govportal.project.dao;

import egovframework.govportal.cmmn.mapper.AbstractMapper;
import egovframework.govportal.project.model.FormTemplateVO;
import egovframework.govportal.project.model.IntegrationSettingVO;
import egovframework.govportal.project.model.ProjectFormVO;
import egovframework.govportal.project.model.ProjectVO;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository("projectDAO")
public class ProjectDAO extends AbstractMapper {

    private static final String NAMESPACE = "egovframework.govportal.project.mapper.ProjectMapper.";

    public void insertProject(ProjectVO project) {
        getSqlSession().insert(NAMESPACE + "insertProject", project);
    }

    public void updateProject(ProjectVO project) {
        getSqlSession().update(NAMESPACE + "updateProject", project);
    }

    public ProjectVO selectProject(UUID projectId) {
        return getSqlSession().selectOne(NAMESPACE + "selectProject", projectId);
    }

    public ProjectVO selectProjectById(UUID projectId) {
        return selectProject(projectId);
    }

    public List<ProjectVO> selectProjects() {
        return getSqlSession().selectList(NAMESPACE + "selectProjects");
    }

    public void updateProjectOdkInfo(UUID projectId, Long odkProjectId, UUID odkProjectUuid) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("projectId", projectId);
        params.put("odkProjectId", odkProjectId);
        params.put("odkProjectUuid", odkProjectUuid);
        getSqlSession().update(NAMESPACE + "updateProjectOdkInfo", params);
    }

    public void deleteProject(UUID projectId, UUID actorId) {
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        params.put("projectId", projectId);
        params.put("actorId", actorId);
        getSqlSession().update(NAMESPACE + "deleteProject", params);
    }

    public List<ProjectVO> selectDeletedProjects() {
        return getSqlSession().selectList(NAMESPACE + "selectDeletedProjects");
    }

    public void restoreProject(UUID projectId) {
        getSqlSession().update(NAMESPACE + "restoreProject", projectId);
    }

    public void permanentlyDeleteProject(UUID projectId) {
        getSqlSession().delete(NAMESPACE + "permanentlyDeleteProject", projectId);
    }

    public void insertProjectForm(ProjectFormVO form) {
        getSqlSession().insert(NAMESPACE + "insertProjectForm", form);
    }

    public void insertIntegration(IntegrationSettingVO integration) {
        getSqlSession().insert(NAMESPACE + "insertIntegration", integration);
    }

    public List<FormTemplateVO> selectFormTemplates() {
        return getSqlSession().selectList(NAMESPACE + "selectFormTemplates");
    }

    public FormTemplateVO selectFormTemplate(UUID templateId) {
        return getSqlSession().selectOne(NAMESPACE + "selectFormTemplate", templateId);
    }
}
