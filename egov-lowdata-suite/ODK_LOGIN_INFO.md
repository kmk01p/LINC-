# ODK Central 로그인 정보

## 접속 정보
- URL: http://localhost:8383
- Email: admin@example.com
- Password: admin123

## 프로젝트 현황
- 총 52개 프로젝트 생성됨
- 모든 프로젝트가 데이터베이스와 연동됨

## API 접속 방법

### 세션 생성
```bash
curl -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'
```

### 프로젝트 목록 조회
```bash
# 먼저 토큰 받기
SESSION=$(curl -s -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

TOKEN=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
CSRF=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['csrf'])")

# 프로젝트 조회
curl -s http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF"
```

## Gov Portal 접속
- URL: http://localhost:8080
- 프로젝트 목록: http://localhost:8080/projects/list.do
