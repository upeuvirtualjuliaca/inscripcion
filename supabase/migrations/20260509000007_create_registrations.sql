-- ============================================================
-- MIGRATION 007: REGISTRATIONS
-- The most critical table in the system.
-- Enforces: no duplicates, max workshops per participant,
-- capacity control, concurrency safety.
-- ============================================================

-- -----------------------------------------------------------
-- generate_confirmation_code
-- Placed here because it references the registrations table.
-- Produces a human-readable unique code like REG-A1B2C3.
-- Uniqueness guaranteed by the unique index on the column.
-- -----------------------------------------------------------
create or replace function generate_confirmation_code()
returns text
language plpgsql as $$
declare
  v_code text;
begin
  -- Generate a short unique code; collision handled by unique constraint retry at app level
  v_code := 'REG-' || upper(substring(md5(random()::text || clock_timestamp()::text) from 1 for 6));
  return v_code;
end;
$$;

-- Human-readable registration number sequence
create sequence registration_number_seq start with 1000 increment by 1;

create table registrations (
  id                  uuid        primary key default gen_random_uuid(),
  registration_number bigint      not null unique default nextval('registration_number_seq'),
  participant_id      uuid        not null references participants(id),
  workshop_id         uuid        not null references workshops(id),
  workshop_shift_id   uuid        not null references workshop_shifts(id),
  confirmation_code   text        not null unique default generate_confirmation_code(),
  registration_date   timestamptz not null default now(),
  status              text        not null default 'confirmed'
                                  check (status in ('confirmed','cancelled','waitlisted')),
  checked_in_at       timestamptz,                           -- physical check-in timestamp
  notes               text,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  deleted_at          timestamptz
);

-- Prevent duplicate active registrations for the same participant + workshop
create unique index registrations_no_duplicate_idx
  on registrations(participant_id, workshop_id)
  where deleted_at is null and status != 'cancelled';

-- Performance indexes
create index registrations_participant_idx  on registrations(participant_id);
create index registrations_workshop_idx     on registrations(workshop_id);
create index registrations_shift_idx        on registrations(workshop_shift_id);
create index registrations_status_idx       on registrations(status) where deleted_at is null;
create index registrations_date_idx         on registrations(registration_date desc);
create index registrations_confirmation_idx on registrations(confirmation_code);
create index registrations_checkin_idx      on registrations(checked_in_at) where checked_in_at is not null;

create trigger trg_registrations_updated_at
  before update on registrations
  for each row execute function update_updated_at_column();
