# 🔐 Guía de Configuración de Secrets

Esta guía te llevará paso a paso para configurar todos los secrets necesarios para el deployment automático del proyecto.

---

## 📋 Tabla de Contenidos

1. [Secrets de GitHub Actions](#secrets-de-github-actions)
2. [Railway Setup](#railway-setup)
3. [Google Play Console](#google-play-console)
4. [Apple App Store Connect](#apple-app-store-connect)
5. [Supabase](#supabase)
6. [ExerciseDB API](#exercisedb-api)
7. [Verificación](#verificación)

---

## Secrets de GitHub Actions

### Acceder a GitHub Secrets

1. Ve a tu repositorio en GitHub
2. Click en `Settings` → `Secrets and variables` → `Actions`
3. Click en `New repository secret`

---

## Railway Setup

Railway se usa para hospedar el Backend (NestJS) y ML Service (FastAPI).

### 1. Crear Cuenta en Railway

1. Ve a [railway.app](https://railway.app)
2. Sign up con GitHub
3. Conecta tu repositorio

### 2. Crear Proyectos

**Proyecto Backend:**
```bash
# En tu terminal
cd backend
railway link
```

**Proyecto ML Service:**
```bash
# En tu terminal
cd ml-service
railway link
```

### 3. Obtener Railway Token

1. Ve a [Railway Dashboard](https://railway.app/account/tokens)
2. Click en `Create Token`
3. Dale un nombre: `GitHub Actions CI/CD`
4. Copia el token

### 4. Agregar a GitHub Secrets

```
Nombre: RAILWAY_TOKEN
Valor: <tu_token_de_railway>
```

### 5. Configurar Variables de Entorno en Railway

**Backend (en Railway dashboard):**
```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@host:5432/dbname
JWT_SECRET=<genera_un_secret_fuerte>
JWT_REFRESH_SECRET=<genera_otro_secret_fuerte>
SUPABASE_URL=<tu_supabase_url>
SUPABASE_KEY=<tu_supabase_anon_key>
RAPIDAPI_KEY=<tu_rapidapi_key>
```

**ML Service (en Railway dashboard):**
```env
ENVIRONMENT=production
JWT_SECRET=<mismo_que_backend>
SENTRY_DSN=<opcional>
ML_SERVICE_URL=https://tu-ml-service.railway.app
```

Para generar secrets fuertes:
```bash
# En tu terminal
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## Google Play Console

Para deployment automático a Play Store (Internal Testing).

### 1. Crear Service Account

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto (o créalo)
3. Ve a `IAM & Admin` → `Service Accounts`
4. Click en `Create Service Account`
   - Name: `github-actions-deployer`
   - Role: `Service Account User`
5. Click en `Create Key` → `JSON`
6. Descarga el archivo JSON

### 2. Dar Permisos en Play Console

1. Ve a [Google Play Console](https://play.google.com/console/)
2. Ve a `Setup` → `API access`
3. Link el service account creado
4. Ve a `App permissions`
5. Selecciona tu app
6. Selecciona permisos:
   - ✅ View app information
   - ✅ Create and edit draft releases
   - ✅ Manage testing tracks

### 3. Agregar a GitHub Secrets

```
Nombre: GOOGLE_PLAY_SERVICE_ACCOUNT
Valor: <contenido_completo_del_json>
```

**Nota:** Pega todo el contenido del archivo JSON, incluyendo las llaves `{}`.

---

## Apple App Store Connect

Para deployment automático a TestFlight.

### 1. Crear App Store Connect API Key

1. Ve a [App Store Connect](https://appstoreconnect.apple.com/)
2. Ve a `Users and Access` → `Keys`
3. Click en `Generate API Key` (o usa una existente)
4. Dale un nombre: `GitHub Actions`
5. Rol: `Admin` (o `App Manager`)
6. Click en `Generate`

### 2. Descargar la Key

1. Click en `Download API Key`
2. **IMPORTANTE:** Solo puedes descargarla una vez
3. Guarda el archivo `.p8` de forma segura

### 3. Anotar la Información

Necesitas estos 3 datos:
- **Issuer ID**: En la parte superior de la página de Keys
- **Key ID**: En la columna de la key creada
- **Private Key**: Contenido del archivo `.p8`

### 4. Leer el Archivo .p8

```bash
cat AuthKey_XXXXXXXXXX.p8
```

Copia todo el contenido (incluyendo `-----BEGIN PRIVATE KEY-----` y `-----END PRIVATE KEY-----`)

### 5. Agregar a GitHub Secrets

```
Nombre: APPLE_ISSUER_ID
Valor: <issuer_id> (ej: 69a6de8f-5b6c-47e3-e053-5b8c7c11a4d1)

Nombre: APPLE_API_KEY_ID
Valor: <key_id> (ej: 2X9R4HXF34)

Nombre: APPLE_API_PRIVATE_KEY
Valor: <contenido_del_archivo_.p8>
```

### 6. Crear ExportOptions.plist

Crea un archivo llamado `ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>TU_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

Reemplaza `TU_TEAM_ID` con tu Apple Team ID (lo encuentras en tu cuenta de Apple Developer).

### 7. Agregar ExportOptions a Secrets

```bash
# Convierte el archivo a base64
cat ExportOptions.plist | base64
```

```
Nombre: IOS_EXPORT_OPTIONS
Valor: <contenido_en_base64>
```

---

## Supabase

### 1. Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com/)
2. Click en `New Project`
3. Dale un nombre: `health-fitness-app`
4. Crea una contraseña de base de datos (guárdala)
5. Selecciona región (preferiblemente cerca de tus usuarios)

### 2. Obtener Credenciales

1. Ve a `Settings` → `API`
2. Copia:
   - **Project URL**
   - **anon/public key**
   - **service_role key** (para el backend)

### 3. Configurar Base de Datos

1. Ve a `SQL Editor`
2. Ejecuta el schema del proyecto:

```sql
-- Ejecuta el contenido de database/schema.sql
-- O crea las tablas manualmente
```

### 4. Configurar OAuth Providers

**Google OAuth:**
1. Ve a `Authentication` → `Providers` → `Google`
2. Enable Google
3. Agrega tus credenciales de Google Cloud Console

**Apple OAuth:**
1. Ve a `Authentication` → `Providers` → `Apple`
2. Enable Apple
3. Agrega tus credenciales de Apple Developer

### 5. Configurar en Variables de Entorno

Estos NO son secrets de GitHub, sino variables de entorno en:
- Backend (Railway)
- Mobile (.env.local)

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## ExerciseDB API

Para acceder a la biblioteca de 1,000+ ejercicios.

### 1. Crear Cuenta en RapidAPI

1. Ve a [rapidapi.com](https://rapidapi.com/)
2. Sign up (gratis)

### 2. Suscribirse a ExerciseDB

1. Busca "ExerciseDB" en RapidAPI
2. Ve a la [página de ExerciseDB](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb)
3. Selecciona un plan:
   - **Free**: 100 requests/day (suficiente para testing)
   - **Basic**: $9.99/mes - 10,000 requests/month (recomendado para producción)
4. Click en `Subscribe`

### 3. Obtener API Key

1. En la página de ExerciseDB
2. Ve a la pestaña `Code Snippets`
3. Copia el valor de `X-RapidAPI-Key`

### 4. Configurar en Railway

Agrega en las variables de entorno del Backend:

```env
RAPIDAPI_KEY=tu_rapidapi_key_aqui
EXERCISEDB_HOST=exercisedb.p.rapidapi.com
```

---

## Snyk (Opcional)

Para security scanning avanzado.

### 1. Crear Cuenta en Snyk

1. Ve a [snyk.io](https://snyk.io/)
2. Sign up con GitHub
3. Conecta tu repositorio

### 2. Obtener Token

1. Ve a `Account Settings`
2. Copia el `API Token`

### 3. Agregar a GitHub Secrets

```
Nombre: SNYK_TOKEN
Valor: <tu_snyk_token>
```

---

## Codecov (Opcional)

Para visualización de cobertura de tests.

### 1. Crear Cuenta en Codecov

1. Ve a [codecov.io](https://codecov.io/)
2. Sign up con GitHub
3. Agrega tu repositorio

### 2. Obtener Token

1. Ve a tu repositorio en Codecov
2. Ve a `Settings` → `General`
3. Copia el `Upload Token`

### 3. Agregar a GitHub Secrets

```
Nombre: CODECOV_TOKEN
Valor: <tu_codecov_token>
```

---

## Sentry (Opcional)

Para error tracking.

### 1. Crear Cuenta en Sentry

1. Ve a [sentry.io](https://sentry.io/)
2. Sign up (gratis para pequeños proyectos)

### 2. Crear Proyectos

Crea 3 proyectos:
1. Backend (Node.js/NestJS)
2. ML Service (Python/FastAPI)
3. Mobile (Flutter)

### 3. Obtener DSN

Para cada proyecto:
1. Ve a `Settings` → `Client Keys (DSN)`
2. Copia el DSN

### 4. Configurar en Railway/Mobile

**Backend:**
```env
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

**ML Service:**
```env
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

**Mobile (.env):**
```env
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

---

## Verificación

### Checklist de Secrets de GitHub

- [ ] `RAILWAY_TOKEN`
- [ ] `GOOGLE_PLAY_SERVICE_ACCOUNT`
- [ ] `APPLE_ISSUER_ID`
- [ ] `APPLE_API_KEY_ID`
- [ ] `APPLE_API_PRIVATE_KEY`
- [ ] `IOS_EXPORT_OPTIONS`
- [ ] `ML_SERVICE_URL`
- [ ] `SNYK_TOKEN` (opcional)
- [ ] `CODECOV_TOKEN` (opcional)

### Verificar Configuración

1. **GitHub Actions:**
   ```bash
   # Hacer un pequeño cambio y push
   git commit --allow-empty -m "ci: test workflows"
   git push

   # Ve a Actions en GitHub y verifica que los workflows se ejecuten
   ```

2. **Railway:**
   ```bash
   # Verificar que los servicios estén desplegados
   curl https://tu-backend.railway.app/health
   curl https://tu-ml-service.railway.app/health
   ```

3. **Mobile Build:**
   ```bash
   # Verificar que puedes build localmente
   cd mobile
   flutter build apk --debug
   flutter build ios --debug --no-codesign
   ```

---

## Troubleshooting

### Error: "Secret not found"

**Solución:**
1. Verifica que el nombre del secret coincida exactamente
2. Los secrets son case-sensitive
3. No uses espacios en los nombres

### Error: Railway deployment fails

**Solución:**
1. Verifica que todas las variables de entorno estén configuradas
2. Revisa los logs en Railway dashboard
3. Asegúrate de que el `railway link` esté correcto

### Error: Google Play upload fails

**Solución:**
1. Verifica que el service account tenga los permisos correctos
2. Asegúrate de que el package name en `build.gradle` coincida con Play Console
3. Revisa que el version code sea mayor al anterior

### Error: TestFlight upload fails

**Solución:**
1. Verifica que los certificados y provisioning profiles estén actualizados
2. Asegúrate de que el Bundle ID coincida
3. Revisa que la App Store Connect API key sea válida

---

## Recursos Adicionales

- [GitHub Actions Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Railway Documentation](https://docs.railway.app/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Supabase Documentation](https://supabase.com/docs)

---

## Seguridad

### Mejores Prácticas

1. **Nunca** commitees secrets en el código
2. **Rota** los secrets regularmente (cada 3-6 meses)
3. **Usa** secrets diferentes para desarrollo y producción
4. **Revoca** secrets comprometidos inmediatamente
5. **Limita** el acceso a secrets solo a quien lo necesite

### Qué NO hacer

❌ Poner secrets en código
❌ Compartir secrets por email/chat
❌ Usar el mismo secret en múltiples servicios
❌ Commitear archivos `.env`
❌ Subir keys a repositorios públicos

### Qué SÍ hacer

✅ Usar GitHub Secrets
✅ Usar variables de entorno
✅ Rotar secrets regularmente
✅ Usar `.env.example` para documentar
✅ Agregar `.env` al `.gitignore`

---

**Última actualización:** 2025-11-17
**Versión:** 1.0.0
