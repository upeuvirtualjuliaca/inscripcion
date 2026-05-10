<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

const route = useRoute()

const pageTitle = computed(() => {
  return (route.meta?.title as string) ?? route.name?.toString() ?? 'Admin'
})

interface NavItem {
  label: string
  to: string
  disabled?: boolean
}

interface NavGroup {
  key: string
  label: string
  items: NavItem[]
}

const navGroups: NavGroup[] = [
  {
    key: 'admin',
    label: 'Admin',
    items: [
      { label: 'Usuarios', to: '/admin/usuarios', disabled: true },
      { label: 'Roles',    to: '/admin/roles',    disabled: true },
    ],
  },
  {
    key: 'talleres',
    label: 'Talleres',
    items: [
      { label: 'Especialidades', to: '/admin/especialidades' },
      { label: 'Talleres',       to: '/admin/talleres' },
      { label: 'Inscripciones',  to: '/admin/inscripciones' },
    ],
  },
  {
    key: 'configuracion',
    label: 'Configuración',
    items: [
      { label: 'Importación', to: '/admin/importaciones' },
    ],
  },
]

// Track which groups are open (all open by default)
const openGroups = ref<Record<string, boolean>>(
  Object.fromEntries(navGroups.map(g => [g.key, true]))
)

function toggleGroup(key: string) {
  openGroups.value[key] = !openGroups.value[key]
}

// Check if any item in a group is the current active route
function groupHasActive(group: NavGroup): boolean {
  return group.items.some(item => route.path.startsWith(item.to))
}
</script>

<template>
  <div class="flex h-screen overflow-hidden" style="background-color: #f1f5f9;">

    <!-- Sidebar -->
    <aside class="w-64 flex-shrink-0 flex flex-col" style="background-color: #003366;">

      <!-- Header -->
      <div
        class="h-16 flex items-center px-6 flex-shrink-0"
        style="border-bottom: 1px solid rgba(255,255,255,0.12);"
      >
        <span class="font-bold text-lg text-white leading-tight">Panel Administrativo</span>
      </div>

      <!-- Navigation -->
      <nav class="flex-1 py-4 overflow-y-auto">
        <div v-for="group in navGroups" :key="group.key" class="mb-1">

          <!-- Group toggle button -->
          <button
            type="button"
            class="w-full flex items-center justify-between px-5 py-2 text-xs font-semibold uppercase tracking-widest transition-colors duration-150 select-none"
            :class="groupHasActive(group)
              ? 'text-white'
              : 'text-white/50 hover:text-white/80'"
            @click="toggleGroup(group.key)"
          >
            <span>{{ group.label }}</span>
            <!-- Chevron icon -->
            <svg
              class="w-3 h-3 transition-transform duration-200"
              :class="openGroups[group.key] ? 'rotate-180' : 'rotate-0'"
              fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"
            >
              <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
            </svg>
          </button>

          <!-- Items (collapsible) -->
          <ul v-show="openGroups[group.key]" class="mt-0.5 mb-3">
            <li v-for="item in group.items" :key="item.to">

              <!-- Disabled -->
              <div
                v-if="item.disabled"
                class="flex items-center justify-between mx-3 px-3 py-2 rounded-md text-sm cursor-not-allowed select-none"
                style="color: rgba(255,255,255,0.28);"
              >
                <span>{{ item.label }}</span>
                <span
                  class="text-xs px-2 py-0.5 rounded-full"
                  style="background: rgba(255,255,255,0.07); color: rgba(255,255,255,0.3);"
                >
                  Pronto
                </span>
              </div>

              <!-- Link -->
              <RouterLink
                v-else
                :to="item.to"
                class="nav-link flex items-center mx-3 px-3 py-2 rounded-md text-sm transition-all duration-150"
                exact-active-class="nav-link--active"
              >
                {{ item.label }}
              </RouterLink>

            </li>
          </ul>

        </div>
      </nav>

      <!-- Footer -->
      <div class="p-4 flex-shrink-0" style="border-top: 1px solid rgba(255,255,255,0.1);">
        <p class="text-xs text-center" style="color: rgba(255,255,255,0.28);">
          Sistema de Registro de Eventos
        </p>
      </div>
    </aside>

    <!-- Main content -->
    <div class="flex-1 flex flex-col overflow-hidden">

      <!-- Top bar -->
      <header class="h-16 bg-white flex items-center px-6 flex-shrink-0" style="border-bottom: 1px solid #e2e8f0;">
        <h1 class="font-semibold text-lg" style="color: #003366;">{{ pageTitle }}</h1>
      </header>

      <!-- Page -->
      <main class="flex-1 overflow-y-auto p-6">
        <RouterView />
      </main>

    </div>
  </div>
</template>

<style scoped>
.nav-link {
  color: rgba(255, 255, 255, 0.65);
}
.nav-link:hover {
  background-color: rgba(255, 255, 255, 0.08);
  color: #ffffff;
}
.nav-link--active {
  background-color: #51a0ce;
  color: #ffffff !important;
  font-weight: 600;
}
.nav-link--active:hover {
  background-color: #51a0ce;
  color: #ffffff;
}
</style>
