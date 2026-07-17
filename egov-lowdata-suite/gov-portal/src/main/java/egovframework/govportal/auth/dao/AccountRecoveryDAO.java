package egovframework.govportal.auth.dao;

import egovframework.govportal.cmmn.mapper.AbstractMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository("accountRecoveryDAO")
public class AccountRecoveryDAO extends AbstractMapper {

    private static final String NAMESPACE = "egovframework.govportal.auth.service.AccountRecoveryMapper.";

    public String findUsernameByNameAndEmail(String name, String email) {
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        params.put("email", email);
        return getSqlSession().selectOne(NAMESPACE + "findUsernameByNameAndEmail", params);
    }

    public boolean verifyUserByNameEmailUsername(String name, String email, String username) {
        Map<String, Object> params = new HashMap<>();
        params.put("name", name);
        params.put("email", email);
        params.put("username", username);
        Boolean result = getSqlSession().selectOne(NAMESPACE + "verifyUserByNameEmailUsername", params);
        return Boolean.TRUE.equals(result);
    }

    public int updatePassword(String username, String password) {
        Map<String, Object> params = new HashMap<>();
        params.put("username", username);
        params.put("password", password);
        return getSqlSession().update(NAMESPACE + "updatePassword", params);
    }

    public String findEmailByUsername(String username) {
        return getSqlSession().selectOne(NAMESPACE + "findEmailByUsername", username);
    }
}
