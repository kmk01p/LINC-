#!/usr/bin/env python3
import psycopg2
import random
import uuid
from datetime import datetime, timedelta
import json

# Database connection
conn = psycopg2.connect(
    host="localhost",
    port="5432",
    database="egov",
    user="egov",
    password="egov"
)
cur = conn.cursor()

# Get all projects
cur.execute("SELECT id, name, country FROM projects WHERE deleted_at IS NULL ORDER BY created_at")
projects = cur.fetchall()

print(f"Found {len(projects)} projects")

form_templates = [
    "Community Health Survey",
    "Field Data Collection",
    "Monitoring Checklist",
    "Impact Assessment",
    "Baseline Survey",
    "Progress Report",
    "Site Inspection",
    "Beneficiary Registration"
]

# For each project, create forms and submissions
for proj_id, proj_name, proj_country in projects:
    print(f"\nProcessing: {proj_name} ({proj_country})")

    # Create random seed based on project ID
    random.seed(str(proj_id))

    # Number of forms for this project (1-4)
    num_forms = random.randint(1, 4)
    form_ids = []

    # Create forms
    for i in range(num_forms):
        form_id = str(uuid.uuid4())
        form_name = random.choice(form_templates)
        xml_form_id = f"{form_name.lower().replace(' ', '_')}_{i+1}"

        cur.execute("""
            INSERT INTO forms (id, project_id, xml_form_id, name, created_at)
            VALUES (%s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, (form_id, proj_id, xml_form_id, form_name, datetime.now() - timedelta(days=random.randint(60, 180))))

        form_ids.append((form_id, form_name))
        print(f"  + Created form: {form_name}")

    # Generate submissions for last 30 days
    base_submissions = random.randint(50, 200)
    growth_rate = random.uniform(0.5, 2.0)

    submission_count = 0
    quality_flag_count = 0

    for day_offset in range(29, -1, -1):
        submission_date = datetime.now() - timedelta(days=day_offset)

        # Daily variation
        daily_trend = base_submissions + (29 - day_offset) * growth_rate
        seasonal = 15 * random.uniform(-1, 1) * (1 + 0.3 * random.random())
        noise = random.gauss(0, 8)
        daily_submissions = max(2, int(daily_trend + seasonal + noise))

        # Create submissions for this day
        for _ in range(daily_submissions):
            form_id, form_name = random.choice(form_ids)
            submission_id = f"sub_{proj_id}_{submission_date.strftime('%Y%m%d')}_{uuid.uuid4().hex[:8]}"

            # Generate realistic payload
            payload = {
                "meta": {
                    "instanceID": submission_id,
                    "submissionDate": submission_date.isoformat()
                },
                "data": {
                    "location": proj_country or "Unknown",
                    "survey_date": submission_date.strftime("%Y-%m-%d"),
                    "respondent_count": random.randint(1, 50),
                    "notes": f"Data collected for {proj_name}"
                }
            }

            cur.execute("""
                INSERT INTO submissions_raw
                (id, project_id, form_id, submission_id, payload, submitted_at, created_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                ON CONFLICT (submission_id) DO NOTHING
            """, (
                str(uuid.uuid4()),
                proj_id,
                form_id,
                submission_id,
                json.dumps(payload),
                submission_date,
                submission_date
            ))

            submission_count += 1

            # Create quality flags for some submissions (10-20%)
            if random.random() < random.uniform(0.10, 0.20):
                flag_statuses = ['flagged', 'under_review', 'resolved']
                flag_weights = [0.3, 0.2, 0.5]  # More resolved than flagged
                status = random.choices(flag_statuses, weights=flag_weights)[0]

                flag_types = ['duplicate', 'incomplete', 'suspicious', 'validation_error']
                flag_type = random.choice(flag_types)

                cur.execute("""
                    INSERT INTO quality_flags
                    (id, project_id, submission_id, flag_type, status, details, created_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (project_id, submission_id, flag_type) DO NOTHING
                """, (
                    str(uuid.uuid4()),
                    proj_id,
                    submission_id,
                    flag_type,
                    status,
                    f"Auto-flagged: {flag_type}",
                    submission_date
                ))

                quality_flag_count += 1

    print(f"  ✓ Created {submission_count} submissions")
    print(f"  ✓ Created {quality_flag_count} quality flags")

conn.commit()
cur.close()
conn.close()

print("\n" + "="*60)
print("Data generation complete!")
print("="*60)

# Summary
conn = psycopg2.connect(
    host="localhost",
    port="5432",
    database="egov",
    user="egov",
    password="egov"
)
cur = conn.cursor()

cur.execute("SELECT COUNT(*) FROM forms")
form_count = cur.fetchone()[0]

cur.execute("SELECT COUNT(*) FROM submissions_raw")
submission_count = cur.fetchone()[0]

cur.execute("SELECT COUNT(*) FROM quality_flags")
flag_count = cur.fetchone()[0]

print(f"\nTotal forms: {form_count}")
print(f"Total submissions: {submission_count}")
print(f"Total quality flags: {flag_count}")

cur.close()
conn.close()
