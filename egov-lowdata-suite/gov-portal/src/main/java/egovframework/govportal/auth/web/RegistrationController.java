package egovframework.govportal.auth.web;

import egovframework.govportal.auth.service.ContactVerificationService;
import egovframework.govportal.auth.service.ContactVerificationService.VerificationType;
import egovframework.govportal.cmmn.exception.ValidationException;
import egovframework.govportal.rbac.model.UserProfileVO;
import egovframework.govportal.rbac.model.UserVO;
import egovframework.govportal.rbac.service.RbacService;
import egovframework.govportal.security.GovportalUserDetails;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.annotation.Resource;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.Arrays;
import java.util.List;

@Controller
public class RegistrationController {

    @Resource(name = "rbacService")
    private RbacService rbacService;
    @Resource
    private ContactVerificationService verificationService;

    @RequestMapping(value = "/register.do", method = RequestMethod.GET)
    public String registerForm(ModelMap model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && authentication.getPrincipal() instanceof GovportalUserDetails) {
            return "redirect:/dashboard.do";
        }

        if (!model.containsAttribute("form")) {
            RegistrationForm form = new RegistrationForm();
            form.setGrade(5);
            model.addAttribute("form", form);
        }
        return "auth/register";
    }

    @RequestMapping(value = "/register.do", method = RequestMethod.POST)
    public String register(@ModelAttribute("form") RegistrationForm form,
                           BindingResult bindingResult,
                           ModelMap model,
                            RedirectAttributes redirectAttributes) {
        if (form.getPassword() == null || form.getPassword().length() < 8) {
            bindingResult.rejectValue("password", "password.tooShort", "비밀번호는 최소 8자 이상이어야 합니다.");
        }
        if (form.getConfirmPassword() == null || !form.getConfirmPassword().equals(form.getPassword())) {
            bindingResult.rejectValue("confirmPassword", "password.mismatch", "비밀번호 확인이 일치하지 않습니다.");
        }
        LocalDate birthDate = null;
        if (!hasText(form.getFullName())) {
            bindingResult.rejectValue("fullName", "fullName.required", "이름을 입력해주세요.");
        }
        if (!hasText(form.getEmail())) {
            bindingResult.rejectValue("email", "email.required", "이메일을 입력해주세요.");
        }
        if (!hasText(form.getPhoneNumber())) {
            bindingResult.rejectValue("phoneNumber", "phone.required", "연락처를 입력해주세요.");
        }
        if (hasText(form.getBirthDate())) {
            try {
                birthDate = LocalDate.parse(form.getBirthDate());
            } catch (DateTimeParseException ex) {
                bindingResult.rejectValue("birthDate", "birthDate.invalid", "생년월일 형식이 올바르지 않습니다.");
            }
        } else {
            bindingResult.rejectValue("birthDate", "birthDate.required", "생년월일을 입력해주세요.");
        }
        if (!verificationService.verify(VerificationType.EMAIL, form.getEmail(), form.getEmailVerificationCode())) {
            bindingResult.rejectValue("emailVerificationCode", "email.code.invalid", "이메일 인증 코드를 확인해주세요.");
        }
        if (!verificationService.verify(VerificationType.PHONE, form.getPhoneNumber(), form.getPhoneVerificationCode())) {
            bindingResult.rejectValue("phoneVerificationCode", "phone.code.invalid", "휴대폰 인증 코드를 확인해주세요.");
        }
        if (bindingResult.hasErrors()) {
            model.addAttribute("errorMessage", "입력값을 다시 확인해주세요.");
            return "auth/register";
        }

        int resolvedGrade = form.getGrade() != null ? form.getGrade() : 5;
        try {
            UserVO user = rbacService.registerUser(form.getUsername(), form.getPassword(), resolvedGrade);
            UserProfileVO profile = new UserProfileVO();
            profile.setUserId(user.getId());
            profile.setFullName(form.getFullName());
            profile.setEmail(form.getEmail());
            profile.setPhoneNumber(form.getPhoneNumber());
            profile.setBirthDate(birthDate);
            profile.setEmailVerified(true);
            profile.setPhoneVerified(true);
            profile.setLastVerifiedAt(LocalDateTime.now());
            rbacService.saveUserProfile(profile);
            verificationService.verifyAndConsume(VerificationType.EMAIL, form.getEmail(), form.getEmailVerificationCode());
            verificationService.verifyAndConsume(VerificationType.PHONE, form.getPhoneNumber(), form.getPhoneVerificationCode());
            redirectAttributes.addFlashAttribute("successMessage",
                    "회원가입이 완료되었습니다. 관리자 승인 후 서비스 이용이 가능합니다.");
            return "redirect:/login.do";
        } catch (ValidationException ex) {
            bindingResult.reject("registrationError", ex.getMessage());
            model.addAttribute("errorMessage", ex.getMessage());
            return "auth/register";
        } catch (Exception ex) {
            bindingResult.reject("registrationError", "회원가입 처리 중 오류가 발생했습니다.");
            model.addAttribute("errorMessage", "회원가입 처리 중 오류가 발생했습니다.");
            return "auth/register";
        }
    }

    @ModelAttribute("gradeOptions")
    public List<Integer> gradeOptions() {
        return Arrays.asList(4, 5);
    }

    private boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }

    public static class RegistrationForm {
        @NotBlank
        @Size(min = 4, max = 50)
        private String username;
        @NotBlank
        @Size(min = 8, max = 100)
        private String password;
        @NotBlank
        private String confirmPassword;
        private Integer grade;
        @NotBlank
        private String fullName;
        @NotBlank
        private String email;
        @NotBlank
        private String phoneNumber;
        @NotBlank
        private String birthDate;
        private String emailVerificationCode;
        private String phoneVerificationCode;

        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public String getConfirmPassword() {
            return confirmPassword;
        }

        public void setConfirmPassword(String confirmPassword) {
            this.confirmPassword = confirmPassword;
        }

        public Integer getGrade() {
            return grade;
        }

        public void setGrade(Integer grade) {
            this.grade = grade;
        }

        public String getFullName() {
            return fullName;
        }

        public void setFullName(String fullName) {
            this.fullName = fullName;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getPhoneNumber() {
            return phoneNumber;
        }

        public void setPhoneNumber(String phoneNumber) {
            this.phoneNumber = phoneNumber;
        }

        public String getBirthDate() {
            return birthDate;
        }

        public void setBirthDate(String birthDate) {
            this.birthDate = birthDate;
        }

        public String getEmailVerificationCode() {
            return emailVerificationCode;
        }

        public void setEmailVerificationCode(String emailVerificationCode) {
            this.emailVerificationCode = emailVerificationCode;
        }

        public String getPhoneVerificationCode() {
            return phoneVerificationCode;
        }

        public void setPhoneVerificationCode(String phoneVerificationCode) {
            this.phoneVerificationCode = phoneVerificationCode;
        }
    }
}
