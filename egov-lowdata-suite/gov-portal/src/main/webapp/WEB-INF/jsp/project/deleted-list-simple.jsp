<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8"/>
    <title>삭제된 프로젝트</title>
</head>
<body>
    <h1>삭제된 프로젝트</h1>
    <p>삭제된 프로젝트 수: ${fn:length(projects)}</p>

    <c:if test="${empty projects}">
        <p>삭제된 프로젝트가 없습니다.</p>
    </c:if>

    <c:if test="${not empty projects}">
        <table border="1">
            <tr>
                <th>프로젝트명</th>
                <th>국가</th>
                <th>분야</th>
                <th>관리</th>
            </tr>
            <c:forEach var="project" items="${projects}">
                <tr>
                    <td>${project.name}</td>
                    <td>${project.country}</td>
                    <td>${project.sector}</td>
                    <td>
                        <form action="${pageContext.request.contextPath}/projects/${project.id}/restore.do" method="post" style="display:inline;">
                            <button type="submit">복원</button>
                        </form>
                        <form action="${pageContext.request.contextPath}/projects/${project.id}/permanent-delete.do" method="post" style="display:inline;">
                            <button type="submit">영구 삭제</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:if>
</body>
</html>
