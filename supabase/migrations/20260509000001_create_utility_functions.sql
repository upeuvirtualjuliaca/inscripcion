-- ============================================================
-- MIGRATION 001: UTILITY FUNCTIONS
-- Shared helper functions used across the entire schema.
-- ============================================================

-- -----------------------------------------------------------
-- update_updated_at_column
-- Automatically refreshes updated_at on every UPDATE.
-- Applied as a BEFORE UPDATE trigger on all auditable tables.
-- -----------------------------------------------------------
create or replace function update_updated_at_column()
returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Note: generate_confirmation_code() is created in migration 007 (after registrations table).
-- Note: get_setting() is created in migration 002 (after system_settings table).
