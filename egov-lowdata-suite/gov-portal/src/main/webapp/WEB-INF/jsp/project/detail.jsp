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
    <title>프로젝트 상세 - LINC 통합관리시스템</title>
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
        
        .detail-card {
            background: white;
            border-radius: 4px;
            padding: 2.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            max-width: 1000px;
        }
        
        .section-header {
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
        
        .section-header i {
            color: var(--un-blue);
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2.5rem;
        }
        
        .info-item {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
            padding: 1.25rem;
        }
        
        .info-label {
            font-size: 0.8rem;
            font-weight: 700;
            color: #8898aa;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
        }
        
        .info-value {
            font-size: 1rem;
            color: #525f7f;
            font-weight: 500;
            word-break: break-all;
        }
        
        .info-value.empty {
            color: #adb5bd;
            font-style: italic;
        }
        
        .status-badge {
            display: inline-block;
            padding: 0.4rem 0.875rem;
            border-radius: 3px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.3px;
            background: #d4edda;
            color: #155724;
        }
        
        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            padding-top: 2rem;
            border-top: 2px solid #f1f3f5;
        }
        
        .btn-primary-custom {
            background: linear-gradient(to right, var(--un-blue) 0%, #0088c5 100%);
            border: none;
            padding: 0.875rem 2rem;
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

        .btn-analytics {
            background: linear-gradient(135deg, #4c6ef5, #5f8bff);
            color: white;
        }

        .btn-analytics:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(76, 110, 245, 0.35);
        }
        
        .btn-secondary-custom {
            background: white;
            border: 2px solid #dee2e6;
            padding: 0.875rem 2rem;
            border-radius: 4px;
            font-weight: 600;
            color: #525f7f;
            transition: all 0.3s ease;
        }
        
        .btn-secondary-custom:hover {
            background: #f8f9fa;
            border-color: #adb5bd;
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
        <h2 class="page-title">${project.name}</h2>
        <p class="page-subtitle">프로젝트 상세 정보</p>
    </div>
    
    <div class="detail-card">
        <div class="section-header">
            <i class="bi bi-info-circle-fill"></i>
            <span>기본 정보</span>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">테넌트 ID</div>
                <div class="info-value">${project.tenantId}</div>
            </div>
            
            <div class="info-item">
                <div class="info-label">상태</div>
                <div class="info-value">
                    <span class="status-badge">${project.status}</span>
                </div>
            </div>
        </div>
        
        <div class="section-header">
            <i class="bi bi-geo-alt-fill"></i>
            <span>프로젝트 속성</span>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">국가</div>
                <div class="info-value ${empty project.country ? 'empty' : ''}">
                    ${not empty project.country ? project.country : '설정되지 않음'}
                </div>
            </div>
            
            <div class="info-item">
                <div class="info-label">분야</div>
                <div class="info-value ${empty project.sector ? 'empty' : ''}">
                    ${not empty project.sector ? project.sector : '설정되지 않음'}
                </div>
            </div>
            
            <div class="info-item">
                <div class="info-label">언어</div>
                <div class="info-value ${empty project.languages ? 'empty' : ''}">
                    ${not empty project.languages ? project.languages : '설정되지 않음'}
                </div>
            </div>
        </div>
        
        <div class="section-header">
            <i class="bi bi-diagram-3-fill"></i>
            <span>ODK 연동 정보</span>
        </div>
        
        <div class="info-grid">
            <div class="info-item">
                <div class="info-label">ODK 프로젝트 UUID</div>
                <div class="info-value ${empty project.odkProjectUuid ? 'empty' : ''}">
                    ${not empty project.odkProjectUuid ? project.odkProjectUuid : '연동되지 않음'}
                </div>
            </div>
            
            <div class="info-item">
                <div class="info-label">ODK Form ID</div>
                <div class="info-value ${empty project.odkXmlFormId ? 'empty' : ''}">
                    ${not empty project.odkXmlFormId ? project.odkXmlFormId : '연동되지 않음'}
                </div>
            </div>
        </div>
        
        <div class="action-buttons">
            <a href="${pageContext.request.contextPath}/projects/list.do" 
               class="btn btn-secondary-custom">
                <i class="bi bi-arrow-left"></i> 목록으로
            </a>
            <a href="${pageContext.request.contextPath}/projects/${project.id}/edit.do"
               class="btn btn-primary-custom">
                <i class="bi bi-pencil"></i> 편집
            </a>
            <a href="${pageContext.request.contextPath}/projects/${project.id}/analytics.do"
               class="btn btn-analytics">
                <i class="bi bi-graph-up"></i> 통계 보기
            </a>
        </div>
    </div>
</main>
</body>
</html>
