#!/bin/bash

# Get session token
SESSION=$(curl -s -X POST http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}')

TOKEN=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
CSRF=$(echo "$SESSION" | python3 -c "import sys, json; print(json.load(sys.stdin)['csrf'])")

echo "Creating ODK Central projects..."

# Array of project names
projects=(
  "Ethiopia Health System"
  "Tanzania Education Infrastructure"
  "Uganda Water Management"
  "Rwanda ICT Capacity"
  "Ghana Renewable Energy"
  "Senegal Women Entrepreneurship"
  "Mozambique Port Infrastructure"
  "Vietnam Smart City"
  "Bangladesh Disaster Management"
  "Myanmar Rural Electrification"
  "Cambodia Tourism Development"
  "Laos Mekong Basin"
  "Philippines Disaster Recovery"
  "Indonesia Marine Fisheries"
  "Mongolia Livestock Modernization"
  "Sri Lanka Healthcare"
  "Nepal Mountain Development"
  "Peru Andes Agriculture"
  "Bolivia Water Management"
  "Colombia Peace Settlement"
  "Paraguay SME Development"
  "Ecuador Biodiversity"
  "Honduras Education Quality"
  "Nicaragua Coffee Productivity"
  "Jordan Syrian Refugee"
  "Iraq Reconstruction"
  "Palestine Youth Training"
  "Fiji Climate Change"
  "Solomon Islands Fisheries"
  "Papua New Guinea Health"
  "Uzbekistan Export Capacity"
  "Kyrgyzstan Tourism"
  "Tajikistan Irrigation"
  "Zambia Mining Technology"
  "Malawi Food Security"
  "Madagascar Ecotourism"
  "Pakistan Education Reform"
  "Afghanistan Women Rights"
  "Timor Leste Public Admin"
  "South Sudan Peacebuilding"
  "Haiti Disaster Recovery"
  "Asia Pacific Climate"
  "Africa Digital Innovation"
  "Latin America Agriculture"
  "DRC Ebola Response"
  "India COVID-19 Vaccination"
  "Brazil Amazon Healthcare"
  "Vietnam AI Training"
  "Kenya Fintech Startup"
  "Kazakhstan Smart Agriculture"
)

# Create projects
count=0
for project_name in "${projects[@]}"; do
  echo "Creating: $project_name"
  result=$(curl -s -X POST http://localhost:8383/v1/projects \
    -H "Authorization: Bearer $TOKEN" \
    -H "X-CSRF-Token: $CSRF" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$project_name\"}")

  project_id=$(echo "$result" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('id', 'error'))" 2>/dev/null)

  if [ "$project_id" != "error" ] && [ ! -z "$project_id" ]; then
    echo "  ✓ Created project ID: $project_id"
    ((count++))
  else
    echo "  ✗ Failed to create project"
  fi

  sleep 0.3
done

echo -e "\n=== Summary ==="
echo "Successfully created $count projects"
echo "Total projects in ODK Central:"
curl -s http://localhost:8383/v1/projects \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-CSRF-Token: $CSRF" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))"
