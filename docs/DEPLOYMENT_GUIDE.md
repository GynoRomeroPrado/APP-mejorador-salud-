# 🚀 Guía de Deployment Paso a Paso

Esta guía te llevará desde cero hasta tener tu aplicación completamente desplegada en producción.

---

## 📋 Prerequisitos

Antes de comenzar, asegúrate de tener:

- [ ] Cuenta de GitHub con repositorio configurado
- [ ] Cuenta de Railway (gratis)
- [ ] Cuenta de Supabase (gratis)
- [ ] Cuenta de Google Play Console ($25 one-time)
- [ ] Cuenta de Apple Developer ($99/año)
- [ ] RapidAPI account (gratis o plan básico)

---

## 🎯 Roadmap de Deployment

```
1. Database (Supabase)         [15 min]
   ↓
2. Backend API (Railway)       [20 min]
   ↓
3. ML Service (Railway)        [15 min]
   ↓
4. Configure Secrets           [30 min]
   ↓
5. Mobile App Build           [30 min]
   ↓
6. Deploy Android             [20 min]
   ↓
7. Deploy iOS                 [30 min]
   ↓
8. Verify & Test              [20 min]

Total: ~3 horas
```

---

## 1️⃣ Database (Supabase)

### Paso 1.1: Crear Proyecto

1. Ve a [supabase.com](https://supabase.com/)
2. Click en `New Project`
3. Configuración:
   ```
   Name: health-fitness-prod
   Database Password: <genera_password_fuerte>
   Region: South America (o la más cercana a tus usuarios)
   Plan: Free (puedes upgradar después)
   ```
4. Click en `Create Project` (toma ~2 minutos)

### Paso 1.2: Ejecutar Schema

1. Ve a `SQL Editor`
2. Click en `New Query`
3. Copia y pega el contenido de `database/schema.sql`
4. Click en `Run` o `Ctrl+Enter`
5. Verifica que no haya errores

**Nota:** Si no tienes el archivo schema.sql, puedes crear las tablas manualmente basándote en los modelos del backend.

### Paso 1.3: Configurar Row Level Security (RLS)

```sql
-- Enable RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercise_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;

-- Policy para users (solo puede ver su propio perfil)
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = user_id::uuid);

-- Policy para workouts
CREATE POLICY "Users can view own workouts" ON workouts
    FOR SELECT USING (auth.uid() = user_id::uuid);

CREATE POLICY "Users can create own workouts" ON workouts
    FOR INSERT WITH CHECK (auth.uid() = user_id::uuid);

-- Repetir para otras tablas según necesites...
```

### Paso 1.4: Configurar OAuth Providers

**Google OAuth:**
1. Ve a `Authentication` → `Providers`
2. Click en `Google`
3. Enable Google provider
4. Ve a [Google Cloud Console](https://console.cloud.google.com/)
5. Crea OAuth 2.0 credentials
6. Agrega redirect URI: `https://xxxxx.supabase.co/auth/v1/callback`
7. Copia Client ID y Client Secret
8. Pégalos en Supabase

**Apple OAuth:**
1. Similar a Google, usando Apple Developer
2. Configura Sign in with Apple
3. Agrega Service ID
4. Configura redirect URI

### Paso 1.5: Guardar Credenciales

Anota estas credenciales (las necesitarás después):

```
SUPABASE_URL: https://xxxxx.supabase.co
SUPABASE_ANON_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
DATABASE_URL: postgresql://postgres:[PASSWORD]@db.xxxxx.supabase.co:5432/postgres
```

---

## 2️⃣ Backend API (Railway)

### Paso 2.1: Instalar Railway CLI

```bash
npm install -g @railway/cli
```

### Paso 2.2: Login a Railway

```bash
railway login
```

Se abrirá un navegador. Autoriza con GitHub.

### Paso 2.3: Crear Proyecto Backend

```bash
cd backend
railway init
```

Selecciona:
- Create new project: `health-fitness-backend`
- Environment: `production`

### Paso 2.4: Link al Proyecto

```bash
railway link
```

Selecciona el proyecto que acabas de crear.

### Paso 2.5: Configurar Variables de Entorno

```bash
# Via CLI
railway variables set NODE_ENV=production
railway variables set PORT=3000
railway variables set JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
railway variables set JWT_REFRESH_SECRET=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")

# O via Dashboard (recomendado)
railway open
```

En el dashboard, ve a Variables y agrega:

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=<tu_supabase_database_url>
JWT_SECRET=<genera_uno_fuerte>
JWT_REFRESH_SECRET=<genera_otro_fuerte>
SUPABASE_URL=<tu_supabase_url>
SUPABASE_KEY=<tu_supabase_anon_key>
RAPIDAPI_KEY=<tu_rapidapi_key>
CORS_ORIGIN=*
```

### Paso 2.6: Deploy

```bash
railway up
```

Espera a que termine el build (~5 minutos).

### Paso 2.7: Obtener URL Pública

```bash
railway domain
```

O en el dashboard, ve a Settings → Generate Domain.

Guarda la URL: `https://health-fitness-backend.up.railway.app`

### Paso 2.8: Verificar Deployment

```bash
curl https://tu-backend.railway.app/health
```

Deberías recibir: `{"status":"ok"}`

### Paso 2.9: Verificar Swagger Docs

Ve a: `https://tu-backend.railway.app/api`

Deberías ver la documentación de Swagger.

---

## 3️⃣ ML Service (Railway)

### Paso 3.1: Crear Proyecto ML

```bash
cd ../ml-service
railway init
```

Nombre: `health-fitness-ml`

### Paso 3.2: Link al Proyecto

```bash
railway link
```

### Paso 3.3: Configurar Variables de Entorno

En Railway dashboard:

```env
ENVIRONMENT=production
JWT_SECRET=<mismo_que_backend>
BACKEND_URL=https://tu-backend.railway.app
SENTRY_DSN=<opcional>
```

### Paso 3.4: Deploy

```bash
railway up
```

### Paso 3.5: Generar Dominio

```bash
railway domain
```

Guarda la URL: `https://health-fitness-ml.up.railway.app`

### Paso 3.6: Verificar Deployment

```bash
curl https://tu-ml-service.railway.app/health
```

Ve a docs: `https://tu-ml-service.railway.app/docs`

---

## 4️⃣ Configurar GitHub Secrets

Sigue la guía completa en [SECRETS_SETUP_GUIDE.md](./SECRETS_SETUP_GUIDE.md).

Secrets mínimos necesarios:

```
RAILWAY_TOKEN
ML_SERVICE_URL=https://tu-ml-service.railway.app
GOOGLE_PLAY_SERVICE_ACCOUNT (para Android)
APPLE_ISSUER_ID (para iOS)
APPLE_API_KEY_ID (para iOS)
APPLE_API_PRIVATE_KEY (para iOS)
IOS_EXPORT_OPTIONS (para iOS)
```

---

## 5️⃣ Mobile App Build

### Paso 5.1: Configurar Variables de Entorno

Crea `mobile/.env.production`:

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
API_BASE_URL=https://tu-backend.railway.app
ML_SERVICE_URL=https://tu-ml-service.railway.app
ENVIRONMENT=production
```

### Paso 5.2: Actualizar Version

Edita `mobile/pubspec.yaml`:

```yaml
version: 1.0.0+1  # formato: version+buildNumber
```

### Paso 5.3: Build Local (Verificación)

**Android:**
```bash
cd mobile
flutter build apk --release
```

APK en: `build/app/outputs/flutter-apk/app-release.apk`

**iOS (solo en Mac):**
```bash
flutter build ios --release --no-codesign
```

---

## 6️⃣ Deploy Android (Google Play)

### Paso 6.1: Crear Keystore para Firma

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Te pedirá:
# - Password del keystore (guárdalo)
# - Nombre, organización, ciudad, país
# - Password del key (puede ser el mismo)
```

### Paso 6.2: Configurar Signing en Android

Crea `mobile/android/key.properties`:

```properties
storePassword=<tu_password>
keyPassword=<tu_password>
keyAlias=upload
storeFile=<path_to_keystore>/upload-keystore.jks
```

**IMPORTANTE:** Agrega al `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

Edita `mobile/android/app/build.gradle`:

```gradle
// Antes de android {
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Paso 6.3: Crear App en Google Play Console

1. Ve a [Play Console](https://play.google.com/console/)
2. Click en `Create app`
3. Configuración:
   ```
   Name: Health & Fitness App
   Default language: Spanish
   App or game: App
   Free or paid: Free (o Paid si cobrarás)
   ```
4. Acepta las políticas

### Paso 6.4: Configurar App Details

1. `App details`:
   - Short description (80 chars)
   - Full description (4000 chars)
   - App icon (512×512 PNG)
   - Feature graphic (1024×500 PNG)

2. `Content rating`:
   - Completa el cuestionario
   - Para fitness app, generalmente es EVERYONE

3. `Target audience`:
   - Age: 18+
   - Target audience: Health & Fitness

4. `Privacy Policy`:
   - URL de tu privacy policy
   - (puedes usar un generador gratuito)

### Paso 6.5: Build y Upload AAB

```bash
flutter build appbundle --release
```

AAB en: `build/app/outputs/bundle/release/app-release.aab`

### Paso 6.6: Crear Release (Internal Testing)

1. En Play Console, ve a `Testing` → `Internal testing`
2. Click en `Create new release`
3. Upload `app-release.aab`
4. Release name: `1.0.0 (1)`
5. Release notes:
   ```
   Primera versión de Health & Fitness App
   - Sistema de autenticación
   - 1,000+ ejercicios
   - Tracking de workouts
   - Sistema de gamificación
   ```
6. Click en `Save` → `Review release` → `Start rollout to Internal testing`

### Paso 6.7: Agregar Testers

1. Ve a `Testing` → `Internal testing` → `Testers`
2. Click en `Create email list`
3. Agrega emails de testers (mínimo tu email)
4. Guarda

Los testers recibirán un email con link para instalar la app.

---

## 7️⃣ Deploy iOS (TestFlight)

**Nota:** Necesitas una Mac para esto.

### Paso 7.1: Configurar Xcode

1. Abre el proyecto iOS:
   ```bash
   cd mobile/ios
   open Runner.xcworkspace
   ```

2. En Xcode:
   - Selecciona `Runner` en el navegador
   - En `General`:
     - Bundle Identifier: `com.healthfitness.app`
     - Version: `1.0.0`
     - Build: `1`
   - En `Signing & Capabilities`:
     - Team: Selecciona tu Apple Developer team
     - Automatically manage signing: ✅

### Paso 7.2: Configurar Capabilities

En `Signing & Capabilities`, agrega:
- ✅ Push Notifications (si usarás)
- ✅ Sign in with Apple (si usarás)
- ✅ HealthKit (si usarás)

### Paso 7.3: Crear App en App Store Connect

1. Ve a [App Store Connect](https://appstoreconnect.apple.com/)
2. Click en `My Apps` → `+` → `New App`
3. Configuración:
   ```
   Platform: iOS
   Name: Health & Fitness App
   Primary Language: Spanish
   Bundle ID: com.healthfitness.app (debe coincidir con Xcode)
   SKU: HEALTH-FITNESS-001
   User Access: Full Access
   ```

### Paso 7.4: Build Archive

En Xcode:
1. Selecciona `Any iOS Device (arm64)` como destino
2. Menu → `Product` → `Archive`
3. Espera a que complete (~10 min)
4. Se abrirá el Organizer

### Paso 7.5: Upload a TestFlight

En Organizer:
1. Selecciona el archive
2. Click en `Distribute App`
3. Selecciona `App Store Connect`
4. Selecciona `Upload`
5. Opciones:
   - ✅ Include bitcode: NO
   - ✅ Upload symbols: YES
   - ✅ Manage version: Automatically
6. Click en `Upload`
7. Espera (~15 min para processing)

### Paso 7.6: Configurar TestFlight

1. En App Store Connect, ve a tu app
2. Ve a `TestFlight`
3. Espera a que el build aparezca
4. Agrega información de prueba:
   - What to test: Descripción de features
   - Email: Para notificaciones
5. Agrega testers:
   - Ve a `Internal Group`
   - Agrega emails de testers
6. Click en `Start Testing`

Los testers recibirán email con invitación.

---

## 8️⃣ Verificación y Testing

### Paso 8.1: Verificar Backend

```bash
# Health check
curl https://tu-backend.railway.app/health

# Swagger docs
open https://tu-backend.railway.app/api

# Test auth endpoint
curl -X POST https://tu-backend.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'
```

### Paso 8.2: Verificar ML Service

```bash
# Health check
curl https://tu-ml-service.railway.app/health

# API docs
open https://tu-ml-service.railway.app/docs

# Test recommendation
curl -X POST https://tu-ml-service.railway.app/recommendations/workout \
  -H "Content-Type: application/json" \
  -d '{"user_data":{"fitness_level":"beginner"},"preferences":{}}'
```

### Paso 8.3: Verificar Database

```bash
# En Supabase SQL Editor
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM workouts;
SELECT COUNT(*) FROM exercises;
```

### Paso 8.4: Test Mobile App

**Android (Internal Testing):**
1. Abre el email de invitación
2. Click en link de Play Store
3. Instala la app
4. Prueba:
   - ✅ Login/Registro
   - ✅ Ver ejercicios
   - ✅ Crear workout
   - ✅ Completar sesión
   - ✅ Ver progreso

**iOS (TestFlight):**
1. Instala TestFlight de App Store
2. Abre el email de invitación
3. Click en `View in TestFlight`
4. Instala la app
5. Prueba las mismas features

### Paso 8.5: Verificar CI/CD

```bash
# Hacer un cambio pequeño
git commit --allow-empty -m "ci: verify workflows"
git push

# Ve a GitHub Actions
# Verifica que todos los workflows pasen
```

### Paso 8.6: Monitoring

**Railway:**
- Ve a dashboard
- Verifica metrics (CPU, Memory, Requests)
- Revisa logs

**Supabase:**
- Ve a Dashboard
- Verifica Database size
- Revisa Auth users
- Checa Storage usage

---

## 9️⃣ Post-Deployment

### Configurar Monitoring

**Sentry (Error Tracking):**
1. Configura proyectos para backend, ML, mobile
2. Agrega DSN a variables de entorno
3. Verifica que los errores se capturen

**Analytics:**
1. Configura Firebase Analytics (opcional)
2. Agrega Google Analytics para web
3. Set up event tracking

### Configurar Backups

**Database (Supabase):**
- Plan Free: Backups diarios por 7 días (automático)
- Plan Pro: Point-in-time recovery

**Code:**
- Git: Ya está respaldado en GitHub
- Branches: Mantén tags de releases

### Configurar Alerts

**Railway:**
1. Ve a Settings → Notifications
2. Enable:
   - Deployment failures
   - Service crashes
   - High resource usage

**Supabase:**
1. Enable email alerts para:
   - Database size > 80%
   - High query time
   - Auth issues

---

## 🎉 ¡Deployment Completo!

Tu aplicación está ahora en producción:

- ✅ **Database:** Supabase
- ✅ **Backend API:** Railway
- ✅ **ML Service:** Railway
- ✅ **Android:** Play Store (Internal Testing)
- ✅ **iOS:** TestFlight
- ✅ **CI/CD:** GitHub Actions
- ✅ **Monitoring:** Configurado

---

## 📊 Próximos Pasos

### Launch Checklist

Antes de lanzar públicamente:

- [ ] Comprehensive testing en ambas plataformas
- [ ] Security audit completo
- [ ] Performance testing
- [ ] Privacy policy actualizada
- [ ] Terms of service
- [ ] App Store screenshots y descripción
- [ ] Play Store listings completos
- [ ] Marketing website (landing page)
- [ ] Social media presence
- [ ] Support email configurado

### Promotion Strategy

1. **Internal Testing** (1-2 semanas)
   - 10-20 testers internos
   - Fix bugs críticos

2. **Closed Beta** (2-4 semanas)
   - 50-100 beta testers
   - Gather feedback
   - Iterate

3. **Open Beta** (2-4 semanas)
   - Unlimited testers
   - Marketing campaigns
   - Press releases

4. **Public Launch**
   - Submit for review
   - Launch marketing
   - Monitor closely

---

## 🔧 Troubleshooting

### Backend no responde

```bash
# Ver logs en Railway
railway logs

# Restart service
railway restart

# Check variables
railway variables
```

### ML Service timeout

```bash
# Aumentar timeout en Railway
railway service-settings --timeout 300

# Scale up (si es necesario)
railway scale --replicas 2
```

### Mobile build fails

```bash
# Clean
flutter clean
flutter pub get

# Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs

# Try again
flutter build apk --release
```

### Play Store rejection

Razones comunes:
- Missing privacy policy
- Incomplete store listing
- Content rating issues
- Icon/screenshot quality

Solución: Lee el feedback de Google y corrige.

### TestFlight processing stuck

- Espera hasta 24 horas
- Si sigue stuck, contacta Apple Support
- Verifica que no haya errores en Xcode

---

## 📞 Support

Si tienes problemas:

1. Revisa los logs (Railway, Supabase)
2. Consulta la documentación oficial
3. Abre un issue en GitHub
4. Contacta support de cada plataforma

---

**Última actualización:** 2025-11-17
**Versión:** 1.0.0

**¡Felicitaciones por tu deployment exitoso! 🎊**
