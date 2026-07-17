package egovframework.govportal.project.service.impl;

import egovframework.govportal.adapters.sidecar.XlsformClient;
import egovframework.govportal.cmmn.exception.BusinessException;
import egovframework.govportal.cmmn.logging.AuditLogger;
import egovframework.govportal.project.dao.ProjectDAO;
import egovframework.govportal.project.model.FormTemplateVO;
import egovframework.govportal.project.model.ProjectVO;
import egovframework.govportal.project.model.ProjectFormVO;
import egovframework.govportal.project.service.ProjectService;
import kr.go.dgif.govportal.adapters.OdkClient;
import kr.go.dgif.govportal.domain.dao.ProjectDao;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;
import java.util.UUID;

@Service("projectService")
public class ProjectServiceImpl extends EgovAbstractServiceImpl implements ProjectService {

    private static final Logger log = LoggerFactory.getLogger(ProjectServiceImpl.class);

    @Resource(name = "projectDAO")
    private ProjectDAO projectDAO;

    @Resource(name = "auditLogger")
    private AuditLogger auditLogger;

    @Resource(name = "xlsformClient")
    private XlsformClient xlsformClient;

    @Resource(name = "odkClient")
    private OdkClient odkClient;

    @Resource(name = "jdbcProjectDao")
    private ProjectDao projectDomainDao;

    @Override
    public List<ProjectVO> listProjects() {
        return projectDAO.selectProjects();
    }

    @Override
    public ProjectVO getProject(UUID projectId) {
        return projectDAO.selectProject(projectId);
    }

    @Override
    @Transactional
    public void createProject(ProjectVO project, UUID templateId) {
        if (project.getId() == null) {
            project.setId(UUID.randomUUID());
        }
        project.setStatus("DRAFT");
        projectDAO.insertProject(project);
        auditLogger.info("PROJECT_CREATE", project.getName(), project.getCreatedBy());

        // If no templateId provided, use default template
        if (templateId == null) {
            templateId = UUID.fromString("00000000-0000-0000-0000-00000000f101");
        }

        byte[] xlsBytes = null;
        String templateName = null;
        FormTemplateVO template = projectDAO.selectFormTemplate(templateId);
        if (template != null) {
            templateName = template.getName();
            xlsBytes = xlsformClient.generateXlsform(template.getJsonSpec());

            // Extract codebook from template if available
            try {
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                com.fasterxml.jackson.databind.JsonNode jsonSpec = mapper.readTree(template.getJsonSpec());
                if (jsonSpec.has("codebook")) {
                    String codebookJson = jsonSpec.get("codebook").toString();
                    project.setCodebook(codebookJson);
                    projectDAO.updateProject(project);
                }
            } catch (Exception e) {
                log.warn("Failed to extract codebook from template: {}", e.getMessage());
            }
        }

        Long createdOdkProjectId = null;
        try {
            if (xlsBytes != null) {
                OdkClient.OdkProjectRef odkProject = odkClient.createProject(project.getName());
                long odkProjectId = odkProject.getProjectId();
                createdOdkProjectId = odkProjectId;
                UUID acteeId = odkProject.getActeeId();

                String formId = slug(project.getName()) + "-" + System.currentTimeMillis();
                String xmlFormId = odkClient.uploadForm(odkProjectId, formId, xlsBytes);
                odkClient.publishForm(odkProjectId, xmlFormId);

                // Create App User and grant form access
                String appUserDisplayName = project.getName() + " - Data Collector";
                OdkClient.AppUserRef appUser = odkClient.createAppUser(odkProjectId, appUserDisplayName);
                odkClient.grantFormAccess(odkProjectId, xmlFormId, appUser.getAppUserId());

                log.info("Created App User {} with token for project {}", appUser.getAppUserId(), odkProjectId);

                project.setOdkProjectId(odkProjectId);
                project.setOdkProjectUuid(acteeId);
                project.setOdkXmlFormId(xmlFormId);
                project.setStatus("ACTIVE");
                projectDAO.updateProject(project);
                projectDomainDao.updateOdkProject(project.getId(), project.getOdkProjectId(), project.getOdkProjectUuid());

                ProjectFormVO form = new ProjectFormVO();
                form.setId(UUID.randomUUID());
                form.setProjectId(project.getId());
                form.setTemplateName(templateName != null ? templateName : formId);
                form.setVersion("v1");
                form.setUploadedAt(java.time.LocalDateTime.now());
                projectDAO.insertProjectForm(form);

                auditLogger.info("PROJECT_ODK", "ODK 프로젝트/폼 배포 및 App User 설정 완료", project.getCreatedBy());
            }
        } catch (BusinessException ex) {
            cleanupOdkProject(createdOdkProjectId);
            cleanupPortalProject(project.getId());
            throw ex;
        } catch (Exception ex) {
            cleanupOdkProject(createdOdkProjectId);
            cleanupPortalProject(project.getId());
            throw ex;
        }
    }

    @Override
    @Transactional
    public void updateProject(ProjectVO project, UUID actorId) {
        ProjectVO existingProject = projectDAO.selectProject(project.getId());
        if (existingProject == null) {
            throw new IllegalArgumentException("프로젝트를 찾을 수 없습니다.");
        }

        // Update basic information
        projectDAO.updateProject(project);
        auditLogger.info("PROJECT_UPDATE", project.getName(), actorId);
    }

    @Override
    @Transactional
    public void deleteProject(UUID projectId, UUID actorId) {
        ProjectVO project = projectDAO.selectProject(projectId);
        if (project == null) {
            throw new IllegalArgumentException("프로젝트를 찾을 수 없습니다.");
        }

        // Soft delete - move to deleted projects view
        projectDAO.deleteProject(projectId, actorId);
        auditLogger.info("PROJECT_SOFT_DELETE", project.getName(), actorId);
    }

    @Override
    public List<ProjectVO> listDeletedProjects() {
        return projectDAO.selectDeletedProjects();
    }

    @Override
    @Transactional
    public void restoreProject(UUID projectId, UUID actorId) {
        // Restore project from deleted projects view
        projectDAO.restoreProject(projectId);
        auditLogger.info("PROJECT_RESTORE", "프로젝트 복원", actorId);
    }

    @Override
    @Transactional
    public void permanentlyDeleteProject(UUID projectId, UUID actorId) {
        // For permanent deletion, we need to get the project without the deleted_at filter
        // So we query directly using selectOne with a custom query or get from deleted list
        List<ProjectVO> deletedProjects = projectDAO.selectDeletedProjects();
        ProjectVO project = deletedProjects.stream()
            .filter(p -> p.getId().equals(projectId))
            .findFirst()
            .orElse(null);

        if (project == null) {
            throw new IllegalArgumentException("삭제된 프로젝트를 찾을 수 없습니다.");
        }

        // Delete from ODK Central if it exists
        if (project.getOdkProjectId() != null) {
            try {
                odkClient.deleteProject(project.getOdkProjectId());
                log.info("Successfully deleted ODK project: {}", project.getOdkProjectId());
            } catch (Exception e) {
                log.error("Failed to delete ODK project {}: {}", project.getOdkProjectId(), e.getMessage(), e);
                // Rollback the transaction to prevent database deletion if ODK deletion fails
                throw new RuntimeException("ODK Central 프로젝트 삭제 실패: " + e.getMessage() +
                    ". 프로젝트를 영구 삭제하려면 먼저 ODK Central에서 수동으로 삭제해주세요.", e);
            }
        }

        // Permanently delete from database
        projectDAO.permanentlyDeleteProject(projectId);
        auditLogger.info("PROJECT_PERMANENT_DELETE", project.getName(), actorId);
    }

    @Override
    public List<FormTemplateVO> listTemplates() {
        return projectDAO.selectFormTemplates();
    }

    private void cleanupOdkProject(Long odkProjectId) {
        if (odkProjectId == null) {
            return;
        }
        try {
            odkClient.deleteProject(odkProjectId);
        } catch (Exception cleanupEx) {
            log.warn("Failed to clean up ODK project {} after error: {}", odkProjectId, cleanupEx.getMessage(), cleanupEx);
        }
    }

    private void cleanupPortalProject(UUID projectId) {
        if (projectId == null) {
            return;
        }
        try {
            projectDAO.permanentlyDeleteProject(projectId);
        } catch (Exception cleanupEx) {
            log.warn("Failed to clean up portal project {} after error: {}", projectId, cleanupEx.getMessage(), cleanupEx);
        }
    }

    private String slug(String name) {
        if (name == null || name.isEmpty()) {
            return "form";
        }
        return name.toLowerCase().replaceAll("[^a-z0-9]+", "-");
    }
}
