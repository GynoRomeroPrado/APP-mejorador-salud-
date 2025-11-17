# CI/CD Pipeline Guide

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Workflows Disponibles](#workflows-disponibles)
3. [Configuración Inicial](#configuración-inicial)
4. [Secrets Requeridos](#secrets-requeridos)
5. [Flujo de Trabajo](#flujo-de-trabajo)
6. [Despliegue](#despliegue)
7. [Troubleshooting](#troubleshooting)

## Descripción General

El proyecto utiliza GitHub Actions para automatizar testing, building, y deployment de los tres componentes principales:

- **Backend** (NestJS): API REST con PostgreSQL
- **ML Service** (FastAPI): Microservicio de Machine Learning
- **Mobile** (Flutter): Aplicación móvil iOS/Android

## Workflows Disponibles

### 1. Backend CI/CD (`backend-ci.yml`)

**Triggers:**
- Push a `main`, `develop`, o `claude/**`
- Pull requests a `main` o `develop`
- Solo cuando hay cambios en `backend/**`

**Jobs:**
- **Test**: Ejecuta tests con cobertura en Node.js 18.x y 20.x
- **Security**: Auditoría de seguridad con npm audit y Snyk
- **Deploy**: Despliega a Railway (solo en `main`)

**Duración estimada:** 8-12 minutos

### 2. ML Service CI/CD (`ml-service-ci.yml`)

**Triggers:**
- Push a `main`, `develop`, o `claude/**`
- Pull requests a `main` o `develop`
- Solo cuando hay cambios en `ml-service/**`

**Jobs:**
- **Test**: Tests con Python 3.11 y 3.12
- **Security**: Safety check y Bandit scan
- **Deploy**: Despliega a Railway (solo en `main`)

**Duración estimada:** 6-10 minutos

### 3. Mobile CI/CD (`mobile-ci.yml`)

**Triggers:**
- Push a `main`, `develop`, o `claude/**`
- Pull requests a `main` o `develop`
- Solo cuando hay cambios en `mobile/**`

**Jobs:**
- **Analyze**: Flutter analyze y format check
- **Test**: Tests unitarios con cobertura (threshold 60%)
- **Integration Test**: Tests de integración con Patrol
- **Build Android**: APK y AAB
- **Build iOS**: IPA
- **Deploy Android**: Google Play Store (internal testing)
- **Deploy iOS**: TestFlight

**Duración estimada:** 15-25 minutos

### 4. Pull Request Checks (`pr-checks.yml`)

**Triggers:**
- Pull requests a `main` o `develop`

**Jobs:**
- **Changes Detection**: Detecta qué componentes cambiaron
- **PR Title Check**: Valida formato semantic commit
- **Code Quality**: CodeQL analysis
- **Component Checks**: Ejecuta checks específicos por componente
- **Size Check**: Compara tamaño de APK
- **Dependency Review**: Revisa dependencias nuevas
- **Auto Labeler**: Etiqueta PRs automáticamente
- **PR Comment**: Comenta resumen de checks

**Duración estimada:** 10-15 minutos

### 5. Scheduled Tasks (`scheduled-tasks.yml`)

**Triggers:**
- Cron diario a las 2 AM UTC
- Manual dispatch

**Jobs:**
- **Cleanup Branches**: Elimina branches `claude/*` > 7 días
- **Cleanup Workflows**: Elimina workflow runs > 30 días
- **Dependencies Report**: Genera reporte de licencias
- **Security Scan**: Trivy vulnerability scanner
- **Performance Audit**: Analiza tamaño de builds
- **Stale Issues**: Marca issues inactivos
- **Backup Config**: Backup de configuraciones

## Configuración Inicial

### 1. Habilitar GitHub Actions

En el repositorio:
1. Settings → Actions → General
2. Workflow permissions: "Read and write permissions"
3. Allow GitHub Actions to create and approve pull requests

### 2. Configurar Environments

Crear environment `production` en Settings → Environments:
- Deployment branches: `main` only
- Required reviewers: Al menos 1 revisor
- Environment secrets (ver sección de Secrets)

### 3. Configurar Branch Protection

Para `main`:
- Require status checks to pass
- Require branches to be up to date
- Require linear history
- Include administrators

Required status checks:
- Backend CI/CD / test
- ML Service CI/CD / test
- Mobile App CI/CD / test
- Pull Request Checks / pr-title-check

## Secrets Requeridos

### Repository Secrets

```bash
# Railway
RAILWAY_TOKEN=<railway_api_token>

# Snyk (opcional)
SNYK_TOKEN=<snyk_api_token>

# Codecov (opcional)
CODECOV_TOKEN=<codecov_token>
```

### Environment Secrets (production)

```bash
# Google Play Store
GOOGLE_PLAY_SERVICE_ACCOUNT=<service_account_json>

# Apple App Store
APPLE_ISSUER_ID=<apple_issuer_id>
APPLE_API_KEY_ID=<apple_api_key_id>
APPLE_API_PRIVATE_KEY=<apple_private_key>
IOS_EXPORT_OPTIONS=<export_options_plist>

# ML Service
ML_SERVICE_URL=<ml_service_production_url>
```

### Cómo Obtener los Secrets

#### Railway Token
1. Ir a https://railway.app/account/tokens
2. Crear nuevo token con permisos de deployment
3. Copiar y agregar como secret

#### Google Play Service Account
1. Google Cloud Console → IAM & Admin → Service Accounts
2. Crear service account con rol "Release Manager"
3. Crear key (JSON)
4. Copiar contenido del JSON como secret

#### Apple App Store Connect API
1. App Store Connect → Users and Access → Keys
2. Generar nueva key con rol "Admin"
3. Descargar `.p8` file
4. Copiar contenido como secret

## Flujo de Trabajo

### Desarrollo Normal

```bash
# 1. Crear feature branch
git checkout -b feat/nueva-caracteristica

# 2. Hacer cambios y commits
git add .
git commit -m "feat: agregar nueva característica"

# 3. Push a remote
git push origin feat/nueva-caracteristica

# 4. Crear Pull Request
# GitHub Actions ejecutará pr-checks.yml automáticamente

# 5. Revisar checks en la PR
# - PR title format
# - Code quality
# - Component-specific tests
# - Size comparison

# 6. Merge a develop (después de aprobación)
# Se ejecutan workflows de CI para develop

# 7. Merge a main (release)
# Se ejecutan workflows completos + deployment
```

### Sesiones Claude Code

```bash
# Las branches claude/* se crean automáticamente
# Formato: claude/feature-name-{session_id}

# Push changes
git push -u origin claude/health-fitness-app-mvp-01AbxmKPjLJbuCuw92StkENh

# Estas branches:
# - Ejecutan todos los workflows
# - Se eliminan automáticamente después de 7 días (scheduled-tasks)
# - Pueden hacer merge a develop/main
```

### Hotfix en Producción

```bash
# 1. Crear hotfix branch desde main
git checkout main
git pull
git checkout -b hotfix/descripcion-bug

# 2. Fix y commit
git add .
git commit -m "fix: corregir bug crítico en autenticación"

# 3. Push y crear PR a main
git push origin hotfix/descripcion-bug

# 4. Después de merge, se despliega automáticamente
```

## Despliegue

### Backend (Railway)

**Ambiente:** Production
**Trigger:** Push a `main`
**Servicio:** `backend`

**Proceso:**
1. Tests pasan exitosamente
2. Security audit sin vulnerabilidades altas
3. Deploy automático a Railway
4. Healthcheck: `GET /health`

**Rollback:**
```bash
# En Railway dashboard
railway service rollback backend --version <previous_version>
```

### ML Service (Railway)

**Ambiente:** Production
**Trigger:** Push a `main`
**Servicio:** `ml-service`

**Proceso:**
1. Tests con Python 3.11 y 3.12 pasan
2. Security scans limpios
3. Deploy automático a Railway
4. Verificación: `GET /health`

### Mobile App

#### Android (Google Play - Internal Testing)

**Trigger:** Push a `main`
**Track:** Internal Testing

**Proceso:**
1. Build AAB exitoso
2. Upload automático a Play Console
3. Disponible para internal testers en ~30 min

**Promover a producción:**
```bash
# Manual en Play Console
# Internal Testing → Closed Testing → Open Testing → Production
```

#### iOS (TestFlight)

**Trigger:** Push a `main`
**Proceso:**
1. Build IPA exitoso
2. Upload automático a App Store Connect
3. Disponible en TestFlight en ~1 hora

**Promover a producción:**
```bash
# Manual en App Store Connect
# TestFlight → Submit for Review → Production
```

## Troubleshooting

### Tests Fallando

**Síntoma:** Tests failing en CI pero pasan localmente

**Solución:**
```bash
# 1. Verificar versión de Node/Python/Flutter
node --version  # Debe coincidir con CI
python --version
flutter --version

# 2. Limpiar dependencias
rm -rf node_modules && npm ci  # Backend
rm -rf venv && pip install -r requirements.txt  # ML
flutter clean && flutter pub get  # Mobile

# 3. Ejecutar tests localmente
npm test  # Backend
pytest -v  # ML
flutter test  # Mobile
```

### Build Fallando

**Síntoma:** Build fails en CI

**Android:**
```bash
# Verificar gradle
cd mobile/android
./gradlew clean build

# Verificar signing config
cat android/app/build.gradle
```

**iOS:**
```bash
# Verificar pods
cd mobile/ios
pod install --repo-update

# Verificar signing
open ios/Runner.xcworkspace
# Product → Archive → Distribute App
```

### Deployment Fallando

**Railway:**
```bash
# Ver logs en Railway dashboard
railway logs --service backend
railway logs --service ml-service

# Verificar variables de entorno
railway variables
```

**Google Play:**
- Verificar service account tiene permisos
- Verificar bundle ID coincide
- Revisar en Play Console → Release dashboard

**TestFlight:**
- Verificar certificados y provisioning profiles
- Revisar en App Store Connect → TestFlight

### Secrets No Disponibles

**Síntoma:** Workflow fails con "Secret not found"

**Solución:**
1. Settings → Secrets and variables → Actions
2. Verificar nombre exacto del secret
3. Para environment secrets: Settings → Environments → production

### Cobertura de Tests Baja

**Síntoma:** Coverage threshold check fails

**Solución:**
```bash
# Mobile (threshold: 60%)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Identificar archivos con baja cobertura
# Agregar tests hasta alcanzar 60%
```

### Dependabot PRs Fallando

**Síntoma:** Dependabot PRs con tests failing

**Solución:**
```bash
# 1. Revisar changelog de dependencia actualizada
# 2. Actualizar código si hay breaking changes
# 3. Si es incompatible, cerrar PR y agregar a ignore en dependabot.yml

# Ejemplo en dependabot.yml:
# ignore:
#   - dependency-name: "package-name"
#     update-types: ["version-update:semver-major"]
```

## Mejores Prácticas

### Commits

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```bash
feat: nueva característica
fix: corrección de bug
docs: cambios en documentación
style: formateo, punto y coma faltante, etc
refactor: refactorización de código
perf: mejoras de performance
test: agregar tests
build: cambios en build system
ci: cambios en CI/CD
chore: otras tareas
```

### Pull Requests

- Título en formato semantic commit
- Descripción clara de cambios
- Incluir screenshots para cambios UI
- Vincular issues relacionados
- Mantener PRs pequeños (< 500 líneas)

### Branches

- `main`: Producción
- `develop`: Desarrollo
- `feat/*`: Nuevas features
- `fix/*`: Bug fixes
- `hotfix/*`: Hotfixes urgentes
- `claude/*`: Sesiones de Claude Code

### Testing

- Mantener cobertura > 60%
- Tests unitarios para toda lógica de negocio
- Tests de integración para flujos críticos
- Tests de widgets para UI compleja

## Monitoreo

### Codecov

Dashboard: https://codecov.io/gh/GynoRomeroPrado/APP-mejorador-salud-

Badges en README:
```markdown
![Backend Coverage](https://codecov.io/gh/USER/REPO/branch/main/graph/badge.svg?flag=backend)
![ML Coverage](https://codecov.io/gh/USER/REPO/branch/main/graph/badge.svg?flag=ml-service)
![Mobile Coverage](https://codecov.io/gh/USER/REPO/branch/main/graph/badge.svg?flag=mobile)
```

### Railway

Dashboard: https://railway.app/dashboard

Comandos útiles:
```bash
railway logs --service backend --lines 100
railway status
railway env
```

### GitHub Actions

Ver todos los workflows:
```
https://github.com/USER/REPO/actions
```

Ver workflow específico:
```
https://github.com/USER/REPO/actions/workflows/backend-ci.yml
```

## Recursos Adicionales

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Railway Documentation](https://docs.railway.app/)
- [Codecov Documentation](https://docs.codecov.com/)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Fastlane](https://fastlane.tools/)

## Contacto

Para preguntas sobre CI/CD:
- Issues: https://github.com/USER/REPO/issues
- Email: tu@email.com
