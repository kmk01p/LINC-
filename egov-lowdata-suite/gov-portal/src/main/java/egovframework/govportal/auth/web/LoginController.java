package egovframework.govportal.auth.web;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    @RequestMapping(value = "/login.do", method = RequestMethod.GET)
    public String loginPage(@RequestParam(value = "error", required = false) String error,
                            @RequestParam(value = "logout", required = false) String logout,
                            ModelMap model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.isAuthenticated()
                && !(authentication.getPrincipal() instanceof String)) {
            return "redirect:/rbac/roles.do";
        }

        if (error != null) {
            model.addAttribute("errorMessage", "로그인에 실패했습니다. 사용자명 또는 비밀번호를 확인하세요.");
        }
        if (logout != null) {
            model.addAttribute("logoutMessage", "정상적으로 로그아웃되었습니다.");
        }
        return "auth/login";
    }
}
