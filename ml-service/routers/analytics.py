"""Router de analytics y predicciones."""

from fastapi import APIRouter, HTTPException, status, Depends
from pydantic import BaseModel, Field
from typing import List, Dict, Any
from datetime import datetime, timedelta
from middleware.auth import get_current_user_id
import structlog

logger = structlog.get_logger()
router = APIRouter()


class ProgressPrediction(BaseModel):
    """Predicción de progreso del usuario."""

    metric: str
    current_value: float
    predicted_30_days: float
    predicted_60_days: float
    predicted_90_days: float
    confidence: float


@router.get("/progress-prediction")
async def predict_user_progress(
    user_id: str = Depends(get_current_user_id),
) -> Dict[str, Any]:
    """
    Predice el progreso futuro del usuario basado en datos históricos.

    Returns:
        Predicciones de diferentes métricas
    """
    try:
        logger.info("Predicting user progress", user_id=user_id)

        # TODO: Obtener datos históricos reales desde Supabase
        # Por ahora, retornamos predicciones de ejemplo

        predictions = [
            ProgressPrediction(
                metric="weight_kg",
                current_value=75.0,
                predicted_30_days=73.5,
                predicted_60_days=72.0,
                predicted_90_days=70.5,
                confidence=0.85,
            ),
            ProgressPrediction(
                metric="body_fat_percentage",
                current_value=18.5,
                predicted_30_days=17.8,
                predicted_60_days=17.0,
                predicted_90_days=16.2,
                confidence=0.78,
            ),
            ProgressPrediction(
                metric="muscle_mass_kg",
                current_value=32.0,
                predicted_30_days=32.5,
                predicted_60_days=33.2,
                predicted_90_days=34.0,
                confidence=0.82,
            ),
            ProgressPrediction(
                metric="vo2_max",
                current_value=42.0,
                predicted_30_days=43.5,
                predicted_60_days=45.0,
                predicted_90_days=46.8,
                confidence=0.75,
            ),
        ]

        return {
            "user_id": user_id,
            "predictions": [p.model_dump() for p in predictions],
            "generated_at": datetime.utcnow().isoformat(),
            "based_on_days": 90,
        }

    except Exception as e:
        logger.error("Error predicting progress", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al predecir progreso",
        )


@router.get("/workout-insights")
async def get_workout_insights(
    user_id: str = Depends(get_current_user_id),
) -> Dict[str, Any]:
    """
    Genera insights sobre los entrenamientos del usuario.

    Returns:
        Análisis de patrones y recomendaciones
    """
    try:
        logger.info("Generating workout insights", user_id=user_id)

        # TODO: Análisis real de datos históricos

        insights = {
            "most_trained_muscle": {
                "muscle": "chest",
                "percentage": 35,
                "sessions_last_30_days": 8,
            },
            "least_trained_muscle": {
                "muscle": "legs",
                "percentage": 10,
                "sessions_last_30_days": 2,
            },
            "consistency_score": 0.72,
            "average_workout_duration": 52,
            "preferred_workout_time": "morning",
            "rest_days_per_week": 3.5,
            "recommendations": [
                {
                    "type": "balance",
                    "message": "Considera aumentar el entrenamiento de piernas para un desarrollo más equilibrado",
                    "priority": "medium",
                },
                {
                    "type": "recovery",
                    "message": "Tu frecuencia de entrenamientos es buena, pero asegúrate de descansar adecuadamente",
                    "priority": "low",
                },
                {
                    "type": "progression",
                    "message": "Has sido consistente por 4 semanas. Es momento de aumentar la intensidad",
                    "priority": "high",
                },
            ],
        }

        return {
            "user_id": user_id,
            "insights": insights,
            "generated_at": datetime.utcnow().isoformat(),
        }

    except Exception as e:
        logger.error("Error generating insights", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al generar insights",
        )


@router.get("/optimal-rest-time")
async def calculate_optimal_rest(
    exercise_type: str,
    user_id: str = Depends(get_current_user_id),
) -> Dict[str, Any]:
    """
    Calcula el tiempo óptimo de descanso entre series.

    Args:
        exercise_type: Tipo de ejercicio (strength, hypertrophy, endurance)

    Returns:
        Tiempo de descanso recomendado
    """
    try:
        # Recomendaciones basadas en ciencia del ejercicio
        rest_recommendations = {
            "strength": {
                "seconds": 180,
                "range_min": 120,
                "range_max": 300,
                "reason": "Recuperación completa del sistema ATP-PC para máxima fuerza",
            },
            "hypertrophy": {
                "seconds": 90,
                "range_min": 60,
                "range_max": 120,
                "reason": "Balance entre fatiga metabólica y recuperación muscular",
            },
            "endurance": {
                "seconds": 45,
                "range_min": 30,
                "range_max": 60,
                "reason": "Descanso mínimo para mantener ritmo cardíaco elevado",
            },
            "cardio_hiit": {
                "seconds": 30,
                "range_min": 20,
                "range_max": 45,
                "reason": "Intervalos cortos para maximizar quema de calorías",
            },
        }

        recommendation = rest_recommendations.get(
            exercise_type, rest_recommendations["hypertrophy"]
        )

        return {
            "user_id": user_id,
            "exercise_type": exercise_type,
            "recommended_rest_seconds": recommendation["seconds"],
            "range": {
                "min_seconds": recommendation["range_min"],
                "max_seconds": recommendation["range_max"],
            },
            "reason": recommendation["reason"],
        }

    except Exception as e:
        logger.error("Error calculating optimal rest", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al calcular tiempo de descanso",
        )


@router.post("/calorie-burn-prediction")
async def predict_calorie_burn(
    workout_duration_minutes: int = Field(..., ge=1, le=300),
    exercise_intensity: str = Field(..., pattern="^(low|moderate|high|very_high)$"),
    user_weight_kg: float = Field(..., ge=30, le=300),
    user_id: str = Depends(get_current_user_id),
) -> Dict[str, Any]:
    """
    Predice las calorías quemadas en un entrenamiento.

    Args:
        workout_duration_minutes: Duración del entrenamiento
        exercise_intensity: Intensidad del ejercicio
        user_weight_kg: Peso del usuario

    Returns:
        Estimación de calorías quemadas
    """
    try:
        # MET values (Metabolic Equivalent of Task)
        met_values = {
            "low": 3.0,  # Caminar, yoga
            "moderate": 5.0,  # Pesas ligeras, ciclismo suave
            "high": 7.0,  # Running, HIIT moderado
            "very_high": 10.0,  # HIIT intenso, sprints
        }

        met = met_values.get(exercise_intensity, 5.0)

        # Fórmula: Calorías = MET × peso (kg) × duración (horas)
        calories_burned = met * user_weight_kg * (workout_duration_minutes / 60)

        # Calcular rangos (±10%)
        calories_min = calories_burned * 0.9
        calories_max = calories_burned * 1.1

        return {
            "user_id": user_id,
            "estimated_calories": round(calories_burned),
            "range": {
                "min": round(calories_min),
                "max": round(calories_max),
            },
            "met_value": met,
            "duration_minutes": workout_duration_minutes,
            "intensity": exercise_intensity,
            "note": "Esta es una estimación. La quema real puede variar según metabolismo individual.",
        }

    except Exception as e:
        logger.error("Error predicting calorie burn", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al predecir calorías quemadas",
        )
