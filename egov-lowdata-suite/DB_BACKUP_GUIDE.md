# 데이터베이스 백업 및 복원 가이드

이 가이드는 egov-lowdata-suite 프로젝트의 데이터베이스를 백업하고 다른 환경에서 복원하는 방법을 설명합니다.

## 📦 백업 방법

### 1. 기본 백업
```bash
./backup_db.sh
```

자동으로 `db_backups` 디렉토리에 날짜/시간 형식의 백업 파일이 생성됩니다.
- 예시: `db_backups/backup_20251111_203000.sql`

### 2. 사용자 지정 이름으로 백업
```bash
./backup_db.sh my_backup
```

`db_backups/my_backup.sql` 파일이 생성됩니다.

### 3. 백업 내용
- **메인 DB**: PostgreSQL의 egov 데이터베이스 전체
- **ODK Central DB** (local 프로파일 사용 시): ODK의 postgres14 데이터베이스

### 4. 주의사항
- Docker 컨테이너가 실행 중이어야 합니다
- 백업 전에 다음 명령으로 컨테이너를 시작하세요:
  ```bash
  docker compose --profile local up -d postgres
  ```

## 🔄 복원 방법

### 1. 백업 파일 목록 확인
```bash
./restore_db.sh
```

사용 가능한 백업 파일 목록이 표시됩니다.

### 2. 백업 파일로 복원
```bash
./restore_db.sh backup_20251111_203000
```

또는 전체 경로 사용:
```bash
./restore_db.sh db_backups/backup_20251111_203000.sql
```

### 3. 복원 프로세스
1. 복원 확인 메시지가 표시됩니다
2. 'y'를 입력하면 복원이 시작됩니다
3. ODK Central 백업이 있으면 추가로 복원 여부를 물어봅니다

### 4. 주의사항
⚠️ **복원 시 기존 데이터가 모두 삭제됩니다!**
- 중요한 데이터가 있다면 먼저 백업하세요
- 복원 전에 반드시 확인 메시지를 읽으세요

## 🚀 다른 노트북으로 이동하기

### 준비물
1. 전체 프로젝트 폴더
2. `db_backups` 디렉토리의 백업 파일들
3. `.env` 파일 (민감한 정보 포함)

### 이동 절차

#### 1단계: 현재 시스템에서 백업
```bash
# DB 백업 생성
./backup_db.sh migration_backup

# 백업 파일 확인
ls -lh db_backups/
```

#### 2단계: 프로젝트 전체 복사
프로젝트 폴더 전체를 USB, 클라우드 등으로 새 노트북에 복사합니다.

포함할 주요 파일/폴더:
- `docker-compose.yml`
- `.env` 파일
- `db_backups/` 디렉토리
- `backup_db.sh`, `restore_db.sh`
- 나머지 모든 프로젝트 파일

#### 3단계: 새 노트북에서 환경 설정
```bash
# Docker 및 Docker Compose 설치 확인
docker --version
docker compose version

# 프로젝트 디렉토리로 이동
cd egov-lowdata-suite

# .env 파일 확인 (필요시 수정)
cat .env
```

#### 4단계: Docker 컨테이너 시작
```bash
# local 프로파일로 전체 시스템 시작
docker compose --profile local up -d

# 또는 특정 서비스만 시작
docker compose --profile local up -d postgres
```

#### 5단계: 데이터베이스 복원
```bash
# 복원 (Claude Code에게 명령)
"데이터베이스를 migration_backup으로 복원해줘"
```

또는 직접 실행:
```bash
./restore_db.sh migration_backup
```

#### 6단계: 서비스 확인
```bash
# 컨테이너 상태 확인
docker compose ps

# 로그 확인
docker compose logs gov-portal
docker compose logs postgres

# 웹 브라우저에서 접속 확인
# - Gov Portal: http://localhost:8080
# - Metabase: http://localhost:3000
# - ODK Central: http://localhost:8383
```

## 🤖 Claude Code에게 명령하기

새 노트북에서 다음과 같이 요청하세요:

### 백업 생성
```
"데이터베이스를 백업해줘"
"DB를 production_backup 이름으로 백업해줘"
```

### 복원 실행
```
"데이터베이스를 복원해줘"
"migration_backup으로 DB를 복원해줘"
```

### 백업 파일 확인
```
"백업 파일 목록을 보여줘"
"db_backups 디렉토리에 뭐가 있어?"
```

### 전체 시스템 시작
```
"docker compose로 전체 시스템을 시작해줘"
"local 프로파일로 시스템을 실행해줘"
```

## 📝 파일 구조

```
egov-lowdata-suite/
├── db_backups/              # 백업 파일 저장 디렉토리
│   ├── backup_20251111_203000.sql
│   ├── backup_20251111_203000_odk.sql
│   └── migration_backup.sql
├── backup_db.sh             # 백업 스크립트
├── restore_db.sh            # 복원 스크립트
├── .env                     # 환경 변수 (민감한 정보 포함)
├── docker-compose.yml       # Docker 설정
└── DB_BACKUP_GUIDE.md      # 이 파일
```

## ⚠️ 보안 주의사항

`.env` 파일에는 다음과 같은 민감한 정보가 포함되어 있습니다:
- 데이터베이스 비밀번호
- API 토큰
- 암호화 키

**주의사항:**
- `.env` 파일을 공개 저장소에 올리지 마세요
- 백업 파일도 민감한 데이터를 포함할 수 있으니 안전하게 보관하세요
- 새 환경에서는 필요시 `.env` 파일의 비밀번호를 변경하세요

## 🔧 문제 해결

### 백업 실패
```bash
# 컨테이너 상태 확인
docker compose ps postgres

# 컨테이너가 실행 중이 아니면 시작
docker compose --profile local up -d postgres

# 로그 확인
docker compose logs postgres
```

### 복원 실패
```bash
# 백업 파일 경로 확인
ls -lh db_backups/

# 파일 내용 확인 (첫 몇 줄)
head -20 db_backups/backup_20251111_203000.sql

# 수동 복원 시도
docker compose exec -T postgres psql -U egov -d egov < db_backups/backup_20251111_203000.sql
```

### 권한 오류
```bash
# 스크립트에 실행 권한 부여
chmod +x backup_db.sh restore_db.sh
```

## 📞 도움이 필요할 때

1. 백업/복원 스크립트를 인수 없이 실행하면 사용법이 표시됩니다
2. Docker 로그를 확인하세요: `docker compose logs`
3. Claude Code에게 "DB 백업/복원 관련 문제가 있어"라고 물어보세요
