export type ImportType = 'students' | 'teachers'

export interface ParseResult {
  headers: string[]
  mappedHeaders: string[]
  unmappedHeaders: string[]
  rows: Record<string, unknown>[]
  totalRows: number
  preview: Record<string, unknown>[]
}

export interface ImportError {
  row: number
  message: string
  data?: Record<string, unknown>
}

export interface ImportProgress {
  status: 'idle' | 'parsing' | 'importing' | 'done' | 'error'
  total: number
  processed: number
  success: number
  errors: ImportError[]
  percentage: number
}

export interface ImportLog {
  id: string
  import_type: string
  file_name: string
  total_records: number
  success_records: number
  failed_records: number
  imported_at: string
  errors_json: ImportError[]
}
