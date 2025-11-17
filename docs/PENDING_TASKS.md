# ⏳ TAREAS PENDIENTES - Health & Fitness App

## 🔴 CRÍTICO - Para Producción (Requerido)

### 1. Configuración de Deployment (~2 horas)

- [ ] **Configurar GitHub Secrets** (30 min)
  - `RAILWAY_TOKEN`
  - `ML_SERVICE_URL`
  - `GOOGLE_PLAY_SERVICE_ACCOUNT`
  - `APPLE_ISSUER_ID`, `APPLE_API_KEY_ID`, `APPLE_API_PRIVATE_KEY`
  - `IOS_EXPORT_OPTIONS`

- [ ] **Configurar Railway** (20 min)
  - Backend: Todas las variables de entorno
  - ML Service: Todas las variables de entorno
  - Verificar deployments

- [ ] **Obtener API Keys** (15 min)
  - RapidAPI (ExerciseDB) - Plan básico recomendado
  - Supabase - Proyecto creado y configurado
  - Sentry (opcional) - Para error tracking

- [ ] **Configurar Android Signing** (20 min)
  - Generar keystore
  - Configurar key.properties
  - Configurar build.gradle
  - Agregar a .gitignore

- [ ] **Configurar iOS Certificates** (30 min)
  - Certificates en Apple Developer
  - Provisioning Profiles
  - Configure en Xcode
  - ExportOptions.plist

- [ ] **Primer Deploy Real** (2-3 horas)
  - Deploy database a Supabase
  - Deploy backend a Railway
  - Deploy ML service a Railway
  - Build y upload Android a Play Store (Internal Testing)
  - Build y upload iOS a TestFlight

---

## 🟡 IMPORTANTE - Testing (Recomendado)

### 2. Tests Faltantes Mobile (~9 horas)

#### Providers Tests (4 archivos, ~2 horas)
- [ ] `auth/providers/auth_provider_test.dart`
- [ ] `exercises/providers/exercises_provider_test.dart`
- [ ] `workouts/providers/workout_providers_test.dart`
- [ ] `gamification/providers/gamification_providers_test.dart`

#### Widget Tests Adicionales (8 archivos, ~4 horas)
- [ ] `exercise_detail_page_test.dart`
- [ ] `workout_session_page_test.dart`
- [ ] `profile_page_test.dart`
- [ ] `streak_card_test.dart`
- [ ] `user_stats_card_test.dart`
- [ ] `daily_quote_card_test.dart`
- [ ] `medication_calendar_page_test.dart`
- [ ] `add_edit_medication_page_test.dart`

#### Integration Tests con Patrol (3 archivos, ~3 horas)
- [ ] `integration_test/auth_flow_test.dart`
- [ ] `integration_test/workout_flow_test.dart`
- [ ] `integration_test/exercise_search_test.dart`

### 3. Tests Faltantes Backend (~6 horas)

#### Unit Tests NestJS (~4 horas)
- [ ] `auth/auth.service.spec.ts`
- [ ] `users/users.service.spec.ts`
- [ ] `workouts/workouts.service.spec.ts`
- [ ] `medications/medications.service.spec.ts`
- [ ] `gamification/gamification.service.spec.ts`

#### E2E Tests NestJS (~2 horas)
- [ ] `test/auth.e2e-spec.ts`
- [ ] `test/workouts.e2e-spec.ts`
- [ ] `test/gamification.e2e-spec.ts`

### 4. Tests Faltantes ML Service (~2 horas)

- [ ] `tests/test_workout_recommender.py`
- [ ] `tests/test_exercise_predictor.py`
- [ ] `tests/test_analytics.py`

---

## 🟢 OPCIONAL - Mejoras Pre-Launch

### 5. Monitoreo y Analytics (~2 horas)

- [ ] **Setup Sentry** (30 min)
  - Backend project
  - ML Service project
  - Mobile project
  - Configure DSNs

- [ ] **Setup Firebase** (1 hora)
  - Firebase project
  - Analytics
  - Performance Monitoring
  - Crashlytics

- [ ] **Setup Mixpanel** (opcional, 30 min)
  - Account setup
  - Event tracking
  - User properties

### 6. Features Opcionales (~7 horas)

- [ ] **Push Notifications** (2-3 horas)
  - Firebase Cloud Messaging
  - Backend endpoints
  - Mobile implementation
  - Test notifications

- [ ] **Deep Linking** (1-2 horas)
  - Configure App Links (Android)
  - Configure Universal Links (iOS)
  - Routing implementation

- [ ] **Optimizaciones Mobile** (2-3 horas)
  - Code splitting
  - Lazy loading
  - Image optimization
  - Build optimizations

### 7. Documentación Adicional (~4 horas)

- [ ] **API Documentation** (1 hora)
  - Postman collection
  - API examples
  - Response schemas

- [ ] **User Documentation** (2 horas)
  - User guide
  - FAQ
  - Video tutorials

- [ ] **Developer Onboarding** (1 hora)
  - Setup guide for new devs
  - Architecture overview
  - Code style guide

---

## 🔵 POST-MVP - Features Futuras

### 8. Features Planificadas (Alta Prioridad)

- [ ] Módulo de nutrición
- [ ] Social features (comunidad, amigos)
- [ ] Plan de entrenamiento personalizado con ML
- [ ] Coach virtual con IA
- [ ] Integración con wearables (Apple Health, Google Fit)

### 9. Features Planificadas (Media Prioridad)

- [ ] Challenges y competencias
- [ ] Marketplace de planes
- [ ] Video calls con entrenadores
- [ ] Análisis de forma con computer vision
- [ ] Seguimiento de sueño

### 10. Mejoras Técnicas Futuras

- [ ] GraphQL API
- [ ] WebSockets para real-time
- [ ] Redis caching
- [ ] Elasticsearch para búsqueda
- [ ] Message queue (RabbitMQ)
- [ ] Modelos ML más sofisticados (Deep Learning)

---

## 📊 RESUMEN

### ✅ Completado (100%)
- ✅ Código del MVP (Backend + ML + Mobile)
- ✅ Tests unitarios de modelos (10 archivos)
- ✅ Tests de repositorios (2 archivos)
- ✅ Tests de widgets (4 archivos)
- ✅ CI/CD completo (6 workflows)
- ✅ Documentación completa (README + 3 guías)

### ⏳ Pendiente para Producción (Crítico) - ~4-5 horas
- ⏳ Configuración de secrets y deployment
- ⏳ Primer deploy real
- ⏳ Testing en ambientes reales

### ⏳ Pendiente para Mejorar Calidad (Importante) - ~17 horas
- ⏳ Más tests mobile (providers, widgets, integration)
- ⏳ Backend tests (unit + E2E)
- ⏳ ML Service tests

### ⏳ Opcional (Nice to have) - ~13 horas
- ⏳ Monitoreo avanzado
- ⏳ Features opcionales
- ⏳ Documentación adicional

---

## 🎯 PRÓXIMO PASO RECOMENDADO

### Para lanzar a producción:

1. **Configurar todos los secrets** → Usar [`SECRETS_SETUP_GUIDE.md`](./SECRETS_SETUP_GUIDE.md)
2. **Hacer el primer deployment** → Usar [`DEPLOYMENT_GUIDE.md`](./DEPLOYMENT_GUIDE.md)
3. **Testing con usuarios reales** → Internal Testing (1-2 semanas)
4. **Fix bugs críticos** → Basado en feedback
5. **Beta testing** → Open Beta (2-4 semanas)
6. **Public launch** → Submit for review y marketing

**Tiempo estimado hasta producción:** 1-2 semanas (solo deployment crítico)

**Tiempo estimado con testing completo:** 4-6 semanas

---

## 📋 Checklist Rápido

**Para Deployment Mínimo:**
- [ ] Configurar secrets en GitHub
- [ ] Configurar variables en Railway
- [ ] Deploy backend y ML service
- [ ] Configurar signing Android/iOS
- [ ] Build y upload a Play Store/TestFlight
- [ ] Testing básico

**Para Producción Sólida (Recomendado):**
- [ ] Todo lo anterior +
- [ ] Tests de providers
- [ ] Integration tests
- [ ] Backend tests
- [ ] Monitoring con Sentry
- [ ] Analytics con Firebase
- [ ] Beta testing extensivo

---

**Última actualización:** 2025-11-17
**Estado:** MVP Code Completo - Pendiente Deployment
