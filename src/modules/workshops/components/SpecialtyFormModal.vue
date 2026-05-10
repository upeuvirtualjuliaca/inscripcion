<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useSpecialties } from '../composables/useSpecialties'
import type { Specialty } from '../types'

const props = defineProps<{
  modelValue: boolean
  specialty: Specialty | null
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', val: boolean): void
  (e: 'saved'): void
}>()

const { createSpecialty, updateSpecialty } = useSpecialties()

const saving = ref(false)
const formError = ref<string | null>(null)

const form = ref({
  name: '',
  description: '',
  color: '#51a0ce',
  status: 'active' as Specialty['status'],
})

const isEdit = computed(() => props.specialty !== null)
const title = computed(() => isEdit.value ? 'Editar Especialidad' : 'Nueva Especialidad')

watch(
  () => props.modelValue,
  (open) => {
    if (open) {
      formError.value = null
      if (props.specialty) {
        form.value = {
          name: props.specialty.name,
          description: props.specialty.description ?? '',
          color: props.specialty.color ?? '#51a0ce',
          status: props.specialty.status,
        }
      } else {
        form.value = {
          name: '',
          description: '',
          color: '#51a0ce',
          status: 'active',
        }
      }
    }
  }
)

function close() {
  emit('update:modelValue', false)
}

async function submit() {
  if (!form.value.name.trim()) {
    formError.value = 'El nombre es obligatorio.'
    return
  }

  saving.value = true
  formError.value = null

  try {
    const payload: Partial<Specialty> = {
      name: form.value.name.trim(),
      description: form.value.description.trim() || null,
      color: form.value.color,
      status: form.value.status,
    }

    if (isEdit.value && props.specialty) {
      await updateSpecialty(props.specialty.id, payload)
    } else {
      await createSpecialty(payload)
    }

    emit('saved')
    close()
  } catch (e: unknown) {
    formError.value = e instanceof Error ? e.message : 'Error al guardar'
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
      <div class="bg-white rounded-xl shadow-2xl w-full max-w-md flex flex-col">

        <!-- Header -->
        <div
          class="flex items-center justify-between px-6 py-4 border-b border-gray-200"
        >
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

        <!-- Body -->
        <form class="px-6 py-5 space-y-4" @submit.prevent="submit">

          <!-- Error -->
          <div
            v-if="formError"
            class="px-4 py-3 rounded-lg text-sm bg-red-50 text-red-700 border border-red-200"
          >
            {{ formError }}
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
              class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:border-transparent"
              style="--tw-ring-color: #51a0ce;"
              placeholder="Nombre de la especialidad"
            />
          </div>

          <!-- Descripcion -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Descripcion</label>
            <textarea
              v-model="form.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:border-transparent resize-none"
              style="--tw-ring-color: #51a0ce;"
              placeholder="Descripcion opcional"
            />
          </div>

          <!-- Color -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Color</label>
            <div class="flex items-center gap-3">
              <input
                v-model="form.color"
                type="color"
                class="h-10 w-16 cursor-pointer rounded border border-gray-300 p-0.5"
              />
              <span
                class="text-sm font-mono px-3 py-2 bg-gray-50 border border-gray-200 rounded-lg"
                :style="{ color: form.color }"
              >{{ form.color }}</span>
              <div
                class="h-8 w-8 rounded-full border border-gray-200 flex-shrink-0"
                :style="{ backgroundColor: form.color }"
              />
            </div>
          </div>

          <!-- Estado toggle -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Estado</label>
            <div class="flex items-center gap-3">
              <button
                type="button"
                class="relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none"
                :style="{ backgroundColor: form.status === 'active' ? '#003366' : '#d1d5db' }"
                @click="form.status = form.status === 'active' ? 'inactive' : 'active'"
              >
                <span
                  class="inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform"
                  :class="form.status === 'active' ? 'translate-x-6' : 'translate-x-1'"
                />
              </button>
              <span class="text-sm text-gray-700">
                {{ form.status === 'active' ? 'Activa' : 'Inactiva' }}
              </span>
            </div>
          </div>

        </form>

        <!-- Footer -->
        <div class="flex items-center justify-end gap-3 px-6 py-4 border-t border-gray-200">
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
