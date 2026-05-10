<script setup lang="ts">
import { ref, watch, computed, onMounted, onUnmounted } from 'vue'
import { useWorkshops } from '../composables/useWorkshops'
import type { Workshop, Specialty, WorkshopShift } from '../types'

const props = defineProps<{
  modelValue: boolean
  workshop: Workshop | null
  specialties: Specialty[]
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', val: boolean): void
  (e: 'saved'): void
}>()

const { createWorkshop, updateWorkshop, upsertShift } = useWorkshops()

const saving = ref(false)
const formError = ref<string | null>(null)

interface ShiftForm {
  id?: string
  shift_name: string
  start_time: string
  end_time: string
  capacity: number | ''
  status: 'open' | 'closed'
}

const form = ref({
  specialty_id: '',
  name: '',
  speaker: '',
  description: '',
  location: '',
  workshop_date: '',
  image_url: '',
  image_position: 'center',
  image_scale: 1.0,
  status: 'available' as 'available' | 'closed' | 'hidden',
  is_visible: true,
  notes: '',
})

const shift1 = ref<ShiftForm>({
  shift_name: '1 Turno',
  start_time: '',
  end_time: '',
  capacity: '',
  status: 'open',
})

const shift2 = ref<ShiftForm>({
  shift_name: '2 Turno',
  start_time: '',
  end_time: '',
  capacity: '',
  status: 'open',
})

// ── Drag-to-position state ──────────────────────────────────────────────────
const previewContainer = ref<HTMLDivElement | null>(null)
const isDragging = ref(false)
const imgOriginX = ref(50)
const imgOriginY = ref(50)
let dragStartX = 0
let dragStartY = 0
let dragStartOriginX = 0
let dragStartOriginY = 0

function parsePosition(pos: string): { x: number; y: number } {
  const parts = pos.trim().split(/\s+/)
  if (parts.length === 2) {
    const x = parseFloat(parts[0])
    const y = parseFloat(parts[1])
    if (!isNaN(x) && !isNaN(y)) return { x, y }
  }
  return { x: 50, y: 50 }
}

function syncOrigin() {
  const { x, y } = parsePosition(form.value.image_position)
  imgOriginX.value = x
  imgOriginY.value = y
}

function startDrag(e: MouseEvent) {
  e.preventDefault()
  isDragging.value = true
  dragStartX = e.clientX
  dragStartY = e.clientY
  dragStartOriginX = imgOriginX.value
  dragStartOriginY = imgOriginY.value
}

function onDrag(e: MouseEvent) {
  if (!isDragging.value || !previewContainer.value) return
  const rect = previewContainer.value.getBoundingClientRect()
  const deltaX = e.clientX - dragStartX
  const deltaY = e.clientY - dragStartY
  // Drag right → image moves right → shows left side (X decreases) → minus deltaX
  // Drag up   → image moves up   → shows top  side (Y decreases) → plus deltaY (negative screen Y)
  const sensitivity = 1.5
  imgOriginX.value = Math.min(100, Math.max(0, dragStartOriginX - (deltaX / rect.width)  * 100 * sensitivity))
  imgOriginY.value = Math.min(100, Math.max(0, dragStartOriginY + (deltaY / rect.height) * 100 * sensitivity))
}

function stopDrag() {
  if (!isDragging.value) return
  isDragging.value = false
  form.value.image_position = `${imgOriginX.value.toFixed(1)} ${imgOriginY.value.toFixed(1)}`
}

onMounted(() => {
  window.addEventListener('mousemove', onDrag)
  window.addEventListener('mouseup', stopDrag)
})

onUnmounted(() => {
  window.removeEventListener('mousemove', onDrag)
  window.removeEventListener('mouseup', stopDrag)
})
// ────────────────────────────────────────────────────────────────────────────

const isEdit = computed(() => props.workshop !== null)
const title = computed(() => isEdit.value ? 'Editar Taller' : 'Nuevo Taller')

function getShiftByNumber(shifts: WorkshopShift[] | undefined, num: 1 | 2): WorkshopShift | undefined {
  return shifts?.find(s => s.shift_number === num)
}

watch(
  () => props.modelValue,
  (open) => {
    if (open) {
      formError.value = null

      if (props.workshop) {
        const w = props.workshop
        form.value = {
          specialty_id: w.specialty_id,
          name: w.name,
          speaker: w.speaker ?? '',
          description: w.description ?? '',
          location: w.location ?? '',
          workshop_date: w.workshop_date ?? '',
          image_url: w.image_url ?? '',
          image_position: w.image_position ?? '50 50',
          image_scale: w.image_scale ?? 1.0,
          status: (w.status === 'full' ? 'available' : w.status) as 'available' | 'closed' | 'hidden',
          is_visible: w.is_visible,
          notes: w.notes ?? '',
        }

        syncOrigin()

        const s1 = getShiftByNumber(w.shifts, 1)
        shift1.value = {
          id: s1?.id,
          shift_name: s1?.shift_name ?? '1 Turno',
          start_time: s1?.start_time ?? '',
          end_time: s1?.end_time ?? '',
          capacity: s1?.capacity ?? '',
          status: (s1?.status === 'full' ? 'closed' : (s1?.status ?? 'open')) as 'open' | 'closed',
        }

        const s2 = getShiftByNumber(w.shifts, 2)
        shift2.value = {
          id: s2?.id,
          shift_name: s2?.shift_name ?? '2 Turno',
          start_time: s2?.start_time ?? '',
          end_time: s2?.end_time ?? '',
          capacity: s2?.capacity ?? '',
          status: (s2?.status === 'full' ? 'closed' : (s2?.status ?? 'open')) as 'open' | 'closed',
        }
      } else {
        form.value = {
          specialty_id: props.specialties[0]?.id ?? '',
          name: '',
          speaker: '',
          description: '',
          location: '',
          workshop_date: '',
          image_url: '',
          image_position: '50 50',
          image_scale: 1.0,
          status: 'available',
          is_visible: true,
          notes: '',
        }
        imgOriginX.value = 50
        imgOriginY.value = 50
        shift1.value = { shift_name: '1 Turno', start_time: '', end_time: '', capacity: '', status: 'open' }
        shift2.value = { shift_name: '2 Turno', start_time: '', end_time: '', capacity: '', status: 'open' }
      }
    }
  }
)

function shiftHasData(s: ShiftForm): boolean {
  return !!(s.start_time && s.end_time)
}

function close() {
  emit('update:modelValue', false)
}

async function submit() {
  if (!form.value.specialty_id) {
    formError.value = 'Debe seleccionar una especialidad.'
    return
  }
  if (!form.value.name.trim()) {
    formError.value = 'El nombre del taller es obligatorio.'
    return
  }

  saving.value = true
  formError.value = null

  try {
    let workshopId: string

    const payload: Partial<Workshop> = {
      specialty_id: form.value.specialty_id,
      name: form.value.name.trim(),
      speaker: form.value.speaker.trim() || null,
      description: form.value.description.trim() || null,
      location: form.value.location.trim() || null,
      workshop_date: form.value.workshop_date || null,
      image_url: form.value.image_url.trim() || null,
      image_position: form.value.image_position,
      image_scale: form.value.image_scale,
      status: form.value.status,
      is_visible: form.value.is_visible,
      notes: form.value.notes.trim() || null,
    }

    if (isEdit.value && props.workshop) {
      await updateWorkshop(props.workshop.id, payload)
      workshopId = props.workshop.id
    } else {
      const created = await createWorkshop(payload)
      workshopId = created.id
    }

    // Upsert shifts if they have data
    if (shiftHasData(shift1.value)) {
      await upsertShift(workshopId, {
        shift_name: shift1.value.shift_name,
        shift_number: 1,
        start_time: shift1.value.start_time,
        end_time: shift1.value.end_time,
        capacity: shift1.value.capacity === '' ? 0 : Number(shift1.value.capacity),
        status: shift1.value.status,
      })
    }

    if (shiftHasData(shift2.value)) {
      await upsertShift(workshopId, {
        shift_name: shift2.value.shift_name,
        shift_number: 2,
        start_time: shift2.value.start_time,
        end_time: shift2.value.end_time,
        capacity: shift2.value.capacity === '' ? 0 : Number(shift2.value.capacity),
        status: shift2.value.status,
      })
    }

    emit('saved')
    close()
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : 'Error al guardar el taller'
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="modelValue"
      class="fixed inset-0 z-50 flex items-center justify-center p-4"
      style="background-color: rgba(0,0,0,0.5);"
      @click.self="close"
    >
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-2xl flex flex-col max-h-[90vh]">

        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-200 flex-shrink-0">
          <h2 class="text-lg font-semibold" style="color: #003366;">{{ title }}</h2>
          <button
            type="button"
            class="text-gray-400 hover:text-gray-600 transition-colors"
            @click="close"
          >
            <svg class="w-5 h-5" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>

        <!-- Scrollable body -->
        <div class="overflow-y-auto flex-1">
          <form class="px-6 py-5 space-y-6" @submit.prevent="submit">

            <!-- Error -->
            <div
              v-if="formError"
              class="px-4 py-3 rounded-lg text-sm bg-red-50 text-red-700 border border-red-200"
            >
              {{ formError }}
            </div>

            <!-- Section 1: Informacion del taller -->
            <div>
              <h3 class="text-sm font-semibold uppercase tracking-wide mb-4" style="color: #003366;">
                Informacion del taller
              </h3>
              <div class="space-y-4">

                <!-- Especialidad -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    Especialidad <span class="text-red-500">*</span>
                  </label>
                  <select
                    v-model="form.specialty_id"
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 bg-white"
                  >
                    <option value="" disabled>Seleccionar especialidad...</option>
                    <option v-for="sp in specialties" :key="sp.id" :value="sp.id">
                      {{ sp.name }}
                    </option>
                  </select>
                </div>

                <!-- Nombre -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">
                    Nombre <span class="text-red-500">*</span>
                  </label>
                  <input
                    v-model="form.name"
                    type="text"
                    required
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                    placeholder="Nombre del taller"
                  />
                </div>

                <!-- Ponente -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Ponente</label>
                  <input
                    v-model="form.speaker"
                    type="text"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                    placeholder="Nombre del ponente"
                  />
                </div>

                <!-- Imagen -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">URL de imagen</label>
                  <input
                    v-model="form.image_url"
                    type="url"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                    placeholder="https://ejemplo.com/imagen.jpg"
                  />
                  <!-- Preview + controls -->
                  <div v-if="form.image_url" class="mt-2 space-y-2">

                    <!-- Draggable image preview -->
                    <div
                      ref="previewContainer"
                      class="relative rounded-lg overflow-hidden border border-gray-200 select-none"
                      style="height: 140px;"
                      :style="{ cursor: isDragging ? 'grabbing' : 'grab' }"
                      @mousedown="startDrag"
                    >
                      <img
                        :src="form.image_url"
                        alt="Preview"
                        class="w-full h-full object-cover pointer-events-none"
                        :style="`object-position: ${imgOriginX}% ${imgOriginY}%; transform: scale(${form.image_scale}); transform-origin: center; transition: ${isDragging ? 'none' : 'object-position 0.1s ease, transform 0.15s ease'};`"
                        @error="($event.target as HTMLImageElement).style.display='none'"
                      />
                      <div
                        class="absolute inset-0 flex items-center justify-center text-xs text-gray-400 bg-gray-50"
                        style="z-index: -1;"
                      >
                        Vista previa no disponible
                      </div>
                      <!-- Drag hint -->
                      <div
                        v-if="!isDragging"
                        class="absolute bottom-1.5 left-1/2 -translate-x-1/2 text-xs text-white/80 rounded px-2 py-0.5 pointer-events-none"
                        style="background: rgba(0,0,0,0.35);"
                      >
                        Arrastra para ajustar posición
                      </div>
                    </div>

                    <!-- Zoom controls -->
                    <div class="flex items-center gap-1.5">
                      <span class="text-xs text-gray-400 shrink-0">Zoom</span>
                      <button type="button"
                        class="w-7 h-7 rounded-lg border border-gray-200 flex items-center justify-center text-gray-600 hover:bg-gray-100 transition-colors duration-100 text-base font-bold disabled:opacity-30"
                        :disabled="form.image_scale <= 1.0"
                        @click="form.image_scale = Math.max(1.0, +(form.image_scale - 0.1).toFixed(1))">
                        −
                      </button>
                      <span class="text-xs font-mono w-8 text-center text-gray-700">{{ form.image_scale.toFixed(1) }}×</span>
                      <button type="button"
                        class="w-7 h-7 rounded-lg border border-gray-200 flex items-center justify-center text-gray-600 hover:bg-gray-100 transition-colors duration-100 text-base font-bold disabled:opacity-30"
                        :disabled="form.image_scale >= 3.0"
                        @click="form.image_scale = Math.min(3.0, +(form.image_scale + 0.1).toFixed(1))">
                        +
                      </button>
                      <span class="ml-2 text-xs text-gray-400">← Arrastra la imagen para encuadrar</span>
                    </div>

                  </div>
                </div>

                <!-- Descripcion -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Descripcion</label>
                  <textarea
                    v-model="form.description"
                    rows="3"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 resize-none"
                    placeholder="Descripcion del taller"
                  />
                </div>

                <!-- Ubicacion + Fecha (2 cols) -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Ubicacion</label>
                    <input
                      v-model="form.location"
                      type="text"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                      placeholder="Salon, auditorio..."
                    />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Fecha</label>
                    <input
                      v-model="form.workshop_date"
                      type="date"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                    />
                  </div>
                </div>

                <!-- Estado + Visible (2 cols) -->
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 items-end">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Estado</label>
                    <select
                      v-model="form.status"
                      class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 bg-white"
                    >
                      <option value="available">Disponible</option>
                      <option value="closed">Cerrado</option>
                      <option value="hidden">Oculto</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">Visible</label>
                    <div class="flex items-center gap-3">
                      <button
                        type="button"
                        class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none"
                        :style="{ backgroundColor: form.is_visible ? '#003366' : '#d1d5db' }"
                        @click="form.is_visible = !form.is_visible"
                      >
                        <span
                          class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform"
                          :class="form.is_visible ? 'translate-x-6' : 'translate-x-1'"
                        />
                      </button>
                      <span class="text-sm text-gray-700">{{ form.is_visible ? 'Visible' : 'Oculto' }}</span>
                    </div>
                  </div>
                </div>

                <!-- Notas internas -->
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">Notas internas</label>
                  <textarea
                    v-model="form.notes"
                    rows="2"
                    class="w-full px-3 py-2 border border-gray-300 rounded-lg text-xs focus:outline-none focus:ring-2 resize-none text-gray-500"
                    placeholder="Notas de uso interno, no visibles al publico"
                  />
                </div>

              </div>
            </div>

            <!-- Divider -->
            <hr class="border-gray-200" />

            <!-- Section 2: Turnos -->
            <div>
              <h3 class="text-sm font-semibold uppercase tracking-wide mb-4" style="color: #003366;">
                Turnos
              </h3>
              <div class="space-y-5">

                <!-- Turno 1 -->
                <div class="border border-gray-200 rounded-lg p-4">
                  <h4 class="text-sm font-semibold text-gray-700 mb-3">Turno 1</h4>
                  <div class="space-y-3">
                    <div>
                      <label class="block text-xs font-medium text-gray-600 mb-1">Nombre del turno</label>
                      <input
                        v-model="shift1.shift_name"
                        type="text"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                      />
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Hora inicio</label>
                        <input
                          v-model="shift1.start_time"
                          type="time"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                        />
                      </div>
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Hora fin</label>
                        <input
                          v-model="shift1.end_time"
                          type="time"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                        />
                      </div>
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Capacidad</label>
                        <input
                          v-model.number="shift1.capacity"
                          type="number"
                          min="1"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                          placeholder="0"
                        />
                      </div>
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Estado del turno</label>
                        <select
                          v-model="shift1.status"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 bg-white"
                        >
                          <option value="open">Abierto</option>
                          <option value="closed">Cerrado</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Turno 2 -->
                <div class="border border-gray-200 rounded-lg p-4">
                  <h4 class="text-sm font-semibold text-gray-700 mb-3">Turno 2</h4>
                  <div class="space-y-3">
                    <div>
                      <label class="block text-xs font-medium text-gray-600 mb-1">Nombre del turno</label>
                      <input
                        v-model="shift2.shift_name"
                        type="text"
                        class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                      />
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Hora inicio</label>
                        <input
                          v-model="shift2.start_time"
                          type="time"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                        />
                      </div>
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Hora fin</label>
                        <input
                          v-model="shift2.end_time"
                          type="time"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                        />
                      </div>
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Capacidad</label>
                        <input
                          v-model.number="shift2.capacity"
                          type="number"
                          min="1"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2"
                          placeholder="0"
                        />
                      </div>
                      <div>
                        <label class="block text-xs font-medium text-gray-600 mb-1">Estado del turno</label>
                        <select
                          v-model="shift2.status"
                          class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 bg-white"
                        >
                          <option value="open">Abierto</option>
                          <option value="closed">Cerrado</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>

              </div>
            </div>

          </form>
        </div>

        <!-- Footer -->
        <div class="flex items-center justify-end gap-3 px-6 py-4 border-t border-gray-200 flex-shrink-0">
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
            :disabled="saving"
            @click="close"
          >
            Cancelar
          </button>
          <button
            type="button"
            class="px-4 py-2 text-sm font-medium text-white rounded-lg transition-colors disabled:opacity-60"
            style="background-color: #003366;"
            :disabled="saving"
            @click="submit"
            @mouseover="($event.target as HTMLElement).style.backgroundColor = '#51a0ce'"
            @mouseleave="($event.target as HTMLElement).style.backgroundColor = saving ? '' : '#003366'"
          >
            <span v-if="saving" class="flex items-center gap-2">
              <svg class="animate-spin h-4 w-4" viewBox="0 0 24 24" fill="none">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"/>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"/>
              </svg>
              Guardando...
            </span>
            <span v-else>Guardar</span>
          </button>
        </div>

      </div>
    </div>
  </Teleport>
</template>
