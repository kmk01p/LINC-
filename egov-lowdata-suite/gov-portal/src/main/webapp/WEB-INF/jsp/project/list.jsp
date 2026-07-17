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
    <title>프로젝트 목록 - LINC 통합관리시스템</title>
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
        
        /* Header */
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
        
        /* Main Content */
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
        
        .action-toolbar {
            background: white;
            border-radius: 4px;
            padding: 1.25rem;
            margin-bottom: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: flex-end;
        }
        
        .btn-primary-custom {
            background: linear-gradient(to right, var(--un-blue) 0%, #0088c5 100%);
            border: none;
            padding: 0.75rem 1.75rem;
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
            background: linear-gradient(to bottom, #f8f9fa 0%, #e9ecef 100%);
            border-bottom: 2px solid #dee2e6;
        }
        
        .table thead th {
            border: none;
            color: #525f7f;
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
        }
        
        .table tbody tr:hover {
            background: #f8f9fa;
        }
        
        .table tbody td {
            padding: 1.25rem 1.5rem;
            vertical-align: middle;
            color: #525f7f;
        }
        
        .status-badge {
            display: inline-block;
            padding: 0.4rem 0.875rem;
            border-radius: 3px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }
        
        .status-active {
            background: #d4edda;
            color: #155724;
        }
        
        .btn-action {
            background: var(--gov-navy);
            color: white;
            border: none;
            padding: 0.5rem 1.25rem;
            border-radius: 3px;
            font-size: 0.875rem;
            font-weight: 600;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-action:hover {
            background: var(--un-dark-blue);
            transform: translateY(-1px);
            color: white;
        }

        .btn-warning-custom {
            background: #ffc107;
            color: #212529;
            border: none;
            padding: 0.5rem 1.25rem;
            border-radius: 3px;
            font-size: 0.875rem;
            font-weight: 600;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-warning-custom:hover {
            background: #e0a800;
            color: #212529;
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

        .btn-analytics {
            background: linear-gradient(135deg, #4c6ef5, #5f8bff);
            color: white;
        }

        .btn-analytics:hover {
            color: white;
            background: linear-gradient(135deg, #425adb, #5679ff);
            transform: translateY(-1px);
        }

        .btn-group-actions {
            display: flex;
            gap: 0.5rem;
            justify-content: center;
        }

        .bulk-actions-bar {
            background: white;
            border-radius: 4px;
            padding: 1rem;
            margin-bottom: 1rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            display: none;
            align-items: center;
            gap: 1rem;
        }

        .bulk-actions-bar.active {
            display: flex;
        }

        .selected-count {
            font-weight: 600;
            color: var(--gov-navy);
        }

        .checkbox-cell {
            width: 40px;
            text-align: center;
        }

        .checkbox-cell input[type="checkbox"] {
            width: 18px;
            height: 18px;
            cursor: pointer;
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
        }
        
        .empty-state h3 {
            font-size: 1.25rem;
            margin-bottom: 0.5rem;
            color: #525f7f;
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
        <h2 class="page-title">프로젝트 목록</h2>
        <p class="page-subtitle">등록된 국제협력 프로젝트를 조회하고 관리합니다</p>
    </div>
    
    <div class="action-toolbar">
        <a href="${pageContext.request.contextPath}/projects/create.do" class="btn btn-primary-custom">
            <i class="bi bi-plus-circle"></i> 새 프로젝트 등록
        </a>
    </div>

    <div class="bulk-actions-bar" id="bulkActionsBar">
        <span class="selected-count">
            <span id="selectedCount">0</span>개 선택됨
        </span>
        <button type="button" class="btn-danger-custom" onclick="bulkDelete()">
            <i class="bi bi-trash"></i> 선택 항목 삭제
        </button>
        <button type="button" class="btn btn-secondary" onclick="clearSelection()">
            선택 해제
        </button>
    </div>

    <div class="data-table-card">
        <c:if test="${empty projects}">
            <div class="empty-state">
                <i class="bi bi-inbox"></i>
                <h3>등록된 프로젝트가 없습니다</h3>
                <p>새 프로젝트를 등록하여 시작하세요</p>
            </div>
        </c:if>
        
        <c:if test="${not empty projects}">
            <table class="table">
                <thead>
                <tr>
                    <th class="checkbox-cell">
                        <input type="checkbox" id="selectAll" onchange="toggleSelectAll(this)">
                    </th>
                    <th>프로젝트명</th>
                    <th>국가</th>
                    <th>분야</th>
                    <th>상태</th>
                    <th>등록일</th>
                    <th style="width: 120px; text-align: center;">관리</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="project" items="${projects}">
                    <tr>
                        <td class="checkbox-cell">
                            <input type="checkbox" class="project-checkbox"
                                   value="${project.id}"
                                   onchange="updateBulkActions()">
                        </td>
                        <td><strong>${project.name}</strong></td>
                        <td>${project.country}</td>
                        <td>${project.sector}</td>
                        <td><span class="status-badge status-active">${project.status}</span></td>
                        <td>${project.createdAt}</td>
                        <td>
                            <div class="btn-group-actions">
                                <a href="${pageContext.request.contextPath}/projects/${project.id}/detail.do"
                                   class="btn btn-action">
                                    <i class="bi bi-eye"></i> 상세
                                </a>
                                <a href="${pageContext.request.contextPath}/projects/${project.id}/analytics.do"
                                   class="btn btn-analytics">
                                    <i class="bi bi-graph-up"></i> 통계
                                </a>
                                <a href="${pageContext.request.contextPath}/projects/${project.id}/edit.do"
                                   class="btn btn-warning-custom">
                                    <i class="bi bi-pencil"></i> 편집
                                </a>
                                <form action="${pageContext.request.contextPath}/projects/${project.id}/delete.do"
                                      method="post"
                                      style="display: inline;"
                                      onsubmit="return confirm('이 프로젝트를 삭제된 프로젝트 목록으로 이동하시겠습니까?\n\n삭제된 프로젝트 메뉴에서 복원하거나 영구 삭제할 수 있습니다.');">
                                    <button type="submit" class="btn-danger-custom">
                                        <i class="bi bi-trash"></i> 삭제
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
