-- marts.kpi_ops: sample KPI metrics for operations dashboard
with submissions as (
    select * from {{ ref('ods_submissions') }}
)
select 
    diagnosis,
    count(*) as submission_count
from submissions
group by 1;