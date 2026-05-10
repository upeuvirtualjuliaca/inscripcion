-- ============================================================
-- MIGRATION 009: BUSINESS TRIGGERS
-- 1. Audit trigger — auto-logs INSERT/UPDATE/DELETE on key tables
-- 2. Shift capacity trigger — maintains registered_count + status
-- 3. Workshop status trigger — marks workshop 'full' when all shifts full
-- ============================================================

-- -----------------------------------------------------------
-- 1. AUDIT TRIGGER FUNCTION
-- Automatically records every data change in audit_logs.
-- -----------------------------------------------------------
create or replace function fn_audit_trigger()
returns trigger
language plpgsql
security definer as $$
declare
  v_old     jsonb;
  v_new     jsonb;
  v_changed text[];
  v_key     text;
begin
  -- Build old/new jsonb values
  if TG_OP = 'DELETE' then
    v_old := to_jsonb(OLD);
    v_new := null;
  elsif TG_OP = 'INSERT' then
    v_old := null;
    v_new := to_jsonb(NEW);
  else -- UPDATE
    v_old := to_jsonb(OLD);
    v_new := to_jsonb(NEW);
    -- Detect which fields changed
    v_changed := array(
      select key
      from jsonb_each(v_old)
      where v_old->key is distinct from v_new->key
    );
  end if;

  insert into audit_logs (
    table_name,
    record_id,
    action,
    old_values,
    new_values,
    changed_fields
  ) values (
    TG_TABLE_NAME,
    case when TG_OP = 'DELETE' then (v_old->>'id')::uuid
         else (v_new->>'id')::uuid end,
    TG_OP,
    v_old,
    v_new,
    v_changed
  );

  if TG_OP = 'DELETE' then
    return OLD;
  else
    return NEW;
  end if;
end;
$$;

-- Apply audit trigger to all critical tables
create trigger trg_audit_specialties
  after insert or update or delete on specialties
  for each row execute function fn_audit_trigger();

create trigger trg_audit_workshops
  after insert or update or delete on workshops
  for each row execute function fn_audit_trigger();

create trigger trg_audit_workshop_shifts
  after insert or update or delete on workshop_shifts
  for each row execute function fn_audit_trigger();

create trigger trg_audit_participants
  after insert or update or delete on participants
  for each row execute function fn_audit_trigger();

create trigger trg_audit_registrations
  after insert or update or delete on registrations
  for each row execute function fn_audit_trigger();

create trigger trg_audit_admin_users
  after insert or update or delete on admin_users
  for each row execute function fn_audit_trigger();

create trigger trg_audit_roles
  after insert or update or delete on roles
  for each row execute function fn_audit_trigger();

create trigger trg_audit_system_settings
  after insert or update on system_settings
  for each row execute function fn_audit_trigger();

-- -----------------------------------------------------------
-- 2. SHIFT CAPACITY TRIGGER
-- Keeps workshop_shifts.registered_count accurate and
-- flips status to 'full' automatically.
-- Handles: INSERT (confirmed) / UPDATE status / soft-delete.
-- -----------------------------------------------------------
create or replace function fn_update_shift_count()
returns trigger
language plpgsql
security definer as $$
declare
  v_delta int := 0;
begin
  -- Determine the change in active registrations for the affected shift(s)

  if TG_OP = 'INSERT' then
    if NEW.status = 'confirmed' and NEW.deleted_at is null then
      v_delta := 1;
    end if;
    perform fn_apply_shift_delta(NEW.workshop_shift_id, v_delta);

  elsif TG_OP = 'UPDATE' then
    -- Case: shift changed
    if OLD.workshop_shift_id is distinct from NEW.workshop_shift_id then
      -- Remove from old shift
      if OLD.status = 'confirmed' and OLD.deleted_at is null then
        perform fn_apply_shift_delta(OLD.workshop_shift_id, -1);
      end if;
      -- Add to new shift
      if NEW.status = 'confirmed' and NEW.deleted_at is null then
        perform fn_apply_shift_delta(NEW.workshop_shift_id, 1);
      end if;
    else
      -- Same shift — check if active count changed
      declare
        v_was_active boolean := (OLD.status = 'confirmed' and OLD.deleted_at is null);
        v_is_active  boolean := (NEW.status = 'confirmed' and NEW.deleted_at is null);
      begin
        if v_was_active and not v_is_active then
          v_delta := -1;
        elsif not v_was_active and v_is_active then
          v_delta := 1;
        end if;
        if v_delta != 0 then
          perform fn_apply_shift_delta(NEW.workshop_shift_id, v_delta);
        end if;
      end;
    end if;

  elsif TG_OP = 'DELETE' then
    if OLD.status = 'confirmed' and OLD.deleted_at is null then
      perform fn_apply_shift_delta(OLD.workshop_shift_id, -1);
    end if;
  end if;

  return NEW;
end;
$$;

-- Helper: applies the delta and auto-manages shift + workshop status
create or replace function fn_apply_shift_delta(p_shift_id uuid, p_delta int)
returns void
language plpgsql
security definer as $$
declare
  v_shift workshop_shifts;
begin
  update workshop_shifts
  set registered_count = greatest(0, registered_count + p_delta),
      status = case
        when registered_count + p_delta >= capacity then 'full'
        when status = 'full' and registered_count + p_delta < capacity then 'open'
        else status
      end
  where id = p_shift_id
  returning * into v_shift;

  -- Cascade: update parent workshop status
  perform fn_sync_workshop_status(v_shift.workshop_id);
end;
$$;

-- Helper: marks workshop 'full' only when ALL its active shifts are full
create or replace function fn_sync_workshop_status(p_workshop_id uuid)
returns void
language plpgsql
security definer as $$
declare
  v_total_shifts int;
  v_full_shifts  int;
begin
  select
    count(*) filter (where deleted_at is null),
    count(*) filter (where deleted_at is null and status = 'full')
  into v_total_shifts, v_full_shifts
  from workshop_shifts
  where workshop_id = p_workshop_id;

  update workshops
  set status = case
    when v_total_shifts > 0 and v_total_shifts = v_full_shifts then 'full'
    when status = 'full' then 'available'
    else status
  end
  where id = p_workshop_id
    and status not in ('closed','hidden');  -- don't auto-reopen manually closed/hidden
end;
$$;

create trigger trg_registrations_shift_count
  after insert or update or delete on registrations
  for each row execute function fn_update_shift_count();
