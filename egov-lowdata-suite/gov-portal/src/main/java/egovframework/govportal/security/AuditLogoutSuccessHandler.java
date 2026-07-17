package egovframework.govportal.security;

import egovframework.govportal.cmmn.logging.AuditLogger;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.logout.SimpleUrlLogoutSuccessHandler;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

@Component("auditLogoutSuccessHandler")
public class AuditLogoutSuccessHandler extends SimpleUrlLogoutSuccessHandler {

    @Resource(name = "auditLogger")
    private AuditLogger auditLogger;

    public AuditLogoutSuccessHandler() {
        setDefaultTargetUrl("/login.do?logout");
    }

    @Override
    public void onLogoutSuccess(HttpServletRequest request, HttpServletResponse response,
                                Authentication authentication) throws IOException, ServletException {
        if (authentication != null) {
            UUID actorId = extractUserId(authentication);
            auditLogger.info("AUTH_LOGOUT", "로그아웃", actorId);
        }
        super.onLogoutSuccess(request, response, authentication);
    }

    private UUID extractUserId(Authentication authentication) {
        Object principal = authentication.getPrincipal();
        if (principal instanceof GovportalUserDetails) {
            return ((GovportalUserDetails) principal).getUserId();
        }
        return null;
    }
}
