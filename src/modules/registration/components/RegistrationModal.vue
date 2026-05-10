<template>
  <div
    v-if="modelValue"
    class="fixed inset-0 z-50 flex items-center justify-center p-4"
  >
    <!-- Overlay -->
    <div
      class="absolute inset-0 bg-black/60 backdrop-blur-sm"
      @click="close"
    ></div>

    <!-- Modal Card -->
    <div
      class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden flex flex-col"
      style="max-height: 90vh;"
    >
      <!-- ===== HEADER ===== -->
      <div class="flex items-center justify-between px-6 py-4 shrink-0" style="background-color: #003366;">
        <div class="flex items-center gap-3">
          <!-- Step icon -->
          <div class="w-8 h-8 rounded-full flex items-center justify-center" style="background-color: rgba(255,255,255,0.15);">
            <!-- Form icon -->
            <svg v-if="step === 'form'" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/>
              <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/>
            </svg>
            <!-- Confirm icon -->
            <svg v-else-if="step === 'confirm'" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 11l3 3L22 4"/>
              <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/>
            </svg>
            <!-- Success icon -->
            <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </div>
          <h2 class="text-white font-bold text-base leading-tight">
            <span v-if="step === 'form'">Formulario de Inscripción</span>
            <span v-else-if="step === 'confirm'">Confirmar datos</span>
            <span v-else>¡Inscripción Exitosa!</span>
          </h2>
        </div>
        <!-- Close button -->
        <button
          @click="close"
          class="w-8 h-8 rounded-full flex items-center justify-center transition-colors duration-150"
          style="background-color: rgba(255,255,255,0.1);"
          onmouseover="this.style.backgroundColor='rgba(255,255,255,0.2)';"
          onmouseout="this.style.backgroundColor='rgba(255,255,255,0.1)';"
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="18" y1="6" x2="6" y2="18"/>
            <line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>

      <!-- ===== PROGRESS BAR ===== -->
      <div v-if="step !== 'success'" class="flex items-center px-6 py-3 shrink-0 bg-white border-b border-gray-100">
        <!-- Step 1 -->
        <div class="flex items-center gap-2 shrink-0">
          <div
            class="w-7 h-7 rounded-full flex items-center justify-center shrink-0"
            :style="step === 'form'
              ? 'background-color: #003366;'
              : 'background-color: #51a0ce;'"
          >
            <svg v-if="step === 'confirm'" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
            <span v-else class="text-white text-xs font-bold">1</span>
          </div>
          <span class="text-xs font-semibold hidden sm:block" :style="step === 'form' ? 'color: #003366;' : 'color: #51a0ce;'">Datos personales</span>
        </div>

        <!-- Connector -->
        <div class="flex-1 mx-2 h-0.5" :style="step === 'confirm' ? 'background-color: #51a0ce;' : 'background-color: #e5e7eb;'"></div>

        <!-- Step 2 -->
        <div class="flex items-center gap-2 shrink-0">
          <div
            class="w-7 h-7 rounded-full flex items-center justify-center shrink-0"
            :style="step === 'confirm'
              ? 'background-color: #003366;'
              : 'background-color: #e5e7eb;'"
          >
            <span class="text-xs font-bold" :style="step === 'confirm' ? 'color: white;' : 'color: #9ca3af;'">2</span>
          </div>
          <span class="text-xs font-semibold hidden sm:block" :style="step === 'confirm' ? 'color: #003366;' : 'color: #9ca3af;'">Confirmación</span>
        </div>

        <!-- Connector -->
        <div class="flex-1 mx-2 h-0.5 bg-gray-200"></div>

        <!-- Step 3 -->
        <div class="flex items-center gap-2 shrink-0">
          <div class="w-7 h-7 rounded-full flex items-center justify-center shrink-0 bg-gray-200">
            <span class="text-xs font-bold text-gray-400">3</span>
          </div>
          <span class="text-xs font-semibold text-gray-400 hidden sm:block">Listo</span>
        </div>
      </div>

      <!-- ===== BODY ===== -->
      <div class="overflow-y-auto flex-1 p-6">

        <!-- ===== STEP: FORM ===== -->
        <div v-if="step === 'form'">

          <!-- Shift selection -->
          <div>
            <label class="text-xs font-semibold text-gray-600 mb-2 block">Turno de asistencia *</label>
            <div class="space-y-2">
              <label
                v-for="shift in availableShifts"
                :key="shift.id"
                class="flex items-center justify-between rounded-xl p-3 cursor-pointer border transition-all duration-150"
                :style="selectedShiftId === shift.id
                  ? 'border-color: #003366; background-color: rgba(0,51,102,0.04);'
                  : isShiftDisabled(shift) ? 'border-color: #e5e7eb; background-color: #f9fafb; opacity: 0.6; cursor: not-allowed;'
                  : 'border-color: #e5e7eb; background-color: white;'"
              >
                <div class="flex items-center gap-3 min-w-0">
                  <input
                    type="radio"
                    :value="shift.id"
                    v-model="selectedShiftId"
                    :disabled="isShiftDisabled(shift)"
                    class="shrink-0"
                    style="accent-color: #003366;"
                  />
                  <div class="min-w-0">
                    <p class="text-sm font-semibold text-gray-800 truncate">
                      {{ shift.shift_name || `Turno ${shift.shift_number}` }}
                    </p>
                    <p v-if="shift.start_time && shift.end_time" class="text-xs text-gray-500 mt-0.5">
                      {{ shift.start_time.slice(0, 5) }} – {{ shift.end_time.slice(0, 5) }}
                    </p>
                  </div>
                </div>
                <!-- Capacity badge -->
                <div class="shrink-0 ml-2">
                  <span
                    v-if="isShiftConflict(shift)"
                    class="text-xs font-semibold px-2.5 py-1 rounded-full"
                    style="background-color: rgba(245,158,11,0.12); color: #d97706;"
                  >Ya tienes este turno</span>
                  <span
                    v-else-if="isShiftDisabled(shift)"
                    class="text-xs font-semibold px-2.5 py-1 rounded-full"
                    style="background-color: rgba(239,68,68,0.12); color: #dc2626;"
                  >Completo</span>
                  <span
                    v-else
                    class="text-xs font-semibold px-2.5 py-1 rounded-full"
                    style="background-color: rgba(34,197,94,0.12); color: #16a34a;"
                  >{{ availableSpots(shift) }} cupos</span>
                </div>
              </label>
            </div>
          </div>

          <!-- Participant data -->
          <div class="mt-5">
            <p class="text-xs font-bold uppercase tracking-widest mb-3" style="color: #003366;">Tus datos</p>

            <!-- UPeU toggle -->
            <div class="mb-4">
              <p class="text-xs font-semibold text-gray-500 mb-2">¿Eres miembro de la UPeU?</p>
              <div class="flex gap-2">
                <button
                  type="button"
                  @click="selectUpeu(true)"
                  class="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold border-2 transition-all duration-150"
                  :style="isUpeu === true
                    ? 'border-color: #003366; background-color: #003366; color: white;'
                    : 'border-color: #e5e7eb; background-color: white; color: #6b7280;'"
                >
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                    :stroke="isUpeu === true ? 'white' : '#9ca3af'"
                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 10v6M2 10l10-5 10 5-10 5z"/>
                    <path d="M6 12v5c3 3 9 3 12 0v-5"/>
                  </svg>
                  Soy de la UPeU
                </button>
                <button
                  type="button"
                  @click="selectUpeu(false)"
                  class="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl text-sm font-semibold border-2 transition-all duration-150"
                  :style="isUpeu === false
                    ? 'border-color: #51a0ce; background-color: #51a0ce; color: white;'
                    : 'border-color: #e5e7eb; background-color: white; color: #6b7280;'"
                >
                  <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                    :stroke="isUpeu === false ? 'white' : '#9ca3af'"
                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                  </svg>
                  No soy de la UPeU
                </button>
              </div>
            </div>

            <!-- UPeU: student search -->
            <div v-if="isUpeu === true" class="mb-4">
              <label class="text-xs font-semibold text-gray-600 mb-1 block">
                Busca tu nombre por DNI o código de estudiante
              </label>
              <div class="flex gap-2">
                <input
                  type="text"
                  v-model="studentQuery"
                  placeholder="Ej: 74123456 o UPeU-2023-001"
                  class="flex-1 border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                  @keydown.enter.prevent="runStudentSearch"
                />
                <button
                  type="button"
                  @click="runStudentSearch"
                  class="px-3 py-2 rounded-lg flex items-center justify-center shrink-0 transition-colors duration-150"
                  style="background-color: #003366;"
                  onmouseover="this.style.backgroundColor='#004d99';"
                  onmouseout="this.style.backgroundColor='#003366';"
                >
                  <svg v-if="studentSearchStatus === 'searching'" class="animate-spin" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/>
                    <path d="M21 12a9 9 0 00-9-9"/>
                  </svg>
                  <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="11" cy="11" r="8"/>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                  </svg>
                </button>
              </div>

              <!-- Search results -->
              <div v-if="studentResults.length > 0" class="mt-1 rounded-xl border border-gray-200 overflow-hidden shadow-sm">
                <button
                  v-for="s in studentResults"
                  :key="s.id"
                  type="button"
                  @click="pickStudent(s)"
                  class="w-full text-left px-4 py-2.5 text-sm hover:bg-blue-50 border-b border-gray-100 last:border-0 transition-colors duration-100"
                >
                  <p class="font-semibold text-gray-800">{{ s.estudiante }}</p>
                  <p class="text-xs text-gray-500 mt-0.5">
                    <span v-if="s.documento">DNI {{ s.documento }}</span>
                    <span v-if="s.documento && s.codigo_estudiante"> · </span>
                    <span v-if="s.codigo_estudiante">{{ s.codigo_estudiante }}</span>
                    <span v-if="s.programa_estudio"> · {{ s.programa_estudio }}</span>
                  </p>
                </button>
              </div>
              <p v-else-if="studentSearchStatus === 'empty'" class="text-xs mt-1.5" style="color: #dc2626;">
                No se encontraron resultados. Verifica tu DNI o código.
              </p>

              <!-- Selected student chip -->
              <div v-if="selectedStudent && studentResults.length === 0 && studentSearchStatus === 'idle'" class="mt-2 flex items-center gap-2 px-3 py-2 rounded-lg" style="background-color: rgba(81,160,206,0.1); border: 1px solid rgba(81,160,206,0.3);">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <polyline points="20 6 9 17 4 12"/>
                </svg>
                <span class="text-xs font-medium" style="color: #1e6fa0;">Estudiante encontrado y datos pre-completados.</span>
              </div>
            </div>

            <!-- Non-UPeU: DNI field with auto-lookup -->
            <div v-if="isUpeu === false" class="mb-3">
              <label class="text-xs font-semibold text-gray-600 mb-1 block">DNI *</label>
              <div class="relative">
                <input
                  type="text"
                  v-model="form.dni"
                  placeholder="Ingresa tu DNI"
                  maxlength="20"
                  class="w-full border rounded-lg px-3 py-2 text-sm pr-9 focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                  :class="dniLookupStatus === 'found' ? 'border-green-400' : 'border-gray-200'"
                  @input="onDniInput"
                />
                <!-- Spinner / check icon -->
                <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none">
                  <svg v-if="dniLookupStatus === 'searching'" class="animate-spin" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/>
                    <path d="M21 12a9 9 0 00-9-9"/>
                  </svg>
                  <svg v-else-if="dniLookupStatus === 'found'" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="20 6 9 17 4 12"/>
                  </svg>
                </div>
              </div>
              <!-- Feedback message -->
              <p v-if="dniLookupStatus === 'found'" class="text-xs mt-1 font-medium" style="color: #16a34a;">
                Datos encontrados y completados automáticamente.
              </p>
              <p v-else-if="dniLookupStatus === 'not_found'" class="text-xs mt-1" style="color: #6b7280;">
                DNI no encontrado. Completa tus datos manualmente.
              </p>
            </div>

            <!-- Fields grid (shown when affiliation is selected) -->
            <div v-if="isUpeu !== null" class="grid grid-cols-2 gap-3" :class="isUpeu === true ? 'mt-0' : ''">
              <!-- DNI (UPeU — read-only after student pick) -->
              <div v-if="isUpeu === true" class="col-span-2">
                <label class="text-xs font-semibold text-gray-600 mb-1 block">DNI *</label>
                <input
                  type="text"
                  v-model="form.dni"
                  placeholder="Se completará al seleccionar"
                  maxlength="20"
                  class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                  :class="selectedStudent ? 'bg-gray-50' : ''"
                />
              </div>
              <!-- First name -->
              <div>
                <label class="text-xs font-semibold text-gray-600 mb-1 block">Nombres *</label>
                <input
                  type="text"
                  v-model="form.first_name"
                  placeholder="Nombres"
                  class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                />
              </div>
              <!-- Last name -->
              <div>
                <label class="text-xs font-semibold text-gray-600 mb-1 block">Apellidos *</label>
                <input
                  type="text"
                  v-model="form.last_name"
                  placeholder="Apellidos"
                  class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                />
              </div>
              <!-- Email -->
              <div class="col-span-2">
                <label class="text-xs font-semibold text-gray-600 mb-1 block">Correo electrónico</label>
                <input
                  type="email"
                  v-model="form.email"
                  placeholder="correo@ejemplo.com"
                  class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                />
              </div>
              <!-- Phone -->
              <div>
                <label class="text-xs font-semibold text-gray-600 mb-1 block">Celular</label>
                <input
                  type="tel"
                  v-model="form.phone"
                  placeholder="999 999 999"
                  class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                />
              </div>
              <!-- Institution -->
              <div>
                <label class="text-xs font-semibold text-gray-600 mb-1 block">
                  {{ isUpeu ? 'Programa / Facultad' : 'Institución / Colegio' }}
                </label>
                <input
                  type="text"
                  v-model="form.institution"
                  :placeholder="isUpeu ? 'Programa de estudio' : 'Nombre del colegio'"
                  class="w-full border border-gray-200 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-[#51a0ce]"
                />
              </div>
            </div>
          </div>

          <!-- Error alert -->
          <div
            v-if="formError"
            class="mt-4 flex items-start gap-2 rounded-lg px-4 py-3"
            style="background-color: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.25);"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <p class="text-sm" style="color: #dc2626;">{{ formError }}</p>
          </div>
        </div>

        <!-- ===== STEP: CONFIRM ===== -->
        <div v-else-if="step === 'confirm'">
          <div class="rounded-xl p-4" style="background-color: #f8fafc;">

            <!-- Workshop name -->
            <h3 class="font-bold text-base leading-snug" style="color: #003366;">{{ props.workshop?.name }}</h3>

            <!-- Specialty badge -->
            <div class="mt-2" v-if="props.workshop?.specialty">
              <span class="text-xs font-bold px-3 py-1 rounded-full text-white" :style="`background-color: ${props.workshop.specialty.color};`">
                {{ props.workshop.specialty.name }}
              </span>
            </div>

            <!-- Selected shift -->
            <div class="mt-3 flex items-center gap-2" v-if="selectedShift">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
              <span class="text-sm font-semibold text-gray-700">
                {{ selectedShift.shift_name || `Turno ${selectedShift.shift_number}` }}
              </span>
              <span v-if="selectedShift.start_time && selectedShift.end_time" class="text-sm text-gray-500">
                {{ selectedShift.start_time.slice(0, 5) }} – {{ selectedShift.end_time.slice(0, 5) }}
              </span>
            </div>

            <!-- Divider -->
            <div class="my-3 border-t border-gray-200"></div>

            <!-- Participant data -->
            <div class="space-y-1.5">
              <div class="flex items-center gap-2">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                  <circle cx="12" cy="7" r="4"/>
                </svg>
                <span class="text-sm font-semibold text-gray-800">{{ form.first_name }} {{ form.last_name }}</span>
              </div>
              <div class="flex items-center gap-2">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <rect x="2" y="5" width="20" height="14" rx="2"/>
                  <path d="M2 10h20"/>
                </svg>
                <span class="text-sm text-gray-600">DNI: {{ form.dni }}</span>
              </div>
              <div v-if="form.email" class="flex items-center gap-2">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                  <polyline points="22,6 12,13 2,6"/>
                </svg>
                <span class="text-sm text-gray-600">{{ form.email }}</span>
              </div>
              <div v-if="form.phone" class="flex items-center gap-2">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.81 19.79 19.79 0 01.17 1.18 2 2 0 012.18 1h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L6.91 8.09a16 16 0 006 6l1.27-.55a2 2 0 012.11.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/>
                </svg>
                <span class="text-sm text-gray-600">{{ form.phone }}</span>
              </div>
              <div v-if="form.institution" class="flex items-center gap-2">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#9ca3af" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
                  <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
                  <polyline points="9 22 9 12 15 12 15 22"/>
                </svg>
                <span class="text-sm text-gray-600">{{ form.institution }}</span>
              </div>
            </div>
          </div>

          <!-- Error alert on confirm step -->
          <div
            v-if="formError"
            class="mt-4 flex items-start gap-2 rounded-lg px-4 py-3"
            style="background-color: rgba(239,68,68,0.08); border: 1px solid rgba(239,68,68,0.25);"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0 mt-0.5">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <p class="text-sm" style="color: #dc2626;">{{ formError }}</p>
          </div>
        </div>

        <!-- ===== STEP: SUCCESS ===== -->
        <div v-else-if="step === 'success'" class="flex flex-col items-center py-4">

          <!-- Animated checkmark circle -->
          <div
            class="w-20 h-20 rounded-full flex items-center justify-center"
            style="background-color: #dcfce7;"
          >
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#16a34a" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="success-check">
              <polyline points="20 6 9 17 4 12"/>
            </svg>
          </div>

          <h3 class="text-2xl font-bold mt-4" style="color: #003366;">¡Inscripción Exitosa!</h3>
          <p class="text-gray-500 text-sm mt-1">Tu lugar está reservado</p>

          <!-- Confirmation code box -->
          <div
            class="mt-6 rounded-2xl py-5 px-8 text-center w-full"
            style="background-color: #003366;"
          >
            <p class="text-xs font-semibold uppercase tracking-widest" style="color: rgba(255,255,255,0.6);">
              Código de confirmación
            </p>
            <p class="text-3xl font-bold text-white tracking-widest mt-1">
              {{ result?.confirmation_code }}
            </p>
            <p class="text-xs mt-2" style="color: rgba(255,255,255,0.5);">
              Guarda este código para el día del evento
            </p>
          </div>

          <!-- Workshop + shift info -->
          <div class="mt-4 flex items-center gap-2 text-sm text-gray-600">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#51a0ce" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="shrink-0">
              <circle cx="12" cy="12" r="10"/>
              <polyline points="12 6 12 12 16 14"/>
            </svg>
            <span class="font-medium text-gray-700">{{ props.workshop?.name }}</span>
            <span v-if="selectedShift" class="text-gray-400">—</span>
            <span v-if="selectedShift">
              {{ selectedShift.shift_name || `Turno ${selectedShift.shift_number}` }}
            </span>
          </div>

          <!-- Registration number -->
          <p v-if="result?.registration_number" class="text-xs text-gray-400 mt-2">
            Inscripción N° {{ result.registration_number }}
          </p>
        </div>

      </div>

      <!-- ===== FOOTER ===== -->
      <div class="border-t border-gray-100 p-4 flex justify-between items-center gap-3 shrink-0">

        <!-- Step: form -->
        <template v-if="step === 'form'">
          <button
            type="button"
            @click="close"
            class="px-5 py-2.5 rounded-xl text-sm font-semibold border border-gray-200 text-gray-600 transition-colors duration-150 hover:bg-gray-50"
          >
            Cancelar
          </button>
          <button
            type="button"
            @click="nextStep"
            :disabled="!canSubmitForm"
            class="flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold text-white transition-all duration-150"
            :style="canSubmitForm ? 'background-color: #003366;' : 'background-color: #9ca3af; cursor: not-allowed;'"
            onmouseover="if(!this.disabled) this.style.backgroundColor='#004d99';"
            onmouseout="if(!this.disabled) this.style.backgroundColor='#003366';"
          >
            Siguiente
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="5" y1="12" x2="19" y2="12"/>
              <polyline points="12 5 19 12 12 19"/>
            </svg>
          </button>
        </template>

        <!-- Step: confirm -->
        <template v-else-if="step === 'confirm'">
          <button
            type="button"
            @click="step = 'form'"
            class="flex items-center gap-2 px-5 py-2.5 rounded-xl text-sm font-semibold border border-gray-200 text-gray-600 transition-colors duration-150 hover:bg-gray-50"
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <line x1="19" y1="12" x2="5" y2="12"/>
              <polyline points="12 19 5 12 12 5"/>
            </svg>
            Volver
          </button>
          <button
            type="button"
            @click="submitForm"
            :disabled="loading"
            class="flex items-center gap-2 px-6 py-2.5 rounded-xl text-sm font-bold text-white transition-all duration-150"
            :style="loading ? 'background-color: #9ca3af; cursor: not-allowed;' : 'background-color: #003366;'"
            onmouseover="if(!this.disabled) this.style.backgroundColor='#004d99';"
            onmouseout="if(!this.disabled) this.style.backgroundColor='#003366';"
          >
            <svg v-if="loading" class="animate-spin" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" stroke-opacity="0.3"/>
              <path d="M21 12a9 9 0 00-9-9"/>
            </svg>
            {{ loading ? 'Procesando...' : 'Confirmar inscripción' }}
          </button>
        </template>

        <!-- Step: success -->
        <template v-else-if="step === 'success'">
          <button
            type="button"
            @click="close"
            class="w-full py-2.5 rounded-xl text-sm font-bold text-white transition-colors duration-150"
            style="background-color: #003366;"
            onmouseover="this.style.backgroundColor='#004d99';"
            onmouseout="this.style.backgroundColor='#003366';"
          >
            Cerrar
          </button>
        </template>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { useRegistration } from '../composables/useRegistration'

// ===== TYPES =====
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
  workshop_date: string | null
  status: string
  specialty_id: string | null
  specialty: { id: string; name: string; color: string } | null
  shifts: Shift[]
}

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

// ===== PROPS & EMITS =====
const props = defineProps<{
  modelValue: boolean
  workshop: Workshop | null
}>()

const emit = defineEmits<{
  'update:modelValue': [value: boolean]
  'registered': []
}>()

// ===== COMPOSABLE =====
const { loading, lookupByDni, searchStudents, submitRegistration, reset, usedShiftNumbers } = useRegistration()

// ===== STATE =====
const step = ref<'form' | 'confirm' | 'success'>('form')
const selectedShiftId = ref<string | null>(null)
const form = ref<ParticipantForm>({
  dni: '',
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  institution: '',
})
const result = ref<RegistrationResult | null>(null)
const formError = ref<string | null>(null)

// UPeU toggle
const isUpeu = ref<boolean | null>(null)

// Student search
const studentQuery = ref('')
const studentResults = ref<import('../composables/useRegistration').Student[]>([])
const studentSearchStatus = ref<'idle' | 'searching' | 'found' | 'empty'>('idle')
const selectedStudent = ref<import('../composables/useRegistration').Student | null>(null)

// Non-UPeU DNI auto-lookup
const dniLookupStatus = ref<'idle' | 'searching' | 'found' | 'not_found'>('idle')
let dniLookupTimer: ReturnType<typeof setTimeout> | null = null

// ===== WATCH =====
watch(
  () => props.modelValue,
  (newVal) => {
    if (newVal) {
      step.value = 'form'
      selectedShiftId.value = null
      form.value = {
        dni: '',
        first_name: '',
        last_name: '',
        email: '',
        phone: '',
        institution: '',
      }
      result.value = null
      formError.value = null
      isUpeu.value = null
      dniLookupStatus.value = 'idle'
      if (dniLookupTimer) { clearTimeout(dniLookupTimer); dniLookupTimer = null }
      studentQuery.value = ''
      studentResults.value = []
      studentSearchStatus.value = 'idle'
      selectedStudent.value = null
      reset()
    }
  },
)

// ===== COMPUTED =====
const availableShifts = computed<Shift[]>(() => {
  if (!props.workshop?.shifts) return []
  return props.workshop.shifts.filter(
    (s) => (s as any).deleted_at === undefined || (s as any).deleted_at === null,
  )
})

const selectedShift = computed<Shift | undefined>(() =>
  availableShifts.value.find((s) => s.id === selectedShiftId.value),
)

const canSubmitForm = computed<boolean>(
  () =>
    isUpeu.value !== null &&
    !!form.value.dni &&
    !!form.value.first_name &&
    !!form.value.last_name &&
    !!selectedShiftId.value,
)

// ===== SHIFT HELPERS =====
function isShiftConflict(shift: Shift): boolean {
  return usedShiftNumbers.value.includes(shift.shift_number)
}

function isShiftDisabled(shift: Shift): boolean {
  if (shift.status === 'closed' || shift.status === 'full') return true
  if (availableSpots(shift) <= 0) return true
  return isShiftConflict(shift)
}

function availableSpots(shift: Shift): number {
  return (shift.capacity ?? 0) - (shift.registered_count ?? 0)
}

// ===== STUDENT HELPERS =====
function splitStudentName(fullName: string): { first_name: string; last_name: string } {
  const words = fullName.trim().split(/\s+/).filter(Boolean)
  if (words.length === 0) return { first_name: '', last_name: '' }
  if (words.length === 1) return { first_name: words[0], last_name: '' }
  const half = Math.ceil(words.length / 2)
  return {
    last_name: words.slice(0, half).join(' '),
    first_name: words.slice(half).join(' '),
  }
}

async function selectUpeu(value: boolean) {
  isUpeu.value = value
  form.value = { dni: '', first_name: '', last_name: '', email: '', phone: '', institution: '' }
  studentQuery.value = ''
  studentResults.value = []
  studentSearchStatus.value = 'idle'
  selectedStudent.value = null
  dniLookupStatus.value = 'idle'
  reset()

  if (value === false) {
    const savedDni = localStorage.getItem('last_registered_dni')
    if (savedDni) {
      form.value.dni = savedDni
      await runDniLookup(savedDni)
    }
  }
}

async function runDniLookup(dni: string) {
  if (!dni || dni.length < 7) return
  dniLookupStatus.value = 'searching'
  const participant = await lookupByDni(dni)
  if (participant) {
    form.value.first_name = participant.first_name
    form.value.last_name  = participant.last_name
    form.value.email      = participant.email
    form.value.phone      = participant.phone
    form.value.institution = participant.institution
    dniLookupStatus.value = 'found'
  } else {
    dniLookupStatus.value = 'not_found'
  }
}

function onDniInput() {
  dniLookupStatus.value = 'idle'
  if (dniLookupTimer) clearTimeout(dniLookupTimer)
  if (form.value.dni.length >= 8) {
    dniLookupTimer = setTimeout(() => runDniLookup(form.value.dni), 500)
  }
}

async function runStudentSearch() {
  if (studentQuery.value.trim().length < 3) return
  studentSearchStatus.value = 'searching'
  studentResults.value = []
  const results = await searchStudents(studentQuery.value.trim())
  studentResults.value = results
  studentSearchStatus.value = results.length > 0 ? 'found' : 'empty'
}

function pickStudent(student: import('../composables/useRegistration').Student) {
  selectedStudent.value = student
  studentResults.value = []
  studentSearchStatus.value = 'idle'
  studentQuery.value = student.estudiante ?? ''

  const { first_name, last_name } = splitStudentName(student.estudiante ?? '')
  form.value.dni = student.documento ?? ''
  form.value.first_name = first_name
  form.value.last_name = last_name
  form.value.email = student.correo_institucional ?? ''
  form.value.phone = student.celular ?? ''
  form.value.institution = student.programa_estudio ?? student.unidad_academica ?? ''
}

// ===== METHODS =====
function close() {
  emit('update:modelValue', false)
}

function nextStep() {
  formError.value = null
  if (isUpeu.value === null) {
    formError.value = 'Por favor indica si eres o no de la UPeU.'
    return
  }
  if (!form.value.dni || !form.value.first_name || !form.value.last_name || !selectedShiftId.value) {
    formError.value = 'Por favor completa los campos obligatorios: DNI, nombres, apellidos y turno.'
    return
  }
  step.value = 'confirm'
}

async function submitForm() {
  formError.value = null
  try {
    const res = await submitRegistration(
      form.value,
      props.workshop!.id,
      selectedShiftId.value!,
    )
    result.value = res
    step.value = 'success'
    // Save DNI for non-UPeU users so next registration auto-fills
    if (isUpeu.value === false && form.value.dni) {
      localStorage.setItem('last_registered_dni', form.value.dni)
    }
    emit('registered')
  } catch (err: any) {
    formError.value = err?.message ?? 'Ocurrió un error al procesar la inscripción.'
  }
}

</script>

<style scoped>
.success-check {
  animation: draw-check 0.5s ease forwards;
}

@keyframes draw-check {
  from {
    stroke-dasharray: 50;
    stroke-dashoffset: 50;
    opacity: 0;
  }
  to {
    stroke-dasharray: 50;
    stroke-dashoffset: 0;
    opacity: 1;
  }
}
</style>
