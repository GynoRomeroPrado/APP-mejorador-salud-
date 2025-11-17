"""Router de health checks."""

from fastapi import APIRouter, Request
from datetime import datetime

router = APIRouter()


@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "ml-api",
    }


@router.get("/ready")
async def readiness_check(request: Request):
    """Readiness check - verifica que los modelos estén cargados."""
    workout_recommender = getattr(request.app.state, "workout_recommender", None)
    exercise_predictor = getattr(request.app.state, "exercise_predictor", None)

    models_ready = (
        workout_recommender is not None
        and exercise_predictor is not None
        and workout_recommender.model is not None
        and exercise_predictor.model is not None
    )

    if not models_ready:
        return {
            "status": "not_ready",
            "reason": "ML models not loaded",
            "timestamp": datetime.utcnow().isoformat(),
        }

    return {
        "status": "ready",
        "models_loaded": True,
        "timestamp": datetime.utcnow().isoformat(),
    }
