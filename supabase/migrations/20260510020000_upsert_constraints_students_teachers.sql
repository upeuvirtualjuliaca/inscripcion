-- ============================================================
-- MIGRATION: Add unique constraints on students(documento)
-- and teachers(numero_documento) to support upsert on import.
-- Deduplicates existing rows first (keeps the most recently updated).
-- ============================================================

-- ── STUDENTS ─────────────────────────────────────────────────
-- 1. Remove duplicate rows keeping the one with the latest updated_at
DELETE FROM students
WHERE id NOT IN (
  SELECT DISTINCT ON (documento) id
  FROM students
  ORDER BY documento, updated_at DESC, ctid DESC
);

-- 2. Drop the old partial index (replaced by the unique constraint below)
DROP INDEX IF EXISTS students_documento_idx;

-- 3. Add unique constraint (also serves as a unique index)
ALTER TABLE students
  ADD CONSTRAINT students_documento_unique UNIQUE (documento);

-- ── TEACHERS ─────────────────────────────────────────────────
-- 1. Remove duplicate rows keeping the one with the latest updated_at
DELETE FROM teachers
WHERE id NOT IN (
  SELECT DISTINCT ON (numero_documento) id
  FROM teachers
  ORDER BY numero_documento, updated_at DESC, ctid DESC
);

-- 2. Drop the old partial index
DROP INDEX IF EXISTS teachers_numero_documento_idx;

-- 3. Add unique constraint
ALTER TABLE teachers
  ADD CONSTRAINT teachers_numero_documento_unique UNIQUE (numero_documento);
