package egovframework.govportal.cmmn.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger LOGGER = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(ValidationException.class)
    public ResponseEntity<Map<String, Object>> handleValidation(ValidationException ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("code", ex.getCode());
        body.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(body);
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<Map<String, Object>> handleBusiness(BusinessException ex) {
        Map<String, Object> body = new HashMap<>();
        body.put("code", ex.getCode());
        body.put("message", ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(body);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public String handleAccessDenied(AccessDeniedException ex,
                                      javax.servlet.http.HttpServletRequest request,
                                      javax.servlet.http.HttpServletResponse response) {
        LOGGER.warn("Access denied: {}", ex.getMessage());

        // API 요청인 경우 (Accept 헤더 확인)
        String acceptHeader = request.getHeader("Accept");
        if (acceptHeader != null && acceptHeader.contains("application/json")) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }

        // 웹 페이지 요청인 경우 대시보드로 리다이렉트
        request.getSession().setAttribute("accessDeniedMessage", "접근 권한이 없습니다. 관리자에게 문의하세요.");
        return "redirect:/dashboard.do?error=access_denied";
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, Object>> handleUnknown(Exception ex) {
        // Don't catch security exceptions
        if (ex instanceof org.springframework.security.core.AuthenticationException) {
            throw (org.springframework.security.core.AuthenticationException) ex;
        }

        LOGGER.error("Unhandled exception", ex);
        Map<String, Object> body = new HashMap<>();
        body.put("code", "UNEXPECTED_ERROR");
        body.put("message", "시스템 오류가 발생했습니다.");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
