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
    <title>역할 부여 - LINC 통합관리시스템</title>
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
        
        .user-selector {
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 26px rgba(15, 49, 96, 0.08);
            border: 1px solid rgba(0, 0, 0, 0.04);
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
        
        .content-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
        }
        
        @media (max-width: 992px) {
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
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--gov-navy);
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #e9ecef;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .panel-header i {
            color: var(--un-blue);
        }
        
        .assignment-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.25rem;
        }
        
        .assignment-card {
            background: #f8f9fa;
            border: 1px solid #dbe4f3;
            border-radius: 16px;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }
        
        .assignment-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid #dde4f0;
        }
        
        .assignment-title {
            font-weight: 700;
            color: var(--gov-navy);
            font-size: 1.05rem;
        }
        
        .info-row {
            display: grid;
            grid-template-columns: 110px 1fr;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }
        
        .info-label {
            color: #8898aa;
            font-weight: 600;
        }
        
        .info-value {
            color: #525f7f;
            word-break: break-all;
        }
        
        .info-value.empty {
            color: #adb5bd;
            font-style: italic;
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
        }
        
        .empty-state i {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.4;
        }
        
        .alert-custom {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 4px;
            padding: 1rem 1.25rem;
            color: #856404;
            margin-bottom: 2rem;
        }

        .alert-inline {
            border-radius: 8px;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-weight: 500;
        }

        .alert-inline i {
            font-size: 1.2rem;
        }

        .alert-inline.success {
            background: #d4edda;
            border: 1px solid #28a74533;
            color: #155724;
        }

        .alert-inline.error {
            background: #f8d7da;
            border: 1px solid #dc354533;
            color: #721c24;
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
        <h2 class="page-title">역할 부여/회수</h2>
        <p class="page-subtitle">사용자에게 역할을 부여하거나 회수합니다</p>
    </div>

    <c:if test="${empty users}">
        <div class="alert-custom">
            <i class="bi bi-exclamation-triangle-fill"></i> 등록된 사용자가 없습니다.
        </div>
    </c:if>

    <c:if test="${not empty users}">
        <div class="user-selector">
            <form method="get" action="${pageContext.request.contextPath}/rbac/assignments.do">
                <div class="row align-items-end">
                    <div class="col-auto">
                        <label class="form-label" for="userSelect">사용자 선택</label>
                    </div>
                    <div class="col">
                        <select id="userSelect" name="userId" class="form-select" onchange="this.form.submit()">
                            <c:forEach var="user" items="${users}">
                                <option value="${user.id}" <c:if test="${user.id == selectedUserId}">selected</c:if>>
                                    ${user.username} (Grade ${user.grade})
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </form>
        </div>

        <c:if test="${not empty successMessage}">
            <div class="alert-inline success">
                <i class="bi bi-check-circle-fill"></i>
                ${successMessage}
            </div>
        </c:if>
        <c:if test="${not empty errorMessage}">
            <div class="alert-inline error">
                <i class="bi bi-exclamation-triangle-fill"></i>
                ${errorMessage}
            </div>
        </c:if>

        <div class="content-grid">
            <div class="panel">
                <div class="panel-header">
                    <i class="bi bi-plus-circle-fill"></i>
                    <span>역할 부여</span>
                </div>
                
                <form action="${pageContext.request.contextPath}/rbac/assignments.do" method="post">
                    <input type="hidden" name="userId" value="${selectedUserId}"/>
                    
                    <div class="mb-3">
                        <label class="form-label" for="roleSelect">역할</label>
                        <select id="roleSelect" name="roleId" class="form-select" required>
                            <option value="">역할 선택</option>
                            <c:forEach var="role" items="${roles}">
                                <option value="${role.id}"
                                        data-role-name="${role.name}"
                                        data-role-admin="${role.name eq 'ROLE_ADMIN_SUPER'}">
                                    ${role.name}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    
                    <div class="mb-3">
                        <div class="d-flex align-items-center justify-content-between">
                            <label class="form-label mb-0" for="tenantInput">테넌트 ID</label>
                            <span class="badge bg-info text-dark" id="tenantAutoBadge" style="display: none;">자동 발급</span>
                        </div>
                        <input class="form-control" id="tenantInput" name="tenantId"
                               placeholder="UUID 형식" data-default-placeholder="UUID 형식" required>
                        <div class="form-text" id="tenantHelpText">UUID 형식의 테넌트 식별자를 입력하세요.</div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label" for="projectInput">프로젝트 ID (선택)</label>
                        <input class="form-control" id="projectInput" name="projectId"
                               placeholder="UUID 형식" data-default-placeholder="UUID 형식">
                        <div class="form-check mt-2">
                            <input class="form-check-input" type="checkbox" id="projectAutoCheckbox"
                                   name="autoProjectId" value="true">
                            <label class="form-check-label" for="projectAutoCheckbox">
                                체크 시 프로젝트 ID를 무작위로 발급합니다.
                            </label>
                        </div>
                        <div class="form-text">랜덤 발급을 선택하면 입력란이 자동으로 채워지고 수정할 수 없습니다.</div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label" for="validFromInput">시작일시</label>
                        <input class="form-control" type="datetime-local" id="validFromInput" name="validFrom">
                    </div>
                    
                    <div class="mb-4">
                        <label class="form-label" for="validToInput">종료일시 (선택)</label>
                        <input class="form-control" type="datetime-local" id="validToInput" name="validTo">
                    </div>
                    
                    <button class="btn btn-primary-custom w-100" type="submit">
                        <i class="bi bi-check-circle"></i> 역할 부여
                    </button>
                </form>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <i class="bi bi-shield-lock"></i>
                    <span>비밀번호 초기화</span>
                </div>

                <form action="${pageContext.request.contextPath}/rbac/assignments/reset-password.do"
                      method="post" autocomplete="off">
                    <input type="hidden" name="userId" value="${selectedUserId}"/>

                    <div class="mb-3">
                        <label class="form-label">대상 사용자</label>
                        <div class="fw-semibold text-primary">
                            <c:forEach var="user" items="${users}">
                                <c:if test="${user.id == selectedUserId}">
                                    ${user.username} (Grade ${user.grade})
                                </c:if>
                            </c:forEach>
                        </div>
                        <div class="form-text">위에서 선택한 사용자 비밀번호를 재설정합니다.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="newPasswordInput">새 비밀번호</label>
                        <input class="form-control" type="password" id="newPasswordInput" name="newPassword"
                               minlength="8" placeholder="최소 8자 이상" autocomplete="new-password" required>
                    </div>

                    <div class="mb-4">
                        <label class="form-label" for="confirmPasswordInput">비밀번호 확인</label>
                        <input class="form-control" type="password" id="confirmPasswordInput" name="confirmPassword"
                               minlength="8" placeholder="다시 한 번 입력" autocomplete="new-password" required>
                        <div class="form-text">보안을 위해 화면에 비밀번호는 노출되지 않습니다.</div>
                    </div>

                    <button class="btn btn-danger-custom w-100" type="submit"
                            onclick="return confirm('선택한 사용자의 비밀번호를 초기화하시겠습니까?');">
                        <i class="bi bi-arrow-counterclockwise"></i> 비밀번호 초기화
                    </button>
                </form>
            </div>

            <div class="panel">
                <div class="panel-header">
                    <i class="bi bi-list-check"></i>
                    <span>현재 부여된 역할</span>
                </div>
                
                <c:if test="${empty assignments}">
                    <div class="empty-state">
                        <i class="bi bi-inbox"></i>
                        <h5>부여된 역할이 없습니다</h5>
                        <div class="mt-2">우측에서 역할을 부여하면 목록이 표시됩니다.</div>
                    </div>
                </c:if>

                <c:if test="${not empty assignments}">
                    <div class="assignment-list">
                        <c:forEach var="row" items="${assignments}">
                            <div class="assignment-card">
                                <form action="${pageContext.request.contextPath}/rbac/assignments/revoke.do" method="post">
                                    <input type="hidden" name="assignmentId" value="${row.id}"/>
                                    <input type="hidden" name="userId" value="${selectedUserId}"/>
                                    
                                    <div class="assignment-header">
                                        <div class="assignment-title">${row.roleName}</div>
                                        <button class="btn btn-danger-custom btn-sm" type="submit"
                                                onclick="return confirm('이 역할을 회수하시겠습니까?')">
                                            <i class="bi bi-x-circle"></i> 회수
                                        </button>
                                    </div>
                                    
                                    <div class="info-row">
                                        <div class="info-label">테넌트</div>
                                        <div class="info-value">${row.tenantId}</div>
                                    </div>
                                    
                                    <div class="info-row">
                                        <div class="info-label">프로젝트</div>
                                        <div class="info-value ${empty row.projectId ? 'empty' : ''}">
                                            ${not empty row.projectId ? row.projectId : '미지정'}
                                        </div>
                                    </div>
                                    
                                    <div class="info-row">
                                        <div class="info-label">시작</div>
                                        <div class="info-value ${empty row.validFrom ? 'empty' : ''}">
                                            ${not empty row.validFrom ? row.validFrom : '미지정'}
                                        </div>
                                    </div>
                                    
                                    <div class="info-row">
                                        <div class="info-label">종료</div>
                                        <div class="info-value ${empty row.validTo ? 'empty' : ''}">
                                            ${not empty row.validTo ? row.validTo : '미지정'}
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
        </div>
    </c:if>
</main>
<script>
    (function () {
        var roleSelect = document.getElementById('roleSelect');
        var tenantInput = document.getElementById('tenantInput');
        var tenantHelpText = document.getElementById('tenantHelpText');
        var tenantAutoBadge = document.getElementById('tenantAutoBadge');
        var projectInput = document.getElementById('projectInput');
        var projectAutoCheckbox = document.getElementById('projectAutoCheckbox');

        function cryptoRandomUuid() {
            if (window.crypto && typeof window.crypto.randomUUID === 'function') {
                return window.crypto.randomUUID();
            }
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
                var r = Math.random() * 16 | 0;
                var v = c === 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        }

        function toggleTenantBehavior() {
            if (!roleSelect || !tenantInput) {
                return;
            }
            var selectedOption = roleSelect.options[roleSelect.selectedIndex];
            var isAdmin = selectedOption && selectedOption.dataset.roleAdmin === 'true';
            if (isAdmin) {
                tenantInput.value = '';
                tenantInput.placeholder = 'ROLE_ADMIN_SUPER는 자동 발급됩니다';
                tenantInput.readOnly = true;
                tenantInput.required = false;
                if (tenantAutoBadge) {
                    tenantAutoBadge.style.display = 'inline-flex';
                }
                if (tenantHelpText) {
                    tenantHelpText.textContent = '관리자 역할은 테넌트 ID가 시스템에서 중복 없이 자동 발급됩니다.';
                }
            } else {
                tenantInput.placeholder = tenantInput.dataset.defaultPlaceholder || 'UUID 형식';
                tenantInput.readOnly = false;
                tenantInput.required = true;
                if (tenantAutoBadge) {
                    tenantAutoBadge.style.display = 'none';
                }
                if (tenantHelpText) {
                    tenantHelpText.textContent = 'UUID 형식의 테넌트 식별자를 입력하세요.';
                }
            }
        }

        function handleProjectAuto() {
            if (!projectInput || !projectAutoCheckbox) {
                return;
            }
            if (projectAutoCheckbox.checked) {
                projectInput.value = cryptoRandomUuid();
                projectInput.readOnly = true;
                projectInput.classList.add('bg-light');
            } else {
                projectInput.readOnly = false;
                projectInput.classList.remove('bg-light');
                projectInput.value = '';
            }
        }

        roleSelect && roleSelect.addEventListener('change', toggleTenantBehavior);
        projectAutoCheckbox && projectAutoCheckbox.addEventListener('change', handleProjectAuto);

        toggleTenantBehavior();
        if (projectAutoCheckbox && projectAutoCheckbox.checked) {
            handleProjectAuto();
        }
    })();
</script>
</body>
</html>
