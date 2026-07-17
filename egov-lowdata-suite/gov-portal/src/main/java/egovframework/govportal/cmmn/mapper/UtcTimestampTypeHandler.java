package egovframework.govportal.cmmn.mapper;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

/**
 * DB의 timestamp WITHOUT TIME ZONE 값을 UTC 기준 LocalDateTime으로 변환합니다.
 */
public class UtcTimestampTypeHandler extends BaseTypeHandler<LocalDateTime> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, LocalDateTime parameter, JdbcType jdbcType)
            throws SQLException {
        ps.setTimestamp(i, Timestamp.from(parameter.toInstant(ZoneOffset.UTC)));
    }

    @Override
    public LocalDateTime getNullableResult(ResultSet rs, String columnName) throws SQLException {
        Timestamp ts = rs.getTimestamp(columnName);
        return fromTimestamp(ts);
    }

    @Override
    public LocalDateTime getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        Timestamp ts = rs.getTimestamp(columnIndex);
        return fromTimestamp(ts);
    }

    @Override
    public LocalDateTime getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        Timestamp ts = cs.getTimestamp(columnIndex);
        return fromTimestamp(ts);
    }

    private LocalDateTime fromTimestamp(Timestamp ts) {
        if (ts == null) {
            return null;
        }
        Instant instant = ts.toInstant();
        return LocalDateTime.ofInstant(instant, ZoneOffset.UTC);
    }
}
