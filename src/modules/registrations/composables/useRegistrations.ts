import { ref } from 'vue'
import { supabase } from '@/core/supabase'

export interface AdminRegistration {
  id: string
  registration_number: number
  confirmation_code: string
  status: string
  registration_date: string
  checked_in_at: string | null
  notes: string | null
  participant: {
    id: string
    dni: string
    first_name: string
    last_name: string
    email: string | null
    phone: string | null
    institution: string | null
  }
  workshop: {
    id: string
    name: string
    specialty: { name: string; color: string } | null
  }
  shift: {
    id: string
    shift_name: string | null
    shift_number: number
    start_time: string | null
    end_time: string | null
  }
}

export function useRegistrations() {
  const registrations = ref<AdminRegistration[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  async function fetchRegistrations() {
    loading.value = true
    error.value = null
    try {
      const { data, error: err } = await supabase
        .from('registrations')
        .select(`
          id,
          registration_number,
          confirmation_code,
          status,
          registration_date,
          checked_in_at,
          notes,
          participant:participants(id, dni, first_name, last_name, email, phone, institution),
          workshop:workshops(id, name, specialty:specialties(name, color)),
          shift:workshop_shifts(id, shift_name, shift_number, start_time, end_time)
        `)
        .is('deleted_at', null)
        .order('registration_date', { ascending: false })

      if (err) throw err
      registrations.value = (data ?? []) as unknown as AdminRegistration[]
    } catch (e: any) {
      error.value = e.message
    } finally {
      loading.value = false
    }
  }

  async function updateParticipant(
    participantId: string,
    fields: { first_name: string; last_name: string; email: string; phone: string; institution: string },
  ): Promise<void> {
    const { error: err } = await supabase
      .from('participants')
      .update(fields)
      .eq('id', participantId)
    if (err) throw new Error(err.message)
  }

  async function updateNotes(registrationId: string, notes: string): Promise<void> {
    const { error: err } = await supabase
      .from('registrations')
      .update({ notes })
      .eq('id', registrationId)
    if (err) throw new Error(err.message)
  }

  async function cancelRegistration(registrationId: string): Promise<void> {
    const { error: err } = await supabase.rpc('cancel_registration', {
      p_registration_id: registrationId,
      p_reason: 'Cancelado por administrador',
    })
    if (err) throw new Error(err.message)
    await fetchRegistrations()
  }

  async function deleteRegistration(registrationId: string): Promise<void> {
    const { error: err } = await supabase
      .from('registrations')
      .update({ deleted_at: new Date().toISOString() })
      .eq('id', registrationId)
    if (err) throw new Error(err.message)
    registrations.value = registrations.value.filter(r => r.id !== registrationId)
  }

  return {
    registrations,
    loading,
    error,
    fetchRegistrations,
    updateParticipant,
    updateNotes,
    cancelRegistration,
    deleteRegistration,
  }
}
