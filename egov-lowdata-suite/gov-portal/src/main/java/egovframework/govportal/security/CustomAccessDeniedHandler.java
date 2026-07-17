package egovframework.govportal.security;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@Component("customAccessDeniedHandler")
public class CustomAccessDeniedHandler implements AccessDeniedHandler {

    private static final Logger logger = LoggerFactory.getLogger(CustomAccessDeniedHandler.class);

    @Override
    public void handle(HttpServletRequest request, HttpServletResponse response,
                       AccessDeniedException accessDeniedException) throws IOException, ServletException {
        
        logger.warn("Access denied for user: {} on path: {}", 
                    request.getRemoteUser(), request.getRequestURI());
        
        // 세션에 에러 메시지 저장
        HttpSession session = request.getSession();
        session.setAttribute("accessDeniedMessage", "접근 권한이 없습니다. 관리자에게 문의하세요.");
        
        // 대시보드로 리다이렉트
        response.sendRedirect(request.getContextPath() + "/dashboard.do?error=access_denied");
    }
}
