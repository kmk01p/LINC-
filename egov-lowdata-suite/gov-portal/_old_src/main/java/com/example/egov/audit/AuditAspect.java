package com.example.egov.audit;

import com.example.egov.domain.User;
import com.example.egov.domain.dao.AuditLogRepository;
import com.example.egov.domain.dao.UserRepository;
import com.example.egov.domain.AuditLog;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.time.Instant;

@Aspect
@Component
public class AuditAspect {
    private static final Logger log = LoggerFactory.getLogger(AuditAspect.class);
    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    public AuditAspect(AuditLogRepository auditLogRepository, UserRepository userRepository) {
        this.auditLogRepository = auditLogRepository;
        this.userRepository = userRepository;
    }

    @Around("@annotation(com.example.egov.audit.Auditable)")
    public Object aroundAuditable(ProceedingJoinPoint joinPoint) throws Throwable {
        Method method = ((MethodSignature) joinPoint.getSignature()).getMethod();
        Auditable auditable = method.getAnnotation(Auditable.class);
        String action = auditable.action();
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String username = auth != null ? auth.getName() : "anonymous";
        Object result;
        try {
            result = joinPoint.proceed();
            audit("SUCCESS", username, action);
        } catch (Throwable ex) {
            audit("ERROR", username, action + ": " + ex.getMessage());
            throw ex;
        }
        return result;
    }

    private void audit(String status, String username, String message) {
        // Persist audit log
        AuditLog logEntity = new AuditLog();
        logEntity.setAction(status);
        logEntity.setMessage(username + ": " + message);
        logEntity.setCreatedAt(Instant.now());
        userRepository.findByUsername(username).ifPresent(u -> logEntity.setUserId(u.getId()));
        auditLogRepository.save(logEntity);
        log.info("[AUDIT] {} - {}", status, message);
    }
}