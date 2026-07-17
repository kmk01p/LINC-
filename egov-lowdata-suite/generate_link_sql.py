#!/usr/bin/env python3
import json
import subprocess

# Get ODK projects
result = subprocess.run([
    'curl', '-s', '-X', 'POST', 'http://localhost:8383/v1/sessions',
    '-H', 'Content-Type: application/json',
    '-d', '{"email":"admin@example.com","password":"admin123"}'
], capture_output=True, text=True)

session = json.loads(result.stdout)
token = session['token']
csrf = session['csrf']

# Fetch projects
result = subprocess.run([
    'curl', '-s', 'http://localhost:8383/v1/projects',
    '-H', f'Authorization: Bearer {token}',
    '-H', f'X-CSRF-Token: {csrf}'
], capture_output=True, text=True)

odk_projects = json.loads(result.stdout)

print("-- Link ODK Central projects to database projects")
print("-- Generated automatically\n")

for proj in odk_projects:
    odk_id = proj['id']
    odk_uuid = proj['acteeId']
    odk_name = proj['name']

    print(f"-- ODK: {odk_name}")
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

print("\n-- Verification")
print("SELECT COUNT(*) as linked FROM projects WHERE odk_project_id IS NOT NULL;")
