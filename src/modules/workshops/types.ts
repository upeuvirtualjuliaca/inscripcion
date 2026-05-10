export interface Specialty {
  id: string
  name: string
  description: string | null
  color: string | null
  sort_order: number
  status: 'active' | 'inactive'
  is_visible: boolean
  created_at: string
  updated_at: string
}

export interface WorkshopShift {
  id: string
  workshop_id: string
  shift_name: string
  shift_number: 1 | 2
  start_time: string
  end_time: string
  capacity: number
  registered_count: number
  status: 'open' | 'full' | 'closed'
}

export interface Workshop {
  id: string
  specialty_id: string
  name: string
  speaker: string | null
  description: string | null
  location: string | null
  image_url: string | null
  image_position: string
  image_scale: number
  workshop_date: string | null
  notes: string | null
  status: 'available' | 'full' | 'closed' | 'hidden'
  is_visible: boolean
  sort_order: number
  shifts?: WorkshopShift[]
  specialty?: Pick<Specialty, 'id' | 'name' | 'color'>
}

export type WorkshopStatus = Workshop['status']
export type SpecialtyStatus = Specialty['status']
