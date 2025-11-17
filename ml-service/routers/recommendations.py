"""Router de recomendaciones personalizadas."""

from fastapi import APIRouter, HTTPException, status, Depends, Request
from pydantic import BaseModel, Field
from typing import List, Optional
from middleware.auth import get_current_user_id
import structlog

logger = structlog.get_logger()
router = APIRouter()


# Schemas de request/response
class UserPreferences(BaseModel):
    """Preferencias del usuario para recomendaciones."""

    max_duration_minutes: int = Field(default=60, ge=10, le=180)
    equipment_available: List[str] = Field(
        default=["bodyweight", "dumbbell", "barbell"]
    )
    goal: str = Field(default="general_fitness")
    days_per_week: int = Field(default=3, ge=1, le=7)


class WorkoutRecommendationRequest(BaseModel):
    """Request de recomendación de entrenamientos."""

    age: int = Field(..., ge=13, le=100)
    weight_kg: float = Field(..., ge=30, le=300)
    height_cm: float = Field(..., ge=100, le=250)
    gender: str = Field(..., pattern="^(male|female|other)$")
    goal: str = Field(
        default="general_fitness",
        pattern="^(weight_loss|muscle_gain|endurance|general_fitness)$",
    )
    fitness_level: str = Field(
        default="intermediate", pattern="^(beginner|intermediate|advanced)$"
    )
    preferences: UserPreferences = Field(default_factory=UserPreferences)


class ExerciseRecommendationRequest(BaseModel):
    """Request de recomendación de ejercicios."""

    target_muscle: str = Field(
        ...,
        pattern="^(chest|back|legs|arms|shoulders|abs|cardio|full_body)$",
    )
    equipment_available: List[str] = Field(
        default=["bodyweight", "dumbbell", "barbell"]
    )
    difficulty: str = Field(
        default="intermediate", pattern="^(beginner|intermediate|advanced)$"
    )
    limit: int = Field(default=10, ge=1, le=50)


@router.post("/workouts")
async def get_workout_recommendations(
    request_data: WorkoutRecommendationRequest,
    request: Request,
    user_id: str = Depends(get_current_user_id),
):
    """
    Genera recomendaciones personalizadas de entrenamientos.

    Args:
        request_data: Datos del usuario y preferencias
        request: Request de FastAPI (para acceder al state)
        user_id: ID del usuario autenticado

    Returns:
        Lista de entrenamientos recomendados
    """
    try:
        logger.info("Generating workout recommendations", user_id=user_id)

        # Obtener el modelo del app state
        recommender = request.app.state.workout_recommender

        # Preparar datos del usuario
        user_data = {
            "age": request_data.age,
            "weight_kg": request_data.weight_kg,
            "height_cm": request_data.height_cm,
            "gender": request_data.gender,
            "goal": request_data.goal,
        }

        # TODO: Obtener historial real de workouts desde Supabase
        workout_history = []

        # Generar recomendaciones
        recommendations = recommender.get_recommendations(
            user_data=user_data,
            workout_history=workout_history,
            preferences=request_data.preferences.model_dump(),
            limit=request_data.preferences.days_per_week,
        )

        logger.info(
            "Workout recommendations generated",
            user_id=user_id,
            count=len(recommendations),
        )

        return {
            "user_id": user_id,
            "recommendations": recommendations,
            "generated_at": "2024-11-17T00:00:00Z",
            "total_count": len(recommendations),
        }

    except Exception as e:
        logger.error("Error generating workout recommendations", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al generar recomendaciones",
        )


@router.post("/exercises")
async def get_exercise_recommendations(
    request_data: ExerciseRecommendationRequest,
    request: Request,
    user_id: str = Depends(get_current_user_id),
):
    """
    Recomienda ejercicios específicos basados en criterios.

    Args:
        request_data: Criterios de búsqueda
        request: Request de FastAPI
        user_id: ID del usuario autenticado

    Returns:
        Lista de ejercicios recomendados
    """
    try:
        logger.info("Generating exercise recommendations", user_id=user_id)

        # Obtener el predictor
        predictor = request.app.state.exercise_predictor

        # TODO: Obtener perfil real del usuario desde Supabase
        user_profile = {
            "fitness_level": 2,  # 1=beginner, 2=intermediate, 3=advanced
            "recent_exercises": [],
        }

        # Predecir ejercicios
        exercises = predictor.predict_exercises(
            user_profile=user_profile,
            target_muscle=request_data.target_muscle,
            equipment_available=request_data.equipment_available,
            difficulty=request_data.difficulty,
            limit=request_data.limit,
        )

        logger.info(
            "Exercise recommendations generated",
            user_id=user_id,
            count=len(exercises),
        )

        return {
            "user_id": user_id,
            "target_muscle": request_data.target_muscle,
            "exercises": exercises,
            "total_count": len(exercises),
        }

    except Exception as e:
        logger.error("Error generating exercise recommendations", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al generar recomendaciones de ejercicios",
        )


@router.get("/suggested-routine")
async def get_suggested_routine(
    user_id: str = Depends(get_current_user_id),
    request: Request = None,
):
    """
    Genera una rutina semanal sugerida para el usuario.

    Returns:
        Rutina semanal completa con entrenamientos asignados a cada día
    """
    try:
        logger.info("Generating weekly routine", user_id=user_id)

        recommender = request.app.state.workout_recommender

        # TODO: Obtener datos reales del usuario
        user_data = {
            "age": 30,
            "weight_kg": 75,
            "height_cm": 175,
            "goal": "general_fitness",
        }

        workout_history = []
        preferences = {
            "max_duration_minutes": 60,
            "equipment_available": ["bodyweight", "dumbbell", "barbell"],
        }

        # Generar 3-4 entrenamientos para la semana
        recommendations = recommender.get_recommendations(
            user_data=user_data,
            workout_history=workout_history,
            preferences=preferences,
            limit=4,
        )

        # Asignar a días de la semana
        weekly_routine = {
            "monday": recommendations[0] if len(recommendations) > 0 else None,
            "tuesday": None,  # Día de descanso
            "wednesday": recommendations[1] if len(recommendations) > 1 else None,
            "thursday": None,  # Día de descanso
            "friday": recommendations[2] if len(recommendations) > 2 else None,
            "saturday": recommendations[3] if len(recommendations) > 3 else None,
            "sunday": None,  # Día de descanso
        }

        return {
            "user_id": user_id,
            "weekly_routine": weekly_routine,
            "total_workouts": len([w for w in weekly_routine.values() if w]),
            "rest_days": len([w for w in weekly_routine.values() if not w]),
        }

    except Exception as e:
        logger.error("Error generating weekly routine", exc_info=e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al generar rutina semanal",
        )
