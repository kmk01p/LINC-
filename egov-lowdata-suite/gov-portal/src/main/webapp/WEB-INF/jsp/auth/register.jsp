<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 - LINC 통합관리시스템</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"/>
    <style>
        :root {
            --un-blue: #009edb;
            --un-dark-blue: #1d4f91;
            --gov-navy: #1e3a5f;
            --gov-gold: #c9a961;
            --bg-soft: #f4f7fa;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            min-height: 100vh;
            background: var(--bg-soft);
            font-family: 'Segoe UI', 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        .layout {
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(320px, 480px) minmax(360px, 520px);
            justify-content: center;
            align-items: stretch;
            gap: 3rem;
            padding: 3rem clamp(1.5rem, 5vw, 6rem);
        }

        @media (max-width: 1024px) {
            .layout {
                grid-template-columns: 1fr;
                padding-top: 2.5rem;
            }
        }

        .hero-panel {
            position: relative;
            background: linear-gradient(135deg, rgba(0, 158, 219, 0.95) 0%, rgba(29, 79, 145, 0.95) 100%);
            border-radius: 24px;
            padding: 3rem 2.5rem;
            color: white;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .hero-panel::before {
            content: '';
            position: absolute;
            inset: 1.5rem;
            border-radius: 18px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            pointer-events: none;
        }

        .hero-panel .badge {
            background: rgba(255, 255, 255, 0.12);
            border-radius: 999px;
            padding: 0.35rem 1.25rem;
            font-size: 0.85rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            width: fit-content;
        }

        .hero-panel h1 {
            font-size: clamp(2rem, 3vw, 2.5rem);
            font-weight: 700;
            margin: 1.5rem 0 1rem;
            line-height: 1.3;
        }

        .hero-panel p {
            color: rgba(255, 255, 255, 0.85);
            font-size: 1rem;
            line-height: 1.7;
        }

        .hero-panel .feature-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1rem;
            margin-top: 2.5rem;
        }

        .hero-panel .feature-card {
            background: rgba(0, 0, 0, 0.15);
            border-radius: 16px;
            padding: 1rem 1.2rem;
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }

        .hero-panel .feature-card i {
            font-size: 1.4rem;
            color: var(--gov-gold);
        }

        .hero-panel .feature-card span {
            font-weight: 600;
        }

        .hero-panel .feature-card small {
            color: rgba(255, 255, 255, 0.75);
            line-height: 1.5;
        }

        .form-panel {
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .register-card {
            background: white;
            border-radius: 24px;
            padding: clamp(2.5rem, 5vw, 3.25rem);
            box-shadow: 0 20px 45px rgba(15, 49, 96, 0.12);
            border: 1px solid rgba(0, 0, 0, 0.04);
        }

        .register-card h2 {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--gov-navy);
            margin-bottom: 0.75rem;
        }

        .register-card p.subtitle {
            color: #6c757d;
            margin-bottom: 2.25rem;
        }

        .alert {
            border-radius: 12px;
            border: none;
            margin-bottom: 1.5rem;
            padding: 0.85rem 1.1rem;
        }

        .form-floating > label {
            color: #6c757d;
        }

        .form-floating > .form-control {
            border-radius: 12px;
            border: 1.5px solid #e1e6ef;
            background: #f8fafc;
            padding: 1.05rem 1rem;
            height: auto;
        }

        .form-floating > .form-control:focus {
            border-color: var(--un-blue);
            box-shadow: 0 0 0 0.25rem rgba(0, 158, 219, 0.12);
            background: white;
        }

        .verification-field {
            margin-bottom: 1.25rem;
        }

        .verification-field label {
            font-weight: 600;
            color: #344767;
            margin-bottom: 0.35rem;
        }

        .verification-field .input-group > .form-control {
            border-top-right-radius: 0;
            border-bottom-right-radius: 0;
        }

        .verification-field .input-group > .btn {
            border-top-left-radius: 0;
            border-bottom-left-radius: 0;
            font-weight: 600;
        }

        .verification-feedback {
            font-size: 0.85rem;
            margin-top: 0.3rem;
            min-height: 1.1rem;
        }

        .verification-feedback.success {
            color: #0f766e;
        }

        .verification-feedback.error {
            color: #c0392b;
        }

        .grade-row {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            margin: 1.25rem 0 1.75rem;
        }

        .grade-option {
            flex: 1 1 45%;
            min-width: 140px;
        }

        .grade-option input {
            display: none;
        }

        .grade-option label {
            display: block;
            background: #f0f4fb;
            border: 1.5px solid #dde3ee;
            border-radius: 16px;
            padding: 1rem;
            text-align: center;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.25s ease;
        }

        .grade-option label span {
            display: block;
            color: #6c757d;
            font-weight: 500;
            margin-top: 0.25rem;
            font-size: 0.9rem;
        }

        .grade-option input:checked + label {
            background: linear-gradient(135deg, rgba(0, 158, 219, 0.15) 0%, rgba(29, 79, 145, 0.15) 100%);
            border-color: var(--un-blue);
            color: var(--gov-navy);
            box-shadow: 0 10px 25px rgba(0, 158, 219, 0.2);
        }

        .register-button {
            width: 100%;
            background: linear-gradient(135deg, var(--un-blue) 0%, var(--un-dark-blue) 100%);
            border: none;
            color: white;
            font-weight: 600;
            padding: 1.05rem;
            border-radius: 14px;
            margin-top: 1rem;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
            box-shadow: 0 12px 24px rgba(0, 158, 219, 0.25);
        }

        .register-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 18px 30px rgba(0, 158, 219, 0.3);
        }

        .login-link {
            text-align: center;
            margin-top: 1.5rem;
            color: #6c757d;
        }

        .login-link a {
            color: var(--un-dark-blue);
            font-weight: 600;
            text-decoration: none;
        }

        .login-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
<div class="layout">
    <section class="hero-panel">
        <div>
            <div class="badge">
                <i class="bi bi-stars"></i>
                LINC Governance
            </div>
            <h1>국제협력 프로젝트<br/>안전한 데이터 거버넌스</h1>
            <p>
                대민 서비스, 현장 조사, 정기 보고 등 다양한 협력 과제를
                하나의 플랫폼에서 관리하세요. 표준화된 권한 체계와 감사를 통해
                모든 데이터를 안전하게 보호합니다.
            </p>
        </div>
        <div class="feature-grid">
            <div class="feature-card">
                <i class="bi bi-shield-lock"></i>
                <span>정교한 권한 제어</span>
                <small>역할 기반 접근 제어와 행위 감사를 통해
                    조직 단위의 보안 정책을 준수합니다.</small>
            </div>
            <div class="feature-card">
                <i class="bi bi-graph-up"></i>
                <span>실시간 현황 파악</span>
                <small>Metabase 연동으로 프로젝트 지표와 품질 현황을
                    직관적으로 모니터링합니다.</small>
            </div>
        </div>
    </section>

    <section class="form-panel">
        <div class="register-card">
            <h2>회원가입</h2>
            <p class="subtitle">기본 정보를 입력하면 관리자 승인 후 서비스 이용이 가능합니다.</p>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i> ${errorMessage}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register.do" method="post">
                <div class="form-floating mb-3">
                    <input type="text"
                           class="form-control"
                           id="username"
                           name="username"
                           placeholder="아이디"
                           value="${form.username}"
                           required
                           minlength="4"
                           maxlength="50">
                    <label for="username"><i class="bi bi-person-badge"></i> 사용자 아이디</label>
                </div>

                <div class="form-floating mb-3">
                    <input type="password"
                           class="form-control"
                           id="password"
                           name="password"
                           placeholder="비밀번호"
                           required
                           minlength="8">
                    <label for="password"><i class="bi bi-lock"></i> 비밀번호</label>
                </div>

                <div class="form-floating mb-3">
                    <input type="password"
                           class="form-control"
                           id="confirmPassword"
                           name="confirmPassword"
                           placeholder="비밀번호 확인"
                           required
                           minlength="8">
                    <label for="confirmPassword"><i class="bi bi-lock-fill"></i> 비밀번호 확인</label>
                </div>

                <div class="form-floating mb-3">
                    <input type="text"
                           class="form-control"
                           id="fullName"
                           name="fullName"
                           placeholder="이름"
                           value="${form.fullName}"
                           required>
                    <label for="fullName"><i class="bi bi-person-lines-fill"></i> 이름</label>
                </div>

                <div class="form-floating mb-3">
                    <input type="date"
                           class="form-control"
                           id="birthDate"
                           name="birthDate"
                           value="${form.birthDate}"
                           required>
                    <label for="birthDate"><i class="bi bi-calendar-heart"></i> 생년월일</label>
                </div>

                <div class="verification-field">
                    <label for="email">이메일 주소</label>
                    <div class="input-group">
                        <input type="email"
                               class="form-control"
                               id="email"
                               name="email"
                               placeholder="user@example.com"
                               value="${form.email}"
                               autocomplete="email"
                               required>
                        <button type="button"
                                class="btn btn-outline-primary"
                                data-verify-action="send"
                                data-verify-type="EMAIL"
                                data-target-input="email"
                                data-feedback="emailFeedback">
                            인증코드 발송
                        </button>
                    </div>
                    <div class="input-group mt-2">
                        <input type="text"
                               class="form-control"
                               id="emailVerificationCode"
                               name="emailVerificationCode"
                               placeholder="6자리 인증코드"
                               value="${form.emailVerificationCode}"
                               maxlength="6"
                               autocomplete="one-time-code"
                               required>
                        <button type="button"
                                class="btn btn-outline-success"
                                data-verify-action="confirm"
                                data-verify-type="EMAIL"
                                data-target-input="email"
                                data-code-input="emailVerificationCode"
                                data-feedback="emailFeedback">
                            인증 확인
                        </button>
                    </div>
                    <div class="verification-feedback" id="emailFeedback"></div>
                </div>

                <div class="verification-field">
                    <label for="phoneNumber">휴대폰 번호</label>
                    <div class="input-group">
                        <input type="tel"
                               class="form-control"
                               id="phoneNumber"
                               name="phoneNumber"
                               placeholder="01012345678"
                               value="${form.phoneNumber}"
                               inputmode="tel"
                               required>
                        <button type="button"
                                class="btn btn-outline-primary"
                                data-verify-action="send"
                                data-verify-type="PHONE"
                                data-target-input="phoneNumber"
                                data-feedback="phoneFeedback">
                            인증코드 발송
                        </button>
                    </div>
                    <div class="input-group mt-2">
                        <input type="text"
                               class="form-control"
                               id="phoneVerificationCode"
                               name="phoneVerificationCode"
                               placeholder="6자리 인증코드"
                               value="${form.phoneVerificationCode}"
                               maxlength="6"
                               inputmode="numeric"
                               required>
                        <button type="button"
                                class="btn btn-outline-success"
                                data-verify-action="confirm"
                                data-verify-type="PHONE"
                                data-target-input="phoneNumber"
                                data-code-input="phoneVerificationCode"
                                data-feedback="phoneFeedback">
                            인증 확인
                        </button>
                    </div>
                    <div class="verification-feedback" id="phoneFeedback"></div>
                </div>

                <div>
                    <label class="form-label fw-semibold text-muted">
                        <i class="bi bi-person-check"></i> 직급 선택
                    </label>
                    <div class="grade-row">
                        <c:forEach var="grade" items="${gradeOptions}">
                            <div class="grade-option">
                                <input type="radio"
                                       name="grade"
                                       id="grade-${grade}"
                                       value="${grade}"
                                       <c:if test="${form.grade == grade || (empty form.grade && grade == 5)}">checked</c:if>>
                                <label for="grade-${grade}">
                                    ${grade}급 담당자
                                    <span>
                                        <c:choose>
                                            <c:when test="${grade == 4}">프로젝트 관리 및 데이터 제출 승인</c:when>
                                            <c:otherwise>현장 데이터 검토 및 보고</c:otherwise>
                                        </c:choose>
                                    </span>
                                </label>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <button class="register-button" type="submit">
                    <i class="bi bi-check-circle-fill"></i> 회원가입 완료
                </button>
            </form>

            <div class="login-link">
                이미 계정이 있으신가요?
                <a href="${pageContext.request.contextPath}/login.do">로그인하기</a>
            </div>
        </div>
    </section>
</div>
<script>
    (function() {
        const contextPath = '${pageContext.request.contextPath}';
        const requestUrl = contextPath + '/auth/api/verification/request';
        const confirmUrl = contextPath + '/auth/api/verification/confirm';

        function getInput(id) {
            return document.getElementById(id);
        }

        function updateFeedback(id, message, type) {
            const node = document.getElementById(id);
            if (!node) return;
            node.textContent = message || '';
            node.classList.remove('success', 'error');
            if (type) {
                node.classList.add(type);
            }
        }

        function sendRequest(url, payload) {
            return fetch(url, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            }).then(resp => resp.json());
        }

        document.querySelectorAll('[data-verify-action]').forEach(button => {
            button.addEventListener('click', () => {
                const action = button.getAttribute('data-verify-action');
                const type = button.getAttribute('data-verify-type');
                const targetId = button.getAttribute('data-target-input');
                const feedbackId = button.getAttribute('data-feedback');
                const codeId = button.getAttribute('data-code-input');
                const targetInput = getInput(targetId);
                if (!targetInput || !targetInput.value.trim()) {
                    updateFeedback(feedbackId, '먼저 정보를 입력해주세요.', 'error');
                    targetInput && targetInput.focus();
                    return;
                }
                const payload = {
                    type,
                    target: targetInput.value.trim()
                };

                if (action === 'send') {
                    sendRequest(requestUrl, payload)
                        .then(data => {
                            const message = data.success
                                ? (data.message + (data.code ? ` (코드: ${data.code})` : ''))
                                : (data.message || '코드를 발송할 수 없습니다.');
                            updateFeedback(feedbackId, message, data.success ? 'success' : 'error');
                        })
                        .catch(() => updateFeedback(feedbackId, '네트워크 오류가 발생했습니다.', 'error'));
                } else if (action === 'confirm') {
                    const codeInput = getInput(codeId);
                    payload.code = codeInput ? codeInput.value.trim() : '';
                    if (!payload.code) {
                        updateFeedback(feedbackId, '인증 코드를 입력해주세요.', 'error');
                        codeInput && codeInput.focus();
                        return;
                    }
                    sendRequest(confirmUrl, payload)
                        .then(data => updateFeedback(feedbackId, data.message, data.success ? 'success' : 'error'))
                        .catch(() => updateFeedback(feedbackId, '인증 확인 중 오류가 발생했습니다.', 'error'));
                }
            });
        });
    })();
</script>
</body>
</html>
