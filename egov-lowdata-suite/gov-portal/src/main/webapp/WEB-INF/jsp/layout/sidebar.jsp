<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<c:set var="username"
        value="${pageContext.request.userPrincipal ne null ? pageContext.request.userPrincipal.name : ''}"/>
<c:set var="isAdmin" value="${fn:containsIgnoreCase(username, 'admin')}"/>
<c:set var="currentPath" value="${pageContext.request.requestURI}"/>

<c:set var="dashboardActive" value="${fn:contains(currentPath, '/dashboard.do')}"/>
<c:set var="projectListActive"
        value="${fn:contains(currentPath, '/projects/list.do')
            or (fn:contains(currentPath, '/projects/')
                and (fn:contains(currentPath, '/detail.do')
                    or fn:contains(currentPath, '/edit.do')
                    or fn:contains(currentPath, '/restore.do')
                    or fn:contains(currentPath, '/permanent-delete.do')))}"/>
<c:set var="projectCreateActive" value="${fn:contains(currentPath, '/projects/create.do')}"/>
<c:set var="projectDeletedActive" value="${fn:contains(currentPath, '/projects/deleted/list.do')}"/>
<c:set var="rbacRolesActive" value="${fn:contains(currentPath, '/rbac/roles')}"/>
<c:set var="rbacAssignmentsActive" value="${fn:contains(currentPath, '/rbac/assignments')}"/>
<c:set var="systemSettingsActive" value="${fn:contains(currentPath, '/admin/settings')}"/>
<c:set var="auditLogActive" value="${fn:contains(currentPath, '/admin/audit/logs')}"/>

<aside class="sidebar">
    <nav class="sidebar-menu">
        <div class="menu-section">
            <div class="menu-title">개요</div>
            <a href="${pageContext.request.contextPath}/dashboard.do"
               class="menu-item${dashboardActive ? ' active' : ''}">
                <i class="bi bi-speedometer2"></i>
                <span>대시보드</span>
            </a>
        </div>

        <div class="menu-section">
            <div class="menu-title">프로젝트 관리</div>
            <a href="${pageContext.request.contextPath}/projects/list.do"
               class="menu-item${projectListActive ? ' active' : ''}">
                <i class="bi bi-folder-fill"></i>
                <span>프로젝트 목록</span>
            </a>
            <a href="${pageContext.request.contextPath}/projects/create.do"
               class="menu-item${projectCreateActive ? ' active' : ''}">
                <i class="bi bi-plus-circle"></i>
                <span>프로젝트 생성</span>
            </a>
        </div>

        <div class="menu-section">
            <div class="menu-title">권한 관리</div>
            <a href="${pageContext.request.contextPath}/rbac/roles.do"
               class="menu-item${rbacRolesActive ? ' active' : ''}">
                <i class="bi bi-shield-check"></i>
                <span>역할 관리</span>
            </a>
            <a href="${pageContext.request.contextPath}/rbac/assignments.do"
               class="menu-item${rbacAssignmentsActive ? ' active' : ''}">
                <i class="bi bi-person-badge"></i>
                <span>역할 부여</span>
            </a>
        </div>

        <div class="menu-section">
            <div class="menu-title">시스템</div>
            <c:if test="${isAdmin}">
                <a href="${pageContext.request.contextPath}/projects/deleted/list.do"
                   class="menu-item${projectDeletedActive ? ' active' : ''}">
                    <i class="bi bi-trash"></i>
                    <span>삭제된 프로젝트</span>
                </a>
            </c:if>
            <c:if test="${isAdmin}">
                <a href="${pageContext.request.contextPath}/admin/settings.do"
                   class="menu-item${systemSettingsActive ? ' active' : ''}">
                    <i class="bi bi-gear"></i>
                    <span>시스템 설정</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/audit/logs.do"
                   class="menu-item${auditLogActive ? ' active' : ''}">
                    <i class="bi bi-file-text"></i>
                    <span>활동 로그</span>
                </a>
            </c:if>
        </div>
    </nav>
</aside>
