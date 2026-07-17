package kr.go.dgif.govportal.domain.dao;

import kr.go.dgif.govportal.domain.entity.Form;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Repository
public class JdbcFormDao implements FormDao {

    private final JdbcTemplate jdbcTemplate;

    public JdbcFormDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<Form> findByProjectId(UUID projectId) {
        String sql = "SELECT id, project_id, xml_form_id, name, created_at FROM forms WHERE project_id = ?";
        return jdbcTemplate.query(sql, new FormRowMapper(), projectId);
    }

    private static class FormRowMapper implements RowMapper<Form> {
        @Override
        public Form mapRow(ResultSet rs, int rowNum) throws SQLException {
            Form form = new Form();
            form.setId((UUID) rs.getObject("id"));
            form.setProjectId((UUID) rs.getObject("project_id"));
            form.setXmlFormId(rs.getString("xml_form_id"));
            form.setName(rs.getString("name"));
            form.setCreatedAt(toInstant(rs.getTimestamp("created_at")));
            return form;
        }

        private Instant toInstant(Timestamp timestamp) {
            return timestamp == null ? null : timestamp.toInstant();
        }
    }
}
