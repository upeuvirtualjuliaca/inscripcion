<template>
  <div v-if="modelValue" class="fixed inset-0 z-50 flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="$emit('update:modelValue', false)"></div>

    <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden flex flex-col" style="max-height: 90vh;">

      <!-- Header -->
      <div class="flex items-center justify-between px-6 py-4 shrink-0" style="background-color: #003366;">
        <div class="flex items-center gap-3">
          <div class="w-8 h-8 rounded-full flex items-center justify-center" style="background-color: rgba(255,255,255,0.15);">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
              <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
            </svg>
          </div>
          <h2 class="text-white font-bold text-base">Editar Inscripción</h2>
        </div>
        <button @click="$emit('update:modelValue', false)"
          class="w-8 h-8 rounded-full flex items-center justify-center"
          style="background-color: rgba(255,255,255,0.1);"
          onmouseover="this.style.backgroundColor='rgba(255,255,255,0.2)'"
          onmouseout="this.style.backgroundColor='rgba(255,255,255,0.1)'">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>

      <!-- Body -->
      <div class="overflow-y-auto flex-1 p-6 space-y-5">

        <!-- Registration summary (read-only) -->
        <div class="rounded-xl p-4" style="background-color: #f8fafc; border: 1px solid #e2e8f0;">
          <p class="text-xs font-bold uppercase tracking-widest mb-2" style="color: #003366;">Taller</p>
          <p class="font-semibold text-gray-800 text-sm">{{ registration?.workshop?.name }}</p>
          <div class="flex items-center gap-2 mt-1">
            <span v-if="registration?.workshop?.specialty" class="text-xs font-bold px-2 py-0.5 rounded-full text-white"
              :style="`background-color: ${registration.workshop.specialty.color}`">
              {{ registration.workshop.specialty.name }}
            </span>
            <span class="text-xs text-gray-500">
              {{ registration?.shift?.shift_name || `Turno ${registration?.shift?.shift_number}` }}
              <template v-if="registration?.shift?.start_time && registration?.shift?.end_time">
                · {{ registration.shift.start_time.slice(0,5) }} – {{ registration.shift.end_time.slice(0,5) }}
              </template>
            </span>
          </div>
          <div class="mt-2 flex items-center gap-3 text-xs text-gray-500">
            <span>Código: <span class="font-mono font-semibold text-gray-700">{{ registration?.confirmation_code }}</span></span>
            <span>Nº {{ registration?.registration_number }}</span>
          </div>
        </div>

        <!-- Participant fields -->
        <div>
          <p class="text-xs font-bold uppercase tracking-widest mb-3" style="color: #003366;">Datos del Participante</p>

          <div class="grid grid-cols-2 gap-3">
            <div class="col-span-2">
              <label class="text-xs font-semibold text-gray-600 mb-1 block">DNI</label>
              <input type="text" :value="registration?.participant?.dni" disabled
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm bg-gray-50 text-gray-500" />
            </div>
            <div>
              <label class="text-xs font-semibold text-gray-600 mb-1 block">Nombres *</label>
              <input type="text" v-model="form.first_name"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]" />
            </div>
            <div>
              <label class="text-xs font-semibold text-gray-600 mb-1 block">Apellidos *</label>
              <input type="text" v-model="form.last_name"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]" />
            </div>
            <div class="col-span-2">
              <label class="text-xs font-semibold text-gray-600 mb-1 block">Correo</label>
              <input type="email" v-model="form.email"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]" />
            </div>
            <div>
              <label class="text-xs font-semibold text-gray-600 mb-1 block">Celular</label>
              <input type="tel" v-model="form.phone"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]" />
            </div>
            <div>
              <label class="text-xs font-semibold text-gray-600 mb-1 block">Institución</label>
              <input type="text" v-model="form.institution"
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]" />
            </div>
            <div class="col-span-2">
              <label class="text-xs font-semibold text-gray-600 mb-1 block">Notas internas</label>
              <textarea v-model="form.notes" rows="2" placeholder="Observaciones del administrador..."
                class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce] resize-none"></textarea>
            </div>
          </div>
        </div>

        <!-- Error -->
        <div v-if="saveError" class="flex items-start gap-2 rounded-lg px-4 py-3"
          style="background-color: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.25);">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <p class="text-sm" style="color: #dc2626;">{{ saveError }}</p>
        </div>
      </div>

      <!-- Footer -->
      <div class="px-6 py-4 shrink-0 flex justify-end gap-3 border-t border-gray-100">
        <button @click="$emit('update:modelValue', false)"
          class="px-5 py-2 rounded-lg text-sm font-semibold border border-gray-200 text-gray-600 hover:bg-gray-50 transition-colors duration-150">
          Cancelar
        </button>
        <button @click="save" :disabled="saving"
          class="px-5 py-2 rounded-lg text-sm font-semibold text-white transition-colors duration-150 flex items-center gap-2"
          style="background-color: #003366;"
          onmouseover="if(!this.disabled) this.style.backgroundColor='#004d99'"
          onmouseout="this.style.backgroundColor='#003366'">
          <svg v-if="saving" class="animate-spin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/><path d="M21 12a9 9 0 00-9-9"/>
          </svg>
          {{ saving ? 'Guardando...' : 'Guardar cambios' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { useRegistrations, type AdminRegistration } from '../composables/useRegistrations'

const props = defineProps<{
  modelValue: boolean
  registration: AdminRegistration | null
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'saved': []
}>()

const { updateParticipant, updateNotes } = useRegistrations()

const saving = ref(false)
const saveError = ref<string | null>(null)

const form = ref({
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  institution: '',
  notes: '',
})

watch(() => props.registration, (reg) => {
  if (reg) {
    form.value = {
      first_name: reg.participant.first_name ?? '',
      last_name: reg.participant.last_name ?? '',
      email: reg.participant.email ?? '',
      phone: reg.participant.phone ?? '',
      institution: reg.participant.institution ?? '',
      notes: reg.notes ?? '',
    }
    saveError.value = null
  }
}, { immediate: true })

async function save() {
  if (!props.registration) return
  saving.value = true
  saveError.value = null
  try {
    await updateParticipant(props.registration.participant.id, {
      first_name: form.value.first_name,
      last_name:  form.value.last_name,
      email:      form.value.email,
      phone:      form.value.phone,
      institution: form.value.institution,
    })
    await updateNotes(props.registration.id, form.value.notes)
    emit('saved')
    emit('update:modelValue', false)
  } catch (e: any) {
    saveError.value = e.message
  } finally {
    saving.value = false
  }
}
</script>
