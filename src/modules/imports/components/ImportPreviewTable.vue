<script setup lang="ts">
import type { ParseResult, ImportType } from '../types'

const props = defineProps<{
  result: ParseResult
  type: ImportType
}>()
</script>

<template>
  <div class="space-y-4">
    <!-- Summary cards -->
    <div class="grid grid-cols-3 gap-4">
      <div class="bg-white rounded-lg border border-gray-200 p-4">
        <p class="text-xs text-gray-500 uppercase tracking-wide font-medium mb-1">Total filas</p>
        <p class="text-2xl font-bold text-gray-800">{{ props.result.totalRows.toLocaleString() }}</p>
      </div>
      <div class="bg-white rounded-lg border border-gray-200 p-4">
        <p class="text-xs text-gray-500 uppercase tracking-wide font-medium mb-1">Columnas reconocidas</p>
        <p class="text-2xl font-bold text-green-600">{{ props.result.mappedHeaders.length }}</p>
      </div>
      <div class="bg-white rounded-lg border border-gray-200 p-4">
        <p class="text-xs text-gray-500 uppercase tracking-wide font-medium mb-1">Columnas no reconocidas</p>
        <p
          class="text-2xl font-bold"
          :class="props.result.unmappedHeaders.length > 0 ? 'text-yellow-600' : 'text-gray-400'"
        >
          {{ props.result.unmappedHeaders.length }}
        </p>
      </div>
    </div>

    <!-- Warning: unmapped headers -->
    <div
      v-if="props.result.unmappedHeaders.length > 0"
      class="bg-yellow-50 border border-yellow-200 rounded-lg p-4"
    >
      <p class="text-sm font-semibold text-yellow-800 mb-2">
        Las siguientes columnas del archivo no se reconocieron y seran ignoradas:
      </p>
      <ul class="flex flex-wrap gap-2">
        <li
          v-for="header in props.result.unmappedHeaders"
          :key="header"
          class="bg-yellow-100 text-yellow-800 text-xs px-2 py-1 rounded font-mono"
        >
          {{ header }}
        </li>
      </ul>
    </div>

    <!-- Preview table -->
    <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
      <div class="px-4 py-3 border-b border-gray-100">
        <p class="text-sm font-semibold text-gray-700">Vista previa de datos</p>
      </div>

      <div class="overflow-x-auto max-h-80 overflow-y-auto">
        <table class="min-w-full text-xs">
          <thead class="bg-gray-50 sticky top-0 z-10">
            <tr>
              <th
                v-for="col in props.result.mappedHeaders"
                :key="col"
                class="px-3 py-2 text-left font-semibold text-gray-600 border-b border-gray-200 whitespace-nowrap"
              >
                {{ col }}
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-100">
            <tr
              v-for="(row, rowIdx) in props.result.preview"
              :key="rowIdx"
              class="hover:bg-gray-50"
            >
              <td
                v-for="col in props.result.mappedHeaders"
                :key="col"
                class="px-3 py-2 text-gray-700 whitespace-nowrap max-w-xs truncate"
              >
                {{ row[col] ?? '' }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="px-4 py-2 border-t border-gray-100 bg-gray-50">
        <p class="text-xs text-gray-500">
          Mostrando {{ props.result.preview.length }} de {{ props.result.totalRows.toLocaleString() }} filas
        </p>
      </div>
    </div>
  </div>
</template>
