<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import type { ImportType } from '../types'
import { useImport } from '../composables/useImport'
import ImportUploader from '../components/ImportUploader.vue'
import ImportPreviewTable from '../components/ImportPreviewTable.vue'
import ImportLogsTable from '../components/ImportLogsTable.vue'

type Tab = 'nueva' | 'historial'

const activeTab = ref<Tab>('nueva')
const selectedType = ref<ImportType | null>(null)
const selectedFile = ref<File | null>(null)
const logsLoading = ref(false)

const { parseResult, progress, logs, parseFile, runImport, fetchLogs, resetImport } = useImport()

// Load logs when switching to history tab
watch(activeTab, async (tab) => {
  if (tab === 'historial') {
    logsLoading.value = true
    await fetchLogs()
    logsLoading.value = false
  }
})

function selectType(type: ImportType) {
  if (progress.status === 'importing') return
  if (selectedType.value !== type) {
    selectedType.value = type
    selectedFile.value = null
    resetImport()
  }
}

async function onFileSelected(file: File) {
  if (!selectedType.value) return
  selectedFile.value = file
  await parseFile(file, selectedType.value)
}

async function onImport() {
  if (!selectedType.value || !parseResult.value) return
  await runImport(selectedType.value)
}

function onReset() {
  selectedType.value = null
  selectedFile.value = null
  resetImport()
}

function downloadErrors() {
  if (progress.errors.length === 0) return
  const lines = ['Fila,Mensaje,Datos']
  for (const err of progress.errors) {
    const data = err.data ? JSON.stringify(err.data) : ''
    lines.push(`${err.row},"${err.message.replace(/"/g, '""')}","${data.replace(/"/g, '""')}"`)
  }
  const blob = new Blob([lines.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = 'errores_importacion.csv'
  a.click()
  URL.revokeObjectURL(url)
}

const showPreview = computed(
  () => parseResult.value !== null && (progress.status === 'idle' || progress.status === 'done')
)

const showImportButton = computed(
  () => parseResult.value !== null && progress.status === 'idle'
)

const showProgress = computed(() => progress.status === 'importing')

const showResult = computed(() => progress.status === 'done')

const importerDisabled = computed(
  () => progress.status === 'importing' || progress.status === 'done'
)
</script>

<template>
  <div class="max-w-5xl mx-auto">
    <!-- Page title -->
    <div class="mb-6">
      <h2 class="text-2xl font-bold text-gray-800">Importaciones</h2>
      <p class="text-sm text-gray-500 mt-1">
        Importa datos de estudiantes y docentes desde archivos Excel (.xlsx / .xls).
      </p>
    </div>

    <!-- Tabs -->
    <div class="border-b border-gray-200 mb-6">
      <nav class="-mb-px flex gap-6">
        <button
          class="pb-3 text-sm font-medium border-b-2 transition-colors duration-150"
          :class="
            activeTab === 'nueva'
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          "
          @click="activeTab = 'nueva'"
        >
          Nueva Importacion
        </button>
        <button
          class="pb-3 text-sm font-medium border-b-2 transition-colors duration-150"
          :class="
            activeTab === 'historial'
              ? 'border-blue-600 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          "
          @click="activeTab = 'historial'"
        >
          Historial de Importaciones
        </button>
      </nav>
    </div>

    <!-- Tab: Nueva Importacion -->
    <div v-if="activeTab === 'nueva'" class="space-y-6">

      <!-- Step 1: Type selector -->
      <div>
        <h3 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">
          Paso 1 — Selecciona el tipo de importacion
        </h3>
        <div class="grid grid-cols-2 gap-4">
          <!-- Students card -->
          <button
            type="button"
            class="text-left p-5 rounded-lg border-2 transition-all duration-150 focus:outline-none"
            :class="[
              selectedType === 'students'
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 bg-white hover:border-blue-200 hover:bg-gray-50',
              importerDisabled ? 'opacity-60 cursor-not-allowed' : 'cursor-pointer',
            ]"
            :disabled="importerDisabled"
            @click="selectType('students')"
          >
            <p
              class="font-semibold text-base mb-1"
              :class="selectedType === 'students' ? 'text-blue-700' : 'text-gray-800'"
            >
              Estudiantes
            </p>
            <p class="text-sm text-gray-500">
              Importa el listado de estudiantes matriculados. El archivo debe contener columnas del
              sistema academico.
            </p>
            <span
              v-if="selectedType === 'students'"
              class="inline-flex items-center mt-2 text-xs text-blue-600 font-semibold"
            >
              Seleccionado
            </span>
          </button>

          <!-- Teachers card -->
          <button
            type="button"
            class="text-left p-5 rounded-lg border-2 transition-all duration-150 focus:outline-none"
            :class="[
              selectedType === 'teachers'
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 bg-white hover:border-blue-200 hover:bg-gray-50',
              importerDisabled ? 'opacity-60 cursor-not-allowed' : 'cursor-pointer',
            ]"
            :disabled="importerDisabled"
            @click="selectType('teachers')"
          >
            <p
              class="font-semibold text-base mb-1"
              :class="selectedType === 'teachers' ? 'text-blue-700' : 'text-gray-800'"
            >
              Docentes
            </p>
            <p class="text-sm text-gray-500">
              Importa la carga docente con asignaturas, horarios y datos de cada profesor.
            </p>
            <span
              v-if="selectedType === 'teachers'"
              class="inline-flex items-center mt-2 text-xs text-blue-600 font-semibold"
            >
              Seleccionado
            </span>
          </button>
        </div>
      </div>

      <!-- Step 2: File uploader -->
      <div v-if="selectedType">
        <h3 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">
          Paso 2 — Sube el archivo Excel
        </h3>

        <!-- Parsing indicator -->
        <div
          v-if="progress.status === 'parsing'"
          class="border-2 border-blue-200 rounded-lg bg-blue-50 p-8 flex items-center justify-center gap-3"
        >
          <svg
            class="animate-spin h-5 w-5 text-blue-500"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
          >
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
            <path
              class="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
            />
          </svg>
          <span class="text-sm text-blue-700 font-medium">Procesando archivo...</span>
        </div>

        <ImportUploader
          v-else
          :disabled="importerDisabled"
          @file-selected="onFileSelected"
        />
      </div>

      <!-- Step 3: Preview table -->
      <div v-if="showPreview && parseResult">
        <h3 class="text-sm font-semibold text-gray-700 uppercase tracking-wide mb-3">
          Paso 3 — Revisa la vista previa
        </h3>
        <ImportPreviewTable :result="parseResult" :type="selectedType!" />
      </div>

      <!-- Import button -->
      <div v-if="showImportButton && parseResult" class="flex items-center gap-4">
        <button
          type="button"
          class="bg-blue-600 hover:bg-blue-700 text-white text-sm font-semibold px-6 py-2.5 rounded-lg transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-blue-400"
          @click="onImport"
        >
          Importar {{ parseResult.totalRows.toLocaleString() }} registros
        </button>
        <button
          type="button"
          class="text-sm text-gray-500 hover:text-gray-700 transition-colors"
          @click="onReset"
        >
          Cancelar
        </button>
      </div>

      <!-- Progress bar -->
      <div v-if="showProgress" class="bg-white border border-gray-200 rounded-lg p-5 space-y-3">
        <div class="flex items-center justify-between text-sm">
          <span class="font-medium text-gray-700">Importando...</span>
          <span class="text-gray-500">{{ progress.percentage }}%</span>
        </div>
        <div class="w-full bg-gray-100 rounded-full h-2.5 overflow-hidden">
          <div
            class="bg-blue-500 h-2.5 rounded-full transition-all duration-300"
            :style="{ width: `${progress.percentage}%` }"
          />
        </div>
        <p class="text-xs text-gray-500">
          {{ progress.processed.toLocaleString() }} de {{ progress.total.toLocaleString() }} filas procesadas
        </p>
      </div>

      <!-- Result panel -->
      <div
        v-if="showResult"
        class="bg-white border border-gray-200 rounded-lg p-6 space-y-4"
      >
        <h3 class="font-semibold text-gray-800 text-base">Importacion completada</h3>

        <div class="grid grid-cols-2 gap-4">
          <div class="bg-green-50 border border-green-200 rounded-lg p-4">
            <p class="text-xs text-green-700 font-medium uppercase tracking-wide mb-1">Registros importados</p>
            <p class="text-2xl font-bold text-green-700">{{ progress.success.toLocaleString() }}</p>
          </div>
          <div class="bg-red-50 border border-red-200 rounded-lg p-4">
            <p class="text-xs text-red-700 font-medium uppercase tracking-wide mb-1">Registros con error</p>
            <p class="text-2xl font-bold text-red-700">{{ progress.errors.length.toLocaleString() }}</p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <button
            v-if="progress.errors.length > 0"
            type="button"
            class="text-sm bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 px-4 py-2 rounded-lg font-medium transition-colors"
            @click="downloadErrors"
          >
            Descargar errores (.csv)
          </button>
          <button
            type="button"
            class="text-sm bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors"
            @click="onReset"
          >
            Nueva importacion
          </button>
        </div>
      </div>

    </div>

    <!-- Tab: Historial -->
    <div v-else-if="activeTab === 'historial'">
      <ImportLogsTable :logs="logs" :loading="logsLoading" />
    </div>
  </div>
</template>
