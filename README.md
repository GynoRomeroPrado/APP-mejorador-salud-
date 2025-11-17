# 💪 Health & Fitness App

> Aplicación móvil completa de salud y fitness con IA, gamificación y seguimiento personalizado

[![Backend CI](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/actions/workflows/backend-ci.yml)
[![ML Service CI](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/actions/workflows/ml-service-ci.yml/badge.svg)](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/actions/workflows/ml-service-ci.yml)
[![Mobile CI](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/actions/workflows/mobile-ci.yml/badge.svg)](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/actions/workflows/mobile-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/GynoRomeroPrado/APP-mejorador-salud-)

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Stack Tecnológico](#-stack-tecnológico)
- [Inicio Rápido](#-inicio-rápido)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Testing](#-testing)
- [CI/CD](#-cicd)
- [Deployment](#-deployment)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

---

## 🎯 Descripción

Health & Fitness App es una aplicación móvil completa que combina seguimiento de entrenamientos, recomendaciones personalizadas con Machine Learning, y un sistema de gamificación para mantener a los usuarios motivados en su viaje fitness.

### 🌟 MVP Completado (v1.0.0)

- ✅ **Autenticación**: Email/Password + OAuth (Google, Apple)
- ✅ **1,000+ Ejercicios**: Integración con ExerciseDB API
- ✅ **Entrenamientos**: Creación, seguimiento y análisis de rutinas
- ✅ **Gamificación**: Sistema de XP, niveles, logros y rachas
- ✅ **IA/ML**: Recomendaciones personalizadas con Machine Learning
- ✅ **Testing**: >65% cobertura en mobile, >80% en backend
- ✅ **CI/CD**: Deployment automático con GitHub Actions

---

## ✨ Características

### 🔐 Autenticación y Perfiles

- Registro e inicio de sesión con email/password
- OAuth 2.0 con Google y Apple
- Onboarding personalizado de 3 pasos
- Perfiles de usuario con métricas de salud (altura, peso, BMI)
- Gestión de sesiones con JWT y refresh tokens

### 💪 Biblioteca de Ejercicios

- **1,000+ ejercicios** con animaciones GIF
- Búsqueda y filtrado avanzado
- 14 grupos musculares
- 20+ tipos de equipamiento
- Favoritos offline con sincronización inteligente
- Traducciones al español

### 🏋️ Seguimiento de Entrenamientos

- Creación de rutinas personalizadas
- Plantillas predefinidas
- Tracking en tiempo real con timer
- Registro de sets (peso, repeticiones, notas)
- Historial completo con estadísticas
- Seguimiento de Personal Records (PRs)
- Estimación de calorías quemadas

### 🎮 Gamificación

- **Sistema de XP**: Gana experiencia por cada actividad
- **Niveles**: Progresión con fórmula exponencial
- **6 Títulos**: Desde Principiante hasta Campeón
- **Logros**: 15+ achievements con 4 niveles de dificultad
- **Rachas**: Seguimiento de días consecutivos
- **Quotes Diarios**: Frases motivacionales

### 🤖 Inteligencia Artificial

- Recomendaciones de workouts con Random Forest
- Predicción de ejercicios con K-NN
- Análisis de progreso
- Insights personalizados
- Estimación inteligente de calorías

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                    Mobile App (Flutter)                  │
│  ┌────────┐  ┌──────────┐  ┌────────────┐  ┌──────────┐ │
│  │   UI   │→ │ Providers│→ │Repositories│→ │DataSources│ │
│  └────────┘  └──────────┘  └────────────┘  └──────────┘ │
└───────────────────────────────┬─────────────────────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
          ┌─────────────────┐    ┌──────────────────┐
          │  NestJS Backend │    │  FastAPI ML      │
          │      API        │◄───│    Service       │
          └────────┬────────┘    └──────────────────┘
                   │
          ┌────────┴────────┐
          │   PostgreSQL    │
          │   (Supabase)    │
          └─────────────────┘
```

**Patrón:** Clean Architecture + Microservices

---

## 🛠️ Stack Tecnológico

### Mobile App

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| Flutter | 3.19+ | Framework UI |
| Dart | 3.2+ | Lenguaje |
| Riverpod | 2.4+ | State Management |
| Freezed | 2.4+ | Immutable Models |
| Hive | 2.2+ | Local Storage |

### Backend

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| NestJS | 10.x | Framework Backend |
| TypeScript | 5.x | Lenguaje |
| PostgreSQL | 16+ | Base de Datos |
| TypeORM | 0.3+ | ORM |
| Passport | 0.7+ | Autenticación |

### ML Service

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| FastAPI | 0.104+ | Framework ML API |
| Python | 3.11+ | Lenguaje |
| scikit-learn | 1.3+ | ML Algorithms |
| XGBoost | 2.0+ | Gradient Boosting |

### DevOps

| Tecnología | Propósito |
|------------|-----------|
| GitHub Actions | CI/CD |
| Railway | Hosting Backend + ML |
| Supabase | Database + Auth |
| Codecov | Code Coverage |

---

## 🚀 Inicio Rápido

### Prerequisitos

```bash
# Node.js 18+
node --version  # v18.x o superior

# Python 3.11+
python --version  # 3.11 o superior

# Flutter 3.19+
flutter --version  # 3.19 o superior
```

### Clonar Repositorio

```bash
git clone https://github.com/GynoRomeroPrado/APP-mejorador-salud-.git
cd APP-mejorador-salud-
```

### Setup Backend

```bash
cd backend
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus configuraciones

# Ejecutar migraciones
npm run migration:run

# Iniciar en desarrollo
npm run start:dev
```

Backend corriendo en `http://localhost:3000`
Swagger docs en `http://localhost:3000/api`

### Setup ML Service

```bash
cd ml-service

# Crear virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env

# Iniciar servicio
python main.py
```

ML Service corriendo en `http://localhost:8000`
Docs en `http://localhost:8000/docs`

### Setup Mobile App

```bash
cd mobile

# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en emulador/dispositivo
flutter run
```

---

## 📁 Estructura del Proyecto

```
APP-mejorador-salud-/
│
├── backend/                    # NestJS Backend API
│   ├── src/
│   │   ├── auth/              # Módulo de autenticación
│   │   ├── users/             # Gestión de usuarios
│   │   ├── medications/       # Seguimiento de medicamentos
│   │   ├── workouts/          # Entrenamientos
│   │   ├── gamification/      # Sistema de gamificación
│   │   └── common/            # Utilidades comunes
│   └── test/                  # Tests
│
├── ml-service/                # FastAPI ML Service
│   ├── models/                # Modelos ML
│   ├── routers/               # API Routers
│   ├── middleware/            # Auth, rate limiting
│   └── tests/                 # Tests
│
├── mobile/                    # Flutter Mobile App
│   ├── lib/
│   │   ├── features/          # Features modulares
│   │   │   ├── auth/          # Autenticación
│   │   │   ├── exercises/     # Ejercicios
│   │   │   ├── workouts/      # Entrenamientos
│   │   │   └── gamification/  # Gamificación
│   │   └── core/              # Core utilities
│   └── test/                  # Tests completos
│
├── .github/                   # GitHub Actions workflows
│   ├── workflows/             # 6 CI/CD pipelines
│   ├── dependabot.yml         # Dependency updates
│   └── CI_CD_GUIDE.md         # Guía de CI/CD
│
├── docs/                      # Documentación
│   └── MVP_COMPLETO_100_PORCIENTO.md
│
└── README.md                  # Este archivo
```

---

## 🧪 Testing

### Mobile Tests

```bash
# Tests unitarios
flutter test

# Tests con cobertura
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration tests
patrol test
```

**Cobertura:** ~65% | **Tests:** 14 archivos

### Backend Tests

```bash
# Tests con cobertura
npm run test:cov

# Tests E2E
npm run test:e2e
```

**Cobertura:** ~85%

### ML Service Tests

```bash
# Tests con cobertura
pytest --cov
```

**Cobertura:** ~80%

---

## 🔄 CI/CD

Usamos **GitHub Actions** para automatización completa.
Ver [CI/CD Guide](.github/CI_CD_GUIDE.md) para detalles.

### Workflows Activos

✅ **Backend CI/CD** - Testing, security, deploy (8-12 min)
✅ **ML Service CI/CD** - Testing, security, deploy (6-10 min)
✅ **Mobile CI/CD** - Testing, build, deploy (15-25 min)
✅ **PR Checks** - Validación de Pull Requests (10-15 min)
✅ **Scheduled Tasks** - Cleanup, security scans (diario)
✅ **Release** - Automatización de releases

---

## 🚢 Deployment

### Backend & ML Service (Railway)

```bash
# Install Railway CLI
npm install -g @railway/cli

# Deploy backend
cd backend
railway up --service backend

# Deploy ML service
cd ml-service
railway up --service ml-service
```

**URLs Producción:**
- Backend API: `https://api.healthfitness.app`
- ML Service: `https://ml.healthfitness.app`

### Mobile App

**Android:**
```bash
flutter build appbundle --release
# Upload a Play Console (automático via CI)
```

**iOS:**
```bash
flutter build ios --release
# Upload a TestFlight (automático via CI)
```

---

## 💻 Comandos Útiles

### Backend
```bash
npm run start:dev    # Desarrollo
npm run build        # Build producción
npm run test:cov     # Tests con cobertura
npm run lint         # Linter
```

### ML Service
```bash
python main.py       # Iniciar servidor
pytest --cov         # Tests con cobertura
black .              # Formatear código
flake8 .             # Linter
```

### Mobile
```bash
flutter run          # Ejecutar app
flutter test         # Tests unitarios
flutter analyze      # Analizar código
flutter build apk    # Build Android
dart format .        # Formatear código
```

---

## 🤝 Contribuir

¡Contribuciones son bienvenidas!

### Proceso

1. Fork el repositorio
2. Crear feature branch (`git checkout -b feat/amazing-feature`)
3. Commit cambios (`git commit -m 'feat: add amazing feature'`)
4. Push a branch (`git push origin feat/amazing-feature`)
5. Abrir Pull Request

### Conventional Commits

```
feat:     nueva característica
fix:      corrección de bug
docs:     cambios en documentación
style:    formateo, punto y coma, etc
refactor: refactorización de código
perf:     mejoras de performance
test:     agregar tests
ci:       cambios en CI/CD
```

---

## 📞 Soporte

- 📧 Email: support@healthfitness.app
- 🐛 Issues: [GitHub Issues](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/issues)
- 📖 Docs: [Documentation](docs/)

---

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 👥 Autores

- **Gyno Romero Prado** - [@GynoRomeroPrado](https://github.com/GynoRomeroPrado)

Ver [contributors](https://github.com/GynoRomeroPrado/APP-mejorador-salud-/contributors) para más información.

---

## 🙏 Agradecimientos

- [ExerciseDB](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb) - API de ejercicios
- [Supabase](https://supabase.com/) - Backend as a Service
- [Railway](https://railway.app/) - Hosting platform
- [Flutter Team](https://flutter.dev/) - Framework móvil
- [NestJS Team](https://nestjs.com/) - Framework backend
- [FastAPI](https://fastapi.tiangolo.com/) - Framework Python

---

## 📊 Estado del Proyecto

![GitHub last commit](https://img.shields.io/github/last-commit/GynoRomeroPrado/APP-mejorador-salud-)
![GitHub issues](https://img.shields.io/github/issues/GynoRomeroPrado/APP-mejorador-salud-)
![GitHub pull requests](https://img.shields.io/github/issues-pr/GynoRomeroPrado/APP-mejorador-salud-)

**Versión:** 1.0.0
**Estado:** ✅ MVP Completado
**Última actualización:** 2025-11-17

---

<p align="center">
  Hecho con ❤️ y 💪 para la comunidad fitness
</p>
