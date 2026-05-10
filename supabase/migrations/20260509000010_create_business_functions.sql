-- ============================================================
-- MIGRATION 010: BUSINESS FUNCTIONS
-- Stored procedures for critical operations.
-- All concurrency-sensitive work lives here in PostgreSQL.
-- ============================================================

-- -----------------------------------------------------------
-- register_participant
-- Atomically registers a participant to a workshop shift.
-- Enforces:
--   · shift must be open and have available capacity
--   · participant has not already registered to this workshop
--   · participant has not exceeded max_workshops_per_user
-- Uses SELECT FOR UPDATE on the shift to prevent race conditions.
-- -----------------------------------------------------------
create or replace function register_participant(
  p_participant_id  uuid,
  p_workshop_id     uuid,
  p_workshop_shift_id uuid
)
returns registrations
language plpgsql
security definer as $$
declare
  v_shift         workshop_shifts;
  v_workshop      workshops;
  v_active_count  int;
  v_max_workshops int;
  v_registration  registrations;
begin
  -- Read max limit from dynamic settings (default 2)
  v_max_workshops := coalesce(get_setting('max_workshops_per_user', '2')::int, 2);

  -- Lock the shift row to prevent concurrent over-booking
  select * into v_shift
  from workshop_shifts
  where id = p_workshop_shift_id
    and deleted_at is null
  for update;

  if not found then
    raise exception 'SHIFT_NOT_FOUND: Turno no encontrado o inactivo.';
  end if;

  -- Validate shift state
  if v_shift.status != 'open' then
    raise exception 'SHIFT_UNAVAILABLE: El turno "%" no está disponible (estado: %).',
      v_shift.shift_name, v_shift.status;
  end if;

  -- Validate shift belongs to the given workshop
  if v_shift.workshop_id != p_workshop_id then
    raise exception 'SHIFT_MISMATCH: El turno no pertenece al taller indicado.';
  end if;

  -- Validate workshop is open for registration
  select * into v_workshop from workshops where id = p_workshop_id and deleted_at is null;
  if not found then
    raise exception 'WORKSHOP_NOT_FOUND: Taller no encontrado.';
  end if;
  if v_workshop.status in ('closed','hidden') then
    raise exception 'WORKSHOP_CLOSED: Las inscripciones para este taller están cerradas.';
  end if;

  -- Check capacity
  if v_shift.registered_count >= v_shift.capacity then
    raise exception 'SHIFT_FULL: El turno "%" está completo (% / %).',
      v_shift.shift_name, v_shift.registered_count, v_shift.capacity;
  end if;

  -- Check for duplicate registration (same participant + workshop)
  if exists (
    select 1 from registrations
    where participant_id     = p_participant_id
      and workshop_id        = p_workshop_id
      and status            != 'cancelled'
      and deleted_at         is null
  ) then
    raise exception 'ALREADY_REGISTERED: El participante ya está inscrito en este taller.';
  end if;

  -- Check global registrations limit
  select count(*) into v_active_count
  from registrations
  where participant_id = p_participant_id
    and status         = 'confirmed'
    and deleted_at     is null;

  if v_active_count >= v_max_workshops then
    raise exception 'MAX_LIMIT_REACHED: El participante ya alcanzó el límite de % taller(es).',
      v_max_workshops;
  end if;

  -- Insert registration (triggers will update registered_count)
  insert into registrations (participant_id, workshop_id, workshop_shift_id)
  values (p_participant_id, p_workshop_id, p_workshop_shift_id)
  returning * into v_registration;

  return v_registration;
end;
$$;

-- -----------------------------------------------------------
-- cancel_registration
-- Soft-cancels a registration and frees the slot.
-- -----------------------------------------------------------
create or replace function cancel_registration(
  p_registration_id uuid,
  p_reason          text default null
)
returns registrations
language plpgsql
security definer as $$
declare
  v_registration registrations;
begin
  select * into v_registration
  from registrations
  where id         = p_registration_id
    and deleted_at is null
  for update;

  if not found then
    raise exception 'REGISTRATION_NOT_FOUND: Inscripción no encontrada.';
  end if;

  if v_registration.status = 'cancelled' then
    raise exception 'ALREADY_CANCELLED: La inscripción ya fue cancelada.';
  end if;

  update registrations
  set status  = 'cancelled',
      notes   = coalesce(p_reason, notes)
  where id = p_registration_id
  returning * into v_registration;

  return v_registration;
end;
$$;

-- -----------------------------------------------------------
-- check_in_participant
-- Records physical check-in at the event.
-- Accepts registration_id or confirmation_code.
-- -----------------------------------------------------------
create or replace function check_in_participant(
  p_confirmation_code text
)
returns registrations
language plpgsql
security definer as $$
declare
  v_registration registrations;
begin
  select * into v_registration
  from registrations
  where confirmation_code = p_confirmation_code
    and deleted_at        is null
  for update;

  if not found then
    raise exception 'INVALID_CODE: Código de confirmación no válido.';
  end if;

  if v_registration.status != 'confirmed' then
    raise exception 'NOT_CONFIRMED: La inscripción no está confirmada (estado: %).',
      v_registration.status;
  end if;

  if v_registration.checked_in_at is not null then
    raise exception 'ALREADY_CHECKED_IN: El participante ya registró asistencia a las %.',
      v_registration.checked_in_at;
  end if;

  update registrations
  set checked_in_at = now()
  where id = v_registration.id
  returning * into v_registration;

  return v_registration;
end;
$$;

-- -----------------------------------------------------------
-- get_workshop_availability
-- Returns real-time availability for all shifts of a workshop.
-- -----------------------------------------------------------
create or replace function get_workshop_availability(p_workshop_id uuid)
returns table (
  shift_id         uuid,
  shift_name       text,
  shift_number     int,
  start_time       time,
  end_time         time,
  capacity         int,
  registered_count int,
  available_spots  int,
  status           text
)
language sql
stable as $$
  select
    id,
    shift_name,
    shift_number,
    start_time,
    end_time,
    capacity,
    registered_count,
    capacity - registered_count as available_spots,
    status
  from workshop_shifts
  where workshop_id = p_workshop_id
    and deleted_at  is null
  order by shift_number;
$$;

-- -----------------------------------------------------------
-- get_participant_registrations
-- Returns a participant's full registration summary.
-- -----------------------------------------------------------
create or replace function get_participant_registrations(p_participant_id uuid)
returns table (
  registration_id     uuid,
  registration_number bigint,
  confirmation_code   text,
  workshop_name       text,
  specialty_name      text,
  shift_name          text,
  start_time          time,
  end_time            time,
  location            text,
  workshop_date       date,
  status              text,
  checked_in_at       timestamptz
)
language sql
stable as $$
  select
    r.id,
    r.registration_number,
    r.confirmation_code,
    w.name,
    s.name,
    ws.shift_name,
    ws.start_time,
    ws.end_time,
    w.location,
    w.workshop_date,
    r.status,
    r.checked_in_at
  from registrations r
  join workshops       w  on w.id  = r.workshop_id
  join specialties     s  on s.id  = w.specialty_id
  join workshop_shifts ws on ws.id = r.workshop_shift_id
  where r.participant_id = p_participant_id
    and r.deleted_at     is null
  order by r.registration_date;
$$;
