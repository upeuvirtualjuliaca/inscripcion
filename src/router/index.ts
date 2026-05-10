import { createRouter, createWebHistory } from 'vue-router'
import authRoutes from '@/modules/auth/routes'
import dashboardRoutes from '@/modules/dashboard/routes'
import importsRoutes from '@/modules/imports/routes'
import workshopsRoutes from '@/modules/workshops/routes'
import registrationRoutes from '@/modules/registration/routes'
import registrationsRoutes from '@/modules/registrations/routes'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    ...authRoutes,
    ...dashboardRoutes,
    ...importsRoutes,
    ...workshopsRoutes,
    ...registrationRoutes,
    ...registrationsRoutes,
    { path: '/', redirect: '/inscripcion' },
  ],
})

export default router
