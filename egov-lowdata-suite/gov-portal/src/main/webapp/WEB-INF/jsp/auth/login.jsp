<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - LINC 통합관리시스템</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"/>
    <style>
        :root {
            --un-blue: #009edb;
            --un-dark-blue: #1d4f91;
            --un-light-blue: #4da6d4;
            --gov-gold: #c9a961;
            --gov-navy: #1e3a5f;
            --gov-gray: #6c757d;
            --bg-light: #f4f7fa;
            --text-dark: #2c3e50;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, var(--un-dark-blue) 0%, var(--gov-navy) 100%);
            font-family: 'Segoe UI', 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            position: relative;
            overflow-x: hidden;
        }
        
        body::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: 
                repeating-linear-gradient(90deg, rgba(255,255,255,0.03) 0px, transparent 1px, transparent 40px, rgba(255,255,255,0.03) 41px),
                repeating-linear-gradient(0deg, rgba(255,255,255,0.03) 0px, transparent 1px, transparent 40px, rgba(255,255,255,0.03) 41px);
            pointer-events: none;
        }
        
        .login-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            position: relative;
            z-index: 1;
        }
        
        .login-wrapper {
            max-width: 480px;
            width: 100%;
        }
        
        .emblem-section {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .emblem {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, var(--un-blue) 0%, var(--un-light-blue) 100%);
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            box-shadow: 0 10px 40px rgba(0, 158, 219, 0.3);
            position: relative;
        }
        
        .emblem::before {
            content: '';
            position: absolute;
            inset: 8px;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
        }
        
        .emblem i {
            font-size: 3rem;
            color: white;
        }
        
        .system-title {
            color: white;
            font-size: 1.75rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            letter-spacing: -0.5px;
        }
        
        .system-subtitle {
            color: rgba(255, 255, 255, 0.85);
            font-size: 1rem;
            font-weight: 400;
        }
        
        .login-card {
            background: white;
            border-radius: 4px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            border-top: 4px solid var(--un-blue);
        }
        
        .card-header-custom {
            background: linear-gradient(to bottom, #f8f9fa 0%, #ffffff 100%);
            padding: 2rem 2.5rem 1.5rem;
            border-bottom: 1px solid #e9ecef;
        }
        
        .card-header-custom h2 {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--text-dark);
            margin: 0;
            text-align: center;
        }
        
        .login-body {
            padding: 2.5rem;
        }
        
        .form-label {
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 0.75rem;
            font-size: 0.9rem;
            display: block;
        }
        
        .form-control {
            border: 2px solid #dee2e6;
            border-radius: 4px;
            padding: 0.875rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }
        
        .form-control:focus {
            border-color: var(--un-blue);
            box-shadow: 0 0 0 0.2rem rgba(0, 158, 219, 0.15);
            background: white;
        }
        
        .btn-login {
            background: linear-gradient(to right, var(--un-blue) 0%, var(--un-light-blue) 100%);
            border: none;
            border-radius: 4px;
            padding: 1rem;
            font-weight: 600;
            font-size: 1.05rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 158, 219, 0.3);
            letter-spacing: 0.5px;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 25px rgba(0, 158, 219, 0.4);
        }
        
        .alert {
            border-radius: 4px;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            border-left: 4px solid;
        }
        
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border-left-color: #dc3545;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left-color: #28a745;
        }
        
        .info-box {
            background: linear-gradient(to bottom, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 4px;
            padding: 1.25rem;
            margin-top: 1.5rem;
            border: 1px solid #dee2e6;
        }
        
        .info-box .info-title {
            font-weight: 600;
            color: var(--gov-navy);
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .info-box .info-text {
            margin: 0;
            font-size: 0.85rem;
            color: #6c757d;
            line-height: 1.6;
        }
        
        .footer-text {
            text-align: center;
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.85rem;
            margin-top: 2rem;
        }
    </style>
</head>
<body>
<div class="login-container">
    <div class="login-wrapper">
        <div class="emblem-section">
            <div class="emblem">
                <i class="bi bi-globe2"></i>
            </div>
            <div class="system-title">LINC</div>
            <div class="system-subtitle">국제협력 프로젝트 통합관리시스템</div>
        </div>
        
        <div class="login-card">
            <div class="card-header-custom">
                <h2>시스템 로그인</h2>
            </div>
            
            <div class="login-body">
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger" role="alert">
                        <i class="bi bi-exclamation-triangle-fill"></i> ${errorMessage}
                    </div>
                </c:if>
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success" role="alert">
                        <i class="bi bi-check-circle-fill"></i> ${successMessage}
                    </div>
                </c:if>
                <c:if test="${not empty logoutMessage}">
                    <div class="alert alert-success" role="alert">
                        <i class="bi bi-check-circle-fill"></i> ${logoutMessage}
                    </div>
                </c:if>
                
                <form action="${pageContext.request.contextPath}/loginProcess.do" method="post">
                    <div class="mb-4">
                        <label class="form-label" for="username">사용자 아이디</label>
                        <input class="form-control" id="username" name="username" 
                               placeholder="아이디를 입력하세요" required autofocus>
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label" for="password">비밀번호</label>
                        <input class="form-control" id="password" name="password" 
                               type="password" placeholder="비밀번호를 입력하세요" required>
                    </div>

                    <button class="btn btn-login btn-primary w-100" type="submit">로그인</button>
                </form>

                <div class="d-flex justify-content-between mt-3 small">
                    <a href="${pageContext.request.contextPath}/auth/recover/id.do" class="text-decoration-none text-muted">
                        아이디 찾기
                    </a>
                    <a href="${pageContext.request.contextPath}/auth/recover/password.do" class="text-decoration-none text-muted">
                        비밀번호 찾기
                    </a>
                </div>

                <div class="mt-4 text-center" style="color: #6c757d;">
                    <span>아직 계정이 없으신가요?</span>
                    <a href="${pageContext.request.contextPath}/register.do" class="fw-semibold" style="color: var(--un-dark-blue); text-decoration: none;">
                        회원가입
                    </a>
                </div>
            </div>
        </div>
        
        <div class="footer-text">
            © 2025 LINC Project Management System. All rights reserved.
        </div>
    </div>
</div>
</body>
</html>
