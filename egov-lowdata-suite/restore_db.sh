#!/bin/bash

# DB 복원 스크립트
# 사용법: ./restore_db.sh <백업파일명>

set -e

# 환경변수 로드
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# 백업 파일 확인
if [ -z "$1" ]; then
    echo "사용법: ./restore_db.sh <백업파일명>"
    echo ""
    echo "사용 가능한 백업 파일:"
    ls -lh ./db_backups/*.sql 2>/dev/null || echo "(백업 파일이 없습니다)"
    exit 1
fi

BACKUP_FILE="$1"

# .sql 확장자가 없으면 추가
if [[ ! "$BACKUP_FILE" =~ \.sql$ ]]; then
    BACKUP_FILE="./db_backups/${BACKUP_FILE}.sql"
fi

# 파일 존재 확인
if [ ! -f "$BACKUP_FILE" ]; then
    echo "오류: 백업 파일을 찾을 수 없습니다: $BACKUP_FILE"
    echo ""
    echo "사용 가능한 백업 파일:"
    ls -lh ./db_backups/*.sql 2>/dev/null || echo "(백업 파일이 없습니다)"
    exit 1
fi

echo "=== PostgreSQL 데이터베이스 복원 시작 ==="
echo "복원 파일: $BACKUP_FILE"

# Docker 컨테이너가 실행 중인지 확인
if ! docker compose ps postgres | grep -q "Up"; then
    echo "오류: postgres 컨테이너가 실행 중이 아닙니다."
    echo "docker compose --profile local up -d postgres 명령으로 먼저 실행해주세요."
    exit 1
fi

# 확인 메시지
echo ""
echo "⚠️  경고: 기존 데이터베이스가 삭제되고 백업 파일로 복원됩니다."
read -p "계속하시겠습니까? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "복원이 취소되었습니다."
    exit 0
fi

# 데이터베이스 복원
echo "복원 중..."
docker compose exec -T postgres psql \
    -U "$POSTGRES_USER" \
    -d "$POSTGRES_DB" \
    < "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "✓ 복원 완료"
else
    echo "✗ 복원 실패"
    exit 1
fi

# ODK Central DB 복원 (파일이 있는 경우)
ODK_BACKUP_FILE="${BACKUP_FILE%.sql}_odk.sql"
if [ -f "$ODK_BACKUP_FILE" ]; then
    if docker compose ps postgres14 2>/dev/null | grep -q "Up"; then
        echo ""
        echo "=== ODK Central 데이터베이스 복원 시작 ==="
        echo "복원 파일: $ODK_BACKUP_FILE"

        read -p "ODK Central DB도 복원하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose exec -T postgres14 psql \
                -U odk \
                -d odk \
                < "$ODK_BACKUP_FILE"

            if [ $? -eq 0 ]; then
                echo "✓ ODK 복원 완료"
            else
                echo "✗ ODK 복원 실패"
            fi
        fi
    fi
fi

echo ""
echo "=== 복원 완료 ==="
