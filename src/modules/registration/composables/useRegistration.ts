import { ref } from 'vue'
import { supabase } from '@/core/supabase'

interface ParticipantForm {
  dni: string
  first_name: string
  last_name: string
  email: string
  phone: string
  institution: string
}

interface RegistrationResult {
  id: string
  registration_number: number
  confirmation_code: string
  participant_id: string
  workshop_id: string
  workshop_shift_id: string
  status: string
}

export interface Student {
  id: string
  documento: string | null
  codigo_estudiante: string | null
  estudiante: string | null
  correo_institucional: string | null
  celular: string | null
  unidad_academica: string | null
  programa_estudio: string | null
}

export function useRegistration() {
  const loading = ref(false)
  const dniStatus = ref<'idle' | 'searching' | 'found' | 'new'>('idle')
  const existingParticipantId = ref<string | null>(null)
  // shift_numbers the participant already has confirmed registrations for (e.g. [1] or [2] or [1,2])
  const usedShiftNumbers = ref<number[]>([])

  async function lookupByDni(dni: string): Promise<ParticipantForm | null> {
    dniStatus.value = 'searching'
    try {
      const { data, error } = await supabase
        .from('participants')
        .select('id, dni, first_name, last_name, email, phone, institution')
        .eq('dni', dni)
        .is('deleted_at', null)
        .maybeSingle()

      if (error) throw error

      if (data) {
        dniStatus.value = 'found'
        existingParticipantId.value = data.id

        // Fetch shift_numbers already used by this participant
        const { data: regs } = await supabase
          .from('registrations')
          .select('workshop_shifts(shift_number)')
          .eq('participant_id', data.id)
          .neq('status', 'cancelled')
          .is('deleted_at', null)

        usedShiftNumbers.value = (regs ?? [])
          .map((r: any) => r.workshop_shifts?.shift_number)
          .filter((n: any) => typeof n === 'number')

        return {
          dni: data.dni ?? '',
          first_name: data.first_name ?? '',
          last_name: data.last_name ?? '',
          email: data.email ?? '',
          phone: data.phone ?? '',
          institution: data.institution ?? '',
        }
      } else {
        dniStatus.value = 'new'
        existingParticipantId.value = null
        usedShiftNumbers.value = []
        return null
      }
    } catch {
      dniStatus.value = 'new'
      existingParticipantId.value = null
      usedShiftNumbers.value = []
      return null
    }
  }

  async function submitRegistration(
    form: ParticipantForm,
    workshopId: string,
    shiftId: string,
  ): Promise<RegistrationResult> {
    loading.value = true
    try {
      let participantId: string

      if (existingParticipantId.value) {
        const { error: updateError } = await supabase
          .from('participants')
          .update({
            first_name: form.first_name,
            last_name: form.last_name,
            email: form.email,
            phone: form.phone,
            institution: form.institution,
          })
          .eq('id', existingParticipantId.value)

        if (updateError) throw updateError
        participantId = existingParticipantId.value
      } else {
        const { data: inserted, error: insertError } = await supabase
          .from('participants')
          .insert({
            dni: form.dni,
            first_name: form.first_name,
            last_name: form.last_name,
            email: form.email,
            phone: form.phone,
            institution: form.institution,
          })
          .select('id')
          .single()

        if (insertError) {
          if (insertError.code === '23505' && insertError.message.includes('participants_dni_active_idx')) {
            throw new Error('Ya existe un participante registrado con ese DNI. Si eres tú, vuelve al paso anterior e ingresa tu DNI para que el sistema recupere tus datos.')
          }
          throw insertError
        }
        participantId = inserted.id
      }

      const { data: rpcData, error: rpcError } = await supabase.rpc('register_participant', {
        p_participant_id: participantId,
        p_workshop_id: workshopId,
        p_workshop_shift_id: shiftId,
      })

      if (rpcError) {
        const msg = rpcError.message ?? ''
        const colonIdx = msg.indexOf(':')
        const humanMessage = colonIdx !== -1 ? msg.slice(colonIdx + 1).trim() : msg
        throw new Error(humanMessage)
      }

      return rpcData as RegistrationResult
    } finally {
      loading.value = false
    }
  }

  async function searchStudents(query: string): Promise<Student[]> {
    if (query.trim().length < 3) return []
    const { data, error } = await supabase
      .from('students')
      .select('id, documento, codigo_estudiante, estudiante, correo_institucional, celular, unidad_academica, programa_estudio')
      .or(`documento.ilike.%${query}%,codigo_estudiante.ilike.%${query}%,estudiante.ilike.%${query}%`)
      .limit(6)
    if (error) return []
    return data ?? []
  }

  function reset() {
    dniStatus.value = 'idle'
    existingParticipantId.value = null
    usedShiftNumbers.value = []
    loading.value = false
  }

  return {
    loading,
    dniStatus,
    existingParticipantId,
    usedShiftNumbers,
    lookupByDni,
    searchStudents,
    submitRegistration,
    reset,
  }
}
