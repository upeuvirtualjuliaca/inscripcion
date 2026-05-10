-- ============================================================
-- MIGRATION 008: AUDIT LOGS
-- Immutable global audit trail. No updates or deletes allowed.
-- ============================================================

create table audit_logs (
  id                uuid        primary key default gen_random_uuid(),
  table_name        text        not null,
  record_id         uuid,
  action            text        not null
                                check (action in (
                                  'INSERT','UPDATE','DELETE',
                                  'IMPORT','LOGIN','LOGOUT','ADMIN','CHECKIN'
                                )),
  old_values        jsonb,
  new_values        jsonb,
  changed_fields    text[],                               -- list of fields that changed
  performed_by      uuid,                                 -- admin_users.id or auth.users.id
  performed_by_email text,
  ip_address        inet,
  user_agent        text,
  metadata          jsonb       not null default '{}',    -- extra context (import_id, etc.)
  created_at        timestamptz not null default now()
  -- No updated_at — audit logs are immutable
);

create index audit_logs_table_idx      on audit_logs(table_name);
create index audit_logs_record_idx     on audit_logs(record_id) where record_id is not null;
create index audit_logs_action_idx     on audit_logs(action);
create index audit_logs_by_idx         on audit_logs(performed_by) where performed_by is not null;
create index audit_logs_created_idx    on audit_logs(created_at desc);

-- Prevent any modification of audit records
create or replace rule audit_logs_no_update as
  on update to audit_logs do instead nothing;

create or replace rule audit_logs_no_delete as
  on delete to audit_logs do instead nothing;
