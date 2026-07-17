package kr.go.dgif.govportal.domain.dao;

import java.time.Instant;
import java.util.UUID;

public interface SubmissionDao {
    void upsertRawSubmission(UUID projectId, UUID formId, String submissionId, String payload, Instant submittedAt);
}
