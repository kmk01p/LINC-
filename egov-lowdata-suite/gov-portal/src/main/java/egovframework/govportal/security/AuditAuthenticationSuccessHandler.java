package egovframework.govportal.security;

import egovframework.govportal.cmmn.logging.AuditLogger;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

@Component("auditAuthenticationSuccessHandler")
public class AuditAuthenticationSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {

    @Resource(name = "auditLogger")
    private AuditLogger auditLogger;

    public AuditAuthenticationSuccessHandler() {
        setDefaultTargetUrl("/dashboard.do");
        setAlwaysUseDefaultTargetUrl(true);
    }

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                        Authentication authentication) throws ServletException, IOException {
        UUID actorId = extractUserId(authentication);
        auditLogger.info("AUTH_LOGIN", "로그인 성공", actorId);
        super.onAuthenticationSuccess(request, response, authentication);
    }

    private UUID extractUserId(Authentication authentication) {
        Object principal = authentication.getPrincipal();
        if (principal instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) principal).getUserId();
        }
        return null;
    }
}
