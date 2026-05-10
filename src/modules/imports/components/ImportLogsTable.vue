<script setup lang="ts">
import { ref } from 'vue'
import type { ImportLog, ImportError } from '../types'

const props = defineProps<{
  logs: ImportLog[]
  loading: boolean
}>()

const expandedRow = ref<string | null>(null)

function toggleRow(log: ImportLog) {
  if (!log.errors_json || log.errors_json.length === 0) return
  expandedRow.value = expandedRow.value === log.id ? null : log.id
}

function formatDate(dateStr: string): string {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('es-PE', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}
</script>

<template>
  <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
    <div class="overflow-x-auto">
      <table class="min-w-full text-sm">
        <thead class="bg-gray-50 border-b border-gray-200">
          <tr>
            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Tipo</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Archivo</th>
            <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wide">Total</th>
            <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wide">Exito</th>
            <th class="px-4 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wide">Errores</th>
            <th class="px-4 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wide">Fecha</th>
          </tr>
        </thead>
        <tbody>
          <!-- Loading skeletons -->
          <template v-if="props.loading">
            <tr v-for="n in 3" :key="n" class="border-b border-gray-100">
              <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-20" /></td>
              <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-40" /></td>
              <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-12 mx-auto" /></td>
              <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-12 mx-auto" /></td>
              <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-12 mx-auto" /></td>
              <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-32" /></td>
            </tr>
          </template>

          <!-- Empty state -->
          <template v-else-if="props.logs.length === 0">
            <tr>
              <td colspan="6" class="px-4 py-12 text-center text-gray-400 text-sm">
                No hay registros de importacion aun.
              </td>
            </tr>
          </template>

          <!-- Data rows -->
          <template v-else>
            <template v-for="log in props.logs" :key="log.id">
              <tr
                class="border-b border-gray-100 transition-colors duration-100"
                :class="[
                  log.errors_json && log.errors_json.length > 0
                    ? 'cursor-pointer hover:bg-gray-50'
                    : 'hover:bg-gray-50',
                ]"
                @click="toggleRow(log)"
              >
                <!-- Tipo badge -->
                <td class="px-4 py-3">
                  <span
                    class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    :class="
                      log.import_type === 'students'
                        ? 'bg-blue-100 text-blue-700'
                        : 'bg-green-100 text-green-700'
                    "
                  >
                    {{ log.import_type === 'students' ? 'Estudiantes' : 'Docentes' }}
                  </span>
                </td>

                <!-- File name -->
                <td class="px-4 py-3 text-gray-700 max-w-xs truncate">
                  {{ log.file_name || '-' }}
                </td>

                <!-- Total -->
                <td class="px-4 py-3 text-center text-gray-700 font-medium">
                  {{ log.total_records.toLocaleString() }}
                </td>

                <!-- Success -->
                <td class="px-4 py-3 text-center font-semibold text-green-600">
                  {{ log.success_records.toLocaleString() }}
                </td>

                <!-- Errors -->
                <td class="px-4 py-3 text-center font-semibold">
                  <span :class="log.failed_records > 0 ? 'text-red-600' : 'text-gray-400'">
                    {{ log.failed_records.toLocaleString() }}
                  </span>
                  <span
                    v-if="log.errors_json && log.errors_json.length > 0"
                    class="ml-1 text-gray-400 text-xs"
                  >
                    {{ expandedRow === log.id ? '▲' : '▼' }}
                  </span>
                </td>

                <!-- Date -->
                <td class="px-4 py-3 text-gray-500 text-xs whitespace-nowrap">
                  {{ formatDate(log.imported_at) }}
                </td>
              </tr>

              <!-- Expanded error detail row -->
              <tr v-if="expandedRow === log.id" :key="`${log.id}-errors`">
                <td colspan="6" class="px-4 py-3 bg-red-50 border-b border-red-100">
                  <p class="text-xs font-semibold text-red-700 mb-2">Detalle de errores:</p>
                  <div class="max-h-48 overflow-y-auto space-y-1">
                    <div
                      v-for="(err, idx) in log.errors_json"
                      :key="idx"
                      class="text-xs text-red-700 bg-white border border-red-100 rounded px-3 py-1.5"
                    >
                      <span class="font-semibold">Fila {{ err.row }}:</span>
                      {{ err.message }}
                    </div>
                  </div>
                </td>
              </tr>
            </template>
          </template>
        </tbody>
      </table>
    </div>
  </div>
</template>
