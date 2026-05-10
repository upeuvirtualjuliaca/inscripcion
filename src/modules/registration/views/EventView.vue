<template>
  <div class="min-h-screen font-sans antialiased">

    <!-- ===== NAVBAR ===== -->
    <nav class="fixed top-0 left-0 right-0 z-50 flex items-center justify-between px-6 h-16"
         style="background-color: #003366;">
      <!-- Logo + Title -->
      <div class="flex items-center gap-3">
        <div class="flex items-center justify-center w-8 h-8 rounded bg-white shrink-0">
          <span class="text-sm font-bold" style="color: #003366;">E</span>
        </div>
        <span class="text-white font-semibold text-sm md:text-base leading-tight">
          I Congreso Macrorregional
        </span>
      </div>
      <!-- Navbar right actions -->
      <div class="flex items-center gap-2">
        <!-- Mis inscripciones -->
        <button
          @click="myRegistrationsOpen = true"
          class="flex items-center gap-2 text-white text-sm font-medium px-4 py-1.5 rounded-full"
          style="background-color: rgba(255,255,255,0.12); transition: background-color 0.2s;"
          onmouseover="this.style.backgroundColor='rgba(255,255,255,0.22)'"
          onmouseout="this.style.backgroundColor='rgba(255,255,255,0.12)'">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/>
          </svg>
          <span class="hidden sm:inline">Mis inscripciones</span>
        </button>
        <!-- Admin login -->
        <RouterLink
          to="/admin"
          class="flex items-center gap-2 border border-white text-white text-sm font-medium px-4 py-1.5 rounded-full"
          style="transition: background-color 0.2s, color 0.2s;"
          onmouseover="this.style.backgroundColor='white'; this.style.color='#003366';"
          onmouseout="this.style.backgroundColor='transparent'; this.style.color='white';">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
            <path d="M7 11V7a5 5 0 0110 0v4"/>
          </svg>
          <span class="hidden sm:inline">Iniciar sesión</span>
        </RouterLink>
      </div>
    </nav>

    <!-- ===== HERO SLIDER ===== -->
    <section class="relative overflow-hidden" style="height: 60vh; background-color: #003366;">

      <!-- Diagonal pattern overlay -->
      <div class="absolute inset-0 pointer-events-none"
           style="background-image: repeating-linear-gradient(45deg, rgba(255,255,255,0.03) 0px, rgba(255,255,255,0.03) 1px, transparent 1px, transparent 40px); z-index: 1;"></div>

      <!-- Slides -->
      <div class="relative w-full h-full" style="z-index: 2;">

        <!-- Slide 1: Main Title -->
        <transition name="slide-fade">
          <div v-if="currentSlide === 0"
               class="absolute inset-0 flex flex-col items-center justify-center text-center px-6 pt-0">
            <p class="text-xs md:text-sm font-semibold tracking-widest uppercase mb-2"
               style="color: #51a0ce;">
              I Congreso Macrorregional de Educación
            </p>
            <h1 class="text-2xl md:text-4xl font-bold leading-snug text-white max-w-3xl">
              Enfoque por Competencias e<br>Innovación Educativas
            </h1>
            <p class="text-lg md:text-2xl font-semibold mt-2" style="color: #51a0ce;">
              para el siglo XXI
            </p>
            <div class="my-4 rounded-full" style="width: 60px; height: 2px; background-color: #ffffff;"></div>
            <button @click="scrollToWorkshops"
                    class="border-2 border-white text-white font-semibold px-6 py-2 text-sm rounded-full"
                    style="transition: background-color 0.3s, color 0.3s;"
                    onmouseover="this.style.color='#003366'; this.style.backgroundColor='white';"
                    onmouseout="this.style.color='white'; this.style.backgroundColor='transparent';">
              Ver talleres disponibles
            </button>
          </div>
        </transition>

        <!-- Slide 2: Event Highlights -->
        <transition name="slide-fade">
          <div v-if="currentSlide === 1"
               class="absolute inset-0 flex flex-col items-center justify-center text-center px-6 pt-0">
            <p class="text-xs uppercase tracking-widest font-semibold mb-5" style="color: #51a0ce;">
              ¿Por qué asistir?
            </p>
            <div class="flex flex-col md:flex-row gap-6 md:gap-12 items-center justify-center max-w-4xl">
              <!-- Feature 1 -->
              <div class="flex flex-col items-center gap-2 max-w-xs">
                <div class="w-12 h-12 rounded-full flex items-center justify-center" style="background-color: rgba(81,160,206,0.2);">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
                    <path d="M6 12v5c3 3 9 3 12 0v-5"/>
                  </svg>
                </div>
                <h3 class="text-white font-bold text-base">Ponentes Especializados</h3>
                <p class="text-gray-300 text-xs leading-relaxed">Expertos nacionales compartiendo conocimientos de alto nivel</p>
              </div>
              <!-- Feature 2 -->
              <div class="flex flex-col items-center gap-2 max-w-xs">
                <div class="w-12 h-12 rounded-full flex items-center justify-center" style="background-color: rgba(81,160,206,0.2);">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
                    <circle cx="9" cy="7" r="4"/>
                    <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/>
                  </svg>
                </div>
                <h3 class="text-white font-bold text-base">Talleres Prácticos</h3>
                <p class="text-gray-300 text-xs leading-relaxed">Sesiones hands-on diseñadas para aplicación inmediata</p>
              </div>
              <!-- Feature 3 -->
              <div class="flex flex-col items-center gap-2 max-w-xs">
                <div class="w-12 h-12 rounded-full flex items-center justify-center" style="background-color: rgba(81,160,206,0.2);">
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="8" r="6"/>
                    <path d="M15.477 12.89L17 22l-5-3-5 3 1.523-9.11"/>
                  </svg>
                </div>
                <h3 class="text-white font-bold text-base">Certificación</h3>
                <p class="text-gray-300 text-xs leading-relaxed">Obtén tu certificado de participación al finalizar</p>
              </div>
            </div>
          </div>
        </transition>

        <!-- Slide 3: Call to Action -->
        <transition name="slide-fade">
          <div v-if="currentSlide === 2"
               class="absolute inset-0 flex flex-col items-center justify-center text-center px-6 pt-0">
            <h2 class="text-3xl md:text-5xl font-bold text-white mb-3">¡Inscríbete Ahora!</h2>
            <p class="text-gray-300 text-base md:text-lg mb-6 max-w-lg">
              Elige tu especialidad y reserva tu lugar en los talleres
            </p>
            <button @click="scrollToWorkshops"
                    class="text-white font-semibold px-8 py-2.5 text-base rounded-full"
                    style="background-color: #51a0ce; transition: background-color 0.2s;"
                    onmouseover="this.style.backgroundColor='#3a8ab8';"
                    onmouseout="this.style.backgroundColor='#51a0ce';">
              Ver talleres
            </button>
            <p class="text-gray-400 text-xs mt-4">Cupos limitados por taller</p>
          </div>
        </transition>
      </div>

      <!-- Left Arrow -->
      <button @click="prevSlide"
              class="absolute left-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full flex items-center justify-center transition-opacity duration-200 hover:opacity-100 opacity-60"
              style="background-color: rgba(255,255,255,0.2); z-index: 10;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#003366" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="15 18 9 12 15 6"/>
        </svg>
      </button>

      <!-- Right Arrow -->
      <button @click="nextSlide"
              class="absolute right-4 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full flex items-center justify-center transition-opacity duration-200 hover:opacity-100 opacity-60"
              style="background-color: rgba(255,255,255,0.2); z-index: 10;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#003366" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="9 18 15 12 9 6"/>
        </svg>
      </button>

      <!-- Dot Navigation -->
      <div class="absolute bottom-12 left-1/2 -translate-x-1/2 flex items-center gap-2" style="z-index: 10;">
        <button v-for="(_, idx) in 3" :key="idx"
                @click="currentSlide = idx"
                class="w-3 h-3 rounded-full border-2 border-white transition-all duration-300"
                :style="currentSlide === idx ? 'background-color: white;' : 'background-color: transparent;'">
        </button>
      </div>

      <!-- Bottom Wave Divider -->
      <div class="absolute bottom-0 left-0 right-0" style="z-index: 10;">
        <svg viewBox="0 0 1440 80" preserveAspectRatio="none" class="w-full" style="display: block; height: 80px;">
          <path d="M0,40 C360,80 1080,0 1440,40 L1440,80 L0,80 Z" fill="white"/>
        </svg>
      </div>
    </section>

    <!-- ===== WORKSHOPS SECTION ===== -->
    <section id="talleres" class="bg-white pt-6 pb-12">
      <!-- Section Header -->
      <div class="text-center px-4 mb-5">
        <h2 class="text-2xl font-bold" style="color: #003366;">Elige tu Especialidad</h2>
        <p class="text-gray-500 mt-1 text-sm max-w-xl mx-auto">
          Selecciona la especialidad de tu interés y explora los talleres disponibles
        </p>
      </div>

      <!-- Specialty Tabs -->
      <div class="flex justify-center flex-wrap gap-2 px-4 mb-6">
        <button @click="activeTab = 'all'"
                class="px-5 py-2 text-sm font-medium rounded-full border transition-all duration-200"
                :style="activeTab === 'all'
                  ? 'background-color: #003366; color: white; border-color: #003366;'
                  : 'background-color: white; color: #003366; border-color: #003366;'">
          Todos
        </button>
        <button v-for="specialty in specialties"
                :key="specialty.id"
                @click="activeTab = specialty.id"
                class="px-5 py-2 text-sm font-medium rounded-full border transition-all duration-200"
                :style="activeTab === specialty.id
                  ? `background-color: #003366; color: white; border-color: #003366;`
                  : `background-color: white; color: #003366; border-color: #003366;`">
          {{ specialty.name }}
        </button>
      </div>

      <!-- Loading Skeletons -->
      <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 px-4 md:px-8 lg:px-16">
        <div v-for="i in 6" :key="i"
             class="bg-white rounded-2xl shadow-md overflow-hidden animate-pulse">
          <div class="h-1.5 w-full bg-gray-200"></div>
          <div class="p-5 space-y-3">
            <div class="h-5 bg-gray-200 rounded-full w-1/3"></div>
            <div class="h-6 bg-gray-200 rounded w-3/4"></div>
            <div class="h-4 bg-gray-200 rounded w-1/2"></div>
            <div class="border-t border-gray-100 pt-3 mt-3 space-y-2">
              <div class="h-4 bg-gray-200 rounded w-full"></div>
              <div class="h-4 bg-gray-200 rounded w-2/3"></div>
            </div>
            <div class="h-10 bg-gray-200 rounded-xl mt-4"></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="!loading && filteredWorkshops.length === 0"
           class="flex flex-col items-center justify-center py-20 px-4">
        <div class="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center mb-4">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
            <line x1="16" y1="2" x2="16" y2="6"/>
            <line x1="8" y1="2" x2="8" y2="6"/>
            <line x1="3" y1="10" x2="21" y2="10"/>
          </svg>
        </div>
        <p class="text-gray-400 text-base">No hay talleres disponibles para esta especialidad.</p>
      </div>

      <!-- Workshop Cards Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10 px-6 md:px-12 lg:px-20">
        <div v-for="workshop in displayedWorkshops"
             :key="workshop.id"
             class="card rounded-2xl overflow-hidden flex flex-col"
             style="background-color: #003366; box-shadow: 0 4px 24px rgba(0,51,102,0.18);">

          <!-- ── IMAGE ── -->
          <div class="card-image relative overflow-hidden" style="height: 120px;">

            <img v-if="workshop.image_url"
                 :src="workshop.image_url"
                 :alt="workshop.name"
                 class="card-img w-full h-full object-cover"
                 :style="(() => { const pos = (workshop as any).image_position || '50 50'; const parts = pos.trim().split(/\s+/); const x = parts.length === 2 && !isNaN(+parts[0]) ? +parts[0] : 50; const y = parts.length === 2 && !isNaN(+parts[1]) ? +parts[1] : 50; const scale = (workshop as any).image_scale || 1; return `object-position: ${x}% ${y}%; transform: scale(${scale}); transform-origin: center;`; })()" />
            <div v-else class="card-img w-full h-full flex items-center justify-center"
                 style="background: linear-gradient(145deg, #002147 0%, #0a4a8a 60%, #51a0ce 100%);">
              <!-- Decorative icon placeholder -->
              <svg width="56" height="56" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.18)" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
                <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
                <path d="M6 12v5c3 3 9 3 12 0v-5"/>
              </svg>
            </div>

            <!-- Dark gradient overlay bottom -->
            <div class="absolute inset-0" style="background: linear-gradient(to bottom, rgba(0,0,0,0) 40%, rgba(0,33,71,0.75) 100%);"></div>

            <!-- Specialty badge — top left -->
            <span class="absolute top-3 left-3 text-xs font-bold px-3 py-1 rounded-full"
                  style="background-color: rgba(255,255,255,0.18); color: #fff; backdrop-filter: blur(6px); letter-spacing: 0.03em;">
              {{ workshop.specialty?.name || 'General' }}
            </span>

            <!-- Status badge — top right (only if not available) -->
            <span v-if="workshop.status === 'full'"
                  class="absolute top-3 right-3 text-xs font-bold px-3 py-1 rounded-full"
                  style="background-color: rgba(239,68,68,0.85); color:#fff;">
              Completo
            </span>

            <!-- Speaker pill — bottom right over gradient -->
            <div v-if="workshop.speaker"
                 class="absolute bottom-3 right-3 flex items-center gap-1.5 px-3 py-1.5 rounded-full"
                 style="background-color: rgba(0,51,102,0.82); backdrop-filter: blur(8px); border: 1px solid rgba(81,160,206,0.35);">
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
              <span class="text-xs font-semibold" style="color: #ffffff; max-width: 130px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                {{ workshop.speaker }}
              </span>
            </div>
          </div>

          <!-- ── BODY ── -->
          <div class="flex flex-col flex-1 px-3 pt-2.5 pb-3">

            <!-- Title -->
            <h3 class="text-xs font-bold leading-snug text-white mb-1.5" style="-webkit-line-clamp:2; display:-webkit-box; -webkit-box-orient:vertical; overflow:hidden;">
              {{ workshop.name }}
            </h3>

            <!-- Meta row: location + date -->
            <div class="flex flex-wrap gap-x-3 gap-y-1 mb-2">
              <div v-if="workshop.location" class="flex items-center gap-1.5">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/>
                  <circle cx="12" cy="10" r="3"/>
                </svg>
                <span class="text-xs" style="color: rgba(255,255,255,0.65);">{{ workshop.location }}</span>
              </div>
              <div v-if="workshop.workshop_date" class="flex items-center gap-1.5">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                  <line x1="16" y1="2" x2="16" y2="6"/>
                  <line x1="8" y1="2" x2="8" y2="6"/>
                  <line x1="3" y1="10" x2="21" y2="10"/>
                </svg>
                <span class="text-xs" style="color: rgba(255,255,255,0.65);">{{ formatDate(workshop.workshop_date) }}</span>
              </div>
            </div>

            <!-- Shifts -->
            <div class="flex-1 mb-2">
              <template v-if="workshop.shifts && workshop.shifts.length > 0">
                <p class="text-xs font-semibold uppercase tracking-widest mb-2" style="color: rgba(255,255,255,0.35);">
                  Turnos
                </p>
                <div class="space-y-2">
                  <div v-for="shift in workshop.shifts" :key="shift.id"
                       class="flex items-center justify-between rounded-lg px-3 py-2"
                       style="background-color: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.08);">
                    <div class="flex items-center gap-2 min-w-0">
                      <!-- Clock icon -->
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                        <circle cx="12" cy="12" r="10"/>
                        <polyline points="12 6 12 12 16 14"/>
                      </svg>
                      <span class="text-xs font-semibold text-white shrink-0">
                        {{ shift.shift_name || `Turno ${shift.shift_number}` }}
                      </span>
                      <span v-if="shift.start_time && shift.end_time" class="text-xs truncate" style="color: rgba(255,255,255,0.45);">
                        {{ shift.start_time.slice(0,5) }} – {{ shift.end_time.slice(0,5) }}
                      </span>
                    </div>
                    <!-- Capacity pill -->
                    <span v-if="shift.status === 'closed'"
                          class="shrink-0 text-xs px-2 py-0.5 rounded-full font-medium"
                          style="background: rgba(255,255,255,0.08); color: rgba(255,255,255,0.4);">
                      Cerrado
                    </span>
                    <span v-else-if="availableSpots(shift) <= 0"
                          class="shrink-0 text-xs px-2.5 py-0.5 rounded-full font-semibold"
                          style="background: rgba(239,68,68,0.18); color: #fca5a5; border: 1px solid rgba(239,68,68,0.3);">
                      Completo
                    </span>
                    <span v-else
                          class="shrink-0 text-xs px-2.5 py-0.5 rounded-full font-semibold"
                          style="background: rgba(34,197,94,0.15); color: #86efac; border: 1px solid rgba(34,197,94,0.25);">
                      {{ availableSpots(shift) }} cupos
                    </span>
                  </div>
                </div>
              </template>
              <template v-else>
                <p class="text-xs italic" style="color: rgba(255,255,255,0.3);">Turnos por confirmar</p>
              </template>
            </div>

            <!-- CTA Button -->
            <button class="card-btn w-full py-3 rounded-xl font-bold text-xs tracking-wide transition-all duration-200"
                    :disabled="workshop.status === 'full'"
                    :class="(workshop.status === 'full' || workshop.status === 'closed') ? 'card-btn--closed' : 'card-btn--active'"
                    @click="workshop.status === 'closed' ? handleClosedWorkshop() : openRegistration(workshop)">
              <span v-if="workshop.status === 'full'">Sin cupos disponibles</span>
              <span v-else-if="workshop.status === 'closed'" class="flex items-center justify-center gap-2">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M22 11.08V12a10 10 0 11-5.93-9.14"/>
                  <polyline points="22 4 12 14.01 9 11.01"/>
                </svg>
                Completado
              </span>
              <span v-else class="flex items-center justify-center gap-2">
                Inscribirse al taller
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="5" y1="12" x2="19" y2="12"/>
                  <polyline points="12 5 19 12 12 19"/>
                </svg>
              </span>
            </button>
          </div>
        </div>
      </div>
      <!-- Ver más button -->
      <div v-if="hasMore" class="flex flex-col items-center mt-10 gap-2">
        <p class="text-sm" style="color: #9ca3af;">
          Mostrando {{ displayedWorkshops.length }} de {{ filteredWorkshops.length }} talleres
        </p>
        <button
          @click="loadMore"
          class="ver-mas-btn flex items-center gap-2 px-8 py-3 rounded-full font-semibold text-sm transition-all duration-300"
          style="background-color: #003366; color: #ffffff;">
          Ver {{ remainingCount }} taller{{ remainingCount !== 1 ? 'es' : '' }} más
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </button>
      </div>

      <!-- Contador cuando ya se muestran todos -->
      <p v-else-if="!loading && filteredWorkshops.length > PAGE_SIZE"
         class="text-center text-sm mt-8" style="color: #9ca3af;">
        Has visto todos los talleres disponibles ({{ filteredWorkshops.length }})
      </p>

    </section>

    <!-- ===== STATS BAR ===== -->
    <section ref="statsSection" class="py-10 px-4" style="background-color: #e6f2ff;">
      <div class="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8">

        <!-- Especialidades -->
        <div class="flex flex-col items-center gap-3 text-center">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <rect x="2" y="3" width="20" height="5" rx="1"/>
            <rect x="2" y="10" width="20" height="5" rx="1"/>
            <rect x="2" y="17" width="20" height="5" rx="1"/>
          </svg>
          <span class="text-5xl font-extrabold tabular-nums leading-none" style="color: #003366;">{{ displayStats.specialties }}</span>
          <span class="text-sm font-semibold" style="color: #003366;">Especialidades</span>
        </div>

        <!-- Talleres -->
        <div class="flex flex-col items-center gap-3 text-center">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/>
            <path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/>
          </svg>
          <span class="text-5xl font-extrabold tabular-nums leading-none" style="color: #003366;">{{ displayStats.workshops }}</span>
          <span class="text-sm font-semibold" style="color: #003366;">Talleres</span>
        </div>

        <!-- Total Cupos -->
        <div class="flex flex-col items-center gap-3 text-center">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 00-3-3.87"/>
            <path d="M16 3.13a4 4 0 010 7.75"/>
          </svg>
          <span class="text-5xl font-extrabold tabular-nums leading-none" style="color: #003366;">{{ displayStats.capacity }}</span>
          <span class="text-sm font-semibold" style="color: #003366;">Total Cupos</span>
        </div>

        <!-- Inscritos -->
        <div class="flex flex-col items-center gap-3 text-center">
          <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 11.08V12a10 10 0 11-5.93-9.14"/>
            <polyline points="22 4 12 14.01 9 11.01"/>
          </svg>
          <span class="text-5xl font-extrabold tabular-nums leading-none" style="color: #003366;">{{ displayStats.registered }}</span>
          <span class="text-sm font-semibold" style="color: #003366;">Inscritos</span>
        </div>

      </div>
    </section>

    <!-- ===== FOOTER ===== -->
    <footer class="py-10 text-center" style="background-color: #003366;">
      <p class="text-white text-sm font-medium mb-2">
        I Congreso Macrorregional de Educación — Enfoque por Competencias e Innovación Educativas para el siglo XXI
      </p>
      <p class="text-sm" style="color: #9ca3af;">Todos los derechos reservados</p>
    </footer>

    <!-- ===== FLOATING WHATSAPP BUTTON ===== -->
    <div class="fixed bottom-6 right-6 z-50 flex items-center gap-3 group">
      <!-- Tooltip -->
      <div class="hidden group-hover:flex items-center bg-white shadow-lg rounded px-3 py-1 text-sm font-medium pointer-events-none"
           style="color: #003366;">
        Consultar por WhatsApp
      </div>

      <!-- Ping ring -->
      <div class="absolute right-0 bottom-0 w-14 h-14 rounded-full animate-ping opacity-75"
           style="background-color: #4ade80;"></div>

      <!-- Button -->
      <a href="https://wa.me/51989429830"
         target="_blank"
         rel="noopener noreferrer"
         class="relative w-14 h-14 rounded-full flex items-center justify-center shadow-lg transition-transform duration-200 hover:scale-110"
         style="background-color: #25D366;">
        <svg width="28" height="28" viewBox="0 0 24 24" fill="white">
          <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
        </svg>
      </a>
    </div>

    <!-- ===== MIS INSCRIPCIONES MODAL ===== -->
    <div v-if="myRegistrationsOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-black/60 backdrop-blur-sm" @click="closeMyRegistrations"></div>

      <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg flex flex-col overflow-hidden" style="max-height: 90vh;">

        <!-- Header -->
        <div class="flex items-center justify-between px-6 py-4 shrink-0" style="background-color: #003366;">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-full flex items-center justify-center" style="background-color: rgba(255,255,255,0.15);">
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
              </svg>
            </div>
            <h2 class="text-white font-bold text-base">Mis inscripciones</h2>
          </div>
          <button @click="closeMyRegistrations"
            class="w-8 h-8 rounded-full flex items-center justify-center"
            style="background-color: rgba(255,255,255,0.1);"
            onmouseover="this.style.backgroundColor='rgba(255,255,255,0.2)'"
            onmouseout="this.style.backgroundColor='rgba(255,255,255,0.1)'">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
            </svg>
          </button>
        </div>

        <!-- Body -->
        <div class="overflow-y-auto flex-1 p-6">

          <!-- Search form -->
          <div v-if="myRegStep === 'search'">
            <p class="text-sm text-gray-600 mb-5">
              Ingresa tu <strong>DNI</strong> o tu <strong>código de confirmación</strong> para consultar tus inscripciones.
            </p>

            <!-- Toggle search type -->
            <div class="flex gap-2 mb-4">
              <button
                @click="myRegSearchType = 'dni'"
                class="flex-1 py-2 rounded-lg text-sm font-semibold border-2 transition-all duration-150"
                :style="myRegSearchType === 'dni'
                  ? 'border-color: #003366; background-color: #003366; color: white;'
                  : 'border-color: #e5e7eb; background-color: white; color: #6b7280;'">
                Por DNI
              </button>
              <button
                @click="myRegSearchType = 'code'"
                class="flex-1 py-2 rounded-lg text-sm font-semibold border-2 transition-all duration-150"
                :style="myRegSearchType === 'code'
                  ? 'border-color: #003366; background-color: #003366; color: white;'
                  : 'border-color: #e5e7eb; background-color: white; color: #6b7280;'">
                Por código
              </button>
            </div>

            <!-- Input -->
            <div class="relative">
              <input
                ref="myRegInput"
                type="text"
                v-model="myRegQuery"
                :placeholder="myRegSearchType === 'dni' ? 'Ej: 74123456' : 'Ej: REG-484A58'"
                maxlength="20"
                class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce] pr-12"
                :class="myRegQuery.length > 0 ? 'border-gray-300' : ''"
                @keydown.enter="searchMyRegistrations"
              />
              <button @click="searchMyRegistrations"
                class="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 rounded-lg flex items-center justify-center"
                style="background-color: #003366;">
                <svg v-if="myRegLoading" class="animate-spin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/><path d="M21 12a9 9 0 00-9-9"/>
                </svg>
                <svg v-else width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
              </button>
            </div>

            <!-- Error -->
            <p v-if="myRegError" class="mt-3 text-sm text-red-600 flex items-center gap-1.5">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
              </svg>
              {{ myRegError }}
            </p>
          </div>

          <!-- Results -->
          <div v-else-if="myRegStep === 'results'">
            <!-- Participant info -->
            <div class="flex items-center justify-between mb-4">
              <div>
                <p class="font-bold text-gray-800">{{ myRegParticipant?.first_name }} {{ myRegParticipant?.last_name }}</p>
                <p class="text-xs text-gray-400">DNI {{ myRegParticipant?.dni }}</p>
              </div>
              <button @click="myRegStep = 'search'; myRegQuery = ''; myRegError = ''"
                class="text-xs text-gray-400 hover:text-gray-600 underline transition-colors duration-150">
                Nueva búsqueda
              </button>
            </div>

            <!-- No registrations -->
            <div v-if="myRegResults.length === 0" class="text-center py-10">
              <div class="w-14 h-14 rounded-full bg-gray-100 flex items-center justify-center mx-auto mb-3">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                  <polyline points="14 2 14 8 20 8"/>
                </svg>
              </div>
              <p class="text-gray-400 text-sm">No tienes inscripciones registradas.</p>
            </div>

            <!-- Registration cards -->
            <div v-else class="space-y-3">
              <div v-for="reg in myRegResults" :key="reg.registration_id"
                class="rounded-xl border overflow-hidden"
                :style="reg.status === 'cancelled' ? 'border-color: #fecaca;' : 'border-color: #e2e8f0;'">

                <!-- Status bar -->
                <div class="px-4 py-2 flex items-center justify-between"
                  :style="reg.status === 'confirmed'  ? 'background-color: rgba(22,163,74,0.08);' :
                          reg.status === 'checked_in'  ? 'background-color: rgba(37,99,235,0.08);' :
                          'background-color: rgba(239,68,68,0.06);'">
                  <div class="flex items-center gap-2">
                    <span class="w-2 h-2 rounded-full"
                      :style="reg.status === 'confirmed'  ? 'background-color: #16a34a;' :
                              reg.status === 'checked_in'  ? 'background-color: #2563eb;' :
                              'background-color: #ef4444;'"></span>
                    <span class="text-xs font-semibold"
                      :style="reg.status === 'confirmed'  ? 'color: #16a34a;' :
                              reg.status === 'checked_in'  ? 'color: #2563eb;' :
                              'color: #ef4444;'">
                      {{ reg.status === 'confirmed' ? 'Inscripción confirmada' : reg.status === 'checked_in' ? 'Asistencia registrada' : 'Cancelada' }}
                    </span>
                  </div>
                  <!-- Confirmation code badge -->
                  <span v-if="reg.status !== 'cancelled'"
                    class="font-mono text-xs font-bold px-2 py-0.5 rounded"
                    style="background-color: rgba(0,51,102,0.08); color: #003366;">
                    {{ reg.confirmation_code }}
                  </span>
                </div>

                <!-- Card body -->
                <div class="px-4 py-3">
                  <p class="font-bold text-gray-800 text-sm leading-snug">{{ reg.workshop_name }}</p>
                  <p class="text-xs text-gray-500 mt-0.5">{{ reg.specialty_name }}</p>

                  <div class="flex flex-wrap gap-3 mt-2">
                    <div class="flex items-center gap-1.5">
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                      </svg>
                      <span class="text-xs text-gray-600">
                        {{ reg.shift_name }}
                        <template v-if="reg.start_time && reg.end_time">
                          · {{ reg.start_time.slice(0,5) }} – {{ reg.end_time.slice(0,5) }}
                        </template>
                      </span>
                    </div>
                    <div v-if="reg.location" class="flex items-center gap-1.5">
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>
                      </svg>
                      <span class="text-xs text-gray-600">{{ reg.location }}</span>
                    </div>
                  </div>

                  <!-- Code reminder -->
                  <div v-if="reg.status === 'confirmed'" class="mt-3 flex items-start gap-2 rounded-lg px-3 py-2" style="background-color: rgba(0,51,102,0.05); border: 1px solid rgba(0,51,102,0.1);">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#003366" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5">
                      <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <p class="text-xs" style="color: #003366;">
                      Guarda el código <strong class="font-mono">{{ reg.confirmation_code }}</strong> — lo necesitarás para registrar tu asistencia el día del evento.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>

    <!-- Registration Modal -->
    <RegistrationModal
      v-model="registrationModalOpen"
      :workshop="selectedWorkshop"
      @registered="() => { /* optionally refresh workshops */ }"
    />

    <!-- ===== TOAST STACK ===== -->
    <div class="fixed bottom-24 left-1/2 -translate-x-1/2 z-50 flex flex-col items-center gap-2 pointer-events-none" style="min-width: 280px;">
      <transition-group name="toast">
        <div v-for="toast in toasts" :key="toast.id"
          class="flex items-center gap-3 px-4 py-3 rounded-xl shadow-lg text-sm font-medium text-white pointer-events-auto"
          style="background-color: #003366; min-width: 280px; max-width: 360px;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
            <circle cx="12" cy="12" r="10"/>
            <line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          {{ toast.message }}
        </div>
      </transition-group>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onUnmounted, reactive } from 'vue'
import { RouterLink } from 'vue-router'
import { supabase } from '@/core/supabase'
import RegistrationModal from '../components/RegistrationModal.vue'

// ===== TYPES =====
interface Specialty {
  id: string
  name: string
  color: string
  sort_order: number
}

interface Shift {
  id: string
  workshop_id: string
  shift_number: number
  shift_name: string | null
  start_time: string | null
  end_time: string | null
  capacity: number
  registered_count: number
  status: string
}

interface Workshop {
  id: string
  name: string
  speaker: string | null
  location: string | null
  date: string | null
  status: string
  is_visible: boolean
  sort_order: number
  specialty_id: string | null
  specialty: Specialty | null
  shifts: Shift[]
}

// ===== STATE =====
const specialties = ref<Specialty[]>([])
const workshops = ref<Workshop[]>([])
const loading = ref(true)
const activeTab = ref<string>('all')

const PAGE_SIZE = 9   // 3 rows × 3 cols
const visibleCount = ref(PAGE_SIZE)

const registrationModalOpen = ref(false)
const selectedWorkshop = ref<Workshop | null>(null)

function openRegistration(workshop: Workshop) {
  selectedWorkshop.value = workshop
  registrationModalOpen.value = true
}

// ===== SLIDER =====
const currentSlide = ref(0)
let sliderInterval: ReturnType<typeof setInterval> | null = null

function nextSlide() {
  currentSlide.value = (currentSlide.value + 1) % 3
}

function prevSlide() {
  currentSlide.value = (currentSlide.value + 2) % 3
}

function startSlider() {
  sliderInterval = setInterval(() => {
    nextSlide()
  }, 6000)
}

// ===== COMPUTED =====
const filteredWorkshops = computed<Workshop[]>(() => {
  if (activeTab.value === 'all') return workshops.value
  return workshops.value.filter((w) => w.specialty_id === activeTab.value)
})

const displayedWorkshops = computed<Workshop[]>(() =>
  filteredWorkshops.value.slice(0, visibleCount.value)
)

const hasMore = computed(() =>
  filteredWorkshops.value.length > visibleCount.value
)

const remainingCount = computed(() =>
  Math.min(PAGE_SIZE, filteredWorkshops.value.length - visibleCount.value)
)

function loadMore() {
  visibleCount.value += PAGE_SIZE
}

// Reset pagination when tab changes
watch(activeTab, () => {
  visibleCount.value = PAGE_SIZE
})

// ===== HELPERS =====
function formatDate(dateStr: string): string {
  try {
    const date = new Date(dateStr + 'T00:00:00')
    return date.toLocaleDateString('es-PE', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    })
  } catch {
    return dateStr
  }
}

function availableSpots(shift: Shift): number {
  return (shift.capacity ?? 0) - (shift.registered_count ?? 0)
}

function hexWithOpacity(hex: string, opacity: number): string {
  // Convert hex color to rgba with given opacity
  try {
    const cleanHex = hex.replace('#', '')
    const r = parseInt(cleanHex.substring(0, 2), 16)
    const g = parseInt(cleanHex.substring(2, 4), 16)
    const b = parseInt(cleanHex.substring(4, 6), 16)
    return `rgba(${r}, ${g}, ${b}, ${opacity})`
  } catch {
    return `rgba(81, 160, 206, ${opacity})`
  }
}

function scrollToWorkshops() {
  document.getElementById('talleres')?.scrollIntoView({ behavior: 'smooth' })
}

// ===== DATA FETCHING =====
async function fetchData() {
  loading.value = true
  try {
    const [specialtiesRes, workshopsRes] = await Promise.all([
      supabase
        .from('specialties')
        .select('id, name, color, sort_order')
        .eq('status', 'active')
        .eq('is_visible', true)
        .is('deleted_at', null)
        .order('sort_order'),
      supabase
        .from('workshops')
        .select('*, shifts:workshop_shifts(*), specialty:specialties(id,name,color)')
        .in('status', ['available', 'full', 'closed'])
        .eq('is_visible', true)
        .is('deleted_at', null)
        .order('sort_order'),
    ])

    if (specialtiesRes.data) {
      specialties.value = specialtiesRes.data as Specialty[]
    }
    if (workshopsRes.data) {
      workshops.value = workshopsRes.data as Workshop[]
    }
  } catch (err) {
    console.error('Error fetching event data:', err)
  } finally {
    loading.value = false
  }
}

// ===== STATS =====
const statsSection = ref<HTMLElement | null>(null)
const displayStats = reactive({ specialties: 0, workshops: 0, capacity: 0, registered: 0 })
let statsAnimated = false

const targetStats = computed(() => ({
  specialties: specialties.value.length,
  workshops: workshops.value.length,
  capacity: workshops.value.flatMap(w => w.shifts).reduce((s, sh) => s + (sh.capacity ?? 0), 0),
  registered: workshops.value.flatMap(w => w.shifts).reduce((s, sh) => s + (sh.registered_count ?? 0), 0),
}))

function animateCounters() {
  if (statsAnimated) return
  statsAnimated = true
  const targets = targetStats.value
  const duration = 1800
  const start = performance.now()

  function tick(now: number) {
    const elapsed = now - start
    const t = Math.min(elapsed / duration, 1)
    // ease-out cubic: slow down near the end
    const eased = 1 - Math.pow(1 - t, 3)
    displayStats.specialties = Math.round(eased * targets.specialties)
    displayStats.workshops    = Math.round(eased * targets.workshops)
    displayStats.capacity     = Math.round(eased * targets.capacity)
    displayStats.registered   = Math.round(eased * targets.registered)
    if (t < 1) requestAnimationFrame(tick)
  }
  requestAnimationFrame(tick)
}

// ===== TOAST =====
interface Toast { id: number; message: string; type: 'info' | 'warning' }
const toasts = ref<Toast[]>([])
let toastCounter = 0

function showToast(message: string, type: Toast['type'] = 'warning') {
  const id = ++toastCounter
  toasts.value.push({ id, message, type })
  setTimeout(() => {
    toasts.value = toasts.value.filter(t => t.id !== id)
  }, 3500)
}

function handleClosedWorkshop() {
  showToast('Los cupos para este taller están completos. Ya no es posible inscribirse.')
}

// ===== MIS INSCRIPCIONES =====
const myRegistrationsOpen = ref(false)
const myRegStep            = ref<'search' | 'results'>('search')
const myRegSearchType      = ref<'dni' | 'code'>('dni')
const myRegQuery           = ref('')
const myRegLoading         = ref(false)
const myRegError           = ref('')
const myRegInput           = ref<HTMLInputElement | null>(null)
const myRegParticipant     = ref<{ id: string; first_name: string; last_name: string; dni: string } | null>(null)

interface MyReg {
  registration_id: string
  registration_number: number
  confirmation_code: string
  workshop_name: string
  specialty_name: string
  shift_name: string
  start_time: string | null
  end_time: string | null
  location: string | null
  workshop_date: string | null
  status: string
  checked_in_at: string | null
}
const myRegResults = ref<MyReg[]>([])

function closeMyRegistrations() {
  myRegistrationsOpen.value = false
  myRegStep.value = 'search'
  myRegQuery.value = ''
  myRegError.value = ''
  myRegResults.value = []
  myRegParticipant.value = null
}

async function searchMyRegistrations() {
  const q = myRegQuery.value.trim()
  if (!q) return
  myRegLoading.value = true
  myRegError.value = ''

  try {
    if (myRegSearchType.value === 'dni') {
      // Look up participant by DNI
      const { data: participant, error: pErr } = await supabase
        .from('participants')
        .select('id, first_name, last_name, dni')
        .eq('dni', q)
        .is('deleted_at', null)
        .maybeSingle()

      if (pErr) throw pErr
      if (!participant) {
        myRegError.value = 'No encontramos ningún participante con ese DNI.'
        return
      }

      myRegParticipant.value = participant

      const { data: regs, error: rErr } = await supabase.rpc('get_participant_registrations', {
        p_participant_id: participant.id,
      })
      if (rErr) throw rErr
      myRegResults.value = (regs ?? []).map((r: any) => ({
        registration_id:     r.registration_id,
        registration_number: r.registration_number,
        confirmation_code:   r.confirmation_code,
        workshop_name:       r.workshop_name,
        specialty_name:      r.specialty_name,
        shift_name:          r.shift_name,
        start_time:          r.start_time,
        end_time:            r.end_time,
        location:            r.location,
        workshop_date:       r.workshop_date,
        status:              r.status,
        checked_in_at:       r.checked_in_at,
      }))

    } else {
      // Look up by confirmation code
      const { data: reg, error: rErr } = await supabase
        .from('registrations')
        .select(`
          id, status, confirmation_code, registration_number,
          participant:participants(id, first_name, last_name, dni)
        `)
        .eq('confirmation_code', q.toUpperCase())
        .is('deleted_at', null)
        .maybeSingle()

      if (rErr) throw rErr
      if (!reg) {
        myRegError.value = 'Código de confirmación no válido. Verifica que lo escribiste correctamente.'
        return
      }

      const p = reg.participant as any
      myRegParticipant.value = { id: p.id, first_name: p.first_name, last_name: p.last_name, dni: p.dni }

      const { data: regs, error: pRErr } = await supabase.rpc('get_participant_registrations', {
        p_participant_id: p.id,
      })
      if (pRErr) throw pRErr
      myRegResults.value = (regs ?? []).map((r: any) => ({
        registration_id:     r.registration_id,
        registration_number: r.registration_number,
        confirmation_code:   r.confirmation_code,
        workshop_name:       r.workshop_name,
        specialty_name:      r.specialty_name,
        shift_name:          r.shift_name,
        start_time:          r.start_time,
        end_time:            r.end_time,
        location:            r.location,
        workshop_date:       r.workshop_date,
        status:              r.status,
        checked_in_at:       r.checked_in_at,
      }))
    }

    myRegStep.value = 'results'
  } catch (e: any) {
    myRegError.value = 'Ocurrió un error al consultar. Intenta de nuevo.'
  } finally {
    myRegLoading.value = false
  }
}

// ===== LIFECYCLE =====
onMounted(() => {
  fetchData()
  startSlider()

  let sectionVisible = false
  const observer = new IntersectionObserver(
    (entries) => {
      sectionVisible = entries[0].isIntersecting
      if (sectionVisible && !loading.value) animateCounters()
    },
    { threshold: 0.3 },
  )
  // trigger animation when data finishes loading and section is already visible
  watch(loading, (val) => {
    if (!val && sectionVisible) animateCounters()
  })
  setTimeout(() => {
    if (statsSection.value) observer.observe(statsSection.value)
  }, 100)
})

onUnmounted(() => {
  if (sliderInterval !== null) {
    clearInterval(sliderInterval)
    sliderInterval = null
  }
})
</script>

<style scoped>
/* Card hover zoom */
.card {
  transition: transform 0.35s ease, box-shadow 0.35s ease;
}
.card:hover {
  transform: translateY(-6px);
  box-shadow: 0 24px 48px rgba(0, 51, 102, 0.32) !important;
}
.card-img {
  transition: transform 0.5s ease;
}
.card:hover .card-img {
  transform: scale(1.06);
}

/* Ver más button */
.ver-mas-btn:hover {
  background-color: #51a0ce !important;
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 51, 102, 0.25);
}

/* CTA button states */
.card-btn--active {
  background-color: #51a0ce;
  color: #ffffff;
}
.card-btn--active:hover {
  background-color: #3a8ab8;
}
.card-btn--disabled {
  background-color: rgba(255,255,255,0.07);
  color: rgba(255,255,255,0.3);
  cursor: not-allowed;
}
.card-btn--closed {
  background-color: rgba(34,197,94,0.15);
  color: #86efac;
  border: 1px solid rgba(34,197,94,0.25);
  cursor: pointer;
}
.card-btn--closed:hover {
  background-color: rgba(34,197,94,0.22);
}

/* Slide fade transition */
.slide-fade-enter-active {
  transition: opacity 0.7s ease, transform 0.7s ease;
}
.slide-fade-leave-active {
  transition: opacity 0.5s ease, transform 0.5s ease;
}
.slide-fade-enter-from {
  opacity: 0;
  transform: translateY(20px);
}
.slide-fade-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}

/* Line clamp utility */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Hide scrollbar for tab overflow */
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}

/* Ensure transitions are smooth */
button {
  outline: none;
}
button:focus-visible {
  outline: 2px solid #51a0ce;
  outline-offset: 2px;
}

/* Toast transitions */
.toast-enter-active { transition: all 0.3s ease; }
.toast-leave-active { transition: all 0.25s ease; }
.toast-enter-from   { opacity: 0; transform: translateY(12px); }
.toast-leave-to     { opacity: 0; transform: translateY(-8px); }
</style>
