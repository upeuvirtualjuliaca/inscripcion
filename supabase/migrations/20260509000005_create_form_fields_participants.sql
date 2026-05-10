-- ============================================================
-- MIGRATION 005: FORM FIELDS & PARTICIPANTS
-- Dynamic form system + participant registry.
-- ============================================================

-- -----------------------------------------------------------
-- FORM_FIELDS
-- Admin-configurable fields for the registration form.
-- extra_data in participants stores values for dynamic fields.
-- -----------------------------------------------------------
create table form_fields (
  id               uuid        primary key default gen_random_uuid(),
  field_key        text        not null unique,           -- used as key in extra_data jsonb
  label            text        not null,
  field_type       text        not null
                               check (field_type in (
                                 'text','email','phone','select',
                                 'checkbox','date','number','textarea'
                               )),
  placeholder      text,
  is_required      boolean     not null default false,
  options          jsonb,                                 -- [{"value":"A","label":"Option A"}]
  validation_rules jsonb,                                 -- {"min":1,"max":100,"pattern":"..."}
  sort_order       int         not null default 0,
  is_active        boolean     not null default true,
  applies_to       text        not null default 'participant'
                               check (applies_to in ('participant','registration')),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  deleted_at       timestamptz
);

create index form_fields_active_idx     on form_fields(is_active)   where deleted_at is null;
create index form_fields_sort_idx       on form_fields(sort_order)  where deleted_at is null;
create index form_fields_applies_idx    on form_fields(applies_to)  where deleted_at is null;

create trigger trg_form_fields_updated_at
  before update on form_fields
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- PARTICIPANTS
-- A participant can exist before registering to any workshop.
-- full_name is a generated column for convenience.
-- extra_data stores any dynamic form field values.
-- -----------------------------------------------------------
create table participants (
  id           uuid        primary key default gen_random_uuid(),
  dni          text        not null,
  first_name   text        not null,
  last_name    text        not null,
  full_name    text        generated always as (last_name || ', ' || first_name) stored,
  email        text,
  phone        text,
  institution  text,
  extra_data   jsonb       not null default '{}',         -- dynamic form field values
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

-- Unique DNI only among non-deleted participants
create unique index participants_dni_active_idx   on participants(dni) where deleted_at is null;
create index participants_email_idx               on participants(email) where deleted_at is null;
create index participants_institution_idx         on participants(institution);
create index participants_extra_data_idx          on participants using gin(extra_data);

create trigger trg_participants_updated_at
  before update on participants
  for each row execute function update_updated_at_column();
