<script setup lang="ts">
import { onMounted, ref, computed } from 'vue'
import { useWorkshops } from '../composables/useWorkshops'
import { useSpecialties } from '../composables/useSpecialties'
import WorkshopFormModal from '../components/WorkshopFormModal.vue'
import type { Workshop } from '../types'

const {
  workshops,
  loading,
  fetchWorkshops,
  duplicateWorkshop,
  setStatus,
  toggleVisibility,
  deleteWorkshop,
} = useWorkshops()

const {
  specialties,
  fetchSpecialties,
} = useSpecialties()

const modalOpen = ref(false)
const selectedWorkshop = ref<Workshop | null>(null)
const selectedSpecialtyId = ref<string>('')

const filteredWorkshops = computed(() => {
  if (!selectedSpecialtyId.value) return workshops.value
  return workshops.value.filter(w => w.specialty_id === selectedSpecialtyId.value)
})

function openCreate() {
  selectedWorkshop.value = null
  modalOpen.value = true
}

function openEdit(w: Workshop) {
  selectedWorkshop.value = w
  modalOpen.value = true
}

async function handleDuplicate(w: Workshop) {
  await duplicateWorkshop(w)
}

async function handleToggleVisible(w: Workshop) {
  await toggleVisibility(w)
}

async function handleToggleStatus(w: Workshop) {
  const newStatus = w.status === 'available' ? 'closed' : 'available'
  await setStatus(w.id, newStatus)
}

async function handleDelete(w: Workshop) {
  if (!window.confirm(`Eliminar el taller "${w.name}"? Esta accion no se puede deshacer.`)) return
  await deleteWorkshop(w.id)
}

async function onFilterChange() {
  await fetchWorkshops(selectedSpecialtyId.value || undefined)
}

async function onSaved() {
  await fetchWorkshops(selectedSpecialtyId.value || undefined)
}

function formatDate(dateStr: string | null): string {
  if (!dateStr) return ''
  const [year, month, day] = dateStr.split('-')
  return `${day}/${month}/${year}`
}

function getStatusLabel(status: Workshop['status']): string {
  const labels: Record<Workshop['status'], string> = {
    available: 'Disponible',
    full: 'Lleno',
    closed: 'Cerrado',
    hidden: 'Oculto',
  }
  return labels[status]
}

function getStatusClasses(status: Workshop['status']): string {
  const map: Record<Workshop['status'], string> = {
    available: 'bg-green-100 text-green-700',
    full: 'bg-amber-100 text-amber-700',
    closed: 'bg-red-100 text-red-700',
    hidden: 'bg-gray-100 text-gray-500',
  }
  return map[status]
}

onMounted(async () => {
  await Promise.all([fetchSpecialties(), fetchWorkshops()])
})
</script>

<template>
  <div>
    <!-- Top bar -->
    <div class="flex flex-wrap items-center gap-3 mb-6">
      <h1 class="text-2xl font-bold mr-auto" style="color: #003366;">Talleres</h1>

      <!-- Specialty filter -->
      <select
        v-model="selectedSpecialtyId"
        class="px-3 py-2 border border-gray-300 rounded-lg text-sm bg-white focus:outline-none focus:ring-2 min-w-48"
        @change="onFilterChange"
      >
        <option value="">Todas las especialidades</option>
        <option v-for="sp in specialties" :key="sp.id" :value="sp.id">
          {{ sp.name }}
        </option>
      </select>

      <!-- New workshop button -->
      <button
        type="button"
        class="flex items-center gap-2 px-4 py-2 text-sm font-medium text-white rounded-lg transition-colors"
        style="background-color: #003366;"
        @click="openCreate"
        @mouseover="($event.target as HTMLElement).style.backgroundColor = '#51a0ce'"
        @mouseleave="($event.target as HTMLElement).style.backgroundColor = '#003366'"
      >
        <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
          <path fill-rule="evenodd" d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z" clip-rule="evenodd" />
        </svg>
        Nuevo Taller
      </button>
    </div>

    <!-- Loading skeleton -->
    <div v-if="loading" class="space-y-3">
      <div
        v-for="n in 4"
        :key="n"
        class="bg-white rounded-xl border border-gray-200 p-4 animate-pulse flex gap-4"
      >
        <div class="w-2 rounded-full bg-gray-200 self-stretch" />
        <div class="flex-1 space-y-2">
          <div class="h-4 bg-gray-200 rounded w-1/3" />
          <div class="h-3 bg-gray-100 rounded w-1/5" />
        </div>
        <div class="flex gap-2 items-center">
          <div class="h-6 bg-gray-100 rounded w-16" />
          <div class="h-6 bg-gray-100 rounded w-14" />
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div
      v-else-if="!loading && filteredWorkshops.length === 0"
      class="flex flex-col items-center justify-center py-20 text-center"
    >
      <div class="w-16 h-16 rounded-full flex items-center justify-center mb-4" style="background-color: #f0f7ff;">
        <svg class="w-8 h-8" style="color: #51a0ce;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 012.25-2.25h13.5A2.25 2.25 0 0121 7.5v11.25m-18 0A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75m-18 0v-7.5A2.25 2.25 0 015.25 9h13.5A2.25 2.25 0 0121 9v7.5" />
        </svg>
      </div>
      <p class="text-base font-medium text-gray-700 mb-1">No hay talleres</p>
      <p class="text-sm text-gray-400 mb-4">
        {{ selectedSpecialtyId ? 'No hay talleres para esta especialidad' : 'Crea el primer taller para comenzar' }}
      </p>
      <button
        type="button"
        class="px-4 py-2 text-sm font-medium text-white rounded-lg"
        style="background-color: #003366;"
        @click="openCreate"
      >
        Nuevo Taller
      </button>
    </div>

    <!-- Workshop list -->
    <div v-else class="space-y-2">
      <div
        v-for="w in filteredWorkshops"
        :key="w.id"
        class="group bg-white rounded-xl border border-gray-200 hover:border-gray-300 hover:shadow-sm transition-all"
      >
        <div class="flex items-center gap-4 px-4 py-3">

          <!-- Colored dot -->
          <div
            class="w-2.5 h-2.5 rounded-full flex-shrink-0"
            :style="{ backgroundColor: w.specialty?.color ?? '#51a0ce' }"
          />

          <!-- Name + specialty -->
          <div class="flex-1 min-w-0">
            <p class="font-semibold text-sm truncate" style="color: #003366;">{{ w.name }}</p>
            <p class="text-xs text-gray-400 truncate">{{ w.specialty?.name ?? '' }}</p>
          </div>

          <!-- Middle info: speaker, location, date -->
          <div class="hidden md:flex flex-col items-start gap-0.5 min-w-0 max-w-xs">
            <p v-if="w.speaker" class="text-xs text-gray-600 truncate">
              <span class="font-medium">Ponente:</span> {{ w.speaker }}
            </p>
            <p v-if="w.location" class="text-xs text-gray-500 truncate">
              <span class="font-medium">Lugar:</span> {{ w.location }}
            </p>
            <p v-if="w.workshop_date" class="text-xs text-gray-500">
              {{ formatDate(w.workshop_date) }}
            </p>
          </div>

          <!-- Badges -->
          <div class="flex items-center gap-2 flex-shrink-0">
            <!-- Status badge -->
            <span
              class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
              :class="getStatusClasses(w.status)"
            >
              {{ getStatusLabel(w.status) }}
            </span>

            <!-- Visibility badge -->
            <span
              class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
              :class="w.is_visible
                ? 'bg-blue-50 text-blue-600'
                : 'bg-gray-100 text-gray-400'"
            >
              {{ w.is_visible ? 'Visible' : 'Oculto' }}
            </span>
          </div>

          <!-- Shift capacity -->
          <div class="hidden lg:flex items-center gap-1 text-xs flex-shrink-0">
            <template v-if="w.shifts && w.shifts.length > 0">
              <template v-for="shift in w.shifts.filter(s => !('deleted_at' in s && s.deleted_at))" :key="shift.id">
                <span
                  class="font-mono px-2 py-0.5 rounded border text-xs"
                  :class="shift.registered_count >= shift.capacity
                    ? 'bg-red-50 text-red-600 border-red-200'
                    : 'bg-gray-50 text-gray-600 border-gray-200'"
                >
                  T{{ shift.shift_number }}: {{ shift.registered_count }}/{{ shift.capacity }}
                </span>
              </template>
            </template>
            <span v-else class="text-gray-300">Sin turnos</span>
          </div>

          <!-- Actions (visible on hover) -->
          <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0">

            <!-- Editar -->
            <button
              type="button"
              class="p-1.5 rounded-lg text-gray-400 hover:text-blue-600 hover:bg-blue-50 transition-colors"
              title="Editar"
              @click="openEdit(w)"
            >
              <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
              </svg>
            </button>

            <!-- Duplicar -->
            <button
              type="button"
              class="p-1.5 rounded-lg text-gray-400 hover:text-purple-600 hover:bg-purple-50 transition-colors"
              title="Duplicar"
              @click="handleDuplicate(w)"
            >
              <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path d="M7 9a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2H9a2 2 0 01-2-2V9z" />
                <path d="M5 3a2 2 0 00-2 2v6a2 2 0 002 2V5h8a2 2 0 00-2-2H5z" />
              </svg>
            </button>

            <!-- Toggle visible -->
            <button
              type="button"
              class="p-1.5 rounded-lg transition-colors"
              :class="w.is_visible
                ? 'text-blue-400 hover:text-blue-600 hover:bg-blue-50'
                : 'text-gray-400 hover:text-gray-600 hover:bg-gray-100'"
              :title="w.is_visible ? 'Ocultar' : 'Mostrar'"
              @click="handleToggleVisible(w)"
            >
              <svg v-if="w.is_visible" class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
                <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
              </svg>
              <svg v-else class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clip-rule="evenodd" />
                <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
              </svg>
            </button>

            <!-- Toggle available/closed -->
            <button
              type="button"
              class="p-1.5 rounded-lg transition-colors"
              :class="w.status === 'available'
                ? 'text-green-500 hover:text-red-600 hover:bg-red-50'
                : 'text-gray-400 hover:text-green-600 hover:bg-green-50'"
              :title="w.status === 'available' ? 'Cerrar taller' : 'Abrir taller'"
              @click="handleToggleStatus(w)"
            >
              <svg v-if="w.status === 'available'" class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
              </svg>
              <svg v-else class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
              </svg>
            </button>

            <!-- Eliminar -->
            <button
              type="button"
              class="p-1.5 rounded-lg text-red-400 hover:text-red-600 hover:bg-red-50 transition-colors"
              title="Eliminar"
              @click="handleDelete(w)"
            >
              <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
            </button>

          </div>
        </div>
      </div>
    </div>

    <!-- Modal -->
    <WorkshopFormModal
      v-model="modalOpen"
      :workshop="selectedWorkshop"
      :specialties="specialties"
      @saved="onSaved"
    />
  </div>
</template>
