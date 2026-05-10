-- ============================================================
-- MIGRATION: Enforce shift_number diversity rule
-- A participant may not register twice for the same shift_number.
-- If they registered for shift_number=1 (Primer Turno), their next
-- registration must use shift_number=2 (Segundo Turno), and vice versa.
-- ============================================================

create or replace function register_participant(
  p_participant_id    uuid,
  p_workshop_id       uuid,
  p_workshop_shift_id uuid
)
returns registrations
language plpgsql
security definer as $$
declare
  v_shift              workshop_shifts;
  v_workshop           workshops;
  v_active_count       int;
  v_max_workshops      int;
  v_registration       registrations;
  v_requested_shift_no int;
  v_conflict_count     int;
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

  -- ── NEW RULE: shift_number diversity ──────────────────────
  -- Each participant must use a different shift_number per registration.
  -- E.g. first registration on shift_number=1, next must be shift_number=2.
  v_requested_shift_no := v_shift.shift_number;

  select count(*) into v_conflict_count
  from registrations r
  join workshop_shifts ws on ws.id = r.workshop_shift_id
  where r.participant_id = p_participant_id
    and r.status        != 'cancelled'
    and r.deleted_at     is null
    and ws.shift_number  = v_requested_shift_no;

  if v_conflict_count > 0 then
    raise exception 'SHIFT_NUMBER_CONFLICT: Ya tienes una inscripción en el Turno %. Debes elegir un turno diferente para este taller.',
      v_requested_shift_no;
  end if;
  -- ──────────────────────────────────────────────────────────

  -- Insert registration (triggers will update registered_count)
  insert into registrations (participant_id, workshop_id, workshop_shift_id)
  values (p_participant_id, p_workshop_id, p_workshop_shift_id)
  returning * into v_registration;

  return v_registration;
end;
$$;
