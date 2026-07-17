-- RBAC core schema for eGovFrame migration

create extension if not exists "uuid-ossp";

create table if not exists app_users (
    id uuid primary key default uuid_generate_v4(),
    username varchar(100) not null unique,
    password varchar(255) not null,
    grade integer not null,
    created_at timestamp without time zone default now()
);

create table if not exists app_permissions (
    id uuid primary key default uuid_generate_v4(),
    code varchar(120) not null unique,
    description varchar(255),
    created_at timestamp without time zone default now()
);

create table if not exists app_roles (
    id uuid primary key default uuid_generate_v4(),
    name varchar(120) not null unique,
    description varchar(255),
    created_at timestamp without time zone default now(),
    created_by uuid
);

create table if not exists app_role_permissions (
    role_id uuid not null references app_roles(id) on delete cascade,
    permission_id uuid not null references app_permissions(id) on delete cascade,
    primary key (role_id, permission_id)
);

create table if not exists app_user_role_assignments (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references app_users(id) on delete cascade,
    role_id uuid not null references app_roles(id) on delete cascade,
    tenant_id uuid not null,
    project_id uuid,
    valid_from timestamp without time zone not null,
    valid_to timestamp without time zone,
    granted_by uuid not null
);

create index if not exists idx_app_user_role_assignments_user on app_user_role_assignments(user_id);

create table if not exists audit_logs (
    id uuid primary key default uuid_generate_v4(),
    severity varchar(10) not null,
    action varchar(120) not null,
    detail text,
    actor_id uuid,
    created_at timestamp without time zone default now()
);

-- Seed permissions and roles
insert into app_permissions (id, code, description)
values
    ('00000000-0000-0000-0000-000000000101', 'proj.read', '프로젝트 열람'),
    ('00000000-0000-0000-0000-000000000102', 'proj.manage', '프로젝트 생성 및 수정'),
    ('00000000-0000-0000-0000-000000000103', 'rbac.role.manage', '역할/권한 관리'),
    ('00000000-0000-0000-0000-000000000104', 'rbac.assign', '역할 부여/회수'),
    ('00000000-0000-0000-0000-000000000105', 'data.view.agg', '집계 데이터 열람'),
    ('00000000-0000-0000-0000-000000000106', 'data.view.row_masked', '마스킹 데이터 열람'),
    ('00000000-0000-0000-0000-000000000107', 'data.view.row', '원시 데이터 열람'),
    ('00000000-0000-0000-0000-000000000108', 'data.export.csv', 'CSV 내보내기'),
    ('00000000-0000-0000-0000-000000000109', 'kegov.publish', 'K-eGov 전송')
on conflict (code) do nothing;

insert into app_roles (id, name, description)
values
    ('00000000-0000-0000-0000-000000001001', 'ROLE_ADMIN_SUPER', '최고 관리자'),
    ('00000000-0000-0000-0000-000000001002', 'ROLE_PUBLIC_OFFICER_GRADE4', '4급 담당자'),
    ('00000000-0000-0000-0000-000000001003', 'ROLE_PUBLIC_OFFICER_GRADE5', '5급 담당자')
on conflict (name) do nothing;

insert into app_users (id, username, password, grade)
values
    ('00000000-0000-0000-0000-000000002001', 'admin', '$2a$12$cOFj7O8q6pHxiTGkT3R8HejE1epS.VIxO2e2FNJJuLxbdJ70Gn32i', 0),
    ('00000000-0000-0000-0000-000000002002', 'grade4user', '$2a$12$3Lo.AgCtnkq5TTqRcThg1OJZzI9e6RuApf1HBUdniSauMRogzxp.W', 4),
    ('00000000-0000-0000-0000-000000002003', 'grade5user', '$2a$12$m.IsHtmHsUfyrPk4LPMyb.R2R.d8fa9abtftdG.UlPzrJzc0CFMpq', 5)
on conflict (username) do nothing;

-- Role permission bundles
insert into app_role_permissions (role_id, permission_id)
values
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000101'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000102'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000103'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000104'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000105'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000106'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000107'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000108'),
    ('00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-000000000109'),
    ('00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-000000000101'),
    ('00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-000000000105'),
    ('00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-000000000107'),
    ('00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-000000000108'),
    ('00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-000000000109'),
    ('00000000-0000-0000-0000-000000001003', '00000000-0000-0000-0000-000000000101'),
    ('00000000-0000-0000-0000-000000001003', '00000000-0000-0000-0000-000000000105'),
    ('00000000-0000-0000-0000-000000001003', '00000000-0000-0000-0000-000000000106'),
    ('00000000-0000-0000-0000-000000001003', '00000000-0000-0000-0000-000000000108')
on conflict do nothing;

insert into app_user_role_assignments
    (id, user_id, role_id, tenant_id, project_id, valid_from, granted_by)
values
    ('00000000-0000-0000-0000-000000003001', '00000000-0000-0000-0000-000000002001', '00000000-0000-0000-0000-000000001001', '00000000-0000-0000-0000-100000000001', null, now(), '00000000-0000-0000-0000-000000002001'),
    ('00000000-0000-0000-0000-000000003002', '00000000-0000-0000-0000-000000002002', '00000000-0000-0000-0000-000000001002', '00000000-0000-0000-0000-100000000001', null, now(), '00000000-0000-0000-0000-000000002001'),
    ('00000000-0000-0000-0000-000000003003', '00000000-0000-0000-0000-000000002003', '00000000-0000-0000-0000-000000001003', '00000000-0000-0000-0000-100000000001', null, now(), '00000000-0000-0000-0000-000000002001')
on conflict do nothing;
