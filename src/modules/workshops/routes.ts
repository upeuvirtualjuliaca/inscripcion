import type { RouteRecordRaw } from 'vue-router'
import AdminLayout from '@/layouts/AdminLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      {
        path: 'especialidades',
        name: 'admin.especialidades',
        component: () => import('./views/SpecialtiesView.vue'),
        meta: { title: 'Especialidades' },
      },
      {
        path: 'talleres',
        name: 'admin.talleres',
        component: () => import('./views/WorkshopsView.vue'),
        meta: { title: 'Talleres' },
      },
    ],
  },
]

export default routes
