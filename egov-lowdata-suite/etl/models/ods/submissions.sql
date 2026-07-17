-- ods.submissions: one record per submission (denormalized)
select * from {{ ref('staging_submissions') }};