-- Copy all projects from 'projects' table to 'projects_biz' table
-- Skip the one that already exists in projects_biz

INSERT INTO projects_biz (
    id, tenant_id, name, country, sector, languages,
    codebook, odk_project_id, odk_project_uuid, odk_xml_form_id,
    status, created_by, created_at, deleted_at, deleted_by
)
SELECT
    p.id,
    p.tenant_id,
    p.name,
    p.country,
    p.sector,
    p.languages,
    COALESCE(p.codebook, '{}'::jsonb),
    p.odk_project_id,
    p.odk_project_uuid,
    p.odk_xml_form_id,
    p.status,
    p.created_by,
    p.created_at,
    NULL as deleted_at,
    NULL as deleted_by
FROM projects p
WHERE NOT EXISTS (
    SELECT 1 FROM projects_biz pb WHERE pb.id = p.id
);

-- Verification
SELECT COUNT(*) as total_projects_biz FROM projects_biz;
SELECT name, country, status, odk_project_id FROM projects_biz ORDER BY created_at LIMIT 10;
