package egovframework.govportal.auth.web;

import egovframework.govportal.auth.service.ContactVerificationService;
import egovframework.govportal.auth.service.ContactVerificationService.VerificationToken;
import egovframework.govportal.auth.service.ContactVerificationService.VerificationType;
import egovframework.govportal.auth.service.EmailService;
import lombok.Data;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/auth/api/verification")
public class ContactVerificationController {

    @Resource
    private ContactVerificationService verificationService;

    @Resource
    private EmailService emailService;

    @PostMapping(value = "/request", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> requestCode(@RequestBody VerificationRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            VerificationType type = VerificationType.valueOf(request.getType().toUpperCase());
            VerificationToken token = verificationService.issueToken(type, request.getTarget());

            // 이메일인 경우 이메일 발송
            if (type == VerificationType.EMAIL) {
                emailService.sendVerificationCode(request.getTarget(), token.getCode());
            }

            response.put("success", true);
            response.put("message", "인증 코드가 발송되었습니다. 테스트 환경에서는 아래 코드를 직접 입력하세요.");
            response.put("code", token.getCode());
        } catch (Exception ex) {
            response.put("success", false);
            response.put("message", ex.getMessage() != null ? ex.getMessage() : "인증 코드를 생성할 수 없습니다.");
        }
        return response;
    }

    @PostMapping(value = "/confirm", consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    @ResponseBody
    public Map<String, Object> confirmCode(@RequestBody VerificationRequest request) {
        Map<String, Object> response = new HashMap<>();
        try {
            VerificationType type = VerificationType.valueOf(request.getType().toUpperCase());
            if (!StringUtils.hasText(request.getCode())) {
                response.put("success", false);
                response.put("message", "인증 코드를 입력해주세요.");
                return response;
            }
            boolean verified = verificationService.verify(type, request.getTarget(), request.getCode());
            response.put("success", verified);
            response.put("message", verified ? "인증이 완료되었습니다." : "인증 코드가 올바르지 않습니다.");
        } catch (Exception ex) {
            response.put("success", false);
            response.put("message", "인증 확인 중 오류가 발생했습니다.");
        }
        return response;
    }

    @Data
    private static class VerificationRequest {
        private String type;
        private String target;
        private String code;
    }
}
