#!/usr/bin/env python3
import random
import uuid
from datetime import datetime, timedelta
import json
import sys

# Read projects from stdin or generate SQL
print("-- Generated statistics data for all projects")
print("-- This will create forms, submissions, and quality flags")
print()

# We'll generate data for project IDs - need to query first
print("-- First, let's get the project IDs")
print("\\set project_data `psql -U egov -d egov -t -A -F'|' -c \"SELECT id, name, country FROM projects WHERE deleted_at IS NULL ORDER BY created_at\"`")
print()

# For now, generate a DO block that will work with all projects
print("""
DO $$
DECLARE
    proj RECORD;
    form_id UUID;
    form_ids UUID[];
    form_names TEXT[] := ARRAY[
        'Community Health Survey',
        'Field Data Collection',
        'Monitoring Checklist',
        'Impact Assessment',
        'Baseline Survey',
        'Progress Report',
        'Site Inspection',
        'Beneficiary Registration'
    ];
    num_forms INT;
    i INT;
    day_offset INT;
    submission_date TIMESTAMP;
    daily_submissions INT;
    curr_submission_id TEXT;
    base_submissions INT;
    submission_count INT;
    quality_flag_count INT;
BEGIN
    -- Loop through all projects
    FOR proj IN SELECT id, name, country FROM projects ORDER BY created_at LOOP
        RAISE NOTICE 'Processing project: % (%)', proj.name, proj.country;

        -- Random number of forms (1-4) based on project id hash
        num_forms := 1 + (abs(hashtext(proj.id::TEXT)) % 4);
        form_ids := ARRAY[]::UUID[];

        -- Create forms
        FOR i IN 1..num_forms LOOP
            form_id := gen_random_uuid();
            INSERT INTO forms (id, project_id, xml_form_id, name, created_at)
            VALUES (
                form_id,
                proj.id,
                form_names[1 + (i % array_length(form_names, 1))] || '_' || i,
                form_names[1 + (i % array_length(form_names, 1))],
                NOW() - ((60 + (hashtext(proj.id::TEXT) % 120)) || ' days')::INTERVAL
            )
            ON CONFLICT DO NOTHING;

            form_ids := array_append(form_ids, form_id);
        END LOOP;

        RAISE NOTICE '  Created % forms, array length: %', num_forms, array_length(form_ids, 1);

        -- Base submissions for this project (50-200)
        base_submissions := 50 + (abs(hashtext(proj.id::TEXT)) % 150);
        submission_count := 0;
        quality_flag_count := 0;

        -- Generate submissions for last 30 days
        FOR day_offset IN REVERSE 29..0 LOOP
            submission_date := NOW() - (day_offset || ' days')::INTERVAL;

            -- Daily submissions with trend and variation
            daily_submissions := GREATEST(2,
                base_submissions +
                (29 - day_offset) * 2 +
                (15 * sin(day_offset / 4.0)) +
                ((hashtext(proj.id::TEXT || day_offset::TEXT) % 16) - 8)
            )::INT;

            -- Create submissions
            FOR i IN 1..daily_submissions LOOP
                form_id := form_ids[1 + ((i - 1) % array_length(form_ids, 1))];
                curr_submission_id := 'sub_' || proj.id || '_' ||
                                to_char(submission_date, 'YYYYMMDD') || '_' ||
                                substring(md5(random()::TEXT), 1, 8);

                INSERT INTO submissions_raw (
                    id, project_id, form_id, submission_id,
                    payload, submitted_at, created_at
                )
                VALUES (
                    gen_random_uuid(),
                    proj.id,
                    form_id,
                    curr_submission_id,
                    jsonb_build_object(
                        'meta', jsonb_build_object(
                            'instanceID', curr_submission_id,
                            'submissionDate', submission_date
                        ),
                        'data', jsonb_build_object(
                            'location', COALESCE(proj.country, 'Unknown'),
                            'survey_date', to_char(submission_date, 'YYYY-MM-DD'),
                            'respondent_count', 1 + (abs(hashtext(curr_submission_id)) % 50),
                            'notes', 'Data collected for ' || proj.name
                        )
                    ),
                    submission_date,
                    submission_date
                )
                ON CONFLICT (submission_id) DO NOTHING;

                submission_count := submission_count + 1;

                -- Create quality flags (10-20% of submissions)
                IF (abs(hashtext(curr_submission_id)) % 100) < 15 THEN
                    INSERT INTO quality_flags (
                        id, project_id, submission_id,
                        flag_type, status, details, created_at
                    )
                    VALUES (
                        gen_random_uuid(),
                        proj.id,
                        curr_submission_id,
                        CASE (abs(hashtext(curr_submission_id)) % 4)
                            WHEN 0 THEN 'duplicate'
                            WHEN 1 THEN 'incomplete'
                            WHEN 2 THEN 'suspicious'
                            ELSE 'validation_error'
                        END,
                        CASE
                            WHEN (abs(hashtext(curr_submission_id)) % 10) < 3 THEN 'flagged'
                            WHEN (abs(hashtext(curr_submission_id)) % 10) < 5 THEN 'under_review'
                            ELSE 'resolved'
                        END,
                        'Auto-flagged for review',
                        submission_date
                    )
                    ON CONFLICT (project_id, submission_id, flag_type) DO NOTHING;

                    quality_flag_count := quality_flag_count + 1;
                END IF;
            END LOOP;
        END LOOP;

        RAISE NOTICE '  ✓ Created % submissions and % quality flags', submission_count, quality_flag_count;
    END LOOP;
END $$;

-- Summary
SELECT 'Total forms: ' || COUNT(*) FROM forms;
SELECT 'Total submissions: ' || COUNT(*) FROM submissions_raw;
SELECT 'Total quality flags: ' || COUNT(*) FROM quality_flags;
""")
