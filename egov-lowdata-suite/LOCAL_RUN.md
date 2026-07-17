# 로컬 0원 실행 가이드

이 문서는 egov‑lowdata‑suite를 로컬 PC에서 완전한 형태로 실행하는 방법을 안내합니다. Docker Desktop 또는 Podman만 설치되어 있으면 비용 없이 전체 구성요소를 구동할 수 있습니다.

## 사전 준비

1. Docker Desktop(또는 Podman)을 설치하고 실행합니다.
2. 프로젝트 루트에서 환경 변수 파일을 준비합니다.

```bash
cd egov-lowdata-suite
cp .env.example .env
```

환경 값은 기본적으로 로컬 컨테이너 주소와 개발용 토큰으로 설정되어 있습니다. 필요에 따라 수정합니다.
특히 `ODK_BASE_URL`은 컨테이너 간 통신을 위해 `http://odk`로 유지해야 합니다.
Metabase 메타데이터는 Postgres의 별도 데이터베이스(`MB_METADATA_DB`, 기본값 `metabase`)에 저장됩니다. `docker compose up` 시 `metabase-db-init` 헬퍼 서비스가 자동으로 데이터베이스를 생성하므로 추가 수동 작업은 필요하지 않습니다.

> ℹ️ **ODK Central 의존성 고정**  
> 프로젝트에는 `vendor/getodk-central` 디렉터리에 `getodk/central` 저장소가 `v2025.2.3` 태그 기준으로 포함되어 있습니다.  
> 향후 업스트림 버전으로 갱신하려면 `./scripts/sync-odk-central.sh <새로운-태그>` 명령으로 로컬 사본을 재동기화한 뒤 `docker compose --profile local build`를 다시 실행하세요.

## 한 줄 실행

모든 서비스를 빌드하고 백그라운드에서 기동하려면 다음 명령을 실행합니다.

```bash
docker compose --profile local up -d --build
```

첫 실행 시 이미지 빌드와 Maven/dbt 설치 등으로 다소 시간이 소요될 수 있습니다. 이후부터는 캐시된 이미지로 빠르게 기동됩니다.

## 서비스 접속 URL

| 서비스                | 주소                                | 설명                                                   |
|----------------------|--------------------------------------|--------------------------------------------------------|
| eGov 콘솔            | http://localhost:8080                | SSO(Mock) 로그인 페이지 → 관리자/프로젝트 생성         |
| ODK Central          | http://localhost:8383                | ODK 프로젝트 관리 UI. admin 토큰 발급은 아래 참고.     |
| Metabase             | http://localhost:3000                | 최초 접속 시 관리자 계정을 생성해야 합니다.           |
| MailHog (SMTP)       | http://localhost:8025                | 개발용 메일 수신 확인용 UI (옵션).                     |

### ODK 토큰 발급 방법

로컬 컨테이너에서 ODK Central을 처음 기동하면 관리자 계정이 없으므로 아래 순서로 계정을 만들고 두 종류의 토큰을 발급한 뒤 `.env`에 반영하세요.

#### 0) 관리자 계정 초기 생성(최초 1회)

```bash
printf 'admin12345\nadmin12345\n' | docker compose exec -T service /bin/bash -lc "odk-cmd user-create -u admin@example.com"
docker compose exec service /bin/bash -lc "odk-cmd user-promote -u admin@example.com"
```

#### 1) 세션 베어러 토큰(웹 사용자용)

```bash
curl -s http://localhost:8383/v1/sessions \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin12345"}'
```

응답에 포함된 `token` 값을 `.env` → `ODK_API_TOKEN`에 붙여넣고 저장합니다. 값이 바뀌면 다음 명령으로 포털 애플리케이션을 재기동해 새 토큰을 로드합니다.

```bash
docker compose restart gov-portal
```

#### 2) App User 토큰(현장 단말/ODK Collect용)

세션 토큰을 준비한 뒤, 아래 명령으로 App User를 생성하면 응답 JSON에 `token` 필드가 포함됩니다. `PROJECT_ID`는 ODK 프로젝트 목록(`/v1/projects`)에서 확인한 실제 ID로 교체하세요.

```bash
curl -s http://localhost:8383/v1/projects/<PROJECT_ID>/app-users \
  -X POST \
  -H "Authorization: Bearer ${ODK_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"displayName":"Field Worker 01"}'
```

획득한 토큰을 `.env` → `ODK_APP_USER_TOKEN`에 저장하면 QR 생성이나 단말 설정 시 활용할 수 있습니다. App User 토큰이 변경된 경우에도 `docker compose restart gov-portal`을 수행해 값을 반영하세요.

## 데모 절차

1. **콘솔 로그인**: `http://localhost:8080`으로 접속하여 SSO(Mock) 로그인 페이지에서 관리자 계정(`admin`/`admin`)으로 로그인합니다.
2. **Admin → Create Project**: 조직/국가/언어 선택 후 JSON 템플릿을 입력하여 `[Preview XLSForm]` 클릭. 미리보기 확인 후 `[Create & Deploy]` 버튼을 누르면 ODK 프로젝트 및 폼이 생성되고, Metabase 대시보드가 자동으로 준비됩니다.
3. **ODK Collect 앱**: 에뮬레이터나 모바일 앱에서 ODK 서버를 `http://localhost:8383`로 설정하고 발급된 토큰을 사용하여 로그인합니다. 생성된 프로젝트에 샘플 제출을 업로드합니다.
4. **데이터 수집**: Quartz 배치가 일정 주기로 OData를 조회하여 `submissions_raw` 테이블에 upsert합니다. 즉시 확인하려면 `/batch/ingest` API를 수동 호출할 수 있습니다.
5. **ETL 실행**: `/batch/etl-run` API를 호출하거나 배치가 자동 실행되면 dbt가 `staging→ods→marts.kpi_ops` 모델을 생성합니다.
6. **Metabase 확인**: 콘솔의 Dashboard 메뉴에서 서버사이드 임베드를 통해 6개의 카드가 포함된 대시보드를 확인합니다.

## 6. 배치 작업 확인

### Quartz 스케줄러 작동 확인

배치 작업은 Quartz 스케줄러에 의해 자동 실행됩니다:

- **ODK Ingest Job**: 매 15분마다 ODK 제출 데이터 수집
- **ETL Run Job**: 6시간마다 dbt 모델 실행
- **K-eGov Publish Job**: 매일 오전 2시 집계 전송
- **Retention Cleanup Job**: 매일 오전 3시 만료 데이터 삭제

### 수동 배치 실행

1. **ODK 데이터 수집 (수동)**
```bash
docker exec -it gov-portal curl -X POST http://localhost:8080/batch/trigger/odk-ingest
```

2. **dbt 모델 실행 (수동)**
```bash
docker exec -it gov-portal curl -X POST http://localhost:8080/batch/trigger/etl-run
```

3. **품질 검사 실행**
```bash
docker exec -it postgres psql -U postgres -d egov -c "SELECT * FROM quality_flags LIMIT 10;"
```

### Metabase 대시보드 확인

1. 프로젝트 생성 후 대시보드 자동 생성 확인
2. 콘솔에서 Dashboard 메뉴 클릭
3. 6종 카드 (Reach, Quality, Action List, Diagnosis Distribution, Attach Validity, Model Health) 표시 확인

### 로그 확인
```bash
# Gov Portal 로그
docker logs -f gov-portal

# Quartz 작업 로그 확인
docker exec -it postgres psql -U postgres -d egov -c "SELECT * FROM audit_logs WHERE action LIKE '%_JOB' ORDER BY created_at DESC LIMIT 20;"
```

## 로컬 환경 보안 주의

* HTTPS가 구성되어 있지 않으므로 외부망에 노출하지 마십시오. 모든 서비스는 내부 테스트/데모 전용입니다.
* 기본 비밀번호 및 토큰은 반드시 변경하거나 외부 접속을 차단하세요.

## 문제 해결 FAQ

* **포트 충돌**: 이미 사용 중인 포트가 있을 경우 `.env`의 포트 값을 변경한 뒤 `docker compose up` 명령에서 `--build` 옵션을 다시 실행합니다.
* **메모리 부족**: 컨테이너 기동 시 OOM이 발생한다면 Docker Desktop 설정에서 메모리 할당을 4GB 이상으로 늘려주세요.
* **권한 오류**: 관리 기능은 `ROLE_ADMIN_SUPER` 권한이 있어야 이용 가능합니다. 초기 데이터가 제대로 로드되지 않았다면 Postgres 컨테이너 로그를 확인하세요.
* **ODK 토큰 문제**: 토큰이 만료되거나 올바르지 않은 경우 ODK CLI로 새 토큰을 발급받아 `.env` 파일을 업데이트한 뒤 `docker compose restart gov-portal`을 수행하세요.
