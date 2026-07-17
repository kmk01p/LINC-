package kr.go.dgif.govportal.domain.dao;

import kr.go.dgif.govportal.domain.entity.Project;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public class JdbcProjectDao implements ProjectDao {

    private static final String BASE_COLUMNS = "id, tenant_id, name, status, odk_project_id, odk_project_uuid, created_at, updated_at";

    private final JdbcTemplate jdbcTemplate;

    public JdbcProjectDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Project> findActiveProjects() {
        String sql = "SELECT " + BASE_COLUMNS + " FROM projects WHERE COALESCE(status, 'ACTIVE') = 'ACTIVE'";
        return jdbcTemplate.query(sql, new ProjectRowMapper());
    }

    @Override
    public Optional<Project> findById(UUID projectId) {
        String sql = "SELECT " + BASE_COLUMNS + " FROM projects WHERE id = ?";
        List<Project> projects = jdbcTemplate.query(sql, new ProjectRowMapper(), projectId);
        return projects.stream().findFirst();
    }

    @Override
    public void updateOdkProject(UUID projectId, Long odkProjectId, UUID odkProjectUuid) {
        String sql = "UPDATE projects SET odk_project_id = ?, odk_project_uuid = ?, updated_at = NOW() WHERE id = ?";
        jdbcTemplate.update(sql, odkProjectId, odkProjectUuid, projectId);
    }

    private static class ProjectRowMapper implements RowMapper<Project> {
        @Override
        public Project mapRow(ResultSet rs, int rowNum) throws SQLException {
            Project project = new Project();
            project.setId((UUID) rs.getObject("id"));
            project.setTenantId((UUID) rs.getObject("tenant_id"));
            project.setName(rs.getString("name"));
            project.setStatus(rs.getString("status"));
            Long odkProjectId = rs.getObject("odk_project_id") != null ? rs.getLong("odk_project_id") : null;
            project.setOdkProjectId(odkProjectId);
            project.setOdkProjectUuid((UUID) rs.getObject("odk_project_uuid"));
            project.setCreatedAt(toInstant(rs.getTimestamp("created_at")));
            project.setUpdatedAt(toInstant(rs.getTimestamp("updated_at")));
            return project;
        }

        private Instant toInstant(Timestamp timestamp) {
            return timestamp == null ? null : timestamp.toInstant();
        }
    }
}
