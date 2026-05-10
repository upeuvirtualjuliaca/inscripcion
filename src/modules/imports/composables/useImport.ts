import { ref, reactive } from 'vue'
import * as XLSX from 'xlsx'
import { supabase } from '@/core/supabase'
import type { ImportType, ParseResult, ImportError, ImportProgress, ImportLog } from '../types'

const STUDENT_COLUMNS = new Set([
  'modo_contrato',
  'modalidad_estudio',
  'sede',
  'unidad_academica',
  'programa_estudio',
  'ciclo',
  'grupo',
  'id_persona',
  'codigo_estudiante',
  'estudiante',
  'documento',
  'sexo',
  'estado_alumno_contrato',
  'codigo_estado_alumno_contrato',
  'correo',
  'usuario',
  'correo_institucional',
  'celular',
  'pais',
  'foto',
  'religion',
  'fecha_nacimiento',
  'fecha_matricula',
])

const TEACHER_COLUMNS = new Set([
  'apellidos_nombres',
  'mayor_grado_academico',
  'tipo_documento',
  'numero_documento',
  'regimen_dedicacion',
  'condicion_laboral',
  'campus_adscripcion_docente',
  'facultad_adscripcion_docente',
  'campus_adscripcion_asignatura',
  'escuela_profesional',
  'asignaturas',
  'tipo_curso',
  'credito',
  'ct',
  'cp',
  'ht',
  'hp',
  'hnp',
  'total_horas',
  'ciclo',
  'ambiente',
  'cupo',
  'condicion_docente',
  'horas_lectivas',
  'factor',
  'horas_laborales',
  'horas_lectivas_semanales',
  'factor_semanal',
  'horas_laborales_semanales',
  'horas_laborales_semanales_carga',
  'tipo',
  'tipo_curso',
  'condicion_docente',
])

const DATE_FIELDS = new Set(['fecha_nacimiento', 'fecha_matricula'])

function normalizeKey(header: string): string {
  return header
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
}

function parseExcelDate(value: unknown): string | null {
  if (value === null || value === undefined || value === '') return null

  if (typeof value === 'number') {
    try {
      const parsed = XLSX.SSF.parse_date_code(value)
      if (parsed) {
        const y = parsed.y.toString().padStart(4, '0')
        const m = parsed.m.toString().padStart(2, '0')
        const d = parsed.d.toString().padStart(2, '0')
        return `${y}-${m}-${d}`
      }
    } catch {
      return null
    }
  }

  if (typeof value === 'string') {
    const trimmed = value.trim()
    // DD/MM/YYYY
    const ddmmyyyy = /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/
    const match = trimmed.match(ddmmyyyy)
    if (match) {
      const [, d, m, y] = match
      return `${y}-${m.padStart(2, '0')}-${d.padStart(2, '0')}`
    }
    // Already ISO-like YYYY-MM-DD
    if (/^\d{4}-\d{2}-\d{2}/.test(trimmed)) {
      return trimmed.slice(0, 10)
    }
  }

  return null
}

export function useImport() {
  const parseResult = ref<ParseResult | null>(null)
  const currentFileName = ref<string>('')
  const logs = ref<ImportLog[]>([])

  const progress = reactive<ImportProgress>({
    status: 'idle',
    total: 0,
    processed: 0,
    success: 0,
    errors: [],
    percentage: 0,
  })

  function resetImport() {
    parseResult.value = null
    currentFileName.value = ''
    progress.status = 'idle'
    progress.total = 0
    progress.processed = 0
    progress.success = 0
    progress.errors = []
    progress.percentage = 0
  }

  async function parseFile(file: File, type: ImportType): Promise<void> {
    currentFileName.value = file.name
    progress.status = 'parsing'

    const columnSet = type === 'students' ? STUDENT_COLUMNS : TEACHER_COLUMNS

    const buffer = await file.arrayBuffer()
    const workbook = XLSX.read(buffer, { type: 'array' })

    const sheetName = workbook.SheetNames[0]
    const worksheet = workbook.Sheets[sheetName]

    // Extract raw rows; first row is headers
    const rawRows = XLSX.utils.sheet_to_json<unknown[]>(worksheet, { header: 1, defval: '' })

    if (rawRows.length === 0) {
      progress.status = 'idle'
      parseResult.value = {
        headers: [],
        mappedHeaders: [],
        unmappedHeaders: [],
        rows: [],
        totalRows: 0,
        preview: [],
      }
      return
    }

    const rawHeaders = (rawRows[0] as unknown[]).map((h) => String(h))
    const normalizedHeaders = rawHeaders.map(normalizeKey)

    const mappedHeaders: string[] = []
    const unmappedHeaders: string[] = []
    const headerIndexMap: Record<string, number> = {}

    normalizedHeaders.forEach((norm, idx) => {
      if (columnSet.has(norm)) {
        if (!mappedHeaders.includes(norm)) {
          mappedHeaders.push(norm)
          headerIndexMap[norm] = idx
        }
      } else {
        if (rawHeaders[idx] && !unmappedHeaders.includes(rawHeaders[idx])) {
          unmappedHeaders.push(rawHeaders[idx])
        }
      }
    })

    const dataRows = rawRows.slice(1)
    const rows: Record<string, unknown>[] = []

    for (const rawRow of dataRows) {
      const typedRow = rawRow as unknown[]
      const row: Record<string, unknown> = {}
      for (const col of mappedHeaders) {
        const idx = headerIndexMap[col]
        let val: unknown = typedRow[idx] ?? null
        if (val === '') val = null
        if (DATE_FIELDS.has(col)) {
          val = parseExcelDate(val)
        }
        row[col] = val
      }
      rows.push(row)
    }

    parseResult.value = {
      headers: rawHeaders,
      mappedHeaders,
      unmappedHeaders,
      rows,
      totalRows: rows.length,
      preview: rows.slice(0, 10),
    }

    progress.status = 'idle'
  }

  async function runImport(type: ImportType): Promise<void> {
    if (!parseResult.value) return

    const { rows, totalRows } = parseResult.value
    const table = type === 'students' ? 'students' : 'teachers'
    const conflictColumn = type === 'students' ? 'documento' : 'numero_documento'

    progress.status = 'importing'
    progress.total = totalRows
    progress.processed = 0
    progress.success = 0
    progress.errors = []
    progress.percentage = 0

    // Insert import log first
    const { data: logData, error: logError } = await supabase
      .from('import_logs')
      .insert({
        import_type: type,
        file_name: currentFileName.value,
        total_records: totalRows,
        success_records: 0,
        failed_records: 0,
        imported_at: new Date().toISOString(),
        errors_json: [],
      })
      .select('id')
      .single()

    if (logError || !logData) {
      progress.status = 'error'
      progress.errors.push({ row: 0, message: `Error al crear el registro de importacion: ${logError?.message ?? 'unknown'}` })
      return
    }

    const importLogId: string = logData.id
    const BATCH_SIZE = 100
    const collectedErrors: ImportError[] = []

    for (let i = 0; i < rows.length; i += BATCH_SIZE) {
      const batch = rows.slice(i, i + BATCH_SIZE)
      const batchWithLogId = batch.map((r) => ({ ...r, import_log_id: importLogId }))

      // Delete existing records with the same key before inserting (avoids duplicates
      // without requiring a unique constraint in the DB)
      const keys = batch.map((r) => r[conflictColumn]).filter(Boolean) as string[]
      if (keys.length > 0) {
        await supabase.from(table).delete().in(conflictColumn, keys)
      }

      const { error: batchError } = await supabase.from(table).insert(batchWithLogId)

      if (batchError) {
        batch.forEach((rowData, batchIdx) => {
          collectedErrors.push({
            row: i + batchIdx + 2,
            message: batchError.message,
            data: rowData,
          })
        })
      } else {
        progress.success += batch.length
      }

      progress.processed = Math.min(i + BATCH_SIZE, rows.length)
      progress.errors = [...collectedErrors]
      progress.percentage = Math.round((progress.processed / rows.length) * 100)
    }

    // Update import log with final counts
    await supabase
      .from('import_logs')
      .update({
        success_records: progress.success,
        failed_records: collectedErrors.length,
        errors_json: collectedErrors,
      })
      .eq('id', importLogId)

    progress.status = 'done'
    progress.percentage = 100
  }

  async function fetchLogs(): Promise<void> {
    const { data, error } = await supabase
      .from('import_logs')
      .select('*')
      .order('imported_at', { ascending: false })
      .limit(50)

    if (!error && data) {
      logs.value = data as ImportLog[]
    }
  }

  return {
    parseResult,
    progress,
    logs,
    parseFile,
    runImport,
    fetchLogs,
    resetImport,
  }
}
