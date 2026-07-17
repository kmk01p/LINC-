-- Simple linking: assign ODK project IDs sequentially to database projects
-- This will link the first 52 database projects with the 52 ODK projects

WITH odk_ids AS (
  SELECT generate_series(16, 67) as odk_project_id
),
db_projects AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) as rn
  FROM projects
)
UPDATE projects p
SET odk_project_id = o.odk_project_id
FROM (
  SELECT dp.id, oi.odk_project_id
  FROM db_projects dp
  JOIN odk_ids oi ON dp.rn = oi.odk_project_id - 15
) o
WHERE p.id = o.id;

-- Verification
SELECT COUNT(*) as total_projects,
       COUNT(odk_project_id) as linked_projects
FROM projects;

-- Show sample
SELECT name, country, odk_project_id
FROM projects
WHERE odk_project_id IS NOT NULL
LIMIT 10;
