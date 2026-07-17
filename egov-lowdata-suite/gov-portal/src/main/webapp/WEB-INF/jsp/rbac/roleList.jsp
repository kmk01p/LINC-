<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="username" value="${pageContext.request.userPrincipal.name}"/>
<c:set var="isAdmin" value="${fn:containsIgnoreCase(username, 'admin')}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>역할 관리 - LINC 통합관리시스템</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"/>
    <style>
        :root {
            --un-blue: #009edb;
            --un-dark-blue: #1d4f91;
            --gov-navy: #1e3a5f;
            --gov-gold: #c9a961;
            --sidebar-width: 260px;
            --header-height: 70px;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f4f7fa;
            color: #2c3e50;
        }
        
        .top-header {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            height: var(--header-height);
            background: linear-gradient(to right, var(--gov-navy) 0%, var(--un-dark-blue) 100%);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            display: flex;
            align-items: center;
            padding: 0 2rem;
            justify-content: space-between;
        }
        
        .header-logo {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: white;
        }
        
        .logo-icon {
            width: 45px;
            height: 45px;
            background: rgba(255, 255, 255, 0.15);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .logo-icon i {
            font-size: 1.5rem;
            color: var(--gov-gold);
        }
        
        .logo-text h1 {
            font-size: 1.25rem;
            font-weight: 700;
            margin: 0;
            line-height: 1;
        }
        
        .logo-text p {
            font-size: 0.75rem;
            margin: 0;
            opacity: 0.8;
        }
        
        .header-user {
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: white;
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 25px;
        }
        
        .user-avatar {
            width: 35px;
            height: 35px;
            background: var(--gov-gold);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: var(--gov-navy);
        }
        
        .btn-logout {
            background: rgba(255, 255, 255, 0.15);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 0.5rem 1.25rem;
            border-radius: 4px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-logout:hover {
            background: rgba(255, 255, 255, 0.25);
            color: white;
        }
        
        .sidebar {
            position: fixed;
            left: 0;
            top: var(--header-height);
            width: var(--sidebar-width);
            height: calc(100vh - var(--header-height));
            background: white;
            border-right: 1px solid #e0e6ed;
            overflow-y: auto;
            z-index: 100;
        }
        
        .sidebar-menu {
            padding: 1.5rem 0;
        }
        
        .menu-section {
            margin-bottom: 2rem;
        }
        
        .menu-title {
            padding: 0.5rem 1.5rem;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            color: #8898aa;
            letter-spacing: 0.5px;
        }
        
        .menu-item {
            display: flex;
            align-items: center;
            padding: 0.875rem 1.5rem;
            color: #525f7f;
            text-decoration: none;
            transition: all 0.2s ease;
            border-left: 3px solid transparent;
            font-weight: 500;
        }
        
        .menu-item i {
            width: 24px;
            margin-right: 1rem;
            font-size: 1.1rem;
            color: #8898aa;
        }
        
        .menu-item:hover {
            background: #f7fafc;
            color: var(--un-blue);
            border-left-color: var(--un-blue);
        }
        
        .menu-item:hover i {
            color: var(--un-blue);
        }
        
        .menu-item.active {
            background: linear-gradient(to right, rgba(0, 158, 219, 0.1) 0%, transparent 100%);
            color: var(--un-blue);
            border-left-color: var(--un-blue);
            font-weight: 600;
        }
        
        .menu-item.active i {
            color: var(--un-blue);
        }
        
        .main-content {
            margin-left: var(--sidebar-width);
            margin-top: var(--header-height);
            padding: 2rem;
            min-height: calc(100vh - var(--header-height));
        }
        
        .page-title-section {
            background: white;
            border-radius: 4px;
            padding: 2rem;
            margin-bottom: 2rem;
            border-left: 4px solid var(--un-blue);
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }
        
        .page-title {
            font-size: 1.75rem;
            font-weight: 700;
            color: var(--gov-navy);
            margin-bottom: 0.5rem;
        }
        
        .page-subtitle {
            color: #8898aa;
            font-size: 0.95rem;
            margin: 0;
        }
        
        .content-grid {
            display: grid;
            grid-template-columns: minmax(320px, 380px) minmax(0, 1fr);
            gap: 2rem;
        }
        
        @media (max-width: 1200px) {
            .content-grid {
                grid-template-columns: 1fr;
            }
        }
        
        .panel {
            background: white;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 10px 28px rgba(15, 49, 96, 0.08);
            border: 1px solid rgba(0, 0, 0, 0.04);
        }
        
        .panel-header {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #e2e8f0;
            font-weight: 700;
            color: var(--gov-navy);
            font-size: 1.1rem;
        }
        
        .panel-header i {
            color: var(--un-blue);
        }
        
        .form-label {
            font-weight: 600;
            color: #525f7f;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }
        
        .form-control, .form-select {
            border: 2px solid #dee2e6;
            border-radius: 4px;
            padding: 0.75rem 1rem;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: var(--un-blue);
            box-shadow: 0 0 0 0.2rem rgba(0, 158, 219, 0.15);
            background: white;
        }
        
        .permission-panel {
            background: #f8f9fa;
            border: 1px solid #e5e9f2;
            border-radius: 12px;
            padding: 1rem;
            max-height: 220px;
            overflow-y: auto;
        }
        
        .permission-grid {
            column-count: 2;
            column-gap: 1.25rem;
        }
        
        @media (max-width: 992px) {
            .permission-grid {
                column-count: 1;
            }
        }
        
        .permission-item {
            break-inside: avoid;
            margin-bottom: 0.75rem;
            padding: 0.35rem 0.5rem;
            border-radius: 8px;
            transition: background 0.2s ease;
        }
        
        .permission-item:hover {
            background: rgba(0, 158, 219, 0.08);
        }
        
        .form-check-input:checked {
            background-color: var(--un-blue);
            border-color: var(--un-blue);
        }
        
        .form-check-label {
            font-size: 0.9rem;
            color: #525f7f;
        }
        
        .role-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1.5rem;
        }
        
        .role-card {
            background: #f8f9fa;
            border: 1px solid #dbe4f3;
            border-radius: 16px;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        
        .role-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid #dde4f0;
        }
        
        .role-name {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--gov-navy);
        }
        
        .btn-primary-custom {
            background: linear-gradient(to right, var(--un-blue) 0%, #0088c5 100%);
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 4px;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
            box-shadow: 0 4px 10px rgba(0, 158, 219, 0.25);
        }
        
        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0, 158, 219, 0.35);
        }
        
        .btn-secondary-custom {
            background: #6c757d;
            border: none;
            padding: 0.75rem 1.75rem;
            border-radius: 4px;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
        }
        
        .btn-secondary-custom:hover {
            background: #5a6268;
        }
        
        .btn-danger-custom {
            background: #dc3545;
            border: none;
            padding: 0.5rem 1.25rem;
            border-radius: 4px;
            font-weight: 600;
            color: white;
            transition: all 0.3s ease;
        }
        
        .btn-danger-custom:hover {
            background: #c82333;
        }
        
        .empty-state {
            text-align: center;
            padding: 3rem 2rem;
            color: #8898aa;
            border: 1px dashed #c6cedd;
            border-radius: 16px;
            background: rgba(230, 236, 248, 0.35);
        }
        
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.4;
        }
    </style>
</head>
<body>
<header class="top-header">
    <div class="header-logo">
        <div class="logo-icon">
            <i class="bi bi-globe2"></i>
        </div>
        <div class="logo-text">
            <h1>LINC</h1>
            <p>국제협력 프로젝트 통합관리시스템</p>
        </div>
    </div>
    <div class="header-user">
        <div class="user-info">
            <div class="user-avatar">
                <i class="bi bi-person-fill"></i>
            </div>
            <span>${username}</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout.do" class="btn btn-logout">
            <i class="bi bi-box-arrow-right"></i> 로그아웃
        </a>
    </div>
</header>

<jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

<main class="main-content">
    <div class="page-title-section">
        <h2 class="page-title">역할 관리</h2>
        <p class="page-subtitle">시스템 역할과 권한을 관리합니다</p>
    </div>

    <div class="content-grid">
        <section class="panel">
            <div class="panel-header">
                <i class="bi bi-plus-circle-fill"></i>
                <span>신규 역할 생성</span>
            </div>
            
            <form action="${pageContext.request.contextPath}/rbac/roles.do" method="post">
                <div class="mb-3">
                    <label class="form-label" for="name">역할 이름</label>
                    <input class="form-control" id="name" name="name" placeholder="예) ROLE_PROJECT_MANAGER" required/>
                </div>
                <div class="mb-3">
                    <label class="form-label" for="description">설명</label>
                    <textarea class="form-control" id="description" name="description" rows="2" placeholder="역할의 책임과 사용 범위를 간략히 적어주세요."></textarea>
                </div>
                
                <div class="mb-3">
                    <label class="form-label">권한 선택</label>
                    <div class="permission-panel">
                        <div class="permission-grid">
                            <c:forEach var="permission" items="${permissions}">
                                <div class="permission-item form-check">
                                    <input class="form-check-input" type="checkbox"
                                           name="permissionIds"
                                           value="${permission.id}"
                                           id="perm-new-${permission.id}"/>
                                    <label class="form-check-label" for="perm-new-${permission.id}">
                                        <strong>${permission.code}</strong>
                                        <c:if test="${not empty permission.description}">
                                            <span style="color: #6c757d; font-size: 0.85rem; display: block;">${permission.description}</span>
                                        </c:if>
                                    </label>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
                
                <button class="btn btn-primary-custom w-100" type="submit">
                    <i class="bi bi-check-circle"></i> 역할 생성
                </button>
            </form>
        </section>
        
        <section class="panel">
            <div class="panel-header">
                <i class="bi bi-list-ul"></i>
                <span>역할 목록</span>
            </div>
            
            <c:if test="${empty roles}">
                <div class="empty-state">
                    <i class="bi bi-inbox"></i>
                    <h4>등록된 역할이 없습니다</h4>
                    <div class="mt-2">좌측에서 역할을 생성하면 목록이 표시됩니다.</div>
                </div>
            </c:if>
            
            <c:if test="${not empty roles}">
                <div class="role-list">
                    <c:forEach var="role" items="${roles}">
                        <div class="role-card">
                            <form action="${pageContext.request.contextPath}/rbac/roles/${role.id}.do" method="post">
                                <div class="role-header">
                                    <div>
                                        <div class="role-name">${role.name}</div>
                                        <div class="text-muted" style="font-size: 0.85rem;">${role.description}</div>
                                    </div>
                                    <button class="btn btn-danger-custom btn-sm"
                                            formaction="${pageContext.request.contextPath}/rbac/roles/${role.id}/delete.do"
                                            formmethod="post"
                                            onclick="return confirm('이 역할을 삭제하시겠습니까?')">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label" for="name-${role.id}">역할 이름</label>
                                    <input class="form-control" id="name-${role.id}" name="name" value="${role.name}" required/>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label" for="description-${role.id}">설명</label>
                                    <textarea class="form-control" id="description-${role.id}" name="description" rows="2">${role.description}</textarea>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label">권한 선택</label>
                                    <div class="permission-panel">
                                        <div class="permission-grid">
                                            <c:forEach var="permission" items="${permissions}">
                                                <c:set var="checked" value="false"/>
                                                <c:forEach var="code" items="${role.permissionCodes}">
                                                    <c:if test="${code eq permission.code}">
                                                        <c:set var="checked" value="true"/>
                                                    </c:if>
                                                </c:forEach>
                                                <div class="permission-item form-check">
                                                    <input class="form-check-input" type="checkbox"
                                                           name="permissionIds"
                                                           value="${permission.id}"
                                                           id="perm-${role.id}-${permission.id}"
                                                           <c:if test="${checked}">checked</c:if>>
                                                    <label class="form-check-label" for="perm-${role.id}-${permission.id}">
                                                        <strong>${permission.code}</strong>
                                                        <c:if test="${not empty permission.description}">
                                                            <span style="color: #6c757d; font-size: 0.85rem; display: block;">${permission.description}</span>
                                                        </c:if>
                                                    </label>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </div>
                                
                                <button class="btn btn-secondary-custom w-100" type="submit">
                                    <i class="bi bi-save"></i> 변경 사항 저장
                                </button>
                            </form>
                        </div>
                    </c:forEach>
                </div>
            </c:if>
        </section>
    </div>
</main>
</body>
</html>
