import { ref } from 'vue'
import { supabase } from '@/core/supabase'
import type { Specialty } from '../types'

const specialties = ref<Specialty[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

async function fetchSpecialties(): Promise<void> {
  loading.value = true
  error.value = null
  try {
    const { data, error: sbError } = await supabase
      .from('specialties')
      .select('*')
      .is('deleted_at', null)
      .order('sort_order', { ascending: true })

    if (sbError) throw sbError
    specialties.value = data ?? []
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al cargar especialidades'
  } finally {
    loading.value = false
  }
}

async function createSpecialty(data: Partial<Specialty>): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('specialties')
      .insert({
        name: data.name,
        description: data.description ?? null,
        color: data.color ?? '#51a0ce',
        sort_order: data.sort_order ?? (specialties.value.length + 1),
        status: data.status ?? 'active',
        is_visible: data.is_visible ?? true,
      })
    if (sbError) throw sbError
    await fetchSpecialties()
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al crear especialidad'
    throw e
  }
}

async function updateSpecialty(id: string, data: Partial<Specialty>): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('specialties')
      .update({ ...data, updated_at: new Date().toISOString() })
      .eq('id', id)
    if (sbError) throw sbError
    await fetchSpecialties()
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al actualizar especialidad'
    throw e
  }
}

async function toggleStatus(s: Specialty): Promise<void> {
  const newStatus: Specialty['status'] = s.status === 'active' ? 'inactive' : 'active'
  await updateSpecialty(s.id, { status: newStatus })
}

async function toggleVisibility(s: Specialty): Promise<void> {
  await updateSpecialty(s.id, { is_visible: !s.is_visible })
}

async function moveSortOrder(s: Specialty, direction: 'up' | 'down'): Promise<void> {
  const list = [...specialties.value]
  const idx = list.findIndex(x => x.id === s.id)
  if (idx === -1) return

  const targetIdx = direction === 'up' ? idx - 1 : idx + 1
  if (targetIdx < 0 || targetIdx >= list.length) return

  const current = list[idx]
  const target = list[targetIdx]

  const currentOrder = current.sort_order
  const targetOrder = target.sort_order

  error.value = null
  try {
    const { error: e1 } = await supabase
      .from('specialties')
      .update({ sort_order: targetOrder, updated_at: new Date().toISOString() })
      .eq('id', current.id)
    if (e1) throw e1

    const { error: e2 } = await supabase
      .from('specialties')
      .update({ sort_order: currentOrder, updated_at: new Date().toISOString() })
      .eq('id', target.id)
    if (e2) throw e2

    await fetchSpecialties()
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al reordenar especialidad'
    throw e
  }
}

async function deleteSpecialty(id: string): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('specialties')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', id)
    if (sbError) throw sbError
    await fetchSpecialties()
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al eliminar especialidad'
    throw e
  }
}

export function useSpecialties() {
  return {
    specialties,
    loading,
    error,
    fetchSpecialties,
    createSpecialty,
    updateSpecialty,
    toggleStatus,
    toggleVisibility,
    moveSortOrder,
    deleteSpecialty,
  }
}
