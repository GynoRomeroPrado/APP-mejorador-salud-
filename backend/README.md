# Backend API - Health & Fitness App

Backend REST API construido con NestJS para la aplicación de salud y fitness.

## Stack Tecnológico

- **Framework**: NestJS 10+
- **Lenguaje**: TypeScript 5+
- **Base de Datos**: PostgreSQL 16 (Supabase)
- **Autenticación**: JWT + Passport
- **Documentación**: Swagger/OpenAPI
- **Rate Limiting**: @nestjs/throttler
- **Validación**: class-validator

## Características

- ✅ Autenticación JWT con refresh tokens
- ✅ OAuth Google (Apple en desarrollo)
- ✅ CRUD completo de medicamentos
- ✅ Logs y estadísticas de adherencia
- ✅ Rate limiting (100 req/min por defecto)
- ✅ Documentación Swagger automática
- ✅ Validación de DTOs
- ✅ Manejo global de errores
- ✅ CORS configurado
- ✅ Helmet para seguridad
- ✅ Compresión gzip

## Instalación

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales
```

## Ejecución

```bash
# Desarrollo
npm run start:dev

# Producción
npm run build
npm run start:prod

# Debug
npm run start:debug
```

## Endpoints Principales

### Autenticación
- `POST /api/v1/auth/register` - Registrar usuario
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/refresh` - Refrescar token
- `GET /api/v1/auth/google` - OAuth Google
- `GET /api/v1/auth/me` - Usuario actual

### Usuarios
- `GET /api/v1/users/profile` - Obtener perfil
- `PUT /api/v1/users/profile` - Actualizar perfil
- `GET /api/v1/users/stats` - Estadísticas del usuario

### Medicamentos
- `GET /api/v1/medications` - Listar medicamentos
- `GET /api/v1/medications/:id` - Obtener medicamento
- `POST /api/v1/medications` - Crear medicamento
- `PUT /api/v1/medications/:id` - Actualizar medicamento
- `DELETE /api/v1/medications/:id` - Eliminar medicamento
- `GET /api/v1/medications/logs/all` - Obtener logs
- `POST /api/v1/medications/logs` - Crear log
- `GET /api/v1/medications/stats/summary` - Estadísticas

## Documentación API

Swagger disponible en desarrollo:
```
http://localhost:3000/api/v1/docs
```

## Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## Estructura del Proyecto

```
src/
├── auth/                 # Módulo de autenticación
│   ├── dto/
│   ├── strategies/
│   └── guards/
├── users/                # Módulo de usuarios
├── medications/          # Módulo de medicamentos
├── exercises/            # Módulo de ejercicios
├── workouts/             # Módulo de entrenamientos
├── health-articles/      # Módulo de artículos
├── gamification/         # Módulo de gamificación
└── common/               # Módulos compartidos
    └── supabase/         # Cliente Supabase
```

## Despliegue

### Railway
```bash
# Conectar a Railway
railway link

# Deploy
railway up
```

### Docker
```bash
# Build
docker build -t health-api .

# Run
docker run -p 3000:3000 health-api
```

## Variables de Entorno Requeridas

- `SUPABASE_URL`: URL del proyecto Supabase
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key de Supabase
- `JWT_SECRET`: Secret para JWT tokens
- `JWT_REFRESH_SECRET`: Secret para refresh tokens
- `GOOGLE_CLIENT_ID`: Client ID de Google OAuth
- `GOOGLE_CLIENT_SECRET`: Secret de Google OAuth

## Seguridad

- Helmet habilitado para headers de seguridad
- Rate limiting: 100 requests/minuto por IP
- CORS configurado
- Validación de DTOs con class-validator
- Passwords hasheados con bcrypt
- JWT tokens con expiración

## Próximos Pasos

- [ ] Implementar Apple OAuth completo
- [ ] Agregar cache con Redis
- [ ] Implementar WebSockets para notificaciones en tiempo real
- [ ] Agregar módulo de ejercicios (ExerciseDB)
- [ ] Agregar módulo de artículos (PubMed, NewsAPI)
- [ ] Implementar endpoints de gamificación

## Licencia

MIT
