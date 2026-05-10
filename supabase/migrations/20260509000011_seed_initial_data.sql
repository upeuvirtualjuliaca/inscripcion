-- ============================================================
-- MIGRATION 011: SEED INITIAL DATA
-- Minimal data to start the system.
-- All values are configurable from the admin panel.
-- ============================================================

-- -----------------------------------------------------------
-- Default form fields for participant registration
-- -----------------------------------------------------------
insert into form_fields (field_key, label, field_type, is_required, sort_order, applies_to) values
  ('dni',         'DNI / Documento',    'text',   true,  1, 'participant'),
  ('first_name',  'Nombres',            'text',   true,  2, 'participant'),
  ('last_name',   'Apellidos',          'text',   true,  3, 'participant'),
  ('email',       'Correo electrónico', 'email',  false, 4, 'participant'),
  ('phone',       'Celular',            'phone',  false, 5, 'participant'),
  ('institution', 'Institución',        'text',   false, 6, 'participant');

-- -----------------------------------------------------------
-- Note: specialties, workshops, and workshop_shifts should be
-- created from the admin panel using the UI, not seeded here.
-- This keeps the system truly data-driven.
-- -----------------------------------------------------------
