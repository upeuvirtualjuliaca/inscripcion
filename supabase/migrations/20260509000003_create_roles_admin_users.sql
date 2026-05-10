-- ============================================================
-- MIGRATION 003: ROLES & ADMIN USERS
-- RBAC administrativo. Roles configurables desde el panel.
-- ============================================================

-- -----------------------------------------------------------
-- ROLES
-- -----------------------------------------------------------
create table roles (
  id           uuid        primary key default gen_random_uuid(),
  name         text        not null unique,               -- slug: super_admin, admin, operador
  display_name text        not null,
  description  text,
  permissions  jsonb       not null default '{}',         -- {"specialties":["read","write"], ...}
  is_system    boolean     not null default false,        -- true = no se puede eliminar
  sort_order   int         not null default 0,
  status       text        not null default 'active'
                           check (status in ('active','inactive')),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

create index roles_status_idx     on roles(status) where deleted_at is null;
create index roles_is_system_idx  on roles(is_system);

create trigger trg_roles_updated_at
  before update on roles
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- ADMIN USERS
-- -----------------------------------------------------------
create table admin_users (
  id            uuid        primary key default gen_random_uuid(),
  role_id       uuid        not null references roles(id),
  auth_user_id  uuid        unique references auth.users(id) on delete set null,
  full_name     text        not null,
  email         text        not null,
  avatar_url    text,
  status        text        not null default 'active'
                            check (status in ('active','inactive','suspended')),
  last_login_at timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

-- Unique email only among active (non-deleted) users
create unique index admin_users_email_active_idx on admin_users(email) where deleted_at is null;
create index admin_users_role_idx    on admin_users(role_id);
create index admin_users_status_idx  on admin_users(status) where deleted_at is null;
create index admin_users_deleted_idx on admin_users(deleted_at) where deleted_at is not null;

create trigger trg_admin_users_updated_at
  before update on admin_users
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- SEED: default roles
-- -----------------------------------------------------------
insert into roles (name, display_name, description, is_system, sort_order, permissions) values
  ('super_admin', 'Super Administrador', 'Acceso total al sistema. No puede eliminarse.',
    true, 1,
    '{"all": ["read","write","delete","import","export"]}'
  ),
  ('admin', 'Administrador', 'Gestión completa de talleres, inscripciones y participantes.',
    true, 2,
    '{"specialties":["read","write"],"workshops":["read","write","delete"],"registrations":["read","write","delete"],"participants":["read","write"],"reports":["read","export"]}'
  ),
  ('operador', 'Operador', 'Puede gestionar inscripciones y consultar información.',
    false, 3,
    '{"workshops":["read"],"registrations":["read","write"],"participants":["read","write"]}'
  ),
  ('visualizador', 'Visualizador', 'Solo lectura. Ideal para pantallas de aforo en tiempo real.',
    false, 4,
    '{"workshops":["read"],"registrations":["read"],"participants":["read"]}'
  );
