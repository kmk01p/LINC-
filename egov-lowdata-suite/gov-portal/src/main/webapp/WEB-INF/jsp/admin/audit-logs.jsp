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
    <title>활동 로그 - LINC 통합관리시스템</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"/>
    <style>
        :root {
            --un-blue: #009edb;
            --un-dark-blue: #1d4f91;
            --gov-navy: #1e3a5f;
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
            color: #c9a961;
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

        .filter-bar {
            margin: 2rem 0;
            background: #fff;
            border-radius: 16px;
            padding: 1.25rem;
            box-shadow: 0 10px 25px rgba(15, 40, 87, 0.08);
        }

        .severity-badge {
            border-radius: 999px;
            padding: 0.2rem 0.75rem;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .severity-INFO {
            background: rgba(0, 158, 219, 0.12);
            color: var(--un-dark-blue);
        }

        .severity-WARN {
            background: rgba(243, 156, 18, 0.12);
            color: #c97c00;
        }

        .audit-table {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(12, 35, 70, 0.08);
        }

        .audit-table thead {
            background: #f0f2f8;
        }

        .audit-table th,
        .audit-table td {
            padding: 1rem 1.25rem;
            text-align: left;
            border-bottom: 1px solid #eef1f7;
        }

        .timeline-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 0.4rem;
        }

        .stat-card {
            background: #fff;
            border-radius: 16px;
            padding: 1.2rem;
            text-align: center;
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.5), 0 14px 30px rgba(20, 28, 60, 0.08);
        }

        .stat-card h4 {
            margin: 0;
            font-size: 2rem;
            color: var(--gov-navy);
        }

        .stat-card span {
            display: block;
            margin-top: 0.35rem;
            color: #6b7590;
        }
    </style>
</head>
<body>
<header class="top-header">
    <div class="header-logo">
        <div class="logo-icon">
            <i class="bi bi-activity"></i>
        </div>
        <div class="logo-text">
            <h1>시스템 활동 로그</h1>
            <p>Real-time Audit Trail</p>
        </div>
    </div>
    <div class="header-user">
        <div class="user-pill">
            <i class="bi bi-person-circle"></i>
            <span>${username}</span>
        </div>
        <a href="${pageContext.request.contextPath}/logout.do" class="btn btn-outline-light btn-sm">로그아웃</a>
    </div>
</header>

<div class="main-container">
    <jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

    <main class="main-content">
    <section class="settings-hero">
        <div class="d-flex justify-content-between flex-wrap gap-3 align-items-center">
            <div>
                <h2>감사 로그 타임라인</h2>
                <p>인증, 프로젝트 조작, 시스템 작업 등 주요 이벤트를 실시간으로 추적합니다.</p>
            </div>
            <div class="d-flex gap-3">
                <c:forEach var="entry" items="${severityStats}">
                    <div class="stat-card">
                        <h4>${entry.value}</h4>
                        <span>${entry.key} 이벤트</span>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

    <section class="filter-bar">
        <form class="row g-3 align-items-center"
              method="get"
              action="${pageContext.request.contextPath}/admin/audit/logs.do">
            <div class="col-md-3">
                <label class="form-label text-muted">심각도</label>
                <select name="severity" class="form-select">
                    <option value="" <c:if test="${empty selectedSeverity}">selected</c:if>>전체</option>
                    <option value="INFO" <c:if test="${selectedSeverity eq 'INFO'}">selected</c:if>>INFO</option>
                    <option value="WARN" <c:if test="${selectedSeverity eq 'WARN'}">selected</c:if>>WARN</option>
                </select>
            </div>
            <div class="col-md-5">
                <label class="form-label text-muted">검색어</label>
                <input type="text"
                       name="query"
                       value="${fn:escapeXml(searchKeyword)}"
                       placeholder="action, detail 키워드로 검색"
                       class="form-control"/>
            </div>
            <div class="col-md-2">
                <label class="form-label text-muted">표시 건수</label>
                <input type="number"
                       name="limit"
                       value="${limit}"
                       min="10"
                       max="500"
                       class="form-control"/>
            </div>
            <div class="col-md-2 d-flex align-items-end justify-content-end">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="bi bi-search"></i> 조회
                </button>
            </div>
        </form>
    </section>

    <section>
        <table class="audit-table">
            <thead>
            <tr>
                <th>발생 시각</th>
                <th>행위</th>
                <th>세부 정보</th>
                <th>세부 수준</th>
                <th>사용자</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="log" items="${logs}">
                <tr>
                    <td style="white-space: nowrap;">${log.createdAt}</td>
                    <td>
                        <span class="timeline-dot ${log.severity eq 'WARN' ? 'bg-warning' : 'bg-info'}"></span>
                        <strong>${log.action}</strong>
                    </td>
                    <td style="max-width: 420px;">
                        <span class="text-muted">${log.detail}</span>
                    </td>
                    <td>
                        <span class="severity-badge severity-${log.severity}">
                            ${log.severity}
                        </span>
                    </td>
                    <td>
                        <code>${log.actorId}</code>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty logs}">
                <tr>
                    <td colspan="5" class="text-center py-4 text-muted">
                        조회된 로그가 없습니다.
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </section>
</main>
</div>
</body>
</html>
