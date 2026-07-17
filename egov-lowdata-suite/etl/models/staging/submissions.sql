-- staging.submissions: raw ingestion from ODK
with source as (
    select * from {{ source('public', 'submissions_raw') }}
)
select 
    payload->>'__id' as submission_id,
    payload->>'patient_id' as patient_id,
    payload->>'diagnosis' as diagnosis,
    to_timestamp(payload->>'meta_end') as submitted_at
from source;