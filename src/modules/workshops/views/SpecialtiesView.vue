<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useSpecialties } from '../composables/useSpecialties'
import SpecialtyFormModal from '../components/SpecialtyFormModal.vue'
import type { Specialty } from '../types'

const {
  specialties,
  loading,
  fetchSpecialties,
  toggleStatus,
  toggleVisibility,
  moveSortOrder,
  deleteSpecialty,
} = useSpecialties()

const modalOpen = ref(false)
const selectedSpecialty = ref<Specialty | null>(null)

function openCreate() {
  selectedSpecialty.value = null
  modalOpen.value = true
}

function openEdit(s: Specialty) {
  selectedSpecialty.value = s
  modalOpen.value = true
}

async function handleDelete(s: Specialty) {
  if (!window.confirm(`Eliminar la especialidad "${s.name}"? Esta accion no se puede deshacer.`)) return
  await deleteSpecialty(s.id)
}

async function onSaved() {
  await fetchSpecialties()
}

onMounted(() => {
  fetchSpecialties()
})
</script>

<template>
  <div>
    <!-- Top bar -->
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold" style="color: #003366;">Especialidades</h1>
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
        Nueva Especialidad
      </button>
    </div>

    <!-- Loading skeleton -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="n in 3"
        :key="n"
        class="bg-white rounded-xl border border-gray-200 p-5 animate-pulse"
      >
        <div class="h-4 bg-gray-200 rounded w-2/3 mb-3" />
        <div class="h-3 bg-gray-100 rounded w-full mb-2" />
        <div class="h-3 bg-gray-100 rounded w-4/5" />
        <div class="flex gap-2 mt-4">
          <div class="h-7 bg-gray-100 rounded w-8" />
          <div class="h-7 bg-gray-100 rounded w-8" />
          <div class="h-7 bg-gray-100 rounded w-8" />
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div
      v-else-if="!loading && specialties.length === 0"
      class="flex flex-col items-center justify-center py-20 text-center"
    >
      <div class="w-16 h-16 rounded-full flex items-center justify-center mb-4" style="background-color: #f0f7ff;">
        <svg class="w-8 h-8" style="color: #51a0ce;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M9.568 3H5.25A2.25 2.25 0 003 5.25v4.318c0 .597.237 1.17.659 1.591l9.581 9.581c.699.699 1.78.872 2.607.33a18.095 18.095 0 005.223-5.223c.542-.827.369-1.908-.33-2.607L11.16 3.66A2.25 2.25 0 009.568 3z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 6h.008v.008H6V6z" />
        </svg>
      </div>
      <p class="text-base font-medium text-gray-700 mb-1">No hay especialidades</p>
      <p class="text-sm text-gray-400 mb-4">Crea la primera especialidad para comenzar</p>
      <button
        type="button"
        class="px-4 py-2 text-sm font-medium text-white rounded-lg"
        style="background-color: #003366;"
        @click="openCreate"
      >
        Nueva Especialidad
      </button>
    </div>

    <!-- Specialty grid -->
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="(s, idx) in specialties"
        :key="s.id"
        class="bg-white rounded-xl border border-gray-200 overflow-hidden shadow-sm hover:shadow-md transition-shadow"
        :style="{ borderLeft: `4px solid ${s.color ?? '#51a0ce'}` }"
      >
        <!-- Card header -->
        <div class="px-5 pt-5 pb-3">
          <div class="flex items-start justify-between gap-2 mb-2">
            <h3 class="font-bold text-base leading-tight flex-1" style="color: #003366;">
              {{ s.name }}
            </h3>
            <div class="flex items-center gap-1.5 flex-shrink-0">
              <!-- Status badge -->
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                :class="s.status === 'active'
                  ? 'bg-green-100 text-green-700'
                  : 'bg-gray-100 text-gray-500'"
              >
                {{ s.status === 'active' ? 'Activa' : 'Inactiva' }}
              </span>
              <!-- Visibility badge -->
              <span
                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium"
                :class="s.is_visible
                  ? 'bg-blue-50 text-blue-600'
                  : 'bg-gray-100 text-gray-400'"
              >
                {{ s.is_visible ? 'Visible' : 'Oculto' }}
              </span>
            </div>
          </div>

          <!-- Description -->
          <p
            v-if="s.description"
            class="text-sm text-gray-500 line-clamp-2"
          >
            {{ s.description }}
          </p>
          <p v-else class="text-sm text-gray-300 italic">Sin descripcion</p>
        </div>

        <!-- Color strip info -->
        <div class="px-5 pb-3">
          <div class="flex items-center gap-2">
            <div
              class="h-3 w-3 rounded-full border border-gray-200"
              :style="{ backgroundColor: s.color ?? '#51a0ce' }"
            />
            <span class="text-xs font-mono text-gray-400">{{ s.color ?? '#51a0ce' }}</span>
          </div>
        </div>

        <!-- Footer actions -->
        <div class="px-4 py-3 border-t border-gray-100 flex items-center gap-1 flex-wrap">

          <!-- Editar -->
          <button
            type="button"
            class="p-2 rounded-lg text-gray-500 hover:text-blue-600 hover:bg-blue-50 transition-colors"
            title="Editar"
            @click="openEdit(s)"
          >
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path d="M13.586 3.586a2 2 0 112.828 2.828l-.793.793-2.828-2.828.793-.793zM11.379 5.793L3 14.172V17h2.828l8.38-8.379-2.83-2.828z" />
            </svg>
          </button>

          <!-- Subir -->
          <button
            type="button"
            class="p-2 rounded-lg text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
            title="Subir"
            :disabled="idx === 0"
            @click="moveSortOrder(s, 'up')"
          >
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L11 7.414V15a1 1 0 11-2 0V7.414L6.707 9.707a1 1 0 01-1.414 0z" clip-rule="evenodd" />
            </svg>
          </button>

          <!-- Bajar -->
          <button
            type="button"
            class="p-2 rounded-lg text-gray-500 hover:text-gray-700 hover:bg-gray-100 transition-colors disabled:opacity-30 disabled:cursor-not-allowed"
            title="Bajar"
            :disabled="idx === specialties.length - 1"
            @click="moveSortOrder(s, 'down')"
          >
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M14.707 10.293a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 111.414-1.414L9 12.586V5a1 1 0 012 0v7.586l2.293-2.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
          </button>

          <!-- Toggle status -->
          <button
            type="button"
            class="p-2 rounded-lg transition-colors"
            :class="s.status === 'active'
              ? 'text-green-600 hover:bg-green-50'
              : 'text-gray-400 hover:bg-gray-100'"
            :title="s.status === 'active' ? 'Desactivar' : 'Activar'"
            @click="toggleStatus(s)"
          >
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg>
          </button>

          <!-- Toggle visibility -->
          <button
            type="button"
            class="p-2 rounded-lg transition-colors"
            :class="s.is_visible
              ? 'text-blue-500 hover:bg-blue-50'
              : 'text-gray-400 hover:bg-gray-100'"
            :title="s.is_visible ? 'Ocultar' : 'Mostrar'"
            @click="toggleVisibility(s)"
          >
            <svg v-if="s.is_visible" class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path d="M10 12a2 2 0 100-4 2 2 0 000 4z" />
              <path fill-rule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clip-rule="evenodd" />
            </svg>
            <svg v-else class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M3.707 2.293a1 1 0 00-1.414 1.414l14 14a1 1 0 001.414-1.414l-1.473-1.473A10.014 10.014 0 0019.542 10C18.268 5.943 14.478 3 10 3a9.958 9.958 0 00-4.512 1.074l-1.78-1.781zm4.261 4.26l1.514 1.515a2.003 2.003 0 012.45 2.45l1.514 1.514a4 4 0 00-5.478-5.478z" clip-rule="evenodd" />
              <path d="M12.454 16.697L9.75 13.992a4 4 0 01-3.742-3.741L2.335 6.578A9.98 9.98 0 00.458 10c1.274 4.057 5.065 7 9.542 7 .847 0 1.669-.105 2.454-.303z" />
            </svg>
          </button>

          <!-- Eliminar -->
          <button
            type="button"
            class="p-2 rounded-lg text-red-400 hover:text-red-600 hover:bg-red-50 transition-colors ml-auto"
            title="Eliminar"
            @click="handleDelete(s)"
          >
            <svg class="w-4 h-4" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </button>

        </div>
      </div>
    </div>

    <!-- Modal -->
    <SpecialtyFormModal
      v-model="modalOpen"
      :specialty="selectedSpecialty"
      @saved="onSaved"
    />
  </div>
</template>
