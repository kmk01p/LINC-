<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="username"
       value="${pageContext.request.userPrincipal ne null ? pageContext.request.userPrincipal.name : '게스트'}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>시스템 설정 - LINC 통합관리시스템</title>
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
            background: linear-gradient(120deg, var(--gov-navy), var(--un-dark-blue));
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 2rem;
            z-index: 1000;
        }

        .header-logo {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #fff;
        }

        .logo-icon {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.15);
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .logo-icon i {
            color: var(--gov-gold);
            font-size: 1.4rem;
        }

        .logo-text h1 {
            font-size: 1.2rem;
            font-weight: 700;
            margin: 0;
        }

        .logo-text p {
            margin: 0;
            opacity: 0.7;
            font-size: 0.85rem;
        }

        .header-user {
            display: flex;
            align-items: center;
            gap: 1rem;
            color: #fff;
        }

        .user-pill {
            background: rgba(255, 255, 255, 0.12);
            padding: 0.4rem 1rem;
            border-radius: 999px;
            display: flex;
            gap: 0.5rem;
            align-items: center;
        }

        /* Sidebar */
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

        .main-container {
            display: flex;
        }

        .main-content {
            margin-top: var(--header-height);
            margin-left: var(--sidebar-width);
            padding: 2rem 2.5rem;
            min-height: calc(100vh - var(--header-height));
        }

        .settings-hero {
            background: #ffffff;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 15px 35px rgba(30, 58, 95, 0.1);
            margin-bottom: 2rem;
            border: 1px solid rgba(0, 0, 0, 0.04);
        }

        .settings-hero h2 {
            margin: 0;
            font-size: 1.6rem;
            color: var(--gov-navy);
        }

        .settings-hero p {
            margin-top: 0.75rem;
            color: #5a637a;
        }

        .settings-section {
            margin-bottom: 2.5rem;
        }

        .settings-section h3 {
            font-size: 1.25rem;
            color: var(--gov-navy);
            margin-bottom: 0.35rem;
        }

        .settings-section p {
            color: #727a92;
            margin-bottom: 1.25rem;
        }

        .settings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 1rem;
        }

        .setting-card {
            background: #fff;
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid rgba(0, 0, 0, 0.05);
            box-shadow: 0 6px 18px rgba(16, 42, 67, 0.06);
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .setting-card.is-modified {
            border-color: rgba(0, 158, 219, 0.45);
            box-shadow: 0 10px 25px rgba(0, 158, 219, 0.15);
        }

        .setting-label {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 0.75rem;
        }

        .setting-label h4 {
            margin: 0;
            font-size: 1.05rem;
            color: var(--gov-navy);
        }

        .setting-label span.badge {
            font-size: 0.75rem;
        }

        .setting-description {
            color: #6c738c;
            font-size: 0.9rem;
            margin-top: 0.25rem;
        }

        .setting-control input[type="text"],
        .setting-control input[type="number"],
        .setting-control input[type="url"] {
            width: 100%;
            border-radius: 10px;
            border: 1px solid #d6dce8;
            padding: 0.65rem 0.9rem;
            font-size: 0.95rem;
        }

        .setting-meta {
            display: flex;
            justify-content: space-between;
            font-size: 0.8rem;
            color: #98a0b8;
        }

        .sticky-footer {
            position: sticky;
            bottom: 0;
            background: rgba(244, 247, 250, 0.95);
            padding: 1rem 0;
            border-top: 1px solid rgba(0, 0, 0, 0.05);
            margin-top: 1.5rem;
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
        }

        .btn-save {
            background: var(--un-dark-blue);
            color: #fff;
            border: none;
            padding: 0.75rem 1.75rem;
            border-radius: 10px;
            font-weight: 600;
        }

        .alert-update {
            border-radius: 12px;
            border-left: 4px solid #2cb67d;
        }
    </style>
</head>
<body>
<header class="top-header">
    <div class="header-logo">
        <div class="logo-icon">
            <i class="bi bi-gear-wide-connected"></i>
        </div>
        <div class="logo-text">
            <h1>LINC 시스템 설정</h1>
            <p>Platform Configuration</p>
        </div>
    </div>
    <div class="header-user">
        <div class="user-pill">
            <i class="bi bi-person-circle"></i>
            <span>${username}</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout.do" class="btn btn-outline-light btn-sm">
            로그아웃
        </a>
    </div>
</header>

<div class="main-container">
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>
    <main class="main-content">
        <section class="settings-hero">
            <div class="d-flex justify-content-between flex-wrap gap-3 align-items-center">
                <div>
                    <h2>플랫폼 거버넌스 설정</h2>
                    <p>ODK 연동, 보안 정책, 알림 채널 등을 중앙에서 제어합니다.</p>
                </div>
                <div class="text-end">
                    <div class="text-muted small">실험적 기능은 관리자만 볼 수 있습니다.</div>
                    <div class="fw-semibold text-success">
                        <i class="bi bi-shield-lock"></i> Admin Only
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${settingsSaved}">
            <div class="alert alert-success alert-update d-flex align-items-center gap-2">
                <i class="bi bi-check-circle-fill"></i>
                <span>
                    설정이 저장되었습니다.
                    <c:if test="${settingsChangedCount > 0}">
                        (${settingsChangedCount}건 변경)
                    </c:if>
                </span>
            </div>
        </c:if>

        <form method="post" action="${pageContext.request.contextPath}/admin/settings.do">
            <c:forEach var="category" items="${groupedSettings}">
                <div class="settings-section">
                    <h3>${category.key}</h3>
                    <p>
                        <c:choose>
                            <c:when test="${category.key eq '통합 연동'}">외부 플랫폼 연동 관련 토글입니다.</c:when>
                            <c:when test="${category.key eq '데이터 파이프라인'}">수집 파이프라인과 ETL 동작을 제어합니다.</c:when>
                            <c:when test="${category.key eq '알림 & 경보'}">Slack · 이메일 등 알림 채널 구성을 조정합니다.</c:when>
                            <c:when test="${category.key eq '보안 & 접근'}">세션 보안과 감사 정책을 정의합니다.</c:when>
                            <c:otherwise>운영팀 공지 및 브랜드 메시지를 설정합니다.</c:otherwise>
                        </c:choose>
                    </p>
                    <div class="settings-grid">
                        <c:forEach var="setting" items="${category.value}">
                            <div class="setting-card${setting.changed ? ' is-modified' : ''}">
                                <div>
                                    <div class="setting-label">
                                        <div>
                                            <h4>${setting.label}</h4>
                                            <div class="setting-description">${setting.description}</div>
                                        </div>
                                        <span class="badge bg-light text-dark">
                                            ${setting.inputType}
                                        </span>
                                    </div>
                                </div>
                                <div class="setting-control">
                                    <c:choose>
                                        <c:when test="${setting.inputType == 'TOGGLE'}">
                                            <div class="form-check form-switch m-0">
                                                <input class="form-check-input"
                                                       type="checkbox"
                                                       role="switch"
                                                       id="${setting.key}"
                                                       name="settings[${setting.key}]"
                                                       <c:if test="${setting.toggleEnabled}">checked</c:if>>
                                                <label class="form-check-label" for="${setting.key}">
                                                    ${setting.toggleEnabled ? '사용' : '중지'}
                                                </label>
                                            </div>
                                        </c:when>
                                        <c:when test="${setting.inputType == 'NUMBER'}">
                                            <input type="number"
                                                   id="${setting.key}"
                                                   name="settings[${setting.key}]"
                                                   value="${setting.value}"
                                                   min="0"
                                                   class="form-control"/>
                                        </c:when>
                                        <c:when test="${setting.inputType == 'URL'}">
                                            <input type="url"
                                                   id="${setting.key}"
                                                   name="settings[${setting.key}]"
                                                   value="${setting.value}"
                                                   placeholder="https://example.com/hook"
                                                   class="form-control"/>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="text"
                                                   id="${setting.key}"
                                                   name="settings[${setting.key}]"
                                                   value="${setting.value}"
                                                   class="form-control"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="setting-meta">
                                    <span>
                                        <i class="bi bi-clock-history"></i>
                                        <c:choose>
                                            <c:when test="${setting.updatedAt ne null}">
                                                ${setting.updatedAt}
                                            </c:when>
                                            <c:otherwise>미기록</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span>
                                        <i class="bi bi-person"></i>
                                        <c:choose>
                                            <c:when test="${setting.updatedBy ne null}">
                                                ${fn:substring(setting.updatedBy, 0, 8)}…
                                            </c:when>
                                            <c:otherwise>시스템</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:forEach>

            <div class="sticky-footer">
                <button type="reset" class="btn btn-outline-secondary">되돌리기</button>
                <button type="submit" class="btn-save">
                    <i class="bi bi-save"></i> 설정 저장
                </button>
            </div>
        </form>
    </main>
</div>
</body>
</html>
