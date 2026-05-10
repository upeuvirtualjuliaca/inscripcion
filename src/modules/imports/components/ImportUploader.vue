<script setup lang="ts">
import { ref } from 'vue'

const props = defineProps<{
  disabled?: boolean
}>()

const emit = defineEmits<{
  (e: 'file-selected', file: File): void
}>()

const isDragging = ref(false)
const selectedFile = ref<File | null>(null)
const fileInputRef = ref<HTMLInputElement | null>(null)

function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / (1024 * 1024)).toFixed(2)} MB`
}

function handleFile(file: File) {
  if (props.disabled) return
  const allowed = [
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel',
  ]
  const extOk = /\.(xlsx|xls)$/i.test(file.name)
  if (!allowed.includes(file.type) && !extOk) return
  selectedFile.value = file
  emit('file-selected', file)
}

function onDragOver(e: DragEvent) {
  if (props.disabled) return
  e.preventDefault()
  isDragging.value = true
}

function onDragLeave() {
  isDragging.value = false
}

function onDrop(e: DragEvent) {
  if (props.disabled) return
  e.preventDefault()
  isDragging.value = false
  const file = e.dataTransfer?.files?.[0]
  if (file) handleFile(file)
}

function onInputChange(e: Event) {
  const target = e.target as HTMLInputElement
  const file = target.files?.[0]
  if (file) handleFile(file)
}

function openPicker() {
  if (props.disabled) return
  fileInputRef.value?.click()
}

function changeFile() {
  selectedFile.value = null
  if (fileInputRef.value) fileInputRef.value.value = ''
  openPicker()
}
</script>

<template>
  <div>
    <input
      ref="fileInputRef"
      type="file"
      accept=".xlsx,.xls"
      class="hidden"
      :disabled="props.disabled"
      @change="onInputChange"
    />

    <!-- Drop zone: no file selected -->
    <div
      v-if="!selectedFile"
      class="border-2 border-dashed rounded-lg p-10 flex flex-col items-center justify-center text-center cursor-pointer transition-colors duration-150"
      :class="[
        props.disabled
          ? 'border-gray-200 bg-gray-50 cursor-not-allowed opacity-60'
          : isDragging
          ? 'border-blue-400 bg-blue-50'
          : 'border-gray-300 bg-white hover:border-blue-300 hover:bg-gray-50',
      ]"
      @dragover="onDragOver"
      @dragleave="onDragLeave"
      @drop="onDrop"
      @click="openPicker"
    >
      <!-- Upload icon -->
      <svg
        class="w-12 h-12 mb-4"
        :class="isDragging ? 'text-blue-400' : 'text-gray-300'"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="1.5"
          d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"
        />
      </svg>

      <p class="text-sm font-medium text-gray-700">
        Arrastra tu archivo aqui o
        <span class="text-blue-600 underline">selecciona uno</span>
      </p>
      <p class="text-xs text-gray-400 mt-1">Solo archivos .xlsx o .xls</p>
    </div>

    <!-- File selected state -->
    <div
      v-else
      class="border-2 border-green-300 rounded-lg bg-green-50 p-5 flex items-center justify-between"
    >
      <div class="flex items-center gap-3 min-w-0">
        <svg
          class="w-8 h-8 text-green-500 flex-shrink-0"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
          />
        </svg>
        <div class="min-w-0">
          <p class="text-sm font-medium text-gray-800 truncate">{{ selectedFile.name }}</p>
          <p class="text-xs text-gray-500">{{ formatSize(selectedFile.size) }}</p>
        </div>
      </div>

      <button
        type="button"
        class="ml-4 flex-shrink-0 text-sm text-blue-600 hover:text-blue-800 font-medium transition-colors"
        :disabled="props.disabled"
        @click="changeFile"
      >
        Cambiar archivo
      </button>
    </div>
  </div>
</template>
