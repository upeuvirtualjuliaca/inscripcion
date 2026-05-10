-- ============================================================
-- MIGRATION 002: SYSTEM SETTINGS
-- Key-value store for all dynamic system configuration.
-- No hardcoded values — everything is managed from the admin panel.
-- ============================================================

create table system_settings (
  id          uuid        primary key default gen_random_uuid(),
  key         text        not null unique,
  value       text,
  value_type  text        not null default 'string'
                          check (value_type in ('string','boolean','integer','decimal','json','color','url','text')),
  label       text        not null,
  description text,
  group_name  text        not null default 'general',
  is_public   boolean     not null default false,   -- exposed to frontend without auth
  sort_order  int         not null default 0,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
  -- Note: settings are not soft-deleted; update value to disable.
);

create index system_settings_group_idx   on system_settings(group_name);
create index system_settings_public_idx  on system_settings(is_public) where is_public = true;

-- updated_at trigger
create trigger trg_system_settings_updated_at
  before update on system_settings
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- SEED: default configuration values
-- -----------------------------------------------------------
insert into system_settings (key, value, value_type, label, description, group_name, is_public, sort_order) values
  -- General
  ('system_name',               'Sistema de Inscripciones',  'string',  'Nombre del sistema',           'Nombre que aparece en la cabecera y correos',          'general',        true,  1),
  ('system_logo_url',           null,                        'url',     'URL del logo',                 'Ruta pública de la imagen del logo',                   'general',        true,  2),
  ('system_banner_url',         null,                        'url',     'URL del banner principal',     'Banner de la página de inscripción',                   'general',        true,  3),
  ('maintenance_mode',          'false',                     'boolean', 'Modo mantenimiento',           'Si true, solo admins pueden acceder',                  'general',        false, 4),
  ('maintenance_message',       'Sistema en mantenimiento. Volvemos pronto.', 'text', 'Mensaje de mantenimiento', 'Texto visible durante el mantenimiento', 'general', true, 5),

  -- Inscriptions
  ('registrations_enabled',     'true',                      'boolean', 'Inscripciones activas',        'Habilitar o deshabilitar todas las inscripciones',     'registrations',  true,  1),
  ('max_workshops_per_user',    '2',                         'integer', 'Máx. talleres por participante','Límite de talleres a los que puede inscribirse',       'registrations',  true,  2),
  ('registration_start_msg',    'Las inscripciones están abiertas. ¡Reserva tu lugar!', 'text', 'Mensaje inicio inscripciones', null, 'registrations', true, 3),
  ('registration_closed_msg',   'Las inscripciones han cerrado. Gracias por participar.', 'text', 'Mensaje cierre inscripciones', null, 'registrations', true, 4),
  ('registration_full_msg',     'Este taller está completo. Prueba con otro turno.',     'text', 'Mensaje taller completo',      null, 'registrations', true, 5),

  -- Contact
  ('whatsapp_number',           null,                        'string',  'Número de WhatsApp',           'Formato internacional: 51999999999',                   'contact',        true,  1),
  ('whatsapp_button_text',      'Consultar por WhatsApp',    'string',  'Texto botón flotante WhatsApp', null,                                                  'contact',        true,  2),
  ('support_email',             null,                        'string',  'Correo de soporte',            null,                                                   'contact',        true,  3),

  -- Branding
  ('primary_color',             '#1a56db',                   'color',   'Color primario',               'Color principal de la interfaz',                       'branding',       true,  1),
  ('secondary_color',           '#7e3af2',                   'color',   'Color secundario',             null,                                                   'branding',       true,  2),
  ('accent_color',              '#e74694',                   'color',   'Color de acento',              null,                                                   'branding',       true,  3),

  -- Event
  ('event_name',                null,                        'string',  'Nombre del evento',            'Nombre oficial del evento académico',                  'event',          true,  1),
  ('event_date',                null,                        'string',  'Fecha del evento',             'Fecha de realización del evento',                      'event',          true,  2),
  ('event_location',            null,                        'string',  'Lugar del evento',             'Dirección o nombre del recinto',                       'event',          true,  3);

-- -----------------------------------------------------------
-- get_setting (placed here — depends on system_settings table)
-- Convenience accessor for system_settings values.
-- Usage: select get_setting('max_workshops_per_user', '2');
-- -----------------------------------------------------------
create or replace function get_setting(p_key text, p_default text default null)
returns text
language sql
stable as $$
  select coalesce(
    (select value from system_settings where key = p_key),
    p_default
  );
$$;
