package egovframework.govportal.cmmn.mapper;

import org.apache.ibatis.session.SqlSession;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * eGovFrame에서 권장하는 SqlSessionTemplate 기반 공통 DAO 추상 클래스입니다.
 * 하위 Mapper DAO에서 상속하여 사용합니다.
 */
public abstract class AbstractMapper {

    @Autowired
    private SqlSessionTemplate sqlSessionTemplate;

    protected SqlSession getSqlSession() {
        return sqlSessionTemplate;
    }
}
