package egovframework.govportal.auth.web;

import egovframework.govportal.auth.service.AccountRecoveryService;
import egovframework.govportal.auth.service.ContactVerificationService;
import egovframework.govportal.auth.service.ContactVerificationService.VerificationType;
import egovframework.govportal.cmmn.exception.ValidationException;
import egovframework.govportal.rbac.model.UserVO;
import egovframework.govportal.rbac.service.RbacService;
import lombok.Data;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.annotation.Resource;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@Controller
@RequestMapping("/auth/recover")
public class AccountRecoveryController {

    @Resource
    private RbacService rbacService;
    @Resource
    private ContactVerificationService verificationService;
    @Resource
    private AccountRecoveryService accountRecoveryService;

    @RequestMapping(value = "/id.do", method = RequestMethod.GET)
    public String recoverIdForm(ModelMap model) {
        if (!model.containsAttribute("idForm")) {
            model.addAttribute("idForm", new IdRecoveryForm());
        }
        return "auth/recover-id";
    }

    @RequestMapping(value = "/id.do", method = RequestMethod.POST)
    public String recoverId(@ModelAttribute("idForm") IdRecoveryForm form,
                            BindingResult bindingResult,
                            ModelMap model) {
        validateCommonIdFields(form, bindingResult);
        if (!verificationService.verify(VerificationType.EMAIL, form.getEmail(), form.getEmailVerificationCode())) {
            bindingResult.rejectValue("emailVerificationCode", "email.code.invalid", "이메일 인증 코드를 다시 확인해주세요.");
        }
        if (bindingResult.hasErrors()) {
            model.addAttribute("errorMessage", "입력값을 다시 확인해주세요.");
            return "auth/recover-id";
        }

        // AccountRecoveryService를 사용하여 아이디 찾기
        String username = accountRecoveryService.findUsername(form.getFullName(), form.getEmail());

        if (username == null) {
            bindingResult.reject("recovery.failed", "입력하신 정보에 해당하는 계정을 찾을 수 없습니다.");
            model.addAttribute("errorMessage", "입력하신 정보에 해당하는 계정을 찾을 수 없습니다.");
            return "auth/recover-id";
        }

        verificationService.verifyAndConsume(VerificationType.EMAIL, form.getEmail(), form.getEmailVerificationCode());
        String masked = maskUsername(username);
        model.addAttribute("recoveredUsername", masked);
        model.addAttribute("successMessage", "계정 정보가 이메일로 전송되었습니다.");
        return "auth/recover-id";
    }

    @RequestMapping(value = "/password.do", method = RequestMethod.GET)
    public String recoverPasswordForm(ModelMap model) {
        if (!model.containsAttribute("passwordForm")) {
            model.addAttribute("passwordForm", new PasswordRecoveryForm());
        }
        return "auth/recover-password";
    }

    @RequestMapping(value = "/password.do", method = RequestMethod.POST)
    public String recoverPassword(@ModelAttribute("passwordForm") PasswordRecoveryForm form,
                                  BindingResult bindingResult,
                                  ModelMap model) {
        if (!StringUtils.hasText(form.getUsername())) {
            bindingResult.rejectValue("username", "username.required", "아이디를 입력해주세요.");
        }
        if (!StringUtils.hasText(form.getEmail())) {
            bindingResult.rejectValue("email", "email.required", "이메일을 입력해주세요.");
        }
        if (!StringUtils.hasText(form.getFullName())) {
            bindingResult.rejectValue("fullName", "name.required", "이름을 입력해주세요.");
        }
        if (form.getNewPassword() == null || form.getNewPassword().length() < 8) {
            bindingResult.rejectValue("newPassword", "password.short", "새 비밀번호는 8자 이상이어야 합니다.");
        }
        if (!form.getNewPassword().equals(form.getConfirmPassword())) {
            bindingResult.rejectValue("confirmPassword", "password.mismatch", "비밀번호 확인이 일치하지 않습니다.");
        }
        if (!verificationService.verify(VerificationType.EMAIL, form.getEmail(), form.getEmailVerificationCode())) {
            bindingResult.rejectValue("emailVerificationCode", "email.code.invalid", "이메일 인증 코드를 다시 확인해주세요.");
        }
        if (bindingResult.hasErrors()) {
            model.addAttribute("errorMessage", "입력값을 다시 확인해주세요.");
            return "auth/recover-password";
        }

        // AccountRecoveryService를 사용하여 비밀번호 재설정 토큰 요청
        String resetToken = accountRecoveryService.requestPasswordReset(
            form.getFullName(),
            form.getEmail(),
            form.getUsername()
        );

        if (resetToken == null) {
            bindingResult.reject("reset.failed", "입력하신 정보에 해당하는 계정을 찾을 수 없습니다.");
            model.addAttribute("errorMessage", "입력하신 정보에 해당하는 계정을 찾을 수 없습니다.");
            return "auth/recover-password";
        }

        // 즉시 비밀번호 재설정 실행
        boolean success = accountRecoveryService.resetPassword(resetToken, form.getNewPassword());

        if (success) {
            verificationService.verifyAndConsume(VerificationType.EMAIL, form.getEmail(), form.getEmailVerificationCode());
            model.addAttribute("successMessage", "비밀번호가 재설정되었습니다. 새로운 비밀번호로 로그인해주세요.");
        } else {
            bindingResult.reject("reset.failed", "비밀번호 재설정에 실패했습니다.");
            model.addAttribute("errorMessage", "비밀번호 재설정에 실패했습니다.");
        }

        return "auth/recover-password";
    }

    private void validateCommonIdFields(IdRecoveryForm form, BindingResult bindingResult) {
        if (!StringUtils.hasText(form.getFullName())) {
            bindingResult.rejectValue("fullName", "fullName.required", "이름을 입력해주세요.");
        }
        if (!StringUtils.hasText(form.getEmail())) {
            bindingResult.rejectValue("email", "email.required", "이메일을 입력해주세요.");
        }
    }

    private LocalDate parseBirthDate(String raw, BindingResult bindingResult, String field) {
        if (!StringUtils.hasText(raw)) {
            bindingResult.rejectValue(field, "birthDate.required", "생년월일을 입력해주세요.");
            return null;
        }
        try {
            return LocalDate.parse(raw);
        } catch (DateTimeParseException ex) {
            bindingResult.rejectValue(field, "birthDate.invalid", "생년월일 형식이 올바르지 않습니다.");
            return null;
        }
    }

    private String maskUsername(String username) {
        if (!StringUtils.hasText(username)) {
            return "";
        }
        if (username.length() <= 2) {
            return username.charAt(0) + "*";
        }
        return username.substring(0, 2) + "****";
    }

    @Data
    public static class IdRecoveryForm {
        @NotBlank
        private String fullName;
        @NotBlank
        private String email;
        private String emailVerificationCode;
    }

    @Data
    public static class PasswordRecoveryForm {
        @NotBlank
        private String fullName;
        @NotBlank
        private String username;
        @NotBlank
        private String email;
        @NotBlank
        private String newPassword;
        @NotBlank
        private String confirmPassword;
        private String emailVerificationCode;
    }
}
