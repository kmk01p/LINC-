package kr.go.dgif.govportal.domain.dao;

import kr.go.dgif.govportal.domain.entity.Form;

import java.util.List;
import java.util.UUID;

public interface FormDao {
    List<Form> findByProjectId(UUID projectId);
}
