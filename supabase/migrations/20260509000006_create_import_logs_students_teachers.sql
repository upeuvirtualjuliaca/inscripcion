-- ============================================================
-- MIGRATION 006: IMPORT LOGS + STUDENTS + TEACHERS
-- Excel import tracking and imported entity tables.
-- ============================================================

-- -----------------------------------------------------------
-- IMPORT_LOGS
-- Tracks every Excel import with success/error details.
-- -----------------------------------------------------------
create table import_logs (
  id              uuid        primary key default gen_random_uuid(),
  import_type     text        not null check (import_type in ('students','teachers')),
  file_name       text        not null,
  total_records   int         not null default 0 check (total_records >= 0),
  success_records int         not null default 0 check (success_records >= 0),
  failed_records  int         not null default 0 check (failed_records >= 0),
  imported_by     uuid        references admin_users(id) on delete set null,
  imported_at     timestamptz not null default now(),
  errors_json     jsonb       not null default '[]',      -- [{row:2, error:"..."}]
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),

  constraint chk_import_counts
    check (success_records + failed_records <= total_records)
);

create index import_logs_type_idx on import_logs(import_type);
create index import_logs_by_idx   on import_logs(imported_by);
create index import_logs_at_idx   on import_logs(imported_at desc);

create trigger trg_import_logs_updated_at
  before update on import_logs
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- STUDENTS
-- Imported from Excel. documento is the natural key.
-- Future relation to participants via dni/documento matching.
-- -----------------------------------------------------------
create table students (
  id                             uuid        primary key default gen_random_uuid(),
  import_log_id                  uuid        references import_logs(id) on delete set null,

  -- Academic fields (as received from the source Excel)
  modo_contrato                  text,
  modalidad_estudio              text,
  sede                           text,
  unidad_academica               text,
  programa_estudio               text,
  ciclo                          text,
  grupo                          text,
  id_persona                     text,
  codigo_estudiante              text,
  estudiante                     text,
  documento                      text        not null,
  sexo                           text,
  estado_alumno_contrato         text,
  codigo_estado_alumno_contrato  text,
  correo                         text,
  usuario                        text,
  correo_institucional           text,
  celular                        text,
  pais                           text,
  foto                           text,
  religion                       text,
  fecha_nacimiento               date,
  fecha_matricula                date,

  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create index students_documento_idx           on students(documento)           where deleted_at is null;
create index students_codigo_estudiante_idx   on students(codigo_estudiante)   where deleted_at is null;
create index students_correo_inst_idx         on students(correo_institucional) where deleted_at is null;
create index students_import_log_idx          on students(import_log_id);
-- Full-text search on student name
create index students_nombre_idx              on students using gin(to_tsvector('spanish', coalesce(estudiante,'')));

create trigger trg_students_updated_at
  before update on students
  for each row execute function update_updated_at_column();

-- -----------------------------------------------------------
-- TEACHERS
-- Imported from Excel. numero_documento is the natural key.
-- -----------------------------------------------------------
create table teachers (
  id                               uuid        primary key default gen_random_uuid(),
  import_log_id                    uuid        references import_logs(id) on delete set null,

  -- Teacher fields (as received from the source Excel)
  apellidos_nombres                text        not null,
  mayor_grado_academico            text,
  tipo_documento                   text,
  numero_documento                 text        not null,
  regimen_dedicacion               text,
  condicion_laboral                text,
  campus_adscripcion_docente       text,
  facultad_adscripcion_docente     text,
  campus_adscripcion_asignatura    text,
  escuela_profesional              text,
  asignaturas                      text,
  tipo_curso                       text,
  credito                          numeric(8,2),
  ct                               numeric(8,2),
  cp                               numeric(8,2),
  ht                               numeric(8,2),
  hp                               numeric(8,2),
  hnp                              numeric(8,2),
  total_horas                      numeric(8,2),
  ciclo                            text,
  ambiente                         text,
  cupo                             int,
  condicion_docente                text,
  horas_lectivas                   numeric(8,2),
  factor                           numeric(8,4),
  horas_laborales                  numeric(8,2),
  horas_lectivas_semanales         numeric(8,2),
  factor_semanal                   numeric(8,4),
  horas_laborales_semanales        numeric(8,2),
  horas_laborales_semanales_carga  numeric(8,2),
  tipo                             text,

  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create index teachers_numero_documento_idx  on teachers(numero_documento)  where deleted_at is null;
create index teachers_import_log_idx        on teachers(import_log_id);
-- Full-text search on teacher name
create index teachers_nombre_idx            on teachers using gin(to_tsvector('spanish', coalesce(apellidos_nombres,'')));

create trigger trg_teachers_updated_at
  before update on teachers
  for each row execute function update_updated_at_column();
