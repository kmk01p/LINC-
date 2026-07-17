# 빠른 시작 가이드

## 마이그레이션 완료 ✅

소프트 삭제 기능이 성공적으로 적용되었습니다!

```bash
# 실행한 명령어
cat gov-portal/src/main/resources/migration-add-soft-delete.sql | docker compose exec -T postgres psql -U egov -d egov

# 결과
ALTER TABLE     # deleted_at 컬럼 추가
ALTER TABLE     # deleted_by 컬럼 추가
CREATE INDEX    # 인덱스 생성
COMMENT         # 컬럼 주석 추가
```

## 기능 테스트

### 1. 웹 애플리케이션 접속

```bash
# 브라우저에서 열기
http://localhost:8080
```

### 2. 로그인

관리자 계정으로 로그인하세요.

### 3. 프로젝트 삭제 테스트

#### a. 프로젝트 목록 확인
```
http://localhost:8080/projects/list.do
```

#### b. 프로젝트 삭제
1. 프로젝트 목록에서 "삭제" 버튼 클릭
2. 확인 메시지: "이 프로젝트를 삭제된 프로젝트 목록으로 이동하시겠습니까?"
3. 확인 클릭

**결과**: 프로젝트가 목록에서 사라짐 (ODK Central은 유지됨)

### 4. 삭제된 프로젝트 페이지 확인

```
http://localhost:8080/projects/deleted/list.do
```

**표시 내용**:
- 삭제된 프로젝트 목록
- 삭제 날짜/시간
- 삭제한 사용자
- 복원/영구삭제 버튼

### 5. 프로젝트 복원 테스트

1. 삭제된 프로젝트 페이지에서 "복원" 버튼 클릭
2. 확인 메시지 확인
3. 프로젝트 목록으로 이동

**결과**: 프로젝트가 다시 목록에 표시됨

### 6. 영구 삭제 테스트

⚠️ **경고**: 이 작업은 되돌릴 수 없습니다!

1. 삭제된 프로젝트 페이지에서 "영구 삭제" 버튼 클릭
2. 경고 메시지 확인
3. 확인 클릭

**결과**:
- 데이터베이스에서 완전히 삭제
- ODK Central에서도 삭제
- 복구 불가능

### 7. UTF-8 인코딩 테스트

#### a. 프로젝트 생성
```
1. "새 프로젝트 등록" 클릭
2. 한글 입력:
   - 프로젝트명: 테스트 프로젝트
   - 국가: 대한민국
   - 분야: 보건의료
3. 저장
```

#### b. 확인
프로젝트 목록에서 한글이 깨지지 않고 표시되는지 확인:
- ❌ 잘못된 예: `ìí°ì¤í¼ì    ë³´`
- ✅ 올바른 예: `테스트 프로젝트`, `대한민국`, `보건의료`

## 데이터베이스 직접 확인

### 활성 프로젝트 조회
```bash
docker compose exec -T postgres psql -U egov -d egov -c "SELECT id, name, country, sector, deleted_at FROM projects_biz WHERE deleted_at IS NULL;"
```

### 삭제된 프로젝트 조회
```bash
docker compose exec -T postgres psql -U egov -d egov -c "SELECT id, name, country, sector, deleted_at, deleted_by FROM projects_biz WHERE deleted_at IS NOT NULL;"
```

### 모든 프로젝트 조회
```bash
docker compose exec -T postgres psql -U egov -d egov -c "SELECT id, name, deleted_at IS NOT NULL as is_deleted FROM projects_biz ORDER BY created_at DESC;"
```

## 트러블슈팅

### 한글이 여전히 깨지는 경우

#### 1. 브라우저 캐시 삭제
```
Ctrl+Shift+R (또는 Cmd+Shift+R)로 하드 리프레시
```

#### 2. 데이터베이스 인코딩 확인
```bash
docker compose exec -T postgres psql -U egov -d egov -c "SHOW client_encoding;"
docker compose exec -T postgres psql -U egov -d egov -c "SHOW server_encoding;"
```

**예상 결과**: 둘 다 `UTF8`이어야 함

#### 3. 애플리케이션 재시작
```bash
docker compose restart gov-portal
```

#### 4. 전체 재빌드 (문제가 지속되면)
```bash
# 컨테이너 중지
docker compose down

# 이미지 재빌드
docker compose build gov-portal

# 다시 시작
docker compose up -d
```

### ODK 정리 페이지가 404 에러

#### 원인
컨트롤러 매핑이 로드되지 않았을 수 있음

#### 해결
```bash
# 로그 확인
docker compose logs gov-portal | grep "deleted"

# 재시작
docker compose restart gov-portal
```

### 복원/영구삭제 버튼이 작동하지 않음

#### 확인사항
1. 관리자 권한으로 로그인했는지 확인
2. 브라우저 콘솔에서 JavaScript 에러 확인
3. 서버 로그 확인:
```bash
docker compose logs gov-portal --tail 50 -f
```

## 유용한 명령어

### 로그 실시간 확인
```bash
docker compose logs gov-portal -f
```

### 컨테이너 상태 확인
```bash
docker compose ps
```

### 데이터베이스 접속
```bash
docker compose exec postgres psql -U egov -d egov
```

### 서비스 재시작
```bash
# 특정 서비스만
docker compose restart gov-portal

# 모든 서비스
docker compose restart
```

### 전체 중지 및 재시작
```bash
docker compose down
docker compose up -d
```

## 다음 단계

✅ 마이그레이션 완료
✅ 서버 재시작 완료
✅ UTF-8 인코딩 설정 완료

**지금 해보세요**:
1. http://localhost:8080 접속
2. 프로젝트 삭제/복원 테스트
3. 한글 입력 테스트
4. ODK 정리 기능 확인

## 문제 발생 시

1. **문서 확인**:
   - `UTF8_SETUP.md` - UTF-8 설정 상세 가이드
   - `ODK_CLEANUP_GUIDE.md` - ODK 정리 기능 상세 가이드

2. **로그 확인**:
   ```bash
   docker compose logs gov-portal --tail 100
   ```

3. **데이터베이스 상태 확인**:
   ```bash
   docker compose exec -T postgres psql -U egov -d egov -c "\d projects_biz"
   ```

4. **컨테이너 재시작**:
   ```bash
   docker compose restart gov-portal
   ```

성공적인 테스트 되시길 바랍니다! 🚀
