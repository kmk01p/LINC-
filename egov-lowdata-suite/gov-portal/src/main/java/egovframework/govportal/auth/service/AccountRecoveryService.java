package egovframework.govportal.auth.service;

import egovframework.govportal.auth.dao.AccountRecoveryDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AccountRecoveryService {

    private static final Logger logger = LoggerFactory.getLogger(AccountRecoveryService.class);
    private static final int RESET_TOKEN_EXPIRY_MINUTES = 30;

    @Autowired
    private AccountRecoveryDAO accountRecoveryDAO;

    @Autowired
    private EmailService emailService;

    @Autowired
    private ContactVerificationService verificationService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // 비밀번호 재설정 토큰 저장소
    private final Map<String, PasswordResetToken> resetTokens = new ConcurrentHashMap<>();

    /**
     * 아이디 찾기: 이름과 이메일로 사용자 조회
     */
    public String findUsername(String name, String email) {
        logger.info("아이디 찾기 요청 - 이름: {}, 이메일: {}", name, email);

        String username = accountRecoveryDAO.findUsernameByNameAndEmail(name, email);

        if (username != null) {
            // 이메일로 아이디 전송
            emailService.sendFoundUsername(email, username, name);
            logger.info("아이디 찾기 성공 - 아이디: {}", username);
            return username;
        }

        logger.warn("아이디 찾기 실패 - 일치하는 사용자 없음");
        return null;
    }

    /**
     * 비밀번호 재설정 요청: 이름, 이메일, 아이디로 확인 후 재설정 토큰 발급
     */
    public String requestPasswordReset(String name, String email, String username) {
        logger.info("비밀번호 재설정 요청 - 이름: {}, 이메일: {}, 아이디: {}", name, email, username);

        // 사용자 확인
        boolean userExists = accountRecoveryDAO.verifyUserByNameEmailUsername(name, email, username);

        if (!userExists) {
            logger.warn("비밀번호 재설정 실패 - 일치하는 사용자 없음");
            return null;
        }

        // 재설정 토큰 생성
        String resetToken = UUID.randomUUID().toString();
        PasswordResetToken token = new PasswordResetToken(
            username,
            LocalDateTime.now().plusMinutes(RESET_TOKEN_EXPIRY_MINUTES)
        );
        resetTokens.put(resetToken, token);

        // 이메일로 재설정 링크 전송
        emailService.sendPasswordResetLink(email, resetToken, username);
        logger.info("비밀번호 재설정 토큰 발급 - 토큰: {}", resetToken);

        return resetToken;
    }

    /**
     * 비밀번호 재설정 토큰 검증
     */
    public boolean validateResetToken(String token) {
        PasswordResetToken resetToken = resetTokens.get(token);

        if (resetToken == null) {
            return false;
        }

        if (resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            resetTokens.remove(token);
            return false;
        }

        return true;
    }

    /**
     * 비밀번호 재설정 실행
     */
    public boolean resetPassword(String token, String newPassword) {
        PasswordResetToken resetToken = resetTokens.get(token);

        if (resetToken == null || resetToken.getExpiresAt().isBefore(LocalDateTime.now())) {
            logger.warn("비밀번호 재설정 실패 - 유효하지 않은 토큰");
            resetTokens.remove(token);
            return false;
        }

        String username = resetToken.getUsername();
        String encodedPassword = passwordEncoder.encode(newPassword);

        // 비밀번호 업데이트
        int updated = accountRecoveryDAO.updatePassword(username, encodedPassword);

        if (updated > 0) {
            // 토큰 삭제
            resetTokens.remove(token);

            // 이메일로 완료 알림
            String email = accountRecoveryDAO.findEmailByUsername(username);
            if (email != null) {
                emailService.sendPasswordResetConfirmation(email, username);
            }

            logger.info("비밀번호 재설정 완료 - 아이디: {}", username);
            return true;
        }

        return false;
    }

    public static class PasswordResetToken {
        private final String username;
        private final LocalDateTime expiresAt;

        public PasswordResetToken(String username, LocalDateTime expiresAt) {
            this.username = username;
            this.expiresAt = expiresAt;
        }

        public String getUsername() {
            return username;
        }

        public LocalDateTime getExpiresAt() {
            return expiresAt;
        }
    }
}
