package egovframework.govportal.auth.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    private static final Logger logger = LoggerFactory.getLogger(EmailService.class);

    /**
     * 인증 코드 이메일 발송
     */
    public void sendVerificationCode(String email, String code) {
        // 실제 환경에서는 JavaMail API나 SendGrid, AWS SES 등을 사용
        logger.info("====================================");
        logger.info("📧 이메일 인증 코드 발송");
        logger.info("수신자: {}", email);
        logger.info("인증 코드: {}", code);
        logger.info("유효 시간: 10분");
        logger.info("====================================");

        // TODO: 실제 이메일 발송 로직 구현
        // 예시:
        // MimeMessage message = mailSender.createMimeMessage();
        // MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
        // helper.setTo(email);
        // helper.setSubject("[LINC] 이메일 인증 코드");
        // helper.setText(buildVerificationEmail(code), true);
        // mailSender.send(message);
    }

    /**
     * 아이디 찾기 결과 이메일 발송
     */
    public void sendFoundUsername(String email, String username, String name) {
        logger.info("====================================");
        logger.info("📧 아이디 찾기 결과 발송");
        logger.info("수신자: {}", email);
        logger.info("이름: {}", name);
        logger.info("아이디: {}", username);
        logger.info("====================================");

        // TODO: 실제 이메일 발송
    }

    /**
     * 비밀번호 재설정 링크 이메일 발송
     */
    public void sendPasswordResetLink(String email, String resetToken, String username) {
        logger.info("====================================");
        logger.info("📧 비밀번호 재설정 링크 발송");
        logger.info("수신자: {}", email);
        logger.info("아이디: {}", username);
        logger.info("재설정 토큰: {}", resetToken);
        logger.info("유효 시간: 30분");
        logger.info("====================================");

        // TODO: 실제 이메일 발송
    }

    /**
     * 비밀번호 재설정 완료 알림
     */
    public void sendPasswordResetConfirmation(String email, String username) {
        logger.info("====================================");
        logger.info("📧 비밀번호 재설정 완료 알림");
        logger.info("수신자: {}", email);
        logger.info("아이디: {}", username);
        logger.info("====================================");

        // TODO: 실제 이메일 발송
    }

    private String buildVerificationEmail(String code) {
        return String.format(
            "<html><body>" +
            "<h2>LINC 이메일 인증</h2>" +
            "<p>아래 인증 코드를 입력해주세요:</p>" +
            "<h1 style='color: #1d4f91; letter-spacing: 5px;'>%s</h1>" +
            "<p>이 코드는 10분간 유효합니다.</p>" +
            "</body></html>",
            code
        );
    }
}
