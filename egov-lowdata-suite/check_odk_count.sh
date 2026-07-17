#!/bin/bash

SESSION=$(curl -s -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

TOKEN=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
CSRF=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['csrf'])")

echo "=== ODK Central Projects ==="
curl -s http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF" | python3 -c "import sys, json; projects = json.load(sys.stdin); print(f'Total: {len(projects)} projects'); [print(f'  {p[\"id\"]}: {p[\"name\"]}') for p in projects[:10]]; print('  ...')  if len(projects) > 10 else None"
