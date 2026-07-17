package kr.go.dgif.govportal.domain.dao;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.UUID;

@Repository
public class JdbcSubmissionDao implements SubmissionDao {

    private final JdbcTemplate jdbcTemplate;

    public JdbcSubmissionDao(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void upsertRawSubmission(UUID projectId, UUID formId, String submissionId, String payload, Instant submittedAt) {
        String sql = ""
            + "INSERT INTO submissions_raw (id, project_id, form_id, submission_id, payload, submitted_at, created_at, updated_at) "
            + "VALUES (gen_random_uuid(), ?, ?, ?, ?::jsonb, ?, NOW(), NOW()) "
            + "ON CONFLICT (submission_id) DO UPDATE "
            + "SET payload = EXCLUDED.payload, updated_at = NOW()";

        jdbcTemplate.update(sql,
            projectId,
            formId,
            submissionId,
            payload,
            submittedAt);
    }
}
