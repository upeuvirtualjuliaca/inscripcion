import { ref } from 'vue'
import { supabase } from '@/core/supabase'
import type { Workshop, WorkshopShift, WorkshopStatus } from '../types'

const workshops = ref<Workshop[]>([])
const loading = ref(false)
const error = ref<string | null>(null)

let lastSpecialtyId: string | undefined = undefined

async function fetchWorkshops(specialtyId?: string): Promise<void> {
  lastSpecialtyId = specialtyId
  loading.value = true
  error.value = null
  try {
    let query = supabase
      .from('workshops')
      .select(`*, shifts:workshop_shifts(*), specialty:specialties(id,name,color)`)
      .is('deleted_at', null)
      .order('sort_order', { ascending: true })

    if (specialtyId) {
      query = query.eq('specialty_id', specialtyId)
    }

    const { data, error: sbError } = await query
    if (sbError) throw sbError
    workshops.value = (data ?? []) as Workshop[]
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al cargar talleres'
  } finally {
    loading.value = false
  }
}

async function createWorkshop(data: Partial<Workshop>): Promise<Workshop> {
  error.value = null
  try {
    const { data: inserted, error: sbError } = await supabase
      .from('workshops')
      .insert({
        specialty_id: data.specialty_id,
        name: data.name,
        speaker: data.speaker ?? null,
        description: data.description ?? null,
        location: data.location ?? null,
        image_url: data.image_url ?? null,
        workshop_date: data.workshop_date ?? null,
        notes: data.notes ?? null,
        status: data.status ?? 'available',
        is_visible: data.is_visible ?? true,
        sort_order: data.sort_order ?? (workshops.value.length + 1),
      })
      .select()
      .single()

    if (sbError) throw sbError
    await fetchWorkshops(lastSpecialtyId)
    return inserted as Workshop
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al crear taller'
    throw e
  }
}

async function updateWorkshop(id: string, data: Partial<Workshop>): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('workshops')
      .update({ ...data, updated_at: new Date().toISOString() })
      .eq('id', id)
    if (sbError) throw sbError
    await fetchWorkshops(lastSpecialtyId)
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al actualizar taller'
    throw e
  }
}

async function duplicateWorkshop(w: Workshop): Promise<void> {
  error.value = null
  try {
    const { data: inserted, error: sbError } = await supabase
      .from('workshops')
      .insert({
        specialty_id: w.specialty_id,
        name: `Copia de ${w.name}`,
        speaker: w.speaker,
        description: w.description,
        location: w.location,
        image_url: w.image_url,
        workshop_date: w.workshop_date,
        notes: w.notes,
        status: w.status,
        is_visible: w.is_visible,
        sort_order: w.sort_order + 1,
      })
      .select()
      .single()

    if (sbError) throw sbError

    // Duplicate shifts without registered_count
    if (w.shifts && w.shifts.length > 0 && inserted) {
      const newWorkshopId = (inserted as Workshop).id
      for (const shift of w.shifts) {
        await supabase.from('workshop_shifts').insert({
          workshop_id: newWorkshopId,
          shift_name: shift.shift_name,
          shift_number: shift.shift_number,
          start_time: shift.start_time,
          end_time: shift.end_time,
          capacity: shift.capacity,
          registered_count: 0,
          status: shift.status === 'full' ? 'open' : shift.status,
        })
      }
    }

    await fetchWorkshops(lastSpecialtyId)
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al duplicar taller'
    throw e
  }
}

async function setStatus(id: string, status: WorkshopStatus): Promise<void> {
  await updateWorkshop(id, { status })
}

async function toggleVisibility(w: Workshop): Promise<void> {
  await updateWorkshop(w.id, { is_visible: !w.is_visible })
}

async function deleteWorkshop(id: string): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('workshops')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', id)
    if (sbError) throw sbError
    await fetchWorkshops(lastSpecialtyId)
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al eliminar taller'
    throw e
  }
}

async function upsertShift(workshopId: string, shift: Partial<WorkshopShift>): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('workshop_shifts')
      .upsert(
        {
          workshop_id: workshopId,
          shift_name: shift.shift_name,
          shift_number: shift.shift_number,
          start_time: shift.start_time,
          end_time: shift.end_time,
          capacity: shift.capacity,
          registered_count: shift.registered_count ?? 0,
          status: shift.status ?? 'open',
        },
        { onConflict: 'workshop_id,shift_number' }
      )
    if (sbError) throw sbError
    await fetchWorkshops(lastSpecialtyId)
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al guardar turno'
    throw e
  }
}

async function deleteShift(shiftId: string): Promise<void> {
  error.value = null
  try {
    const { error: sbError } = await supabase
      .from('workshop_shifts')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', shiftId)
    if (sbError) throw sbError
    await fetchWorkshops(lastSpecialtyId)
  } catch (e: unknown) {
    error.value = e instanceof Error ? e.message : 'Error al eliminar turno'
    throw e
  }
}

export function useWorkshops() {
  return {
    workshops,
    loading,
    error,
    fetchWorkshops,
    createWorkshop,
    updateWorkshop,
    duplicateWorkshop,
    setStatus,
    toggleVisibility,
    deleteWorkshop,
    upsertShift,
    deleteShift,
  }
}
