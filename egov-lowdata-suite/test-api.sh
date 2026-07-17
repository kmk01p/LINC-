#!/bin/bash

echo "=== 삭제된 프로젝트 API 테스트 ==="
echo ""

# 1. 로그인 시도
echo "1. 로그인 중..."
LOGIN_RESPONSE=$(curl -s -c cookies.txt -X POST http://localhost:8080/login.do \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123")

if [ -f cookies.txt ]; then
  echo "   ✓ 쿠키 파일 생성됨"
else
  echo "   ✗ 쿠키 파일 생성 실패"
  echo "   로그인 페이지 URL을 확인하거나 수동으로 로그인하세요"
fi

echo ""

# 2. 프로젝트 목록 조회
echo "2. 프로젝트 목록 조회..."
curl -s -b cookies.txt http://localhost:8080/projects/list.do -o /dev/null -w "   상태 코드: %{http_code}\n"

echo ""

# 3. 삭제된 프로젝트 목록 조회 (에러 발생 지점)
echo "3. 삭제된 프로젝트 목록 조회..."
echo "   URL: http://localhost:8080/projects/deleted/list.do"
RESPONSE=$(curl -s -b cookies.txt -w "\n상태코드:%{http_code}" http://localhost:8080/projects/deleted/list.do)

HTTP_CODE=$(echo "$RESPONSE" | grep "상태코드:" | cut -d: -f2)
echo "   상태 코드: $HTTP_CODE"

if [ "$HTTP_CODE" == "200" ]; then
  echo "   ✓ 성공!"
elif [ "$HTTP_CODE" == "500" ]; then
  echo "   ✗ 500 에러 발생"
  echo ""
  echo "   === 응답 내용 (처음 500자) ==="
  echo "$RESPONSE" | head -c 500
  echo ""
  echo ""
  echo "   === 서버 로그 확인 (최근 30줄) ==="
  docker compose logs gov-portal --tail 30 | grep -E "Exception|Error|WARN" | tail -10
elif [ "$HTTP_CODE" == "302" ]; then
  echo "   ✗ 로그인이 필요합니다"
else
  echo "   ✗ 예상치 못한 응답: $HTTP_CODE"
fi

echo ""
echo "=== 테스트 완료 ==="

# 정리
rm -f cookies.txt
