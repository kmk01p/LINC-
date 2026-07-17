package egovframework.govportal.audit.dao;

import egovframework.govportal.audit.model.AuditLogVO;
import egovframework.govportal.cmmn.mapper.AbstractMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository("auditLogDAO")
public class AuditLogDAO extends AbstractMapper {

    private static final String NAMESPACE = "egovframework.govportal.audit.mapper.AuditLogMapper.";

    public void insertLog(AuditLogVO log) {
        getSqlSession().insert(NAMESPACE + "insertLog", log);
    }

    public List<AuditLogVO> selectRecentLogs(int limit, String severity, String keyword) {
        Map<String, Object> params = new HashMap<>();
        params.put("limit", limit > 0 ? limit : 200);
        params.put("severity", severity);
        params.put("keyword", keyword);
        return getSqlSession().selectList(NAMESPACE + "selectLogs", params);
    }
}
