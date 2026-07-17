#!/bin/bash

# Get session token
SESSION=$(curl -s -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

TOKEN=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
CSRF=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['csrf'])")

echo "Token: $TOKEN"
echo "CSRF: $CSRF"

# Test GET request
echo -e "\n=== Listing existing projects ==="
curl -s http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF" | python3 -m json.tool | head -30

# Create a test project
echo -e "\n=== Creating test project ==="
curl -s -X POST http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF" \
  -H "Content-Type: application/json" \
  -d '{"name":"Kenya Agricultural Modernization"}' | python3 -m json.tool
