<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="username" value="${pageContext.request.userPrincipal.name}"/>
<c:set var="isAdmin" value="${fn:containsIgnoreCase(username, 'admin')}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>삭제된 프로젝트 - LINC 통합관리시스템</title>
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
            border-left: 4px solid #dc3545;
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

        .alert-warning-custom {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 4px;
            padding: 1.25rem;
            margin-bottom: 2rem;
            color: #856404;
        }

        .data-table-card {
            background: white;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }

        .table {
            margin: 0;
        }

        .table thead {
            background: linear-gradient(to bottom, #fff3cd 0%, #ffe8a1 100%);
            border-bottom: 2px solid #ffc107;
        }

        .table thead th {
            border: none;
            color: #856404;
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            padding: 1.25rem 1.5rem;
            white-space: nowrap;
        }

        .table tbody tr {
            border-bottom: 1px solid #f1f3f5;
            transition: all 0.2s ease;
            background: #fffbf0;
        }

        .table tbody tr:hover {
            background: #fff9e6;
        }

        .table tbody td {
            padding: 1.25rem 1.5rem;
            vertical-align: middle;
            color: #525f7f;
        }

        .btn-success-custom {
            background: #28a745;
            color: white;
            border: none;
            padding: 0.5rem 1.25rem;
            border-radius: 3px;
            font-size: 0.875rem;
            font-weight: 600;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn-success-custom:hover {
            background: #218838;
            transform: translateY(-1px);
        }

        .btn-danger-custom {
            background: #dc3545;
            color: white;
            border: none;
            padding: 0.5rem 1.25rem;
            border-radius: 3px;
            font-size: 0.875rem;
            font-weight: 600;
            transition: all 0.2s ease;
            cursor: pointer;
        }

        .btn-danger-custom:hover {
            background: #c82333;
            transform: translateY(-1px);
        }

        .btn-group-actions {
            display: flex;
            gap: 0.5rem;
            justify-content: center;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #8898aa;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            opacity: 0.4;
            color: #28a745;
        }

        .empty-state h3 {
            font-size: 1.25rem;
            margin-bottom: 0.5rem;
            color: #525f7f;
        }

        .deleted-badge {
            background: #dc3545;
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 3px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }
    </style>
</head>
<body>
<!-- Top Header -->
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

<!-- Sidebar -->
<jsp:include page="/WEB-INF/jsp/layout/sidebar.jsp"/>

<!-- Main Content -->
<main class="main-content">
    <div class="page-title-section">
        <h2 class="page-title"><i class="bi bi-trash"></i> 삭제된 프로젝트</h2>
        <p class="page-subtitle">삭제된 프로젝트를 복원하거나 영구적으로 삭제합니다</p>
    </div>

    <div class="alert-warning-custom">
        <i class="bi bi-exclamation-triangle-fill"></i>
        <strong>주의:</strong> 이 목록의 프로젝트들은 삭제 대기 중입니다.
        복원하면 프로젝트 목록으로 돌아가고, 영구 삭제하면 ODK Central에서도 완전히 삭제됩니다.
    </div>

    <div class="data-table-card">
        <c:if test="${empty projects}">
            <div class="empty-state">
                <i class="bi bi-check-circle"></i>
                <h3>삭제된 프로젝트 목록이 비어있습니다</h3>
                <p>삭제된 프로젝트가 없습니다.</p>
                <a href="${pageContext.request.contextPath}/projects/list.do"
                   class="btn btn-success-custom" style="margin-top: 1rem;">
                    <i class="bi bi-arrow-left"></i> 프로젝트 목록으로 돌아가기
                </a>
            </div>
        </c:if>

        <c:if test="${not empty projects}">
            <table class="table">
                <thead>
                <tr>
                    <th>프로젝트명</th>
                    <th>국가</th>
                    <th>분야</th>
                    <th>삭제일</th>
                    <th>삭제자</th>
                    <th style="width: 220px; text-align: center;">관리</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="project" items="${projects}">
                    <tr>
                        <td>
                            <strong>${project.name}</strong>
                            <span class="deleted-badge">삭제됨</span>
                        </td>
                        <td>${project.country}</td>
                        <td>${project.sector}</td>
                        <td>
                            ${project.deletedAt}
                        </td>
                        <td>${project.deletedBy}</td>
                        <td>
                            <div class="btn-group-actions">
                                <form action="${pageContext.request.contextPath}/projects/${project.id}/restore.do"
                                      method="post"
                                      style="display: inline;"
                                      onsubmit="return confirm('이 프로젝트를 복원하시겠습니까? 프로젝트 목록으로 되돌아갑니다.');">
                                    <button type="submit" class="btn-success-custom">
                                        <i class="bi bi-arrow-counterclockwise"></i> 복원
                                    </button>
                                </form>
                                <form action="${pageContext.request.contextPath}/projects/${project.id}/permanent-delete.do"
                                      method="post"
                                      style="display: inline;"
                                      onsubmit="return confirm('정말로 이 프로젝트를 영구 삭제하시겠습니까?\n\n경고: ODK Central의 프로젝트와 모든 데이터가 완전히 삭제되며 복구할 수 없습니다.');">
                                    <button type="submit" class="btn-danger-custom">
                                        <i class="bi bi-trash-fill"></i> 영구 삭제
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </c:if>
    </div>
</main>
</body>
</html>
