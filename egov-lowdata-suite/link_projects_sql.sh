#!/bin/bash

# Get session token
SESSION=$(curl -s -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

TOKEN=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
CSRF=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['csrf'])")

echo "Fetching ODK projects..."

# Get all ODK projects
PROJECTS=$(curl -s http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF")

# Create SQL update statements
cat > /tmp/link_projects.sql << 'EOF'
-- Link projects with ODK Central projects
EOF

echo "$PROJECTS" | python3 << 'PYEOF'
import json
import sys

projects = json.load(sys.stdin)

# Generate SQL updates for each ODK project
for i, proj in enumerate(projects):
    odk_id = proj['id']
    odk_uuid = proj['acteeId']
    odk_name = proj['name']

    # Create UPDATE statement
    print(f"-- ODK Project: {odk_name}")
    print(f"UPDATE projects SET ")
    print(f"  odk_project_id = {odk_id}, ")
    print(f"  odk_project_uuid = '{odk_uuid}'::uuid ")
    print(f"WHERE id = (")
    print(f"  SELECT id FROM projects ")
    print(f"  WHERE odk_project_id IS NULL ")
    print(f"  ORDER BY created_at ")
    print(f"  LIMIT 1")
    print(f");")
    print()

PYEOF

python3 << 'PYEOF2' >> /tmp/link_projects.sql
import json
import sys

# Read ODK projects from stdin
odk_json = """
PYEOF2

echo "$PROJECTS" >> /tmp/link_projects.sql

cat >> /tmp/link_projects.sql << 'PYEOF3'
"""

projects = json.loads(odk_json)

for proj in projects:
    odk_id = proj['id']
    odk_uuid = proj['acteeId']
    odk_name = proj['name']

    print(f"-- {odk_name}")
    print(f"UPDATE projects SET odk_project_id = {odk_id}, odk_project_uuid = '{odk_uuid}'::uuid")
    print(f"WHERE id = (SELECT id FROM projects WHERE odk_project_id IS NULL ORDER BY created_at LIMIT 1);")
    print()
PYEOF3

# Execute the SQL
echo "Linking projects in database..."
docker compose exec -T postgres psql -U egov -d egov -f /tmp/link_projects.sql

# Verify
echo -e "\n=== Verification ==="
docker compose exec postgres psql -U egov -d egov -c "SELECT COUNT(*) as linked_projects FROM projects WHERE odk_project_id IS NOT NULL;"
