"""Microservicio FastAPI para recomendaciones ML."""

import sentry_sdk
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
import structlog

from config import get_settings, Settings
from models.workout_recommender import WorkoutRecommender
from models.exercise_predictor import ExercisePredictor
from routers import recommendations, analytics, health
from middleware.auth import verify_token
from middleware.rate_limit import RateLimitMiddleware

# Configurar logging estructurado
structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.add_log_level,
        structlog.processors.JSONRenderer(),
    ]
)
logger = structlog.get_logger()

settings = get_settings()

# Inicializar Sentry si está configurado
if settings.sentry_dsn:
    sentry_sdk.init(
        dsn=settings.sentry_dsn,
        environment=settings.environment,
        traces_sample_rate=1.0 if settings.environment == "development" else 0.1,
    )


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gestión del ciclo de vida de la aplicación."""
    # Startup
    logger.info("Starting ML service", version=settings.model_version)

    # Cargar modelos ML
    app.state.workout_recommender = WorkoutRecommender()
    app.state.exercise_predictor = ExercisePredictor()

    await app.state.workout_recommender.load_model()
    await app.state.exercise_predictor.load_model()

    logger.info("ML models loaded successfully")

    yield

    # Shutdown
    logger.info("Shutting down ML service")


# Crear aplicación FastAPI
app = FastAPI(
    title="Health & Fitness ML API",
    description="Microservicio de Machine Learning para recomendaciones personalizadas",
    version=settings.model_version,
    lifespan=lifespan,
    docs_url="/api/ml/docs" if settings.debug else None,
    redoc_url="/api/ml/redoc" if settings.debug else None,
)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"] if settings.environment == "development" else [
        "https://yourdomain.com",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(RateLimitMiddleware, requests_per_minute=60)


# Manejador global de errores
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Maneja todas las excepciones no capturadas."""
    logger.error("Unhandled exception", exc_info=exc, path=request.url.path)

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": "Internal server error",
            "path": request.url.path,
        },
    )


# Rutas
app.include_router(health.router, prefix="/api/ml", tags=["Health"])
app.include_router(
    recommendations.router,
    prefix="/api/ml/recommendations",
    tags=["Recommendations"],
    dependencies=[Depends(verify_token)],
)
app.include_router(
    analytics.router,
    prefix="/api/ml/analytics",
    tags=["Analytics"],
    dependencies=[Depends(verify_token)],
)


@app.get("/")
async def root():
    """Endpoint raíz."""
    return {
        "service": "Health & Fitness ML API",
        "version": settings.model_version,
        "status": "online",
        "docs": "/api/ml/docs",
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
        log_level="info",
    )
