# Docker 없이 로컬 실행하기

> ⚠️ **경고**  
> 이 가이드는 Docker/Compose 없이 모든 컴포넌트를 직접 실행하려는 경우에만 참고하십시오.  
> ODK Central과 Enketo까지 수동으로 구성해야 하므로 설치 시간이 매우 오래 걸리고, 각 서비스는 개별 터미널 창(또는 tmux 세션)에서 실행해야 합니다.  
> 가능한 경우 Docker 기반 실행(`LOCAL_RUN.md`)을 강력히 권장합니다.

## 1. 사전 준비

### 필수 소프트웨어

| 용도 | 권장 버전 | 비고 |
|------|-----------|------|
| JDK 17 | Temurin 17 | `gov-portal` 실행 |
| Maven | 3.9.x | (`./mvnw` 자동 다운로드 가능) |
| Node.js | 20.x | ODK Central Backend/Frontend, Enketo |
| npm | 10.x 이상 | Node 설치 시 포함 |
| Yarn | 1.22.x | Enketo 빌드용 |
| Python | 3.11.x | xlsform-sidecar, kegov mock, Metabase bootstrap |
| pip | 23.x 이상 | Python 패키지 설치 |
| PostgreSQL | 16.x | 공통 데이터베이스 |
| Redis | 7.x | Enketo 캐시용 |
| Git | 최신 | 소스 코드 클론 |

macOS라면 Homebrew로 `brew install temurin@17 maven node@20 yarn python@3.11 postgresql@16 redis git` 형태로 설치할 수 있습니다.

### 필수 저장소/아티팩트

```bash
mkdir -p ~/workspace/egov-suite && cd ~/workspace/egov-suite
git clone https://github.com/<YOUR-ORG>/egov-lowdata-suite.git
git clone https://github.com/getodk/central-backend.git
git clone https://github.com/getodk/central-frontend.git
git clone https://github.com/enketo/enketo.git
```

Metabase는 JAR 파일로 배포됩니다. 최신 버전을 다운로드해 두세요.

```bash
curl -L https://downloads.metabase.com/v0.50.26/metabase.jar -o metabase/metabase.jar
```

## 2. PostgreSQL 데이터베이스 준비

PostgreSQL 서버를 실행한 뒤, 아래 SQL을 한 번만 수행합니다.

```sql
-- superuser 계정(예: postgres)에서 실행
CREATE ROLE egov LOGIN PASSWORD 'secret';
CREATE ROLE jubilant LOGIN PASSWORD 'jubilant';

-- eGov 콘솔 및 Metabase용
CREATE DATABASE egov OWNER egov ENCODING 'UTF8';
CREATE DATABASE metabase_db OWNER egov ENCODING 'UTF8';

-- ODK Central Backend용 (테스트 DB는 선택)
CREATE DATABASE jubilant OWNER jubilant ENCODING 'UTF8';
CREATE DATABASE jubilant_test OWNER jubilant ENCODING 'UTF8';

-- 각 데이터베이스에 필요한 확장 설치
\c jubilant
CREATE EXTENSION IF NOT EXISTS CITEXT;
CREATE EXTENSION IF NOT EXISTS PG_TRGM;
CREATE EXTENSION IF NOT EXISTS PGROWLOCKS;

\c jubilant_test
CREATE EXTENSION IF NOT EXISTS CITEXT;
CREATE EXTENSION IF NOT EXISTS PG_TRGM;
CREATE EXTENSION IF NOT EXISTS PGROWLOCKS;
```

### 환경 변수 파일

`egov-lowdata-suite` 루트에 `.env`를 생성하고 다음 값을 설정합니다. (Docker 예제와 다르므로 새로 작성하세요.)

```env
POSTGRES_USER=egov
POSTGRES_PASSWORD=secret
POSTGRES_DB=egov

ODK_BASE_URL=http://localhost:8383
# Session bearer token from POST /v1/sessions (24h validity)
ODK_API_TOKEN=
# App User token for /v1/key/<token>/... requests (optional)
ODK_APP_USER_TOKEN=

MB_BASE_URL=http://localhost:3000
MB_EMBED_SECRET=dev-embed-secret
MB_SESSION=

SIDECAR_BASE=http://localhost:5001

SERVER_PORT=8080
SECRET_KEY=supersecret
SPRING_PROFILES_ACTIVE=default
```

세션 토큰과 App User 토큰 발급 절차는 Docker 모드와 동일합니다. `curl`이나 `pyODK` 등을 사용해 `/v1/sessions`와 `/v1/projects/{id}/app-users` 엔드포인트에서 토큰을 얻은 뒤, 각각 `ODK_API_TOKEN`, `ODK_APP_USER_TOKEN` 값으로 채워 주세요. 값이 변경되면 애플리케이션을 재시작해 반영해야 합니다.

## 3. 보조 서비스 실행

각 항목은 **별도 터미널**에서 실행하세요. 서비스가 준비된 뒤 다음 단계로 넘어갑니다.

### 3.1 Redis

```bash
redis-server
```

### 3.2 XLSForm 사이드카 (`localhost:5001`)

```bash
cd ~/workspace/egov-suite/egov-lowdata-suite/xlsform-sidecar
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```

### 3.3 K-eGov 모의 서버 (선택, `localhost:5000`)

```bash
cd ~/workspace/egov-suite/egov-lowdata-suite/kegov
python3 -m venv .venv
source .venv/bin/activate
pip install flask
python mock_server.py
```

## 4. ODK Central 수동 실행

### 4.1 Backend (`central-backend`)

```bash
cd ~/workspace/egov-suite/central-backend
npm install
make
make run   # 또는 make dev
```

> Backend는 `http://localhost:8383`에서 동작합니다.  
> `config/default.json`의 `database`/`xlsform`/`enketo` 설정이 위에서 준비한 포트와 일치하는지 확인하세요.

### 4.2 Frontend (`central-frontend`)

엔케토와 연동하기 위해 Nginx가 필요합니다. macOS의 경우 `brew install nginx` 후 아래를 수행합니다.

```bash
cd ~/workspace/egov-suite/central-frontend
npm install
npm run dev
```

Frontend는 Vite dev 서버를 통해 `http://localhost:8989`로 노출되며, 자동으로 Nginx 리버스 프록시가 함께 구동됩니다.

### 4.3 Enketo Express (`enketo`)

```bash
cd ~/workspace/egov-suite/enketo
yarn install
yarn build

mkdir -p config
cat > config/config.json <<'JSON'
{
  "port": "8005",
  "linked form and data server": {
    "server url": "localhost:8989",
    "api key": "enketorules",
    "authentication": {
      "allow insecure transport": "true"
    }
  },
  "base path": "-",
  "query parameter to pass to submission": "st",
  "redis": {
    "cache": {
      "port": "6379"
    }
  }
}
JSON

yarn workspace enketo-express start
```

### 4.4 관리자 계정 및 API 토큰 발급

새 터미널에서:

```bash
cd ~/workspace/egov-suite/central-backend
printf 'admin12345\nadmin12345\n' | node lib/bin/cli.js user-create --email admin@example.com
node lib/bin/cli.js user-promote --email admin@example.com
curl -s http://localhost:8383/v1/sessions \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin12345"}'  # 출력된 token 필드를 복사
```

발급한 토큰을 `.env`의 `ODK_API_TOKEN` 값에 복사합니다.

이제 브라우저에서 `http://localhost:8989` 접속 후 Frontend를 통해 로그인할 수 있습니다.

## 5. Metabase 실행

Metabase는 단일 JAR로 실행합니다.

```bash
cd ~/workspace/egov-suite/egov-lowdata-suite/metabase
MB_DB_TYPE=postgres \
MB_DB_DBNAME=metabase_db \
MB_DB_PORT=5432 \
MB_DB_USER=egov \
MB_DB_PASS=secret \
MB_DB_HOST=localhost \
java -jar metabase.jar
```

초기 관리자 계정 생성 후, `metabase/bootstrap.py`를 이용해 카드/대시보드를 자동 구성할 수 있습니다.

```bash
cd ~/workspace/egov-suite/egov-lowdata-suite/metabase
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-bootstrap.txt
export MB_BASE_URL=http://localhost:3000
export MB_SESSION=<Metabase-세션-토큰>
export MB_EMBED_SECRET=<Metabase-Embed-Secret>
python bootstrap.py <project_id>
```

필요한 의존성은 `requirements-bootstrap.txt`에 정의되어 있습니다.

> `MB_SESSION`은 Metabase 관리자 로그인 후 브라우저 개발자 도구 → Application → Cookies에서 `metabase.SESSION` 값을 복사하면 됩니다.  
> `MB_EMBED_SECRET`은 Metabase Admin → Settings → Embedding in other applications 메뉴에서 발급합니다.

## 6. eGov 콘솔(gov-portal) 실행

```bash
cd ~/workspace/egov-suite/egov-lowdata-suite/gov-portal
./mvnw spring-boot:run
```

앱은 `http://localhost:8080`에서 동작합니다. `.env`에 설정한 값이 자동으로 바인딩되며, 초기 스키마/데이터(`schema.sql`, `data.sql`)가 자동 적용됩니다.

## 7. dbt ETL 파이프라인 실행 (선택)

1. dbt-core 설치:

   ```bash
   pip install dbt-postgres
   ```

2. `etl/profiles.yml.example`를 복사하여 `~/.dbt/profiles.yml`에 저장하고 데이터베이스 접속 정보를 수정합니다.

3. 모델 실행:

   ```bash
   cd ~/workspace/egov-suite/egov-lowdata-suite/etl
   dbt deps
   dbt run
   dbt test
   ```

## 8. 전체 서비스 연결 체크리스트

1. **ODK Central Frontend** (`http://localhost:8989`)에 로그인 가능.
2. **XLSForm 사이드카** `/health` 엔드포인트가 `{"status":"ok"}` 반환.
3. **gov-portal** 에서 프로젝트 생성 → 중앙 ODK에 Form 배포 성공.
4. **Metabase** (`http://localhost:3000`) 대시보드 접속 가능.
5. **Quartz 배치** (`gov-portal`) 로그에서 ODK → Postgres 동기화 정상 여부 확인.
6. 필요 시 **kegov mock 서버** (`http://localhost:5000`)에 전송 테스트.

## 9. 트러블슈팅

| 증상 | 원인 / 해결 |
|------|-------------|
| Central Backend 기동 실패 (`ECONNREFUSED localhost:5001`) | XLSForm 사이드카가 실행되지 않았거나 포트 충돌. |
| Form 배포 시 Enketo 오류 (`The form you tried to access...`) | Enketo 미기동 또는 캐시 미생성. Enketo 서비스와 Redis 상태 확인 후 Form을 Draft→Publish. |
| gov-portal에서 Metabase 카드 임베드 실패 | `MB_BASE_URL`, `MB_EMBED_SECRET` 설정 확인. 필요 시 Metabase 관리자 페이지에서 새 시크릿 발급. |
| Metabase 시작 시 DB 커넥션 실패 | Postgres 접속 정보 확인 (`metabase_db`가 존재해야 함). |
| dbt 실행 시 인증 오류 | `~/.dbt/profiles.yml`의 사용자/패스워드 확인. |

---

### 실행 요약 (각 터미널 별)

| 터미널 | 명령 |
|--------|------|
| T1 | `postgres` 서버 (서비스로 실행) |
| T2 | `redis-server` |
| T3 | `python xlsform-sidecar/app.py` |
| T4 | `python kegov/mock_server.py` (선택) |
| T5 | `make run` (`central-backend`) |
| T6 | `npm run dev` (`central-frontend`) |
| T7 | `yarn workspace enketo-express start` (`enketo`) |
| T8 | `java -jar metabase.jar` (`metabase`) |
| T9 | `./mvnw spring-boot:run` (`gov-portal`) |
| T10 | 필요 시 `dbt run` (`etl`) |

이 과정을 통해 Docker 없이도 모든 컴포넌트를 실행할 수 있지만, 서비스가 많고 수동 관리가 까다롭습니다. 문제없이 동작을 확인한 뒤에는 Docker/Compose로의 전환을 다시 고려하는 것을 권장합니다.
