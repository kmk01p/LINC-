#!/usr/bin/env python3
import os
import sys
import psycopg2
from psycopg2.extras import RealDictCursor
from datetime import datetime

DB_HOST = os.getenv('POSTGRES_HOST', 'postgres')
DB_PORT = os.getenv('POSTGRES_PORT', '5432')
DB_NAME = os.getenv('POSTGRES_DB', 'egov')
DB_USER = os.getenv('POSTGRES_USER', 'postgres')
DB_PASSWORD = os.getenv('POSTGRES_PASSWORD', 'secret')

def connect_db():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )


def run_quality_checks():
    conn = connect_db()
    cursor = conn.cursor(cursor_factory=RealDictCursor)
    
    try:
        # Check for missing required fields
        cursor.execute("""
            INSERT INTO quality_flags (id, project_id, submission_id, flag_type, status, details, created_at)
            SELECT 
                gen_random_uuid(),
                project_id,
                submission_id,
                'missing_fields',
                'flagged',
                'Required fields missing',
                NOW()
            FROM submissions_raw
            WHERE payload->>'patient_name' IS NULL
            ON CONFLICT DO NOTHING
        """)
        
        # Check for duplicate submissions
        cursor.execute("""
            INSERT INTO quality_flags (id, project_id, submission_id, flag_type, status, details, created_at)
            SELECT 
                gen_random_uuid(),
                project_id,
                submission_id,
                'duplicate',
                'flagged',
                'Potential duplicate submission',
                NOW()
            FROM submissions_raw sr1
            WHERE EXISTS (
                SELECT 1 FROM submissions_raw sr2
                WHERE sr1.project_id = sr2.project_id
                AND sr1.submission_id != sr2.submission_id
                AND sr1.payload->>'patient_id' = sr2.payload->>'patient_id'
                AND sr1.submitted_at::DATE = sr2.submitted_at::DATE
            )
            ON CONFLICT DO NOTHING
        """)
        
        conn.commit()
        print(f"Quality checks completed at {datetime.now()}")
        
    except Exception as e:
        conn.rollback()
        print(f"Error running quality checks: {e}", file=sys.stderr)
        sys.exit(1)
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    run_quality_checks()
