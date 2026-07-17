-- LINC Demo Seed Data (ODK field collection scenario)
-- Run: psql -U egov -d egov -f scripts/sql/demo_seed_odk.sql

BEGIN;

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
-- tenant : 00000000-0000-0000-0000-100000000001
-- admin  : 00000000-0000-0000-0000-000000002001

-- Legacy users table (FK target for projects.created_by)
INSERT INTO users (id, username, password, grade, created_at)
VALUES
    ('00000000-0000-0000-0000-000000002001', 'admin', 'admin', 0, NOW()),
    ('00000000-0000-0000-0000-000000002002', 'grade4user', 'password', 4, NOW()),
    ('00000000-0000-0000-0000-000000002003', 'grade5user', 'password', 5, NOW())
ON CONFLICT (username) DO NOTHING;

-- Remove previous demo rows (idempotent re-run)
DELETE FROM quality_flags WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003',
    'd1000000-0000-4000-8000-000000000099'
);
DELETE FROM sync_cursor WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003'
);
DELETE FROM submissions_raw WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003'
);
DELETE FROM policies WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003'
);
DELETE FROM project_integrations WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003',
    'd1000000-0000-4000-8000-000000000099'
);
DELETE FROM project_forms WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003',
    'd1000000-0000-4000-8000-000000000099'
);
DELETE FROM forms WHERE project_id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003'
);
DELETE FROM projects WHERE id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003',
    'd1000000-0000-4000-8000-000000000099'
);
DELETE FROM projects_biz WHERE id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003',
    'd1000000-0000-4000-8000-000000000099'
);

-- ---------------------------------------------------------------------------
-- Projects (portal UI + ODK ingest layer)
-- ---------------------------------------------------------------------------
INSERT INTO projects_biz
    (id, tenant_id, name, country, sector, languages, codebook, odk_project_id, odk_project_uuid, odk_xml_form_id, status, created_by, created_at)
VALUES
    (
        'd1000000-0000-4000-8000-000000000001',
        '00000000-0000-0000-0000-100000000001',
        'LINC 에티오피아 보건현장 조사',
        'Ethiopia',
        'Health',
        'en,am',
        '{"facility_type":{"hospital":"병원","health_center":"헬스센터","health_post":"보건소"},"diagnosis_primary":{"malaria":"말라리아","tb":"결핵","respiratory_infection":"급성 호흡기 감염"}}'::jsonb,
        1,
        'a1111111-1111-4111-8111-111111111111',
        'et_healthcare_service_visit',
        'ACTIVE',
        '00000000-0000-0000-0000-000000002001',
        NOW() - INTERVAL '45 days'
    ),
    (
        'd1000000-0000-4000-8000-000000000002',
        '00000000-0000-0000-0000-100000000001',
        '케냐 농촌 생활환경 모니터링',
        'Kenya',
        'Agriculture',
        'en,sw',
        '{"gender":{"female":"여성","male":"남성"},"services":{"counseling":"상담","training":"교육","medical":"의료 지원"}}'::jsonb,
        2,
        'a2222222-2222-4222-8222-222222222222',
        'baseline_survey',
        'ACTIVE',
        '00000000-0000-0000-0000-000000002001',
        NOW() - INTERVAL '30 days'
    ),
    (
        'd1000000-0000-4000-8000-000000000003',
        '00000000-0000-0000-0000-100000000001',
        '라오스 기초생활 지원 대상 조사',
        'Laos',
        'Social Welfare',
        'lo,en',
        '{"age_group":{"20s":"20대","30s":"30대","40s":"40대","50s":"50대","60plus":"60대 이상"}}'::jsonb,
        3,
        'a3333333-3333-4333-8333-333333333333',
        'baseline_survey',
        'ACTIVE',
        '00000000-0000-0000-0000-000000002001',
        NOW() - INTERVAL '20 days'
    ),
    (
        'd1000000-0000-4000-8000-000000000099',
        '00000000-0000-0000-0000-100000000001',
        '2025 탄자니아 식수 인프라 점검 (종료)',
        'Tanzania',
        'Water & Sanitation',
        'en,sw',
        '{}'::jsonb,
        4,
        'a4444444-4444-4444-8444-444444444444',
        'water_inspection_v1',
        'ARCHIVED',
        '00000000-0000-0000-0000-000000002001',
        NOW() - INTERVAL '120 days'
    );

INSERT INTO projects
    (id, tenant_id, name, country, sector, languages, codebook, odk_project_id, odk_project_uuid, odk_xml_form_id, status, created_by, created_at, updated_at)
SELECT
    id, tenant_id, name, country, sector, languages, codebook,
    odk_project_id, odk_project_uuid, odk_xml_form_id, status, created_by, created_at, NOW()
FROM projects_biz
WHERE id IN (
    'd1000000-0000-4000-8000-000000000001',
    'd1000000-0000-4000-8000-000000000002',
    'd1000000-0000-4000-8000-000000000003'
);

UPDATE projects_biz
SET deleted_at = NOW() - INTERVAL '7 days',
    deleted_by = '00000000-0000-0000-0000-000000002001'
WHERE id = 'd1000000-0000-4000-8000-000000000099';

-- ---------------------------------------------------------------------------
-- Forms (ODK XLSForm IDs)
-- ---------------------------------------------------------------------------
INSERT INTO forms (id, project_id, xml_form_id, name, created_at) VALUES
    ('f1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', 'et_healthcare_service_visit', 'ET HealthCare Service Visit', NOW() - INTERVAL '44 days'),
    ('f1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000001', 'et_healthcare_follow_up', 'ET HealthCare Follow-up Visit', NOW() - INTERVAL '30 days'),
    ('f1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000002', 'baseline_survey', '기본 진단 설문', NOW() - INTERVAL '29 days'),
    ('f1000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000003', 'baseline_survey', '기초생활 지원 대상 설문', NOW() - INTERVAL '19 days');

INSERT INTO project_forms (id, project_id, template_name, version, uploaded_at) VALUES
    ('e1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', 'ET-HealthCare 방문 템플릿', 'v1.2', NOW() - INTERVAL '44 days'),
    ('e1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000002', '기본 진단 템플릿', 'v1.0', NOW() - INTERVAL '29 days'),
    ('e1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000003', '기본 진단 템플릿', 'v1.0', NOW() - INTERVAL '19 days');

INSERT INTO project_integrations (id, project_id, type, payload) VALUES
    ('c1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', 'ODK',
     '{"odkProjectId":1,"odkFormId":"et_healthcare_service_visit","odkExternalUrl":"http://localhost:8383","appUserDisplayName":"LINC Field Team Addis"}'::jsonb),
    ('c1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000001', 'METABASE',
     '{"dashboardId":2,"collectionName":"LINC Ethiopia Health","cardCount":6}'::jsonb),
    ('c1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000002', 'ODK',
     '{"odkProjectId":2,"odkFormId":"baseline_survey","odkExternalUrl":"http://localhost:8383","appUserDisplayName":"Kenya Rural Monitor"}'::jsonb),
    ('c1000000-0000-4000-8000-000000000004', 'd1000000-0000-4000-8000-000000000003', 'ODK',
     '{"odkProjectId":3,"odkFormId":"baseline_survey","odkExternalUrl":"http://localhost:8383","appUserDisplayName":"Laos Welfare Survey Team"}'::jsonb);

INSERT INTO policies (id, project_id, pseudonymization, geo_precision, retention_months, export_allowed) VALUES
    ('b1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', TRUE, 2, 24, TRUE),
    ('b1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000002', TRUE, 3, 12, FALSE),
    ('b1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000003', TRUE, 2, 18, TRUE);

-- ---------------------------------------------------------------------------
-- ODK submissions (simulated Collect / Enketo submissions)
-- ---------------------------------------------------------------------------
DO $$
DECLARE
    i INT;
    day_offset INT;
    submitted TIMESTAMPTZ;
    sub_id TEXT;
    facility_types TEXT[] := ARRAY['hospital','health_center','health_post','private_clinic'];
    diagnoses TEXT[] := ARRAY['malaria','tb','respiratory_infection','diarrheal_disease','non_communicable'];
    regions TEXT[] := ARRAY['Addis Ababa','Oromia','Amhara','SNNPR','Tigray'];
    enumerators TEXT[] := ARRAY['Abebe Kebede','Hanna Tadesse','Dawit Mekonnen','Selam Girma','Yonas Haile'];
    genders TEXT[] := ARRAY['female','male'];
    age_groups TEXT[] := ARRAY['20s','30s','40s','50s','60plus'];
    services_list TEXT[] := ARRAY['counseling','training','medical','cash'];
    payload JSONB;
BEGIN
    -- Ethiopia healthcare visits (~180 submissions, last 30 days)
    FOR i IN 1..180 LOOP
        day_offset := (i % 30);
        submitted := date_trunc('day', NOW()) - (day_offset || ' days')::INTERVAL + ((i % 12) || ' hours')::INTERVAL;
        sub_id := 'odk-eth-' || lpad(i::text, 5, '0');

        payload := jsonb_build_object(
            '__id', sub_id,
            '__system', jsonb_build_object(
                'submissionDate', to_char(submitted, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                'updatedAt', to_char(submitted + INTERVAL '2 minutes', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                'submitterId', (1 + (i % 5)),
                'deviceId', 'collect-android-' || (100 + (i % 8))
            ),
            'facility_id', 'ET-HC-' || lpad((1 + (i % 24))::text, 3, '0'),
            'facility_name', (ARRAY['Bole Health Center','Kirkos Clinic','Yeka Hospital','Gondar Health Post','Hawassa Mobile Team'])[1 + (i % 5)],
            'facility_type', facility_types[1 + (i % array_length(facility_types, 1))],
            'administrative_region', regions[1 + (i % array_length(regions, 1))],
            'visit_date', to_char(submitted::date, 'YYYY-MM-DD'),
            'enumerator_name', enumerators[1 + (i % array_length(enumerators, 1))],
            'enumerator_id', 'ENUM-' || lpad((1 + (i % 5))::text, 3, '0'),
            'consent_obtained', 'yes',
            'patient_id', 'PAT-2026-' || lpad(i::text, 4, '0'),
            'patient_age', 5 + (i % 75),
            'patient_gender', genders[1 + (i % 2)],
            'diagnosis_primary', diagnoses[1 + (i % array_length(diagnoses, 1))],
            'severity_level', (ARRAY['mild','moderate','severe'])[1 + (i % 3)],
            'treatment_given', 'medication counseling',
            'referral_made', CASE WHEN i % 11 = 0 THEN 'yes' ELSE 'no' END,
            'patient_status', (ARRAY['stable','improved','unchanged'])[1 + (i % 3)],
            'attachments_count', (i % 4),
            'data_quality_verified', CASE WHEN i % 9 = 0 THEN 'no' ELSE 'yes' END,
            'feedback_notes', 'ODK Collect 현장 제출 #' || i
        );

        INSERT INTO submissions_raw (project_id, form_id, submission_id, payload, submitted_at)
        VALUES (
            'd1000000-0000-4000-8000-000000000001',
            CASE WHEN i % 7 = 0 THEN 'f1000000-0000-4000-8000-000000000002'::uuid ELSE 'f1000000-0000-4000-8000-000000000001'::uuid END,
            sub_id,
            payload,
            submitted
        );
    END LOOP;

    -- Kenya baseline survey (~95 submissions)
    FOR i IN 1..95 LOOP
        day_offset := (i % 28);
        submitted := date_trunc('day', NOW()) - (day_offset || ' days')::INTERVAL + ((8 + (i % 10)) || ' hours')::INTERVAL;
        sub_id := 'odk-ken-' || lpad(i::text, 5, '0');

        payload := jsonb_build_object(
            '__id', sub_id,
            '__system', jsonb_build_object(
                'submissionDate', to_char(submitted, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                'updatedAt', to_char(submitted + INTERVAL '1 minute', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                'submitterId', (1 + (i % 4)),
                'deviceId', 'collect-android-ken-' || (200 + (i % 6))
            ),
            'respondent_id', 'R-KEN-' || lpad(i::text, 4, '0'),
            'household_size', 2 + (i % 8),
            'gender', genders[1 + (i % 2)],
            'age_group', age_groups[1 + (i % array_length(age_groups, 1))],
            'services', services_list[1 + (i % 4)] || ' ' || services_list[1 + ((i + 1) % 4)],
            'feedback', '농촌 생활환경 모니터링 현장 응답 #' || i
        );

        INSERT INTO submissions_raw (project_id, form_id, submission_id, payload, submitted_at)
        VALUES (
            'd1000000-0000-4000-8000-000000000002',
            'f1000000-0000-4000-8000-000000000003',
            sub_id,
            payload,
            submitted
        );
    END LOOP;

    -- Laos welfare survey (~62 submissions)
    FOR i IN 1..62 LOOP
        day_offset := (i % 21);
        submitted := date_trunc('day', NOW()) - (day_offset || ' days')::INTERVAL + ((10 + (i % 8)) || ' hours')::INTERVAL;
        sub_id := 'odk-lao-' || lpad(i::text, 5, '0');

        payload := jsonb_build_object(
            '__id', sub_id,
            '__system', jsonb_build_object(
                'submissionDate', to_char(submitted, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                'updatedAt', to_char(submitted + INTERVAL '3 minutes', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'),
                'submitterId', (1 + (i % 3)),
                'deviceId', 'collect-android-lao-' || (300 + (i % 5))
            ),
            'respondent_id', 'R-LAO-' || lpad(i::text, 4, '0'),
            'household_size', 1 + (i % 10),
            'gender', genders[1 + (i % 2)],
            'age_group', age_groups[1 + (i % array_length(age_groups, 1))],
            'services', 'counseling cash',
            'feedback', '기초생활 지원 대상 현장 조사 #' || i
        );

        INSERT INTO submissions_raw (project_id, form_id, submission_id, payload, submitted_at)
        VALUES (
            'd1000000-0000-4000-8000-000000000003',
            'f1000000-0000-4000-8000-000000000004',
            sub_id,
            payload,
            submitted
        );
    END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- Quality flags (ODK ingest / QC pipeline)
-- ---------------------------------------------------------------------------
INSERT INTO quality_flags (project_id, submission_id, flag_type, status, details, created_at)
SELECT
    sr.project_id,
    sr.submission_id,
    'missing_fields',
    'flagged',
    '필수 필드 누락: data_quality_verified = no',
    sr.submitted_at + INTERVAL '30 minutes'
FROM submissions_raw sr
WHERE sr.payload->>'data_quality_verified' = 'no'
ON CONFLICT DO NOTHING;

INSERT INTO quality_flags (project_id, submission_id, flag_type, status, details, created_at)
SELECT
    sr.project_id,
    sr.submission_id,
    'duplicate',
    'under_review',
    '동일 patient_id · 동일일자 중복 제출 의심',
    sr.submitted_at + INTERVAL '1 hour'
FROM submissions_raw sr
WHERE sr.submission_id IN ('odk-eth-00011','odk-eth-00022','odk-ken-00008','odk-lao-00015')
ON CONFLICT DO NOTHING;

INSERT INTO quality_flags (project_id, submission_id, flag_type, status, details, created_at)
SELECT
    sr.project_id,
    sr.submission_id,
    'geo_outlier',
    'resolved',
    'GPS 좌표 이상치 확인 후 정상 범위로 분류',
    sr.submitted_at + INTERVAL '2 hours'
FROM submissions_raw sr
WHERE sr.submission_id IN ('odk-eth-00005','odk-eth-00040','odk-eth-00088','odk-ken-00020','odk-lao-00030')
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- ODK sync cursors (last incremental ingest timestamps)
-- ---------------------------------------------------------------------------
INSERT INTO sync_cursor (project_id, form_id, last_updated_at, updated_at) VALUES
    ('d1000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000001', to_char(NOW() - INTERVAL '15 minutes', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), NOW()),
    ('d1000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000002', to_char(NOW() - INTERVAL '45 minutes', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), NOW()),
    ('d1000000-0000-4000-8000-000000000002', 'f1000000-0000-4000-8000-000000000003', to_char(NOW() - INTERVAL '20 minutes', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), NOW()),
    ('d1000000-0000-4000-8000-000000000003', 'f1000000-0000-4000-8000-000000000004', to_char(NOW() - INTERVAL '10 minutes', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'), NOW());

-- ---------------------------------------------------------------------------
-- Batch / system audit trail (JdbcAuditLogDao schema)
-- ---------------------------------------------------------------------------
INSERT INTO audit_logs (tenant_id, project_id, action, status, message, created_by, created_at) VALUES
    ('00000000-0000-0000-0000-100000000001', 'd1000000-0000-4000-8000-000000000001', 'ODK_INGEST', 'SUCCESS', 'ODK OData 증분 동기화 완료: 12건 upsert (et_healthcare_service_visit)', 'system', NOW() - INTERVAL '15 minutes'),
    ('00000000-0000-0000-0000-100000000001', 'd1000000-0000-4000-8000-000000000002', 'ODK_INGEST', 'SUCCESS', 'ODK OData 증분 동기화 완료: 5건 upsert (baseline_survey)', 'system', NOW() - INTERVAL '20 minutes'),
    ('00000000-0000-0000-0000-100000000001', 'd1000000-0000-4000-8000-000000000001', 'ETL_RUN', 'SUCCESS', 'dbt staging→marts 모델 실행 완료', 'system', NOW() - INTERVAL '3 hours'),
    ('00000000-0000-0000-0000-100000000001', NULL, 'PROJECT_CREATE', 'SUCCESS', 'LINC 에티오피아 보건현장 조사 프로젝트 생성 및 ODK 배포', 'admin', NOW() - INTERVAL '45 days'),
    ('00000000-0000-0000-0000-100000000001', 'd1000000-0000-4000-8000-000000000003', 'QUALITY_CHECK', 'SUCCESS', '품질 검사 완료: flagged 3건, resolved 5건', 'system', NOW() - INTERVAL '1 day');

COMMIT;

-- Summary
SELECT 'projects_biz (active)' AS item, COUNT(*)::text AS count FROM projects_biz WHERE deleted_at IS NULL
UNION ALL SELECT 'projects_biz (deleted)', COUNT(*)::text FROM projects_biz WHERE deleted_at IS NOT NULL
UNION ALL SELECT 'submissions_raw', COUNT(*)::text FROM submissions_raw
UNION ALL SELECT 'quality_flags', COUNT(*)::text FROM quality_flags
UNION ALL SELECT 'sync_cursor', COUNT(*)::text FROM sync_cursor;
