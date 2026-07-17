# eGov Low-Data Suite

전자정부표준프레임워크(eGovFrame) 기반으로 개발된 로우데이터 분석 모노레포입니다. 이 프로젝트는 공공기관에서 현장 자료를 효율적으로 수집‑분석하고 관리자용 제어 기능을 제공하기 위해 설계되었습니다. Spring Boot 3.x와 Thymeleaf를 이용한 콘솔(Web UI), ODK Central 연동, Metabase 대시보드, dbt ETL 파이프라인, JSON→XLSForm 변환 사이드카 등 여러 컴포넌트를 하나의 저장소로 관리합니다.

## 저장소 구조

```
egov-lowdata-suite/
├─ README.md             # 프로젝트 개요 및 설치 가이드
├─ LOCAL_RUN.md          # 로컬(0원) 실행 가이드
├─ docker-compose.yml    # 로컬/클라우드 공용 컴포즈 파일
├─ .env.example          # 환경 변수 템플릿
├─ gov-portal/           # Spring Boot 3.x 애플리케이션 (eGovFrame 콘솔)
│  ├─ pom.xml            # Maven 빌드 스크립트
│  ├─ src/main/java/
│  │  └─ com/example/egov/
│  │     ├─ EgovApplication.java         # 엔트리 포인트
│  │     ├─ config/                      # 보안, Quartz 설정
│  │     │  ├─ SecurityConfig.java
│  │     │  └─ QuartzConfig.java
│  │     ├─ auth/                        # RBAC 엔티티 및 어노테이션
│  │     │  ├─ User.java
│  │     │  ├─ Role.java
│  │     │  ├─ Permission.java
│  │     │  ├─ RolePermission.java
│  │     │  └─ UserRoleAssignment.java
│  │     ├─ audit/                       # 감사용 AOP
│  │     │  └─ AuditAspect.java
│  │     ├─ adapters/                    # 외부 서비스 연동
│  │     │  ├─ OdkClient.java
│  │     │  ├─ MetabaseClient.java
│  │     │  └─ PipelineClient.java
│  │     ├─ controllers/
│  │     │  ├─ AdminController.java      # 관리자용 CRUD
│  │     │  ├─ ProjectController.java    # 프로젝트/폼
│  │     │  ├─ DashboardController.java  # 메타베이스 임베드
│  │     │  ├─ BatchController.java      # 배치 관리
│  │     │  └─ IngestController.java     # ODK 수집
│  │     ├─ scheduler/
│  │     │  ├─ OdkIngestJob.java
│  │     │  ├─ EtlRunJob.java
│  │     │  ├─ PublishKegovJob.java
│  │     │  └─ RetentionJob.java
│  │     └─ domain/dao/entity/dto/       # DAO/엔티티/DTO
│  └─ src/main/resources/
│     ├─ application.yml                 # 앱 설정
│     ├─ schema.sql                      # 초기 DDL
│     ├─ data.sql                        # 초기 데이터
│     └─ templates/                      # Thymeleaf 템플릿
│        ├─ login.html
│        ├─ admin_roles.html
│        ├─ admin_assignments.html
│        └─ admin_create_project.html
├─ xlsform-sidecar/      # Flask 사이드카: JSON→XLSX
│  ├─ app.py
│  ├─ requirements.txt
│  └─ templates/
│     └─ sample_template.json            # 예시 폼 정의
├─ etl/                 # dbt 프로젝트 및 배치 스크립트
│  ├─ dbt_project.yml
│  ├─ profiles.yml.example
│  ├─ packages.yml
│  ├─ models/
│  │  ├─ staging/
│  │  ├─ ods/
│  │  └─ marts/
│  └─ jobs/
│     ├─ quality_checks.py
│     ├─ batch_scoring.py
│     ├─ publish_kegov.py
│     └─ retention_cleanup.py
├─ metabase/
│  ├─ bootstrap.py                      # 컬렉션/카드 자동 생성
│  └─ templates/
│     └─ ops_cards.json                 # 카드 사전
├─ vendor/
│  └─ getodk-central/                   # ODK Central (v2025.2.3) 소스 스냅샷
├─ scripts/
│  └─ sync-odk-central.sh               # ODK Central 버전 동기화 유틸리티
└─ kegov/
   ├─ openapi.yaml                      # 집계 전송 계약 예시
   └─ mock_server.py                    # 전송용 샌드박스

```

## 주요 기능

* **SSO(Mock)**와 직급 기반 RBAC(4급/5급) 구현 – OAuth/OIDC/SAML 환경에 배포 시 실제 인증 서버로 대체 가능.
* **Admin 콘솔**을 통한 역할/권한 관리, 사용자↔역할 할당, 프로젝트 생성/수정/종료.
* **프로젝트 생성 자동화**: JSON 템플릿을 XLSForm으로 변환 후 ODK 프로젝트/폼 생성→배포, Metabase 대시보드 6개 자동 생성.
* **ODK 수집 배치**: Quartz 기반으로 OData API 증분 동기화, ETL(dbt) 실행, K-eGov 집계 전송, 보존정책 삭제.
* **로컬 0원 모드**: 단일 PC에서 Docker Compose로 모든 컴포넌트를 실행 가능하며, 별도 비용 없이 데모 환경 구축.

자세한 실행 방법과 데모 절차는 `LOCAL_RUN.md`를, Docker 없이 수동으로 구성해야 하는 경우에는 `LOCAL_RUN_NO_DOCKER.md`를 참조하십시오.
