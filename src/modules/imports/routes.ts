import type { RouteRecordRaw } from 'vue-router'
import AdminLayout from '@/layouts/AdminLayout.vue'

const routes: RouteRecordRaw[] = [
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      {
        path: '',
        redirect: '/admin/importaciones',
      },
      {
        path: 'importaciones',
        name: 'admin.importaciones',
        component: () => import('./views/ImportsView.vue'),
        meta: { title: 'Importaciones' },
      },
    ],
  },
]

export default routes
