<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>프로젝트 통계 - ${project.name}</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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

        .card-panel {
            background: white;
            border-radius: 4px;
            padding: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
        }

        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1rem;
        }

        .stat-tile {
            border-radius: 18px;
            padding: 1.25rem;
            background: linear-gradient(135deg, rgba(0,158,219,0.1), rgba(29,79,145,0.08));
        }

        .stat-label {
            font-size: 0.85rem;
            color: #5b6a8c;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--gov-navy);
        }

        .chart-selector-container {
            margin-top: 1.5rem;
        }

        .chart-card {
            border-radius: 4px;
            background: white;
            padding: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            min-height: 500px;
        }

        .chart-content {
            width: 100%;
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
            max-width: 360px;
            max-height: 360px;
        }

        .quality-empty {
            display: none;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #6f7895;
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
            margin: 0.5rem 0 0;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 0.4rem;
        }

        .quality-list li {
            display: flex;
            align-items: center;
            gap: 0.4rem;
            font-size: 0.9rem;
            color: #58607a;
        }

        .quality-dot {
            width: 12px;
            height: 12px;
            border-radius: 999px;
        }

        .text-capitalize {
            text-transform: capitalize;
        }

        .config-card {
            margin-bottom: 2rem;
        }

        .config-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 1rem;
        }

        .config-grid label {
            font-weight: 600;
            color: #4a5672;
            margin-bottom: 0.4rem;
        }

        .config-grid select,
        .config-grid input {
            width: 100%;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 0.55rem 0.75rem;
        }

        .model-toggles {
            display: flex;
            flex-direction: column;
            gap: 0.35rem;
            padding: 0.35rem 0;
        }

        .config-note {
            font-size: 0.85rem;
            color: #6c7a96;
        }

        .btn-primary-custom,
        .btn-soft {
            background: linear-gradient(to right, var(--un-blue) 0%, #0088c5 100%);
            border: none;
            padding: 0.875rem 2rem;
            border-radius: 4px;
            font-weight: 600;
            color: white;
            text-decoration: none;
            display: inline-flex;
            gap: 0.5rem;
            align-items: center;
            box-shadow: 0 4px 10px rgba(0, 158, 219, 0.25);
            transition: all 0.3s ease;
        }

        .btn-primary-custom:hover,
        .btn-soft:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0, 158, 219, 0.35);
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
        <div class="d-flex justify-content-between flex-wrap align-items-center">
            <div>
                <h2 class="page-title">${project.name}</h2>
                <p class="page-subtitle">프로젝트 통계 &amp; 예측 · Metabase 없이도 내장형 분석</p>
            </div>
            <div class="d-flex gap-2 flex-wrap">
                <a class="btn btn-soft" href="${pageContext.request.contextPath}/dashboard.do">
                    <i class="bi bi-speedometer2"></i> 대시보드
                </a>
                <a class="btn btn-soft" href="${pageContext.request.contextPath}/projects/${project.id}/detail.do">
                    <i class="bi bi-arrow-left"></i> 상세로 이동
                </a>
            </div>
        </div>
    </div>

    <div class="card-panel">
        <div class="d-flex justify-content-between flex-wrap align-items-center mb-3">
            <div>
                <div class="text-muted text-uppercase" style="letter-spacing: 0.08em; font-size: 0.8rem;">요약</div>
                <h3 class="fw-bold mb-0">데이터 현황</h3>
            </div>
            <div class="text-muted small">최근 ${analyticsPayload.dailyStats.size()}일 기준</div>
        </div>
        <div class="stat-grid">
            <div class="stat-tile">
                <div class="stat-label">총 제출 수</div>
                <div class="stat-value">${analyticsPayload.summary.totalSubmissions}</div>
                <div class="text-muted small">프로젝트 누적 값</div>
            </div>
            <div class="stat-tile">
                <div class="stat-label">운영 중인 폼</div>
                <div class="stat-value">${analyticsPayload.summary.activeForms}</div>
                <div class="text-muted small">연동된 ODK 폼 수</div>
            </div>
            <div class="stat-tile">
                <div class="stat-label">품질 경보</div>
                <div class="stat-value">${analyticsPayload.summary.qualityAlerts}</div>
                <div class="text-muted small">Flagged + Under Review</div>
            </div>
            <div class="stat-tile">
                <div class="stat-label">예상 일별 평균</div>
                <div class="stat-value">${analyticsPayload.summary.forecastedDailyAverage}</div>
                <div class="text-muted small">
                    주간 증감 ${analyticsPayload.summary.weekOverWeekGrowth >= 0 ? '+' : ''}${analyticsPayload.summary.weekOverWeekGrowth}%
                </div>
            </div>
        </div>
    </div>

    <div class="card-panel config-card">
        <div class="d-flex justify-content-between flex-wrap align-items-center mb-3">
            <h3 class="fw-bold mb-0">시각화 옵션</h3>
            <div class="config-note">
                실제 프로젝트에 맞춰 색상/지표 이름을 바꾸고 싶으면 아래 옵션을 활용하세요.
            </div>
        </div>
        <div class="config-grid">
            <div>
                <label for="colorSchemeSelect">색상 팔레트</label>
                <select id="colorSchemeSelect" class="form-select">
                    <option value="unblue">UN Blue (기본)</option>
                    <option value="forest">Forest</option>
                    <option value="sunset">Sunset</option>
                </select>
            </div>
            <div>
                <label for="customLabelInput">폼 이름 커스터마이징 (쉼표 구분)</label>
                <input type="text" id="customLabelInput" placeholder="예: 보건폼A, 커뮤니티보고B, 현장점검C">
                <small class="config-note">실제 현장 폼 이름을 입력하면 그래프에 즉시 반영됩니다.</small>
            </div>
            <div>
                <label>예측 모델 표시</label>
                <div class="model-toggles">
                    <label><input type="checkbox" class="prediction-toggle" data-model="linearRegression" checked> Linear Regression</label>
                    <label><input type="checkbox" class="prediction-toggle" data-model="exponentialSmoothing" checked> Exponential Moving Average</label>
                    <label><input type="checkbox" class="prediction-toggle" data-model="gradientBoosting" checked> XGBoost Gradient Boosting</label>
                </div>
            </div>
        </div>
    </div>

    <c:if test="${not empty analyticsPayload}">
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
                    <canvas id="submission-trend-chart" height="380"></canvas>
                    <small class="text-muted d-block mt-2">점선은 향후 14일 예측 (선택한 모델 기준)</small>
                </div>
                <div id="chart-project-contribution" class="chart-content" style="display: none;">
                    <canvas id="project-bar-chart" height="380"></canvas>
                    <small class="text-muted d-block mt-2">상위 수집 채널 기준</small>
                </div>
                    <div id="chart-quality-status" class="chart-content" style="display: none;">
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
    </c:if>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<c:if test="${not empty analyticsJson}">
    <script type="application/json" id="analytics-data">
        <c:out value="${analyticsJson}" escapeXml="false"/>
    </script>
    <script>
        (function () {
            const node = document.getElementById('analytics-data');
            if (!node) return;
            const analytics = JSON.parse(node.textContent || '{}');
            if (!analytics.dailyStats) return;

            const colorSchemes = {
                unblue: {
                    bars: ['rgba(0,158,219,0.6)', 'rgba(0,158,219,0.45)', 'rgba(0,158,219,0.3)', 'rgba(0,158,219,0.2)', 'rgba(0,158,219,0.15)'],
                    donut: ['#ff6b6b', '#f9c74f', '#4ecdc4', '#7c4dff'],
                    predictions: {
                        linearRegression: '#ff6b6b',
                        exponentialSmoothing: '#4ecdc4',
                        gradientBoosting: '#7c4dff'
                    }
                },
                forest: {
                    bars: ['rgba(46,125,50,0.75)', 'rgba(67,160,71,0.6)', 'rgba(102,187,106,0.45)', 'rgba(129,199,132,0.3)', 'rgba(165,214,167,0.2)'],
                    donut: ['#2f9e44', '#74c0fc', '#f08c00', '#1971c2'],
                    predictions: {
                        linearRegression: '#2f9e44',
                        exponentialSmoothing: '#f08c00',
                        gradientBoosting: '#1971c2'
                    }
                },
                sunset: {
                    bars: ['rgba(255,94,98,0.7)', 'rgba(255,149,0,0.6)', 'rgba(255,196,0,0.45)', 'rgba(255,214,102,0.3)', 'rgba(249,65,68,0.25)'],
                    donut: ['#ff5e62', '#ff9966', '#ffd166', '#c83e4d'],
                    predictions: {
                        linearRegression: '#ff5e62',
                        exponentialSmoothing: '#ffd166',
                        gradientBoosting: '#c83e4d'
                    }
                }
            };

            let currentScheme = 'unblue';
            let submissionChart, projectBarChart, qualityChart, donutResizeTimer;
            let donutNeedsInit = true;
            const donutFallbackPalette = ['#ff6b6b', '#f9c74f', '#4ecdc4', '#7c4dff'];

            const modelLabels = {
                linearRegression: 'Linear Regression',
                exponentialSmoothing: 'Exponential Moving Average',
                gradientBoosting: 'XGBoost Gradient Boosting'
            };

            function buildSubmissionTrend() {
                const ctx = document.getElementById('submission-trend-chart');
                if (!ctx) return;
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
                const predictionDatasets = Object.keys(analytics.predictions || {}).map(key => ({
                    label: modelLabels[key] || key,
                    data: (analytics.predictions[key] || []).map(point => ({x: point.date, y: point.value})),
                    borderColor: colorSchemes[currentScheme].predictions[key] || '#999',
                    backgroundColor: 'transparent',
                    borderDash: [6, 4],
                    borderWidth: 2,
                    pointRadius: (analytics.predictions[key] || []).map(point => point.projected ? 0 : 3),
                    pointHoverRadius: 4,
                    tension: 0.35,
                    key
                }));

                submissionChart = new Chart(ctx, {
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
                        interaction: {mode: 'index', intersect: false},
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
                                    minRotation: 0
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
                                title: {display: true, text: '제출 수'},
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
                                grid: {drawOnChartArea: false, drawBorder: true},
                                title: {display: true, text: '품질 경보'},
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
                if (!ctx || !analytics.topProjects) return;
                const labels = analytics.topProjects.map(project => project.name);
                const colors = colorSchemes[currentScheme].bars;
                projectBarChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels,
                        datasets: [{
                            label: '기여 제출 수',
                            data: analytics.topProjects.map(project => project.submissions),
                            backgroundColor: labels.map((_, idx) => colors[idx % colors.length]),
                            borderColor: 'rgba(0,0,0,0.05)',
                            borderWidth: 1
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
                        plugins: {
                            legend: {display: false}
                        }
                    }
                });
            }

            function normalizeQualityCount(value) {
                if (typeof value === 'number') return value;
                if (typeof value === 'string') {
                    const stripped = value.replace(/,/g, '').trim();
                    return stripped ? Number(stripped) || 0 : 0;
                }
                return 0;
            }

            function prepareQualityStats() {
                return (analytics.qualityStats || []).map(stat => ({
                    status: stat && stat.status ? stat.status : 'unknown',
                    count: normalizeQualityCount(stat ? stat.count : 0)
                }));
            }

            function formatStatusLabel(status) {
                const safe = (status || 'unknown').replace(/_/g, ' ');
                return safe.replace(/\b\w/g, char => char.toUpperCase());
            }

            function toggleDonutPlaceholder(show) {
                const canvas = document.getElementById('quality-donut-chart');
                const placeholder = document.getElementById('quality-donut-empty');
                if (!canvas || !placeholder) return;
                canvas.style.display = show ? 'none' : 'block';
                placeholder.classList.toggle('active', show);
            }

            function applyLegendColors(stats, colorMap, palette) {
                const fallbackPalette = (palette && palette.length) ? palette : donutFallbackPalette;
                document.querySelectorAll('.quality-dot').forEach(dot => {
                    const status = dot.getAttribute('data-status');
                    if (colorMap.has(status)) {
                        dot.style.background = colorMap.get(status);
                    } else {
                        const idx = stats.findIndex(stat => stat.status === status);
                        dot.style.background = fallbackPalette[idx >= 0 ? idx % fallbackPalette.length : 0] || '#dfe4f2';
                    }
                });
            }

            function buildQualityDonut(force = false) {
                const container = document.getElementById('quality-donut');
                const canvas = document.getElementById('quality-donut-chart');
                if (!container || !canvas) return;
                const isVisible = container.offsetWidth > 0 && container.offsetHeight > 0;
                if (!isVisible && !force) {
                    donutNeedsInit = true;
                    return;
                }
                const stats = prepareQualityStats();
                const dataset = stats.some(stat => stat.count > 0)
                    ? stats.filter(stat => stat.count > 0)
                    : stats;
                const palette = (colorSchemes[currentScheme] && colorSchemes[currentScheme].donut) || donutFallbackPalette;
                if (!dataset.length || dataset.every(stat => stat.count === 0)) {
                    toggleDonutPlaceholder(true);
                    if (qualityChart) {
                        qualityChart.destroy();
                        qualityChart = null;
                    }
                    donutNeedsInit = false;
                    const fallbackMap = new Map();
                    stats.forEach((stat, idx) => fallbackMap.set(stat.status, palette[idx % palette.length]));
                    applyLegendColors(stats, fallbackMap, palette);
                    return;
                }
                toggleDonutPlaceholder(false);
                const labels = dataset.map(stat => formatStatusLabel(stat.status));
                const data = dataset.map(stat => stat.count);
                const colors = dataset.map((_, idx) => palette[idx % palette.length]);

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
                                borderColor: '#fff',
                                borderWidth: 2,
                                hoverOffset: 6
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '60%',
                            plugins: {
                                legend: { display: false },
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
                        colorMap.set(stat.status, palette[idx % palette.length]);
                    }
                });
                applyLegendColors(stats, colorMap, palette);
                donutNeedsInit = false;
            }

            function applyColorScheme() {
                currentScheme = document.getElementById('colorSchemeSelect').value;
                if (submissionChart) {
                    submissionChart.data.datasets.forEach(dataset => {
                        if (dataset.key && colorSchemes[currentScheme].predictions[dataset.key]) {
                            dataset.borderColor = colorSchemes[currentScheme].predictions[dataset.key];
                        }
                    });
                    submissionChart.update();
                }
                if (projectBarChart) {
                    const colors = colorSchemes[currentScheme].bars;
                    projectBarChart.data.datasets[0].backgroundColor =
                        projectBarChart.data.labels.map((_, idx) => colors[idx % colors.length]);
                    projectBarChart.update();
                }
                buildQualityDonut(!!qualityChart);
            }

            function applyCustomLabels() {
                const input = document.getElementById('customLabelInput').value;
                if (!input || !projectBarChart) return;
                const labels = input.split(',').map(v => v.trim()).filter(Boolean);
                if (labels.length === 0) return;
                projectBarChart.data.labels = projectBarChart.data.labels.map((label, idx) => labels[idx] || label);
                projectBarChart.update();
            }

            function applyPredictionVisibility() {
                if (!submissionChart) return;
                document.querySelectorAll('.prediction-toggle').forEach(toggle => {
                    const key = toggle.getAttribute('data-model');
                    submissionChart.data.datasets.forEach(dataset => {
                        if (dataset.key === key) {
                            dataset.hidden = !toggle.checked;
                        }
                    });
                });
                submissionChart.update();
            }

            buildSubmissionTrend();
            buildProjectBar();
            buildQualityDonut(false);

            const schemeSelect = document.getElementById('colorSchemeSelect');
            if (schemeSelect) {
                schemeSelect.addEventListener('change', applyColorScheme);
            }
            const labelInput = document.getElementById('customLabelInput');
            if (labelInput) {
                labelInput.addEventListener('change', applyCustomLabels);
                labelInput.addEventListener('blur', applyCustomLabels);
            }
            document.querySelectorAll('.prediction-toggle').forEach(toggle => {
                toggle.addEventListener('change', applyPredictionVisibility);
            });

            // Chart selector functionality
            const chartSelector = document.getElementById('chart-selector');
            if (chartSelector) {
                chartSelector.addEventListener('change', function() {
                    const selectedChart = this.value;
                    document.querySelectorAll('.chart-content').forEach(content => {
                        const isActive = content.id === 'chart-' + selectedChart;
                        content.style.display = isActive ? 'block' : 'none';
                        content.classList.toggle('active', isActive);
                    });
                    if (selectedChart === 'quality-status') {
                        requestAnimationFrame(() => buildQualityDonut(true));
                    }
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
