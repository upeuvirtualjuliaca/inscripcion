<template>
  <div class="p-6 max-w-7xl mx-auto">

    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <div>
        <h1 class="text-xl font-bold" style="color: #003366;">Inscripciones</h1>
        <p class="text-sm text-gray-500 mt-0.5">Gestión de participantes inscritos en los talleres</p>
      </div>
      <button @click="fetchRegistrations"
        class="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium border border-gray-200 text-gray-600 hover:bg-gray-50 transition-colors duration-150">
        <svg :class="loading ? 'animate-spin' : ''" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/>
          <path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/>
        </svg>
        Actualizar
      </button>
    </div>

    <!-- Stats row -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
      <div v-for="stat in stats" :key="stat.label"
        class="bg-white rounded-xl p-4 border border-gray-100 shadow-sm flex items-center gap-3">
        <div class="w-10 h-10 rounded-lg flex items-center justify-center shrink-0"
          :style="`background-color: ${stat.bg};`">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" :stroke="stat.color" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" v-html="stat.icon"></svg>
        </div>
        <div>
          <p class="text-2xl font-extrabold leading-none" :style="`color: ${stat.color}`">{{ stat.value }}</p>
          <p class="text-xs text-gray-500 mt-0.5">{{ stat.label }}</p>
        </div>
      </div>
    </div>

    <!-- Filters -->
    <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 mb-4 flex flex-wrap gap-3 items-center">
      <!-- Search -->
      <div class="relative flex-1 min-w-48">
        <svg class="absolute left-3 top-1/2 -translate-y-1/2 pointer-events-none" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input type="text" v-model="search" placeholder="Buscar por nombre, DNI o código..."
          class="w-full pl-9 pr-3 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#51a0ce]" />
      </div>
      <!-- Status filter -->
      <select v-model="filterStatus"
        class="text-sm border border-gray-200 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#51a0ce] text-gray-700">
        <option value="">Todos los estados</option>
        <option value="confirmed">Confirmado</option>
        <option value="cancelled">Cancelado</option>
        <option value="checked_in">Con asistencia</option>
      </select>
      <!-- Workshop filter -->
      <select v-model="filterWorkshop"
        class="text-sm border border-gray-200 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#51a0ce] text-gray-700 max-w-48 truncate">
        <option value="">Todos los talleres</option>
        <option v-for="w in workshopOptions" :key="w" :value="w">{{ w }}</option>
      </select>
      <!-- Clear -->
      <button v-if="search || filterStatus || filterWorkshop"
        @click="search = ''; filterStatus = ''; filterWorkshop = ''"
        class="text-xs text-gray-400 hover:text-gray-600 px-2 py-1 rounded transition-colors duration-150">
        Limpiar filtros
      </button>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full text-sm">
          <thead class="bg-gray-50 border-b border-gray-100">
            <tr>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Nº</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Participante</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Taller</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Turno</th>
              <th class="px-4 py-3 text-center text-xs font-semibold text-gray-500 uppercase tracking-wide">Estado</th>
              <th class="px-4 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wide">Fecha</th>
              <th class="px-4 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wide">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <!-- Loading -->
            <template v-if="loading">
              <tr v-for="n in 8" :key="n" class="border-b border-gray-50">
                <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-8"></div></td>
                <td class="px-4 py-3">
                  <div class="h-4 bg-gray-100 rounded animate-pulse w-32 mb-1"></div>
                  <div class="h-3 bg-gray-100 rounded animate-pulse w-20"></div>
                </td>
                <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-40"></div></td>
                <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-20"></div></td>
                <td class="px-4 py-3"><div class="h-6 bg-gray-100 rounded-full animate-pulse w-20 mx-auto"></div></td>
                <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-24"></div></td>
                <td class="px-4 py-3"><div class="h-4 bg-gray-100 rounded animate-pulse w-16 ml-auto"></div></td>
              </tr>
            </template>

            <!-- Empty -->
            <template v-else-if="filtered.length === 0">
              <tr>
                <td colspan="7" class="px-4 py-16 text-center">
                  <div class="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-3">
                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/>
                      <path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>
                    </svg>
                  </div>
                  <p class="text-gray-400 text-sm">No se encontraron inscripciones.</p>
                </td>
              </tr>
            </template>

            <!-- Rows -->
            <template v-else>
              <tr v-for="reg in filtered" :key="reg.id"
                class="border-b border-gray-50 hover:bg-gray-50 transition-colors duration-100 group">

                <!-- Nº -->
                <td class="px-4 py-3 text-gray-400 text-xs font-mono">#{{ reg.registration_number }}</td>

                <!-- Participante -->
                <td class="px-4 py-3">
                  <p class="font-semibold text-gray-800 leading-tight">
                    {{ reg.participant.last_name }}, {{ reg.participant.first_name }}
                  </p>
                  <p class="text-xs text-gray-400 mt-0.5">DNI {{ reg.participant.dni }}</p>
                  <p class="text-xs font-mono text-gray-400">{{ reg.confirmation_code }}</p>
                </td>

                <!-- Taller -->
                <td class="px-4 py-3 max-w-xs">
                  <p class="text-gray-700 text-sm leading-snug line-clamp-2">{{ reg.workshop.name }}</p>
                  <span v-if="reg.workshop.specialty" class="inline-block mt-1 text-xs font-semibold px-2 py-0.5 rounded-full text-white"
                    :style="`background-color: ${reg.workshop.specialty.color};`">
                    {{ reg.workshop.specialty.name }}
                  </span>
                </td>

                <!-- Turno -->
                <td class="px-4 py-3 whitespace-nowrap">
                  <p class="text-sm font-medium text-gray-700">
                    {{ reg.shift?.shift_name || `Turno ${reg.shift?.shift_number}` }}
                  </p>
                  <p v-if="reg.shift?.start_time" class="text-xs text-gray-400">
                    {{ reg.shift.start_time.slice(0,5) }} – {{ reg.shift.end_time?.slice(0,5) }}
                  </p>
                </td>

                <!-- Estado -->
                <td class="px-4 py-3 text-center">
                  <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold"
                    :class="{
                      'bg-green-100 text-green-700': reg.status === 'confirmed',
                      'bg-red-100 text-red-600':     reg.status === 'cancelled',
                      'bg-blue-100 text-blue-700':   reg.status === 'checked_in',
                    }">
                    <span class="w-1.5 h-1.5 rounded-full"
                      :class="{
                        'bg-green-500': reg.status === 'confirmed',
                        'bg-red-500':   reg.status === 'cancelled',
                        'bg-blue-500':  reg.status === 'checked_in',
                      }"></span>
                    {{ statusLabel(reg.status) }}
                  </span>
                </td>

                <!-- Fecha -->
                <td class="px-4 py-3 text-xs text-gray-500 whitespace-nowrap">
                  {{ formatDate(reg.registration_date) }}
                </td>

                <!-- Acciones -->
                <td class="px-4 py-3">
                  <div class="flex items-center justify-end gap-1 opacity-0 group-hover:opacity-100 transition-opacity duration-150">
                    <!-- Edit -->
                    <button @click="openEdit(reg)" title="Editar datos"
                      class="w-8 h-8 rounded-lg flex items-center justify-center transition-colors duration-150 hover:bg-blue-50">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
                        <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
                      </svg>
                    </button>
                    <!-- Cancel (only if confirmed) -->
                    <button v-if="reg.status === 'confirmed'" @click="confirmCancel(reg)" title="Cancelar inscripción"
                      class="w-8 h-8 rounded-lg flex items-center justify-center transition-colors duration-150 hover:bg-orange-50">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#f97316" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/><line x1="8" y1="12" x2="16" y2="12"/>
                      </svg>
                    </button>
                    <!-- Delete -->
                    <button @click="confirmDelete(reg)" title="Eliminar inscripción"
                      class="w-8 h-8 rounded-lg flex items-center justify-center transition-colors duration-150 hover:bg-red-50">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/>
                        <path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            </template>
          </tbody>
        </table>
      </div>

      <!-- Table footer -->
      <div v-if="!loading && filtered.length > 0"
        class="px-4 py-3 border-t border-gray-100 text-xs text-gray-400 flex items-center justify-between">
        <span>{{ filtered.length }} inscripción{{ filtered.length !== 1 ? 'es' : '' }}</span>
        <span v-if="filtered.length !== registrations.length">de {{ registrations.length }} totales</span>
      </div>
    </div>

    <!-- Edit modal -->
    <EditRegistrationModal
      v-model="editModalOpen"
      :registration="selectedRegistration"
      @saved="fetchRegistrations"
    />

    <!-- Confirm dialog -->
    <div v-if="confirmDialog.open" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="confirmDialog.open = false"></div>
      <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-sm p-6">
        <div class="w-12 h-12 rounded-full flex items-center justify-center mx-auto mb-4"
          :style="confirmDialog.type === 'delete' ? 'background-color: rgba(239,68,68,0.1);' : 'background-color: rgba(249,115,22,0.1);'">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none"
            :stroke="confirmDialog.type === 'delete' ? '#ef4444' : '#f97316'"
            stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
            <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
          </svg>
        </div>
        <h3 class="text-center font-bold text-gray-800 mb-2">{{ confirmDialog.title }}</h3>
        <p class="text-center text-sm text-gray-500 mb-6">{{ confirmDialog.message }}</p>
        <div class="flex gap-3">
          <button @click="confirmDialog.open = false"
            class="flex-1 py-2 rounded-lg text-sm font-semibold border border-gray-200 text-gray-600 hover:bg-gray-50 transition-colors duration-150">
            Cancelar
          </button>
          <button @click="confirmDialog.onConfirm()" :disabled="actionLoading"
            class="flex-1 py-2 rounded-lg text-sm font-semibold text-white transition-colors duration-150 flex items-center justify-center gap-2"
            :style="confirmDialog.type === 'delete' ? 'background-color: #ef4444;' : 'background-color: #f97316;'">
            <svg v-if="actionLoading" class="animate-spin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/><path d="M21 12a9 9 0 00-9-9"/>
            </svg>
            {{ confirmDialog.type === 'delete' ? 'Eliminar' : 'Cancelar inscripción' }}
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, reactive } from 'vue'
import { useRegistrations, type AdminRegistration } from '../composables/useRegistrations'
import EditRegistrationModal from '../components/EditRegistrationModal.vue'

const { registrations, loading, fetchRegistrations, cancelRegistration, deleteRegistration } = useRegistrations()

// ── Filters ──────────────────────────────────────────────────
const search        = ref('')
const filterStatus  = ref('')
const filterWorkshop = ref('')

const workshopOptions = computed(() => {
  const names = new Set(registrations.value.map(r => r.workshop.name))
  return Array.from(names).sort()
})

const filtered = computed(() => {
  const q = search.value.toLowerCase().trim()
  return registrations.value.filter(r => {
    if (filterStatus.value  && r.status !== filterStatus.value) return false
    if (filterWorkshop.value && r.workshop.name !== filterWorkshop.value) return false
    if (!q) return true
    const fullName = `${r.participant.first_name} ${r.participant.last_name}`.toLowerCase()
    return (
      fullName.includes(q) ||
      r.participant.dni.includes(q) ||
      r.confirmation_code.toLowerCase().includes(q)
    )
  })
})

// ── Stats ─────────────────────────────────────────────────────
const stats = computed(() => [
  {
    label: 'Total inscritos',
    value: registrations.value.length,
    color: '#003366', bg: 'rgba(0,51,102,0.08)',
    icon: '<path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/>',
  },
  {
    label: 'Confirmados',
    value: registrations.value.filter(r => r.status === 'confirmed').length,
    color: '#16a34a', bg: 'rgba(22,163,74,0.1)',
    icon: '<path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>',
  },
  {
    label: 'Con asistencia',
    value: registrations.value.filter(r => r.status === 'checked_in').length,
    color: '#2563eb', bg: 'rgba(37,99,235,0.1)',
    icon: '<path d="M16 21v-2a4 4 0 00-4-4H6a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><polyline points="16 11 18 13 22 9"/>',
  },
  {
    label: 'Cancelados',
    value: registrations.value.filter(r => r.status === 'cancelled').length,
    color: '#dc2626', bg: 'rgba(220,38,38,0.08)',
    icon: '<circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>',
  },
])

// ── Edit modal ────────────────────────────────────────────────
const editModalOpen       = ref(false)
const selectedRegistration = ref<AdminRegistration | null>(null)

function openEdit(reg: AdminRegistration) {
  selectedRegistration.value = reg
  editModalOpen.value = true
}

// ── Confirm dialog ────────────────────────────────────────────
const actionLoading = ref(false)
const confirmDialog = reactive({
  open: false,
  type: 'delete' as 'delete' | 'cancel',
  title: '',
  message: '',
  onConfirm: async () => {},
})

function confirmCancel(reg: AdminRegistration) {
  confirmDialog.type    = 'cancel'
  confirmDialog.title   = 'Cancelar inscripción'
  confirmDialog.message = `¿Cancelar la inscripción de ${reg.participant.first_name} ${reg.participant.last_name} al taller "${reg.workshop.name}"? El cupo quedará disponible para otro participante.`
  confirmDialog.onConfirm = async () => {
    actionLoading.value = true
    try {
      await cancelRegistration(reg.id)
    } finally {
      actionLoading.value = false
      confirmDialog.open  = false
    }
  }
  confirmDialog.open = true
}

function confirmDelete(reg: AdminRegistration) {
  confirmDialog.type    = 'delete'
  confirmDialog.title   = 'Eliminar inscripción'
  confirmDialog.message = `¿Eliminar definitivamente la inscripción de ${reg.participant.first_name} ${reg.participant.last_name}? El cupo quedará libre y el participante podrá inscribirse en otro taller.`
  confirmDialog.onConfirm = async () => {
    actionLoading.value = true
    try {
      await deleteRegistration(reg.id)
    } finally {
      actionLoading.value = false
      confirmDialog.open  = false
    }
  }
  confirmDialog.open = true
}

// ── Helpers ───────────────────────────────────────────────────
function statusLabel(status: string): string {
  return { confirmed: 'Confirmado', cancelled: 'Cancelado', checked_in: 'Asistió' }[status] ?? status
}

function formatDate(dateStr: string): string {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('es-PE', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  })
}

onMounted(fetchRegistrations)
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
