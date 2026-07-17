package egovframework.govportal.auth.service;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class ContactVerificationService {

    private static final int EXPIRY_MINUTES = 10;

    private final Map<String, VerificationToken> tokens = new ConcurrentHashMap<>();

    public VerificationToken issueToken(VerificationType type, String target) {
        String normalized = normalizeTarget(type, target);
        if (!StringUtils.hasText(normalized)) {
            throw new IllegalArgumentException("대상 정보가 올바르지 않습니다.");
        }
        String code = String.format("%06d", ThreadLocalRandom.current().nextInt(0, 1_000_000));
        VerificationToken token = new VerificationToken(code, LocalDateTime.now().plusMinutes(EXPIRY_MINUTES));
        tokens.put(buildKey(type, normalized), token);
        return token;
    }

    public boolean verify(VerificationType type, String target, String code) {
        return verifyInternal(type, target, code, false);
    }

    public boolean verifyAndConsume(VerificationType type, String target, String code) {
        return verifyInternal(type, target, code, true);
    }

    public boolean isVerified(VerificationType type, String target) {
        String normalized = normalizeTarget(type, target);
        VerificationToken token = tokens.get(buildKey(type, normalized));
        return token != null && token.getExpiresAt().isAfter(LocalDateTime.now());
    }

    private boolean verifyInternal(VerificationType type, String target, String code, boolean consume) {
        String normalized = normalizeTarget(type, target);
        if (!StringUtils.hasText(normalized) || !StringUtils.hasText(code)) {
            return false;
        }
        String key = buildKey(type, normalized);
        VerificationToken token = tokens.get(key);
        if (token == null || token.getExpiresAt().isBefore(LocalDateTime.now())) {
            tokens.remove(key);
            return false;
        }
        if (!Objects.equals(token.getCode(), code.trim())) {
            return false;
        }
        if (consume) {
            tokens.remove(key);
        }
        return true;
    }

    private String normalizeTarget(VerificationType type, String target) {
        if (!StringUtils.hasText(target)) {
            return null;
        }
        String trimmed = target.trim();
        if (type == VerificationType.EMAIL) {
            return trimmed.toLowerCase();
        }
        return trimmed.replaceAll("[^0-9+]", "");
    }

    private String buildKey(VerificationType type, String normalized) {
        return type.name() + ":" + normalized;
    }

    public enum VerificationType {
        EMAIL,
        PHONE
    }

    public static class VerificationToken {
        private final String code;
        private final LocalDateTime expiresAt;

        public VerificationToken(String code, LocalDateTime expiresAt) {
            this.code = code;
            this.expiresAt = expiresAt;
        }

        public String getCode() {
            return code;
        }

        public LocalDateTime getExpiresAt() {
            return expiresAt;
        }
    }
}
