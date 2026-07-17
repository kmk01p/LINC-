-- Seed permissions
insert into app_permissions (id, code) values
  (gen_random_uuid(), 'proj.read'),
  (gen_random_uuid(), 'proj.manage'),
  (gen_random_uuid(), 'rbac.role.manage'),
  (gen_random_uuid(), 'rbac.assign'),
  (gen_random_uuid(), 'data.view.agg'),
  (gen_random_uuid(), 'data.view.row_masked'),
  (gen_random_uuid(), 'data.view.row'),
  (gen_random_uuid(), 'data.export.csv'),
  (gen_random_uuid(), 'kegov.publish')
on conflict (code) do nothing;

-- Seed roles
insert into app_roles (id, name) values
  (gen_random_uuid(), 'ROLE_ADMIN_SUPER'),
  (gen_random_uuid(), 'ROLE_PUBLIC_OFFICER_GRADE4'),
  (gen_random_uuid(), 'ROLE_PUBLIC_OFFICER_GRADE5')
on conflict (name) do nothing;

-- Assign permissions to roles (simplified) - grant all to admin, subset to others
-- For demonstration we select ids dynamically using subqueries
insert into app_role_permissions (role_id, permission_id)
select r.id, p.id from app_roles r, app_permissions p where r.name = 'ROLE_ADMIN_SUPER'
on conflict do nothing;

insert into app_role_permissions (role_id, permission_id)
select r.id, p.id from app_roles r join app_permissions p on p.code in ('proj.read','data.view.agg','data.view.row','data.export.csv','kegov.publish') where r.name = 'ROLE_PUBLIC_OFFICER_GRADE4'
on conflict do nothing;

insert into app_role_permissions (role_id, permission_id)
select r.id, p.id from app_roles r join app_permissions p on p.code in ('proj.read','data.view.agg','data.view.row_masked','data.export.csv') where r.name = 'ROLE_PUBLIC_OFFICER_GRADE5'
on conflict do nothing;

-- Seed users
insert into app_users (id, username, password, grade) values
  (gen_random_uuid(), 'admin', 'admin', 0),
  (gen_random_uuid(), 'grade4user', 'password', 4),
  (gen_random_uuid(), 'grade5user', 'password', 5)
on conflict (username) do nothing;

-- Assign roles to users (valid forever)
insert into app_user_role_assignments (id, user_id, role_id, tenant_id, project_id, valid_from, valid_to, granted_by)
select gen_random_uuid(), u.id, r.id, gen_random_uuid(), null, now(), null, u.id
from app_users u
join app_roles r on (u.username = 'admin' and r.name = 'ROLE_ADMIN_SUPER')
   or (u.username = 'grade4user' and r.name = 'ROLE_PUBLIC_OFFICER_GRADE4')
   or (u.username = 'grade5user' and r.name = 'ROLE_PUBLIC_OFFICER_GRADE5')
where not exists (
    select 1 from app_user_role_assignments existing
    where existing.user_id = u.id and existing.role_id = r.id
);
