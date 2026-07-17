<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>대시보드 - LINC 통합관리시스템</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"/>
    <style>
        :root {
            --un-blue: #009edb;
            --un-dark-blue: #1d4f91;
            --gov-navy: #1e3a5f;
            --gov-gold: #c9a961;
            --bg-soft: #f5f7fb;
        }

        * {
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-soft);
            margin: 0;
            color: #2c3e50;
        }

        .page {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .topbar {
            padding: 1.5rem clamp(1.5rem, 5vw, 4rem);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .topbar h1 {
            font-size: clamp(1.75rem, 2.5vw, 2.2rem);
            font-weight: 700;
            color: var(--gov-navy);
            margin: 0;
        }

        .user-pill {
            background: white;
            border-radius: 999px;
            padding: 0.5rem 1.25rem;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            box-shadow: 0 10px 25px rgba(15, 49, 96, 0.1);
        }

        .topbar-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .logout-btn {
            background: linear-gradient(120deg, var(--un-blue), var(--un-dark-blue));
            color: white;
            border: none;
            border-radius: 999px;
            padding: 0.55rem 1.3rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            text-decoration: none;
            box-shadow: 0 12px 24px rgba(0, 158, 219, 0.25);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .logout-btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 14px 28px rgba(0, 158, 219, 0.35);
        }

        .hero {
            background: linear-gradient(135deg, rgba(0, 158, 219, 0.12) 0%, rgba(29, 79, 145, 0.12) 100%);
            border-radius: 24px;
            margin: 0 clamp(1.5rem, 5vw, 4rem);
            padding: clamp(2.5rem, 5vw, 3.5rem);
            display: grid;
            grid-template-columns: minmax(220px, 1.2fr) minmax(250px, 1fr);
            gap: 2.5rem;
        }

        @media (max-width: 992px) {
            .hero {
                grid-template-columns: 1fr;
            }
        }

        .hero h2 {
            font-size: clamp(1.9rem, 3vw, 2.4rem);
            font-weight: 700;
            color: var(--gov-navy);
        }

        .hero p {
            color: #4a5568;
            line-height: 1.7;
            margin-top: 0.75rem;
        }

        .status-card {
            background: white;
            border-radius: 20px;
            padding: 1.75rem;
            box-shadow: 0 18px 35px rgba(15, 49, 96, 0.12);
        }

        .status-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            margin-bottom: 1rem;
            font-weight: 600;
            color: var(--gov-navy);
            font-size: 1.05rem;
        }

        .status-title i {
            font-size: 1.35rem;
            color: var(--un-blue);
        }

        .awaiting-box {
            background: rgba(255, 193, 7, 0.15);
            border: 1px solid rgba(255, 193, 7, 0.3);
            border-radius: 16px;
            padding: 1.5rem;
            color: #8a6d3b;
            display: flex;
            gap: 1rem;
        }

        .awaiting-box i {
            font-size: 1.75rem;
        }

        .module-grid {
            margin: clamp(2.5rem, 5vw, 4rem);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 1.75rem;
        }

        .module-card {
            background: white;
            border-radius: 18px;
            padding: 1.9rem;
            min-height: 240px;
            box-shadow: 0 16px 30px rgba(15, 49, 96, 0.12);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            border: 1px solid rgba(0, 0, 0, 0.04);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .module-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 36px rgba(15, 49, 96, 0.16);
        }

        .module-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: rgba(0, 158, 219, 0.12);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            color: var(--un-blue);
            margin-bottom: 1.25rem;
        }

        .module-card h3 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--gov-navy);
            margin-bottom: 0.75rem;
        }

        .module-card p {
            color: #627290;
            line-height: 1.6;
            flex: 1;
        }

        .module-card a {
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
            font-weight: 600;
            color: var(--un-dark-blue);
            text-decoration: none;
        }

        .module-card a:hover {
            text-decoration: underline;
        }

        .insight-wrapper {
            margin: clamp(2rem, 5vw, 4rem);
            background: white;
            border-radius: 24px;
            padding: clamp(1.5rem, 4vw, 2.5rem);
            box-shadow: 0 25px 45px rgba(20, 45, 90, 0.12);
        }

        .section-header {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
            margin-bottom: 1.5rem;
        }

        @media (min-width: 768px) {
            .section-header {
                flex-direction: row;
                align-items: flex-end;
                justify-content: space-between;
            }
        }

        .section-copy {
            flex: 1;
            min-width: 240px;
        }

        .section-header h3 {
            margin: 0;
            font-size: 1.45rem;
            color: var(--gov-navy);
        }

        .section-subtitle {
            color: #5d6b88;
            font-size: 0.95rem;
        }

        .section-controls {
            display: flex;
            width: 100%;
            justify-content: flex-start;
            flex-wrap: wrap;
            gap: 0.5rem;
        }

        @media (min-width: 768px) {
            .section-controls {
                width: auto;
                justify-content: flex-end;
            }
        }

        .project-scope-form {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .project-scope-form label {
            font-weight: 600;
            color: #4a5672;
            margin: 0;
        }

        .project-scope-form select {
            min-width: 220px;
        }

        .scope-chip {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            background: rgba(29, 79, 145, 0.12);
            color: var(--gov-navy);
            border-radius: 999px;
            padding: 0.2rem 0.75rem;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.75rem;
        }

        .summary-card {
            border-radius: 18px;
            padding: 1.25rem;
            background: linear-gradient(135deg, rgba(0,158,219,0.08), rgba(29,79,145,0.08));
            border: 1px solid rgba(0, 0, 0, 0.04);
        }

        .summary-label {
            font-size: 0.9rem;
            color: #5f6d86;
        }

        .summary-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--gov-navy);
        }

        .summary-hint {
            font-size: 0.85rem;
            color: #7f8ba5;
        }

        .chart-selector-container {
            margin-top: 1.5rem;
        }

        .chart-card {
            background: #fafcfe;
            border-radius: 20px;
            padding: 2rem;
            border: 1px solid rgba(0, 0, 0, 0.03);
            box-shadow: inset 0 0 0 1px rgba(255,255,255,0.4), 0 20px 40px rgba(56,80,120,0.08);
            min-height: 500px;
        }

        .chart-content {
            width: 100%;
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .chart-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 0.5rem;
        }

        .chart-card-header h4 {
            margin: 0;
            font-size: 1.1rem;
            color: var(--gov-navy);
        }

        .chip {
            padding: 0.25rem 0.7rem;
            border-radius: 999px;
            font-size: 0.8rem;
            font-weight: 600;
            color: white;
        }

        .chip.success {
            background: linear-gradient(135deg, #4ecdc4, #2a9d8f);
        }

        .chip.neutral {
            background: linear-gradient(135deg, #a8b5d6, #8794b0);
        }

        .chart-hint {
            font-size: 0.8rem;
            color: #8a96ad;
        }

        #quality-donut {
            width: 100%;
            height: 400px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            flex-direction: column;
            gap: 1rem;
        }

        #quality-donut canvas {
            max-width: 320px;
            max-height: 320px;
        }

        .quality-empty {
            display: none;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #7a829c;
            font-size: 0.95rem;
            padding: 1rem;
            border: 1px dashed #dfe4f2;
            border-radius: 12px;
            width: 100%;
            max-width: 360px;
        }

        .quality-empty.active {
            display: flex;
        }

        .quality-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 0.5rem;
        }

        .quality-list li {
            font-size: 0.9rem;
            color: #56607a;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        .quality-dot {
            width: 12px;
            height: 12px;
            border-radius: 999px;
            display: inline-block;
        }

        .text-capitalize {
            text-transform: capitalize;
        }

        .external-link-section {
            margin: clamp(1.5rem, 5vw, 4rem);
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.25rem;
        }

        .external-card {
            background: white;
            border-radius: 20px;
            padding: 1.75rem;
            border: 1px solid rgba(0, 0, 0, 0.05);
            box-shadow: 0 18px 34px rgba(15, 49, 96, 0.12);
            display: flex;
            flex-direction: column;
            gap: 1rem;
        }

        .external-icon {
            width: 52px;
            height: 52px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.6rem;
        }

        .external-icon.odk {
            background: linear-gradient(135deg, #ffb347, #ff7e5f);
        }

        .external-icon.metabase {
            background: linear-gradient(135deg, #7f7fff, #3c6ff0);
        }

        .external-card h3 {
            margin: 0.5rem 0 0;
            font-size: 1.3rem;
            color: var(--gov-navy);
            font-weight: 700;
        }

        .external-card p {
            margin: 0;
            color: #60708f;
            line-height: 1.6;
        }

        .external-chip {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.35rem 0.9rem;
            border-radius: 999px;
            font-size: 0.85rem;
            background: rgba(0, 158, 219, 0.12);
            color: var(--un-dark-blue);
            font-weight: 600;
            width: fit-content;
        }

        .external-btn {
            border: none;
            border-radius: 14px;
            padding: 0.75rem 1.1rem;
            color: white;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.35rem;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .external-btn.odk {
            background: linear-gradient(135deg, #ff9a3c, #ff7a18);
            box-shadow: 0 12px 24px rgba(255, 122, 24, 0.25);
        }

        .external-btn.metabase {
            background: linear-gradient(135deg, #6a8dff, #4a60ff);
            box-shadow: 0 12px 24px rgba(74, 96, 255, 0.25);
        }

        .external-btn:hover {
            transform: translateY(-2px);
        }

        .external-btn.disabled {
            background: rgba(96, 112, 143, 0.3);
            color: rgba(255, 255, 255, 0.8);
            box-shadow: none;
            cursor: not-allowed;
            pointer-events: none;
        }

        .external-hint {
            font-size: 0.85rem;
            color: #9aa5b4;
        }

        .metabase-wrapper {
            margin: clamp(1.5rem, 5vw, 4rem);
            background: white;
            border-radius: 22px;
            padding: clamp(1.75rem, 4vw, 2.5rem);
            box-shadow: 0 20px 45px rgba(15, 49, 96, 0.16);
        }

        .metabase-wrapper h3 {
            font-weight: 700;
            color: var(--gov-navy);
            margin-bottom: 1.25rem;
        }

        .metabase-iframe {
            width: 100%;
            height: 620px;
            border: none;
            border-radius: 18px;
            background: #f8fbff;
        }

        .metabase-card-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 0.5rem;
        }

        .metabase-card-frame {
            background: linear-gradient(135deg, rgba(0, 158, 219, 0.08), rgba(29, 79, 145, 0.08));
            border-radius: 18px;
            padding: 0.75rem;
            box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05), 0 14px 26px rgba(15, 49, 96, 0.12);
        }

        .metabase-card-frame iframe {
            width: 100%;
            height: 360px;
            border: none;
            border-radius: 14px;
            background: white;
        }

        .metabase-placeholder {
            border: 1px dashed rgba(0, 0, 0, 0.15);
            border-radius: 16px;
            padding: 2rem;
            text-align: center;
            color: #708096;
        }

        .footer {
            margin-top: auto;
            padding: 2rem;
            text-align: center;
            color: #9aa5b4;
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
<div class="page">
    <header class="topbar">
        <div>
            <h1>환영합니다, ${username} 님</h1>
            <div class="text-muted mt-2">LINC 국제협력 프로젝트 통합관리 대시보드</div>
        </div>
        <div class="topbar-actions">
            <div class="user-pill">
                <i class="bi bi-person-circle" style="font-size: 1.4rem; color: var(--un-blue);"></i>
                <span>${username}</span>
            </div>
            <a href="${pageContext.request.contextPath}/logout.do" class="logout-btn">
                <i class="bi bi-box-arrow-right"></i>
                로그아웃
            </a>
        </div>
    </header>

    <section class="hero">
        <!-- 접근 거부 에러 메시지 -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert" style="margin: 0 0 1.5rem 0; border-radius: 12px; border-left: 4px solid #ff6b6b;">
                <i class="bi bi-exclamation-triangle-fill me-2"></i>
                <strong>접근 거부:</strong> ${errorMessage}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <script>
                // 3초 후 자동으로 메시지 제거
                setTimeout(function() {
                    var alertNode = document.querySelector('.alert');
                    if (!alertNode) {
                        return;
                    }
                    if (window.bootstrap && typeof bootstrap.Alert === 'function') {
                        try {
                            var bsAlert = new bootstrap.Alert(alertNode);
                            bsAlert.close();
                        } catch (e) {
                            alertNode.parentNode && alertNode.parentNode.removeChild(alertNode);
                        }
                    } else {
                        alertNode.parentNode && alertNode.parentNode.removeChild(alertNode);
                    }
                }, 3000);
            </script>
        </c:if>

        <div>
            <h2>오늘도 안전한 데이터 거버넌스를 시작해보세요.</h2>
            <p>
                역할 기반 권한 제어, 실시간 모니터링, 외부 플랫폼 연동까지
                하나의 포털에서 통합 관리가 가능합니다. 필요한 기능을 선택하여 업무를 시작하세요.
            </p>
        </div>
        <div class="status-card">
            <div class="status-title">
                <i class="bi bi-activity"></i>
                현재 이용 권한 상태
            </div>

            <c:if test="${awaitingApproval}">
                <div class="awaiting-box">
                    <i class="bi bi-hourglass-split"></i>
                    <div>
                        <strong>관리자 승인 대기 중입니다.</strong>
                        <div>권한이 부여되면 안내 드리며, 필요 시 관리자에게 승인 요청을 전달해주세요.</div>
                    </div>
                </div>
            </c:if>

            <ul class="list-unstyled mt-3 mb-0" style="color: #627290;">
                <li class="mb-2">
                    <i class="bi ${canViewProjects ? 'bi-check-circle-fill text-success' : 'bi-dash-circle text-muted'}"></i>
                    프로젝트 열람 권한
                </li>
                <li class="mb-2">
                    <i class="bi ${canManageProjects ? 'bi-check-circle-fill text-success' : 'bi-dash-circle text-muted'}"></i>
                    프로젝트 생성/수정 권한
                </li>
                <li class="mb-2">
                    <i class="bi ${canAssignRoles ? 'bi-check-circle-fill text-success' : 'bi-dash-circle text-muted'}"></i>
                    역할 배정 권한
                </li>
                <li>
                    <i class="bi ${canManageRoles ? 'bi-check-circle-fill text-success' : 'bi-dash-circle text-muted'}"></i>
                    역할/권한 관리 권한
                </li>
            </ul>
        </div>
    </section>

    <c:if test="${not empty analyticsPayload}">
        <section class="insight-wrapper">
            <div class="section-header">
                <div class="section-copy">
                    <h3>프로젝트 통계 &amp; 예측</h3>
                    <div class="section-subtitle">
                        ODK Central 원천 데이터를 직접 집계하고 XGBoost · Linear Regression · Exponential Smoothing으로 향후 2주를 예측했습니다.
                    </div>
                    <c:if test="${not empty selectedProjectId}">
                        <div class="scope-chip">
                            <i class="bi bi-funnel"></i>
                            ${selectedProjectName}
                        </div>
                    </c:if>
                </div>
                <div class="section-controls">
                    <form id="project-scope-form"
                          class="project-scope-form"
                          method="get"
                          action="${pageContext.request.contextPath}/dashboard.do">
                        <label for="project-scope-select">프로젝트 범위</label>
                        <select id="project-scope-select" name="projectId" class="form-select form-select-sm">
                            <option value="" <c:if test="${empty selectedProjectId}">selected</c:if>>전체 프로젝트</option>
                            <c:forEach var="project" items="${projectOptions}">
                                <option value="${project.id}" <c:if test="${project.id eq selectedProjectId}">selected</c:if>>
                                    ${project.name}
                                </option>
                            </c:forEach>
                        </select>
                    </form>
                </div>
            </div>

            <div class="summary-grid">
                <div class="summary-card">
                    <div class="summary-label">총 프로젝트</div>
                    <div class="summary-value">${analyticsPayload.summary.totalProjects}</div>
                    <div class="summary-hint">운영 폼 ${analyticsPayload.summary.activeForms}개</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">총 제출 수</div>
                    <div class="summary-value">${analyticsPayload.summary.totalSubmissions}</div>
                    <div class="summary-hint">최근 30일 기준</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">품질 경보</div>
                    <div class="summary-value">${analyticsPayload.summary.qualityAlerts}</div>
                    <div class="summary-hint">Flagged · Under Review</div>
                </div>
                <div class="summary-card">
                    <div class="summary-label">예상 일별 평균</div>
                    <div class="summary-value">${analyticsPayload.summary.forecastedDailyAverage}</div>
                    <div class="summary-hint">
                        주간 증감
                        <c:choose>
                            <c:when test="${analyticsPayload.summary.weekOverWeekGrowth >= 0}">
                                +${analyticsPayload.summary.weekOverWeekGrowth}%
                            </c:when>
                            <c:otherwise>
                                ${analyticsPayload.summary.weekOverWeekGrowth}%
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="chart-selector-container">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h3 class="mb-0">통계 차트</h3>
                    <select id="chart-selector" class="form-select" style="width: auto;">
                        <option value="submission-trend">일별 제출 추이 &amp; 예측</option>
                        <option value="project-contribution">프로젝트 기여도</option>
                        <option value="quality-status">품질 심사 현황</option>
                    </select>
                </div>

                <div class="chart-card">
                    <div id="chart-submission-trend" class="chart-content active">
                        <div class="chart-card-header">
                            <h4>일별 제출 추이 &amp; 예측 모델</h4>
                            <span class="chip success">XGBoost · Linear · EMA</span>
                        </div>
                        <canvas id="submission-trend-chart" height="380"></canvas>
                        <div class="chart-hint">점선 구간은 향후 14일 예측 값입니다.</div>
                    </div>
                    <div id="chart-project-contribution" class="chart-content" style="display: none;">
                        <div class="chart-card-header">
                            <h4>프로젝트별 기여도</h4>
                            <span class="chip neutral">Chart.js Bar</span>
                        </div>
                        <canvas id="project-bar-chart" height="380"></canvas>
                        <div class="chart-hint">상위 5개 프로젝트 기준</div>
                    </div>
                        <div id="chart-quality-status" class="chart-content" style="display: none;">
                            <div class="chart-card-header">
                                <h4>품질 심사 현황</h4>
                                <span class="chip neutral">Chart.js Doughnut</span>
                            </div>
                            <div id="quality-donut">
                                <canvas id="quality-donut-chart" height="320"></canvas>
                                <div id="quality-donut-empty" class="quality-empty">
                                    <i class="bi bi-emoji-neutral mb-2" style="font-size: 1.5rem;"></i>
                                    <span>표시할 품질 데이터가 없습니다.</span>
                                </div>
                            </div>
                            <ul class="quality-list mt-3">
                                <c:forEach var="quality" items="${analyticsPayload.qualityStats}">
                                    <li>
                                        <span class="quality-dot" data-status="${quality.status}"></span>
                                        <span class="text-capitalize">${quality.status}</span>
                                    <strong>${quality.count}</strong>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </div>
            </div>
        </section>
    </c:if>

    <c:if test="${not empty odkExternalUrl or not empty metabaseConsoleUrl}">
        <section class="external-link-section">
            <article class="external-card">
                <div class="external-icon odk">
                    <i class="bi bi-collection"></i>
                </div>
                <h3>ODK Central 현장 수집 허브</h3>
                <p>모바일 ODK Collect와 동기화되는 관리 콘솔입니다. 폼 배포·계정 관리·제출 현황까지 한 번에 확인하세요.</p>
                <span class="external-chip">
                    <i class="bi bi-link-45deg"></i>
                    포트 8383
                </span>
                <c:choose>
                    <c:when test="${not empty odkExternalUrl}">
                        <a href="${odkExternalUrl}"
                           target="_blank"
                           rel="noopener noreferrer"
                           class="external-btn odk">
                            <i class="bi bi-box-arrow-up-right"></i>
                            ODK Central 열기
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="external-btn disabled">
                            URL 미설정
                        </div>
                        <div class="external-hint">.env의 ODK_EXTERNAL_URL을 설정하세요.</div>
                    </c:otherwise>
                </c:choose>
                <div class="external-hint">새 탭에서 열립니다.</div>
            </article>

            <article class="external-card">
                <div class="external-icon metabase">
                    <i class="bi bi-bar-chart-line"></i>
                </div>
                <h3>Metabase 분석 콘솔</h3>
                <p>카드 편집·대시보드 구성·권한 관리를 위해 Metabase 관리 화면으로 이동합니다.</p>
                <span class="external-chip">
                    <i class="bi bi-link-45deg"></i>
                    포트 3000
                </span>
                <c:choose>
                    <c:when test="${not empty metabaseConsoleUrl}">
                        <a href="${metabaseConsoleUrl}"
                           target="_blank"
                           rel="noopener noreferrer"
                           class="external-btn metabase">
                            <i class="bi bi-box-arrow-up-right"></i>
                            Metabase 열기
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="external-btn disabled">
                            URL 미설정
                        </div>
                        <div class="external-hint">MB_EMBED_EXTERNAL_BASE_URL 또는 MB_BASE_URL을 확인하세요.</div>
                    </c:otherwise>
                </c:choose>
                <div class="external-hint">브라우저 새 탭에서 바로 확인할 수 있습니다.</div>
            </article>
        </section>
    </c:if>

    <c:if test="${not empty metabaseDashboardUrl or not empty metabaseCardEmbeds}">
        <section class="metabase-wrapper">
            <div class="d-flex justify-content-between align-items-center flex-wrap mb-3" style="gap: 0.5rem;">
                <h3 class="mb-0">Metabase 실시간 지표</h3>
                <small class="text-muted">Signed Embed · 10분마다 토큰 갱신</small>
            </div>
            <c:if test="${not empty metabaseDashboardUrl}">
                <iframe class="metabase-iframe"
                        src="${metabaseDashboardUrl}"
                        allowtransparency="true"
                        frameborder="0"
                        allowfullscreen></iframe>
            </c:if>
            <c:if test="${empty metabaseDashboardUrl and not empty metabaseCardEmbeds}">
                <div class="metabase-card-grid">
                    <c:forEach var="embed" items="${metabaseCardEmbeds}">
                        <div class="metabase-card-frame">
                            <iframe src="${embed}"
                                    allowtransparency="true"
                                    frameborder="0"
                                    allowfullscreen></iframe>
                        </div>
                    </c:forEach>
                </div>
            </c:if>
            <c:if test="${empty metabaseDashboardUrl and empty metabaseCardEmbeds}">
                <div class="metabase-placeholder">
                    <i class="bi bi-activity me-2"></i>
                    Metabase 임베드 구성이 아직 완료되지 않았습니다.
                </div>
            </c:if>
        </section>
    </c:if>

    <section class="module-grid">
        <c:if test="${canViewProjects}">
            <div class="module-card">
                <div>
                    <div class="module-icon">
                        <i class="bi bi-folder"></i>
                    </div>
                    <h3>프로젝트 현황</h3>
                    <p>프로젝트 목록, 상세 정보, 수집된 현장 데이터를 열람하고 분석할 수 있습니다.</p>
                </div>
                <a href="${pageContext.request.contextPath}/projects/list.do">
                    프로젝트 바로가기 <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </c:if>

        <c:if test="${canManageProjects}">
            <div class="module-card">
                <div>
                    <div class="module-icon">
                        <i class="bi bi-pencil-square"></i>
                    </div>
                    <h3>프로젝트 관리</h3>
                    <p>새로운 국제협력 과제를 개설하고, 코드북·제출 정책을 설정하여 체계적으로 운영하세요.</p>
                </div>
                <a href="${pageContext.request.contextPath}/projects/create.do">
                    생성하기 <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </c:if>

        <c:if test="${canManageRoles}">
            <div class="module-card">
                <div>
                    <div class="module-icon">
                        <i class="bi bi-shield-check"></i>
                    </div>
                    <h3>역할/권한 템플릿</h3>
                    <p>업무 유형별 표준 역할을 정의하고, 필요한 권한 묶음을 구성하여 조직 정책을 반영합니다.</p>
                </div>
                <a href="${pageContext.request.contextPath}/rbac/roles.do">
                    역할 관리하기 <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </c:if>

        <c:if test="${canAssignRoles}">
            <div class="module-card">
                <div>
                    <div class="module-icon">
                        <i class="bi bi-people"></i>
                    </div>
                    <h3>구성원 권한 배정</h3>
                    <p>신규 등록 사용자에게 프로젝트 단위의 역할을 부여하고, 유효 기간을 관리합니다.</p>
                </div>
                <a href="${pageContext.request.contextPath}/rbac/assignments.do">
                    배정 관리 <i class="bi bi-arrow-right"></i>
                </a>
            </div>
        </c:if>

        <c:if test="${awaitingApproval}">
            <div class="module-card" style="border-style: dashed; border-color: #cfd6e5;">
                <div>
                    <div class="module-icon" style="background: rgba(255, 193, 7, 0.2); color: #d39e00;">
                        <i class="bi bi-bell"></i>
                    </div>
                    <h3>승인 안내</h3>
                    <p>현재 사용할 수 있는 모듈이 없습니다. 관리자에게 권한 승인을 요청하거나 시스템 관리팀에 문의하세요.</p>
                </div>
                <span class="text-muted fw-semibold">
                    담당자: admin@linc.gov (내부용)
                </span>
            </div>
        </c:if>
    </section>

    <footer class="footer">
        © 2025 LINC Project Management System. All rights reserved.
    </footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<c:if test="${not empty analyticsJson}">
    <script type="application/json" id="analytics-data">
        <c:out value="${analyticsJson}" escapeXml="false"/>
    </script>
    <script>
        (function() {
            const analyticsNode = document.getElementById('analytics-data');
            if (!analyticsNode) {
                return;
            }
            const analytics = JSON.parse(analyticsNode.textContent || '{}');
            if (!analytics || !analytics.dailyStats) {
                return;
            }

            const modelLabels = {
                linearRegression: 'Linear Regression',
                exponentialSmoothing: 'Exponential Moving Average',
                gradientBoosting: 'XGBoost Gradient Boosting'
            };

            const modelColors = {
                linearRegression: '#ff6b6b',
                exponentialSmoothing: '#4ecdc4',
                gradientBoosting: '#7c4dff'
            };
            const qualityPalette = ['#ff6b6b', '#f9c74f', '#4ecdc4', '#7c4dff'];

            function buildSubmissionTrend() {
                const ctx = document.getElementById('submission-trend-chart');
                if (!ctx) {
                    return;
                }
                const actualDataset = {
                    label: '실제 제출',
                    data: analytics.dailyStats.map(point => ({x: point.date, y: point.submissions})),
                    borderColor: '#1d4f91',
                    backgroundColor: 'rgba(29,79,145,0.15)',
                    fill: true,
                    tension: 0.3,
                    borderWidth: 2
                };

                const flaggedDataset = {
                    label: '품질 경보',
                    data: analytics.dailyStats.map(point => ({x: point.date, y: point.flagged})),
                    borderColor: '#f39c12',
                    backgroundColor: 'rgba(243,156,18,0.35)',
                    type: 'bar',
                    yAxisID: 'y1',
                    borderWidth: 0,
                    barPercentage: 0.45
                };

                const predictionDatasets = [];
                Object.keys(analytics.predictions || {}).forEach(key => {
                    const series = analytics.predictions[key];
                    if (!series || series.length === 0) {
                        return;
                    }
                    predictionDatasets.push({
                        label: modelLabels[key] || key,
                        data: series.map(point => ({x: point.date, y: point.value})),
                        borderColor: modelColors[key] || '#999',
                        backgroundColor: 'transparent',
                        borderDash: [6, 4],
                        borderWidth: 2,
                        pointRadius: series.map(point => point.projected ? 0 : 3),
                        pointHoverRadius: 4,
                        tension: 0.35
                    });
                });

                new Chart(ctx, {
                    type: 'line',
                    data: {
                        datasets: [
                            actualDataset,
                            flaggedDataset,
                            ...predictionDatasets
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        interaction: {
                            mode: 'index',
                            intersect: false
                        },
                        stacked: false,
                        layout: {
                            padding: {
                                left: 10,
                                right: 10,
                                top: 20,
                                bottom: 10
                            }
                        },
                        scales: {
                            x: {
                                type: 'category',
                                ticks: {
                                    maxTicksLimit: 10,
                                    autoSkip: true,
                                    maxRotation: 45,
                                    minRotation: 0,
                                    padding: 8
                                },
                                grid: {
                                    display: true,
                                    drawBorder: true,
                                    drawOnChartArea: true,
                                    drawTicks: true
                                }
                            },
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: '제출 수'
                                },
                                ticks: {
                                    padding: 8
                                },
                                grid: {
                                    drawBorder: true
                                }
                            },
                            y1: {
                                position: 'right',
                                beginAtZero: true,
                                grid: { drawOnChartArea: false, drawBorder: true },
                                title: {
                                    display: true,
                                    text: '품질 경보'
                                },
                                ticks: {
                                    padding: 8
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    padding: 15,
                                    boxWidth: 12,
                                    boxHeight: 12,
                                    font: {
                                        size: 11
                                    }
                                }
                            }
                        }
                    }
                });
            }

            function buildProjectBar() {
                const ctx = document.getElementById('project-bar-chart');
                if (!ctx || !analytics.topProjects) {
                    return;
                }
                const labels = analytics.topProjects.map(project => project.name);
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels,
                        datasets: [{
                            label: '제출 수',
                            data: analytics.topProjects.map(project => project.submissions),
                            backgroundColor: labels.map((_, idx) => `rgba(0,158,219,${0.25 + idx * 0.1})`),
                            borderColor: 'rgba(0,158,219,0.85)',
                            borderWidth: 1.5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: true,
                        layout: {
                            padding: {
                                left: 10,
                                right: 10,
                                top: 20,
                                bottom: 10
                            }
                        },
                        scales: {
                            x: {
                                ticks: {
                                    autoSkip: true,
                                    maxRotation: 45,
                                    minRotation: 0,
                                    padding: 8
                                },
                                grid: {
                                    display: false
                                }
                            },
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    padding: 8
                                },
                                grid: {
                                    drawBorder: true
                                }
                            }
                        },
                        plugins: { legend: { display: false } }
                    }
                });
            }

            let donutResizeTimer;
            let qualityChart;
            let donutNeedsInit = true;

            function normalizeCount(value) {
                if (typeof value === 'number') {
                    return value;
                }
                if (typeof value === 'string') {
                    const stripped = value.replace(/,/g, '').trim();
                    return stripped ? Number(stripped) || 0 : 0;
                }
                return 0;
            }

            function prepareQualityStats(source) {
                return (source || []).map(stat => ({
                    status: stat && stat.status ? stat.status : 'unknown',
                    count: normalizeCount(stat ? stat.count : 0)
                }));
            }

            function formatStatusLabel(status) {
                const safe = (status || 'unknown').replace(/_/g, ' ');
                return safe.replace(/\b\w/g, char => char.toUpperCase());
            }

            function applyLegendColors(stats, colorMap) {
                document.querySelectorAll('.quality-dot').forEach(dot => {
                    const status = dot.getAttribute('data-status');
                    dot.style.background = colorMap.get(status) || '#dfe4f2';
                });
            }

            function toggleDonutPlaceholder(show) {
                const canvas = document.getElementById('quality-donut-chart');
                const placeholder = document.getElementById('quality-donut-empty');
                if (!canvas || !placeholder) {
                    return;
                }
                canvas.style.display = show ? 'none' : 'block';
                placeholder.classList.toggle('active', show);
            }

            function buildQualityDonut(force = false) {
                const container = document.getElementById('quality-donut');
                const canvas = document.getElementById('quality-donut-chart');
                if (!container || !canvas) {
                    return;
                }
                const visible = container.offsetWidth > 0 && container.offsetHeight > 0;
                if (!visible && !force) {
                    donutNeedsInit = true;
                    return;
                }
                const stats = prepareQualityStats(analytics.qualityStats);
                const dataset = stats.some(stat => stat.count > 0)
                    ? stats.filter(stat => stat.count > 0)
                    : stats;
                if (!dataset.length || dataset.every(stat => stat.count === 0)) {
                    toggleDonutPlaceholder(true);
                    if (qualityChart) {
                        qualityChart.destroy();
                        qualityChart = null;
                    }
                    donutNeedsInit = false;
                    const fallbackColors = new Map();
                    stats.forEach((stat, idx) => fallbackColors.set(stat.status, qualityPalette[idx % qualityPalette.length]));
                    applyLegendColors(stats, fallbackColors);
                    return;
                }
                toggleDonutPlaceholder(false);
                const labels = dataset.map(stat => formatStatusLabel(stat.status));
                const data = dataset.map(stat => stat.count);
                const colors = dataset.map((_, idx) => qualityPalette[idx % qualityPalette.length]);

                if (qualityChart) {
                    qualityChart.data.labels = labels;
                    qualityChart.data.datasets[0].data = data;
                    qualityChart.data.datasets[0].backgroundColor = colors;
                    qualityChart.update();
                } else {
                    qualityChart = new Chart(canvas, {
                        type: 'doughnut',
                        data: {
                            labels,
                            datasets: [{
                                data,
                                backgroundColor: colors,
                                borderColor: '#ffffff',
                                borderWidth: 2,
                                hoverOffset: 6
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '60%',
                            plugins: {
                                legend: {
                                    display: false
                                },
                                tooltip: {
                                    callbacks: {
                                        label(context) {
                                            const value = context.parsed || 0;
                                            const datasetValues = (context.dataset && context.dataset.data) || [];
                                            const total = datasetValues.reduce((sum, entry) => sum + entry, 0);
                                            const percent = total ? ((value / total) * 100).toFixed(1) : 0;
                                            return `${context.label}: ${value} (${percent}%)`;
                                        }
                                    }
                                }
                            }
                        }
                    });
                }

                const colorMap = new Map();
                dataset.forEach((stat, idx) => colorMap.set(stat.status, colors[idx]));
                stats.forEach((stat, idx) => {
                    if (!colorMap.has(stat.status)) {
                        colorMap.set(stat.status, qualityPalette[idx % qualityPalette.length]);
                    }
                });
                applyLegendColors(stats, colorMap);
                donutNeedsInit = false;
            }

            buildSubmissionTrend();
            buildProjectBar();
            buildQualityDonut(false);

            // Chart selector functionality
            const chartSelector = document.getElementById('chart-selector');
            if (chartSelector) {
                chartSelector.addEventListener('change', function() {
                    const selectedChart = this.value;
                    document.querySelectorAll('.chart-content').forEach(content => {
                        const isActive = content.id === 'chart-' + selectedChart;
                        content.style.display = isActive ? 'flex' : 'none';
                        content.classList.toggle('active', isActive);
                    });
                    if (selectedChart === 'quality-status') {
                        requestAnimationFrame(() => buildQualityDonut(true));
                    }
                });
            }

            const projectScopeSelect = document.getElementById('project-scope-select');
            if (projectScopeSelect && projectScopeSelect.form) {
                projectScopeSelect.addEventListener('change', () => {
                    projectScopeSelect.form.submit();
                });
            }

            window.addEventListener('resize', () => {
                clearTimeout(donutResizeTimer);
                donutResizeTimer = setTimeout(() => {
                    if (qualityChart) {
                        qualityChart.resize();
                    } else if (donutNeedsInit) {
                        buildQualityDonut(true);
                    }
                }, 150);
            });
        })();
    </script>
</c:if>
</body>
</html>
