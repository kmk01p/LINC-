package egovframework.govportal.adapters.sidecar;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import egovframework.govportal.cmmn.exception.BusinessException;
import egovframework.govportal.cmmn.exception.ValidationException;
import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.annotation.Resource;
import java.util.Collections;
import java.util.Map;

@Component("xlsformClient")
public class XlsformClient {

    private static final Logger LOGGER = LoggerFactory.getLogger(XlsformClient.class);
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final TypeReference<Map<String, Object>> MAP_REFERENCE =
        new TypeReference<Map<String, Object>>() {};

    @Resource(name = "restTemplate")
    private RestTemplate restTemplate;

    @Resource(name = "propertyConfigurer")
    private EgovPropertyService propertyService;

    public byte[] generateXlsform(String jsonSpec) {
        if (jsonSpec == null || jsonSpec.isEmpty()) {
            throw new ValidationException("폼 템플릿 JSON이 비어있습니다.");
        }

        Map<String, Object> spec = parseSpec(jsonSpec);
        String baseUrl = resolve(propertyService.getString("Globals.Sidecar.BaseUrl"));
        String url = baseUrl + "/generate";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setAccept(Collections.singletonList(MediaType.APPLICATION_OCTET_STREAM));

        try {
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(spec, headers);
            ResponseEntity<byte[]> response = restTemplate.postForEntity(url, entity, byte[].class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new BusinessException("SIDECAR_ERROR",
                    "XLSForm 생성을 실패했습니다. 상태코드: " + response.getStatusCode());
            }
            return response.getBody();
        } catch (BusinessException ex) {
            throw ex;
        } catch (Exception ex) {
            LOGGER.error("Failed to call XLSForm sidecar", ex);
            throw new BusinessException("SIDECAR_ERROR", "XLSForm 변환 중 오류가 발생했습니다.");
        }
    }

    public String preview(String jsonSpec) {
        byte[] bytes = generateXlsform(jsonSpec);
        return "Generated " + bytes.length + " bytes XLSX";
    }

    private Map<String, Object> parseSpec(String jsonSpec) {
        try {
            Map<String, Object> spec = OBJECT_MAPPER.readValue(jsonSpec, MAP_REFERENCE);
            if (spec == null || !spec.containsKey("fields")) {
                throw new ValidationException("폼 템플릿 JSON에 fields 배열이 필요합니다.");
            }
            return spec;
        } catch (ValidationException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new ValidationException("폼 템플릿 JSON 파싱에 실패했습니다.");
        }
    }

    private String resolve(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        if (trimmed.startsWith("${") && trimmed.endsWith("}")) {
            String inner = trimmed.substring(2, trimmed.length() - 1);
            int colonIndex = inner.indexOf(':');
            String envKey = colonIndex >= 0 ? inner.substring(0, colonIndex) : inner;
            String defaultValue = colonIndex >= 0 ? inner.substring(colonIndex + 1) : "";
            String envValue = System.getenv(envKey);
            if (envValue == null || envValue.isEmpty()) {
                envValue = System.getProperty(envKey);
            }
            return (envValue != null && !envValue.isEmpty()) ? envValue : defaultValue;
        }
        return value;
    }
}
