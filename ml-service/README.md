# 🤖 Microservicio ML - Health & Fitness App

Microservicio de Machine Learning construido con FastAPI para proporcionar recomendaciones personalizadas de entrenamientos y predicciones de progreso.

## 🎯 Características

- ✅ **Recomendaciones de entrenamientos** - Algoritmos ML para sugerir rutinas personalizadas
- ✅ **Predicción de ejercicios** - K-NN para encontrar ejercicios óptimos
- ✅ **Analytics predictivo** - Predicciones de progreso a 30/60/90 días
- ✅ **Insights inteligentes** - Análisis de patrones de entrenamiento
- ✅ **Cálculo de calorías** - Estimación basada en MET values
- ✅ **Autenticación JWT** - Integración con backend principal
- ✅ **Rate limiting** - Protección contra abuso (60 req/min)
- ✅ **Logging estructurado** - Logs JSON con structlog
- ✅ **Monitoreo** - Integración con Sentry

## 🚀 Stack Tecnológico

- **Framework**: FastAPI 0.104+
- **ML**: scikit-learn, XGBoost
- **Base de datos**: Supabase (PostgreSQL)
- **Caché**: Redis
- **Autenticación**: python-jose (JWT)
- **Monitoreo**: Sentry
- **Logging**: structlog

## 📦 Instalación

```bash
# Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales
```

## 🏃 Ejecución

### Desarrollo
```bash
# Iniciar servidor con hot-reload
uvicorn main:app --reload --host 0.0.0.0 --port 8001

# O usar el script directo
python main.py
```

### Producción
```bash
# Usar Gunicorn con workers de Uvicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8001
```

### Docker
```bash
# Build
docker build -t health-ml-service .

# Run
docker run -p 8001:8001 --env-file .env health-ml-service
```

## 📚 Documentación API

Una vez iniciado el servidor, la documentación interactiva está disponible en:

- **Swagger UI**: http://localhost:8001/api/ml/docs
- **ReDoc**: http://localhost:8001/api/ml/redoc

## 🔑 Endpoints Principales

### Health Checks
- `GET /api/ml/health` - Health check básico
- `GET /api/ml/ready` - Verifica si los modelos ML están cargados

### Recomendaciones (requiere autenticación)
- `POST /api/ml/recommendations/workouts` - Recomendaciones de entrenamientos
- `POST /api/ml/recommendations/exercises` - Recomendaciones de ejercicios
- `GET /api/ml/recommendations/suggested-routine` - Rutina semanal sugerida

### Analytics (requiere autenticación)
- `GET /api/ml/analytics/progress-prediction` - Predicción de progreso
- `GET /api/ml/analytics/workout-insights` - Insights de entrenamientos
- `GET /api/ml/analytics/optimal-rest-time` - Tiempo óptimo de descanso
- `POST /api/ml/analytics/calorie-burn-prediction` - Estimación de calorías

## 🔐 Autenticación

Todos los endpoints (excepto health checks) requieren un token JWT válido:

```bash
# Ejemplo con curl
curl -X POST "http://localhost:8001/api/ml/recommendations/workouts" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "age": 30,
    "weight_kg": 75,
    "height_cm": 175,
    "gender": "male",
    "goal": "muscle_gain",
    "fitness_level": "intermediate",
    "preferences": {
      "max_duration_minutes": 60,
      "equipment_available": ["bodyweight", "dumbbell", "barbell"]
    }
  }'
```

## 🧠 Modelos ML

### Workout Recommender
- **Algoritmo**: Random Forest Classifier
- **Features**: Edad, BMI, nivel de actividad, objetivo, preferencias
- **Output**: Lista de entrenamientos con score de confianza

### Exercise Predictor
- **Algoritmo**: K-Nearest Neighbors
- **Features**: Músculo objetivo, equipamiento, dificultad
- **Output**: Ejercicios rankeados por score

## 📊 Ejemplo de Response

### Recomendación de Entrenamientos
```json
{
  "user_id": "uuid-123",
  "recommendations": [
    {
      "workout_id": "workout_003",
      "name": "Upper Body Hypertrophy",
      "description": "Entrenamiento enfocado en crecimiento muscular superior",
      "target_muscle_group": "chest",
      "difficulty": "advanced",
      "estimated_duration": 60,
      "estimated_calories": 350,
      "confidence_score": 0.895,
      "reason": "Desarrollo muscular avanzado",
      "exercises": [
        {"name": "Bench Press", "sets": 4, "reps": 8},
        {"name": "Incline Dumbbell Press", "sets": 4, "reps": 10}
      ]
    }
  ],
  "total_count": 1
}
```

### Predicción de Progreso
```json
{
  "user_id": "uuid-123",
  "predictions": [
    {
      "metric": "weight_kg",
      "current_value": 75.0,
      "predicted_30_days": 73.5,
      "predicted_60_days": 72.0,
      "predicted_90_days": 70.5,
      "confidence": 0.85
    }
  ]
}
```

## 🧪 Testing

```bash
# Tests unitarios
pytest tests/

# Con coverage
pytest --cov=. --cov-report=html

# Test específico
pytest tests/test_recommender.py -v
```

## 🔧 Configuración

Variables de entorno importantes:

| Variable | Descripción | Default |
|----------|-------------|---------|
| `PORT` | Puerto del servidor | 8001 |
| `ENVIRONMENT` | Entorno (development/production) | development |
| `DEBUG` | Habilitar modo debug | true |
| `SUPABASE_URL` | URL del proyecto Supabase | - |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key | - |
| `JWT_SECRET` | Secret para validar JWT | - |
| `REDIS_URL` | URL de Redis para caché | redis://localhost:6379/0 |
| `SENTRY_DSN` | DSN de Sentry (opcional) | - |
| `MAX_RECOMMENDATIONS` | Máximo de recomendaciones | 10 |
| `MIN_CONFIDENCE_SCORE` | Score mínimo de confianza | 0.6 |

## 🚀 Despliegue

### Railway
```bash
# Conectar proyecto
railway link

# Configurar variables
railway variables set SUPABASE_URL=...
railway variables set JWT_SECRET=...

# Deploy
railway up
```

### Render
```bash
# Crear nuevo Web Service
# Runtime: Python 3.11
# Build Command: pip install -r requirements.txt
# Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
```

## 📈 Performance

- **Latencia promedio**: < 100ms
- **Rate limit**: 60 requests/minuto por IP
- **Caché TTL**: 1 hora (configurable)
- **Max workers**: 4 (producción)

## 🔍 Monitoreo

El servicio está integrado con:
- **Sentry**: Tracking de errores
- **Structlog**: Logs estructurados en JSON
- **Health checks**: `/health` y `/ready` endpoints

## 🤝 Integración con Backend Principal

Este microservicio se comunica con el backend NestJS principal:
- **Autenticación**: Valida tokens JWT generados por NestJS
- **Base de datos**: Lee datos de usuarios y workouts desde Supabase
- **Endpoints**: Llamado desde backend o directamente desde mobile

## 📝 TODO

- [ ] Integrar ExerciseDB API real
- [ ] Implementar caché con Redis
- [ ] Agregar más algoritmos ML (Neural Networks)
- [ ] Fine-tuning de modelos con datos reales
- [ ] Implementar A/B testing de recomendaciones
- [ ] Agregar soporte para entrenamientos en casa vs gym
- [ ] Predicción de lesiones basada en patrones

## 📄 Licencia

MIT

---

**Desarrollado para Health & Fitness App** 🏋️‍♂️💪
