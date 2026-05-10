import type { RouteRecordRaw } from 'vue-router'
import AdminLayout from '@/layouts/AdminLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      {
        path: 'inscripciones',
        name: 'admin.inscripciones',
        component: () => import('./views/RegistrationsView.vue'),
        meta: { title: 'Inscripciones' },
      },
    ],
  },
]

export default routes
