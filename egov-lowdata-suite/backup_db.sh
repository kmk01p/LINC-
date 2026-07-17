#!/bin/bash

# DB 백업 스크립트
# 사용법: ./backup_db.sh [백업파일명]

set -e

# 환경변수 로드
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# 백업 디렉토리 생성
BACKUP_DIR="./db_backups"
mkdir -p "$BACKUP_DIR"

# 백업 파일명 설정
if [ -z "$1" ]; then
    BACKUP_FILE="$BACKUP_DIR/backup_$(date +%Y%m%d_%H%M%S).sql"
else
    BACKUP_FILE="$BACKUP_DIR/$1.sql"
fi

echo "=== PostgreSQL 데이터베이스 백업 시작 ==="
echo "백업 파일: $BACKUP_FILE"

# Docker 컨테이너가 실행 중인지 확인
if ! docker compose ps postgres | grep -q "Up"; then
    echo "오류: postgres 컨테이너가 실행 중이 아닙니다."
    echo "docker compose --profile local up -d postgres 명령으로 먼저 실행해주세요."
    exit 1
fi

# pg_dump를 사용하여 전체 데이터베이스 백업
docker compose exec -T postgres pg_dump \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    --clean \
    --if-exists \
    --no-owner \
    --no-acl \
    > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✓ 백업 완료: $BACKUP_FILE"
    echo "파일 크기: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "✗ 백업 실패"
    exit 1
fi

# ODK Central DB도 백업 (local 프로파일 사용 시)
if docker compose ps postgres14 2>/dev/null | grep -q "Up"; then
    ODK_BACKUP_FILE="${BACKUP_FILE%.sql}_odk.sql"
    echo ""
    echo "=== ODK Central 데이터베이스 백업 시작 ==="
    echo "백업 파일: $ODK_BACKUP_FILE"

    docker compose exec -T postgres14 pg_dump \
        -U odk \
        -d odk \
        --clean \
        --if-exists \
        --no-owner \
        --no-acl \
        > "$ODK_BACKUP_FILE"

    if [ $? -eq 0 ]; then
        echo "✓ ODK 백업 완료: $ODK_BACKUP_FILE"
        echo "파일 크기: $(du -h "$ODK_BACKUP_FILE" | cut -f1)"
    else
        echo "✗ ODK 백업 실패"
    fi
fi

echo ""
echo "=== 백업 완료 ==="
echo "백업 파일 목록:"
ls -lh "$BACKUP_DIR"/*.sql 2>/dev/null || echo "(백업 파일이 없습니다)"
