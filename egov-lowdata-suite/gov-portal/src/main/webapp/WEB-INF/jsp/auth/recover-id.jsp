<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>아이디 찾기 - LINC 통합관리시스템</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"/>
    <style>
        body {
            margin: 0;
            min-height: 100vh;
            background: #f4f7fb;
            font-family: 'Segoe UI', 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
        }

        .recovery-layout {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3rem 1.5rem;
        }

        .recovery-card {
            width: 100%;
            max-width: 520px;
            background: #fff;
            border-radius: 24px;
            padding: 2.5rem;
            box-shadow: 0 20px 45px rgba(15, 49, 96, 0.12);
            border: 1px solid rgba(0, 0, 0, 0.04);
        }

        h1 {
            font-size: 1.75rem;
            margin-bottom: 0.5rem;
            color: #1e3a5f;
        }

        p.subtitle {
            color: #6b748c;
            margin-bottom: 1.75rem;
        }

        .form-floating > .form-control {
            border-radius: 12px;
            border: 1.5px solid #e1e6ef;
            background: #f8fafc;
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
            margin-top: 0.35rem;
            min-height: 1.1rem;
        }

        .verification-feedback.success {
            color: #0f766e;
        }

        .verification-feedback.error {
            color: #c0392b;
        }

        .btn-primary {
            width: 100%;
            padding: 0.9rem;
            font-weight: 600;
            border-radius: 12px;
        }

        .alert {
            border-radius: 12px;
            border: none;
            margin-bottom: 1.5rem;
            padding: 0.85rem 1.1rem;
        }

        .result-box {
            background: #f1f5fb;
            border-radius: 16px;
            padding: 1.25rem;
            margin-bottom: 1.5rem;
            text-align: center;
            color: #0f4c81;
            font-weight: 600;
        }

        .links {
            margin-top: 1.5rem;
            text-align: center;
            color: #6b748c;
        }

        .links a {
            font-weight: 600;
            color: #1d4f91;
        }
    </style>
</head>
<body>
<div class="recovery-layout">
    <div class="recovery-card">
        <h1>아이디 찾기</h1>
        <p class="subtitle">본인 확인 후 가입하신 아이디를 안내해드립니다.</p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle-fill"></i> ${errorMessage}
            </div>
        </c:if>
        <c:if test="${not empty successMessage}">
            <div class="alert alert-success">
                <i class="bi bi-check-circle-fill"></i> ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty recoveredUsername}">
            <div class="result-box">
                <i class="bi bi-person-badge"></i>
                <div>회원님의 아이디는 <strong>${recoveredUsername}</strong> 입니다.</div>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/auth/recover/id.do" method="post">
            <div class="form-floating mb-3">
                <input type="text"
                       class="form-control"
                       id="fullName"
                       name="fullName"
                       placeholder="이름"
                       value="${idForm.fullName}"
                       required>
                <label for="fullName"><i class="bi bi-person-lines-fill"></i> 이름</label>
            </div>

            <div class="verification-field">
                <label for="emailId">이메일 주소</label>
                <div class="input-group">
                    <input type="email"
                           class="form-control"
                           id="emailId"
                           name="email"
                           placeholder="user@example.com"
                           value="${idForm.email}"
                           required>
                    <button type="button"
                            class="btn btn-outline-primary"
                            data-verify-action="send"
                            data-verify-type="EMAIL"
                            data-target-input="emailId"
                            data-feedback="idEmailFeedback">
                        인증코드 발송
                    </button>
                </div>
                <div class="input-group mt-2">
                    <input type="text"
                           class="form-control"
                           id="emailIdCode"
                           name="emailVerificationCode"
                           placeholder="6자리 인증코드"
                           value="${idForm.emailVerificationCode}"
                           maxlength="6"
                           required>
                    <button type="button"
                            class="btn btn-outline-success"
                            data-verify-action="confirm"
                            data-verify-type="EMAIL"
                            data-target-input="emailId"
                            data-code-input="emailIdCode"
                            data-feedback="idEmailFeedback">
                        인증 확인
                    </button>
                </div>
                <div class="verification-feedback" id="idEmailFeedback"></div>
            </div>

            <button type="submit" class="btn btn-primary">
                <i class="bi bi-search"></i> 아이디 찾기
            </button>
        </form>

        <div class="links">
            <div><a href="${pageContext.request.contextPath}/auth/recover/password.do">비밀번호 찾기</a></div>
            <div>또는 <a href="${pageContext.request.contextPath}/login.do">로그인 화면으로 돌아가기</a></div>
        </div>
    </div>
</div>

<script>
    (function() {
        const contextPath = '${pageContext.request.contextPath}';
        const requestUrl = contextPath + '/auth/api/verification/request';
        const confirmUrl = contextPath + '/auth/api/verification/confirm';

        function send(url, payload) {
            return fetch(url, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            }).then(resp => resp.json());
        }

        function updateFeedback(id, message, type) {
            const node = document.getElementById(id);
            if (!node) return;
            node.textContent = message || '';
            node.classList.remove('success', 'error');
            if (type) node.classList.add(type);
        }

        document.querySelectorAll('[data-verify-action]').forEach(button => {
            button.addEventListener('click', () => {
                const action = button.dataset.verifyAction;
                const type = button.dataset.verifyType;
                const targetInput = document.getElementById(button.dataset.targetInput);
                const feedbackId = button.dataset.feedback;
                const codeInputId = button.dataset.codeInput;
                if (!targetInput || !targetInput.value.trim()) {
                    updateFeedback(feedbackId, '이메일 주소를 입력해주세요.', 'error');
                    targetInput && targetInput.focus();
                    return;
                }
                const payload = {type, target: targetInput.value.trim()};
                if (action === 'send') {
                    send(requestUrl, payload).then(data => {
                        const message = data.success
                            ? data.message + (data.code ? ` (코드: ${data.code})` : '')
                            : (data.message || '코드를 발송할 수 없습니다.');
                        updateFeedback(feedbackId, message, data.success ? 'success' : 'error');
                    }).catch(() => updateFeedback(feedbackId, '네트워크 오류가 발생했습니다.', 'error'));
                } else {
                    const codeInput = document.getElementById(codeInputId);
                    payload.code = codeInput ? codeInput.value.trim() : '';
                    if (!payload.code) {
                        updateFeedback(feedbackId, '인증 코드를 입력해주세요.', 'error');
                        codeInput && codeInput.focus();
                        return;
                    }
                    send(confirmUrl, payload).then(data => {
                        updateFeedback(feedbackId, data.message, data.success ? 'success' : 'error');
                    }).catch(() => updateFeedback(feedbackId, '인증 확인 중 오류가 발생했습니다.', 'error'));
                }
            });
        });
    })();
</script>
</body>
</html>
