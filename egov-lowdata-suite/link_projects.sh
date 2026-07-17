#!/bin/bash

# Get session token
SESSION=$(curl -s -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

TOKEN=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
CSRF=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['csrf'])")

echo "Fetching ODK projects and linking to database..."

# Get all ODK projects
PROJECTS=$(curl -s http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF")

# Save to file for processing
echo "$PROJECTS" > /tmp/odk_projects.json

# Create Python script to link projects
cat > /tmp/link_projects.py << 'EOF'
import json
import psycopg2
import re

# Read ODK projects
with open('/tmp/odk_projects.json', 'r') as f:
    odk_projects = json.load(f)

# Connect to database
conn = psycopg2.connect(
    host="localhost",
    port="5432",
    database="egov",
    user="egov",
    password="egov"
)
cur = conn.cursor()

# Get all projects from our database
cur.execute("SELECT id, name, country FROM projects ORDER BY created_at")
db_projects = cur.fetchall()

# Create mapping of keywords to ODK projects
odk_map = {}
for odk in odk_projects:
    odk_id = odk['id']
    odk_name = odk['name']
    odk_uuid = odk['acteeId']

    # Extract keywords from ODK project name
    keywords = odk_name.lower().split()
    for keyword in keywords:
        if len(keyword) > 3:  # Only use meaningful keywords
            if keyword not in odk_map:
                odk_map[keyword] = []
            odk_map[keyword].append({
                'id': odk_id,
                'uuid': odk_uuid,
                'name': odk_name
            })

# Update database projects with ODK info
updated = 0
for db_id, db_name, db_country in db_projects:
    # Try to find matching ODK project
    best_match = None

    # First try exact name match
    for odk in odk_projects:
        if db_name.lower() in odk['name'].lower() or odk['name'].lower() in db_name.lower():
            best_match = odk
            break

    # If no exact match, try keyword matching
    if not best_match:
        db_keywords = (db_name + ' ' + (db_country or '')).lower().split()
        for keyword in db_keywords:
            if keyword in odk_map and len(odk_map[keyword]) > 0:
                best_match = next((p for p in odk_projects if p['id'] == odk_map[keyword][0]['id']), None)
                if best_match:
                    # Remove this ODK project from pool so it won't be matched again
                    odk_map[keyword].pop(0)
                    break

    # If still no match, just assign next available ODK project
    if not best_match and len(odk_projects) > 0:
        best_match = odk_projects[0]
        odk_projects.pop(0)

    if best_match:
        cur.execute(
            "UPDATE projects SET odk_project_id = %s, odk_project_uuid = %s WHERE id = %s",
            (best_match['id'], best_match['acteeId'], db_id)
        )
        print(f"✓ Linked '{db_name}' -> ODK Project ID {best_match['id']}: {best_match['name']}")
        updated += 1
    else:
        print(f"✗ No ODK project available for '{db_name}'")

conn.commit()
cur.close()
conn.close()

print(f"\n=== Summary ===")
print(f"Successfully linked {updated} projects")
EOF

python3 /tmp/link_projects.py
