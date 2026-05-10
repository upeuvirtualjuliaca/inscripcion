-- ============================================================
-- MIGRATION 004: SPECIALTIES → WORKSHOPS → WORKSHOP_SHIFTS
-- Core academic hierarchy of the system.
-- ============================================================

-- -----------------------------------------------------------
-- SPECIALTIES
-- -----------------------------------------------------------
create table specialties (
  id          uuid        primary key default gen_random_uuid(),
  name        text        not null,
  description text,
  color       text,                                       -- hex color for UI badges
  icon        text,                                       -- icon name/class
  sort_order  int         not null default 0,
  status      text        not null default 'active'
                          check (status in ('active','inactive')),
  is_visible  boolean     not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create index specialties_status_idx     on specialties(status)     where deleted_at is null;
create index specialties_visible_idx    on specialties(is_visible) where deleted_at is null;
create index specialties_sort_idx       on specialties(sort_order) where deleted_at is null;

create trigger trg_specialties_updated_at
  before update on specialties
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- WORKSHOPS
-- -----------------------------------------------------------
create table workshops (
  id            uuid        primary key default gen_random_uuid(),
  specialty_id  uuid        not null references specialties(id),
  name          text        not null,
  speaker       text,
  description   text,
  location      text,
  image_url     text,
  workshop_date date,
  notes         text,                                     -- internal notes for admins
  status        text        not null default 'available'
                            check (status in ('available','full','closed','hidden')),
  is_visible    boolean     not null default true,
  sort_order    int         not null default 0,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create index workshops_specialty_idx  on workshops(specialty_id) where deleted_at is null;
create index workshops_status_idx     on workshops(status)       where deleted_at is null;
create index workshops_visible_idx    on workshops(is_visible)   where deleted_at is null;
create index workshops_date_idx       on workshops(workshop_date);

create trigger trg_workshops_updated_at
  before update on workshops
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- WORKSHOP_SHIFTS
-- Each workshop has up to 2 independent shifts with their
-- own capacity. registered_count is denormalized for
-- real-time aforo display — maintained by triggers.
-- -----------------------------------------------------------
create table workshop_shifts (
  id               uuid        primary key default gen_random_uuid(),
  workshop_id      uuid        not null references workshops(id),
  shift_name       text        not null,                  -- '1° Turno', '2° Turno'
  shift_number     int         not null check (shift_number in (1, 2)),
  start_time       time        not null,
  end_time         time        not null,
  capacity         int         not null default 30 check (capacity > 0),
  registered_count int         not null default 0
                               check (registered_count >= 0),
  status           text        not null default 'open'
                               check (status in ('open','full','closed')),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  deleted_at       timestamptz,

  -- Each workshop can have at most one shift 1 and one shift 2
  unique (workshop_id, shift_number),

  -- End time must be after start time
  constraint chk_shift_times check (end_time > start_time),

  -- registered_count cannot exceed capacity
  constraint chk_shift_capacity check (registered_count <= capacity)
);

create index workshop_shifts_workshop_idx on workshop_shifts(workshop_id) where deleted_at is null;
create index workshop_shifts_status_idx   on workshop_shifts(status)      where deleted_at is null;

create trigger trg_workshop_shifts_updated_at
  before update on workshop_shifts
  for each row execute function update_updated_at_column();
