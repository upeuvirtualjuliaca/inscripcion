import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/inscripcion',
    name: 'public.event',
    component: () => import('./views/EventView.vue'),
    meta: { title: 'I Congreso Macrorregional de Educación' },
  },
]

export default routes
