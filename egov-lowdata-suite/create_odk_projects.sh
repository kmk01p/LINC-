#!/bin/bash

# Login and save session
curl -c cookies.txt -s http://localhost:8383/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}' > /dev/null

echo "Creating ODK Central projects..."

# Array of project names
projects=(
  "Kenya Agricultural Modernization"
  "Ethiopia Health System"
  "Tanzania Education Infrastructure"
  "Vietnam Smart City"
  "Bangladesh Disaster Management"
  "Peru Andes Agriculture"
  "Jordan Syrian Refugee Support"
  "Fiji Climate Change Response"
  "Uzbekistan Export Capacity"
  "Kenya Fintech Startup"
  "Rwanda ICT Capacity"
  "Colombia Peace Settlement"
  "Philippines Disaster Recovery"
  "Indonesia Marine Fisheries"
  "Mongolia Livestock Modernization"
  "Pakistan Education Reform"
  "Brazil Amazon Healthcare"
  "India COVID-19 Vaccination"
  "DRC Ebola Response"
  "Ghana Renewable Energy"
)

# Create projects
for project_name in "${projects[@]}"; do
  echo "Creating project: $project_name"
  curl -b cookies.txt -s http://localhost:8383/v1/projects \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$project_name\"}" | python3 -c "import sys, json; print(json.load(sys.stdin)['id'])"
  sleep 0.5
done

echo "Done creating ODK projects!"
