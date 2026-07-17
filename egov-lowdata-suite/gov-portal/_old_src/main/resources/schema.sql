create extension if not exists pgcrypto;

-- Core tables
create table if not exists app_users (
    id uuid primary key default gen_random_uuid(),
    username varchar(50) not null unique,
    password varchar(100) not null,
    grade integer not null,
    created_at timestamptz default now()
);

create table if not exists app_roles (
    id uuid primary key default gen_random_uuid(),
    name varchar(100) not null unique
);

create table if not exists app_permissions (
    id uuid primary key default gen_random_uuid(),
    code varchar(100) not null unique
);

create table if not exists app_role_permissions (
    role_id uuid not null references app_roles(id) on delete cascade,
    permission_id uuid not null references app_permissions(id) on delete cascade,
    primary key (role_id, permission_id)
);

create table if not exists app_user_role_assignments (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references app_users(id) on delete cascade,
    role_id uuid not null references app_roles(id) on delete cascade,
    tenant_id uuid not null,
    project_id uuid,
    valid_from timestamptz not null,
    valid_to timestamptz,
    granted_by uuid references app_users(id)
);

create table if not exists app_projects (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null,
    name varchar(200) not null,
    country varchar(100),
    sector varchar(100),
    languages text,
    codebook jsonb,
    odk_project_uuid uuid,
    created_by uuid references app_users(id),
    created_at timestamptz default now(),
    updated_at timestamptz
);

create table if not exists app_forms (
    id uuid primary key default gen_random_uuid(),
    project_id uuid not null references app_projects(id) on delete cascade,
    xml_form_id varchar(200) not null,
    name varchar(200) not null,
    created_at timestamptz default now()
);

create table if not exists app_policies (
    id uuid primary key default gen_random_uuid(),
    project_id uuid not null references app_projects(id) on delete cascade,
    pseudonymization boolean default true,
    geo_precision integer default 2,
    retention_months integer default 12,
    export_allowed boolean default false
);

create table if not exists app_submissions_raw (
    id bigserial primary key,
    project_id uuid not null references app_projects(id) on delete cascade,
    form_id uuid not null references app_forms(id) on delete cascade,
    payload jsonb not null,
    submitted_at timestamptz not null
);

create table if not exists app_audit_logs (
    id bigserial primary key,
    user_id uuid references app_users(id),
    action varchar(200) not null,
    message text,
    created_at timestamptz default now()
);

-- Views for masked data (simplified)
create or replace view app_v_submissions_masked as
select 
    s.id,
    s.project_id,
    s.form_id,
    -- pseudonymize patient_id field (if exists)
    s.payload - 'patient_id' as payload_masked,
    s.submitted_at
from app_submissions_raw s;

-- Row-level security: Example policy using app.tenant_id and project_id (to be set per session)
alter table app_submissions_raw enable row level security;
drop policy if exists submissions_per_project on app_submissions_raw;
create policy submissions_per_project on app_submissions_raw
    using (true);
