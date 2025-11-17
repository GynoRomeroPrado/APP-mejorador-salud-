"""Modelo de recomendación de entrenamientos personalizados."""

import joblib
import numpy as np
import pandas as pd
from pathlib import Path
from typing import List, Dict, Any
from datetime import datetime, timedelta
import structlog
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler

logger = structlog.get_logger()


class WorkoutRecommender:
    """Recomienda entrenamientos personalizados basados en historial y objetivos."""

    def __init__(self):
        self.model = None
        self.scaler = None
        self.model_path = Path(__file__).parent / "saved_models"
        self.model_path.mkdir(exist_ok=True)

    async def load_model(self):
        """Carga el modelo entrenado o crea uno nuevo."""
        model_file = self.model_path / "workout_recommender.joblib"
        scaler_file = self.model_path / "scaler.joblib"

        try:
            if model_file.exists() and scaler_file.exists():
                self.model = joblib.load(model_file)
                self.scaler = joblib.load(scaler_file)
                logger.info("Workout recommender model loaded from disk")
            else:
                # Crear modelo inicial
                self.model = RandomForestClassifier(
                    n_estimators=100,
                    max_depth=10,
                    random_state=42,
                )
                self.scaler = StandardScaler()
                logger.info("New workout recommender model created")

        except Exception as e:
            logger.error("Error loading model", exc_info=e)
            raise

    async def save_model(self):
        """Guarda el modelo entrenado."""
        try:
            joblib.dump(self.model, self.model_path / "workout_recommender.joblib")
            joblib.dump(self.scaler, self.model_path / "scaler.joblib")
            logger.info("Model saved successfully")
        except Exception as e:
            logger.error("Error saving model", exc_info=e)

    def get_recommendations(
        self,
        user_data: Dict[str, Any],
        workout_history: List[Dict[str, Any]],
        preferences: Dict[str, Any],
        limit: int = 10,
    ) -> List[Dict[str, Any]]:
        """
        Genera recomendaciones de entrenamientos personalizadas.

        Args:
            user_data: Datos del usuario (edad, peso, altura, género, objetivo)
            workout_history: Historial de entrenamientos
            preferences: Preferencias del usuario (equipo disponible, duración)
            limit: Número máximo de recomendaciones

        Returns:
            Lista de entrenamientos recomendados con score de confianza
        """
        try:
            # Extraer características del usuario
            features = self._extract_user_features(
                user_data, workout_history, preferences
            )

            # Calcular similitud con entrenamientos disponibles
            recommendations = self._calculate_workout_scores(features, preferences)

            # Ordenar por score y retornar top N
            recommendations.sort(key=lambda x: x["confidence_score"], reverse=True)

            return recommendations[:limit]

        except Exception as e:
            logger.error("Error generating recommendations", exc_info=e)
            return []

    def _extract_user_features(
        self,
        user_data: Dict[str, Any],
        workout_history: List[Dict[str, Any]],
        preferences: Dict[str, Any],
    ) -> Dict[str, float]:
        """Extrae características relevantes del usuario."""
        # Calcular BMI
        height_m = user_data.get("height_cm", 170) / 100
        weight_kg = user_data.get("weight_kg", 70)
        bmi = weight_kg / (height_m ** 2)

        # Calcular nivel de actividad
        activity_level = self._calculate_activity_level(workout_history)

        # Días desde último entrenamiento
        days_since_last = self._days_since_last_workout(workout_history)

        # Preferencias de grupos musculares
        muscle_preferences = self._analyze_muscle_preferences(workout_history)

        return {
            "age": user_data.get("age", 30),
            "bmi": bmi,
            "activity_level": activity_level,
            "days_since_last": days_since_last,
            "goal_weight_loss": 1.0 if user_data.get("goal") == "weight_loss" else 0.0,
            "goal_muscle_gain": 1.0 if user_data.get("goal") == "muscle_gain" else 0.0,
            "goal_endurance": 1.0 if user_data.get("goal") == "endurance" else 0.0,
            "preferred_chest": muscle_preferences.get("chest", 0.0),
            "preferred_back": muscle_preferences.get("back", 0.0),
            "preferred_legs": muscle_preferences.get("legs", 0.0),
            "preferred_arms": muscle_preferences.get("arms", 0.0),
            "available_duration": preferences.get("max_duration_minutes", 60),
        }

    def _calculate_activity_level(self, workout_history: List[Dict[str, Any]]) -> float:
        """Calcula el nivel de actividad del usuario (0-10)."""
        if not workout_history:
            return 0.0

        # Contar entrenamientos en últimos 30 días
        thirty_days_ago = datetime.now() - timedelta(days=30)
        recent_workouts = [
            w for w in workout_history
            if datetime.fromisoformat(w.get("completed_at", "2000-01-01"))
            > thirty_days_ago
        ]

        # 0-3 workouts = principiante (0-3)
        # 4-8 workouts = intermedio (4-7)
        # 9+ workouts = avanzado (8-10)
        count = len(recent_workouts)
        if count <= 3:
            return min(count, 3)
        elif count <= 8:
            return 3 + (count - 3) * 0.8
        else:
            return 8 + min((count - 8) * 0.2, 2)

    def _days_since_last_workout(self, workout_history: List[Dict[str, Any]]) -> int:
        """Calcula días desde el último entrenamiento."""
        if not workout_history:
            return 999

        last_workout = max(
            workout_history,
            key=lambda w: datetime.fromisoformat(w.get("completed_at", "2000-01-01")),
        )

        last_date = datetime.fromisoformat(last_workout.get("completed_at", "2000-01-01"))
        return (datetime.now() - last_date).days

    def _analyze_muscle_preferences(
        self, workout_history: List[Dict[str, Any]]
    ) -> Dict[str, float]:
        """Analiza qué grupos musculares prefiere entrenar el usuario."""
        muscle_counts = {"chest": 0, "back": 0, "legs": 0, "arms": 0, "shoulders": 0}

        for workout in workout_history:
            target_muscle = workout.get("target_muscle_group", "").lower()
            if target_muscle in muscle_counts:
                muscle_counts[target_muscle] += 1

        # Normalizar a 0-1
        total = sum(muscle_counts.values()) or 1
        return {k: v / total for k, v in muscle_counts.items()}

    def _calculate_workout_scores(
        self, user_features: Dict[str, float], preferences: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Calcula scores de confianza para entrenamientos candidatos."""
        # Entrenamientos base según objetivo y nivel
        workout_templates = self._get_workout_templates()

        scored_workouts = []

        for template in workout_templates:
            score = self._score_workout_template(template, user_features, preferences)

            if score >= 0.6:  # Umbral mínimo de confianza
                scored_workouts.append({
                    "workout_id": template["id"],
                    "name": template["name"],
                    "description": template["description"],
                    "target_muscle_group": template["target_muscle"],
                    "difficulty": template["difficulty"],
                    "estimated_duration": template["duration_minutes"],
                    "estimated_calories": template["calories"],
                    "exercises": template["exercises"],
                    "confidence_score": round(score, 3),
                    "reason": template["reason"],
                })

        return scored_workouts

    def _score_workout_template(
        self,
        template: Dict[str, Any],
        user_features: Dict[str, float],
        preferences: Dict[str, Any],
    ) -> float:
        """Calcula score de confianza para un template de entrenamiento."""
        score = 0.0

        # Nivel de actividad vs dificultad (30%)
        activity_level = user_features["activity_level"]
        difficulty_map = {"beginner": 2, "intermediate": 5, "advanced": 8}
        template_difficulty = difficulty_map.get(template["difficulty"], 5)

        activity_match = 1.0 - abs(activity_level - template_difficulty) / 10
        score += activity_match * 0.30

        # Objetivo del usuario (30%)
        goal_match = 0.0
        if user_features["goal_weight_loss"] > 0 and "cardio" in template["name"].lower():
            goal_match = 0.9
        elif user_features["goal_muscle_gain"] > 0 and "strength" in template["name"].lower():
            goal_match = 0.9
        elif user_features["goal_endurance"] > 0 and "endurance" in template["name"].lower():
            goal_match = 0.9
        else:
            goal_match = 0.5

        score += goal_match * 0.30

        # Duración disponible (20%)
        duration_match = 1.0
        if template["duration_minutes"] > user_features["available_duration"]:
            duration_match = user_features["available_duration"] / template["duration_minutes"]

        score += duration_match * 0.20

        # Preferencias de grupos musculares (20%)
        target_muscle = template["target_muscle"].lower()
        muscle_preference = user_features.get(f"preferred_{target_muscle}", 0.3)
        score += muscle_preference * 0.20

        return min(score, 1.0)

    def _get_workout_templates(self) -> List[Dict[str, Any]]:
        """Retorna templates de entrenamientos pre-definidos."""
        return [
            {
                "id": "workout_001",
                "name": "Full Body Strength - Principiante",
                "description": "Entrenamiento completo para desarrollar fuerza base",
                "difficulty": "beginner",
                "target_muscle": "full_body",
                "duration_minutes": 45,
                "calories": 250,
                "reason": "Ideal para comenzar a construir fuerza",
                "exercises": [
                    {"name": "Squats", "sets": 3, "reps": 12},
                    {"name": "Push-ups", "sets": 3, "reps": 10},
                    {"name": "Dumbbell Rows", "sets": 3, "reps": 12},
                    {"name": "Plank", "sets": 3, "duration_seconds": 30},
                ],
            },
            {
                "id": "workout_002",
                "name": "HIIT Cardio - Pérdida de Grasa",
                "description": "Intervalos de alta intensidad para quemar calorías",
                "difficulty": "intermediate",
                "target_muscle": "cardio",
                "duration_minutes": 30,
                "calories": 400,
                "reason": "Máxima quema de calorías en poco tiempo",
                "exercises": [
                    {"name": "Jumping Jacks", "sets": 4, "duration_seconds": 45},
                    {"name": "Burpees", "sets": 4, "reps": 15},
                    {"name": "Mountain Climbers", "sets": 4, "duration_seconds": 45},
                    {"name": "High Knees", "sets": 4, "duration_seconds": 30},
                ],
            },
            {
                "id": "workout_003",
                "name": "Upper Body Hypertrophy",
                "description": "Entrenamiento enfocado en crecimiento muscular superior",
                "difficulty": "advanced",
                "target_muscle": "chest",
                "duration_minutes": 60,
                "calories": 350,
                "reason": "Desarrollo muscular avanzado",
                "exercises": [
                    {"name": "Bench Press", "sets": 4, "reps": 8},
                    {"name": "Incline Dumbbell Press", "sets": 4, "reps": 10},
                    {"name": "Cable Flyes", "sets": 3, "reps": 12},
                    {"name": "Tricep Dips", "sets": 3, "reps": 12},
                ],
            },
            {
                "id": "workout_004",
                "name": "Leg Day - Fuerza",
                "description": "Entrenamiento intenso de piernas",
                "difficulty": "intermediate",
                "target_muscle": "legs",
                "duration_minutes": 50,
                "calories": 380,
                "reason": "Desarrolla piernas fuertes y potentes",
                "exercises": [
                    {"name": "Barbell Squats", "sets": 4, "reps": 10},
                    {"name": "Romanian Deadlifts", "sets": 4, "reps": 10},
                    {"name": "Leg Press", "sets": 3, "reps": 12},
                    {"name": "Leg Curls", "sets": 3, "reps": 12},
                    {"name": "Calf Raises", "sets": 4, "reps": 15},
                ],
            },
            {
                "id": "workout_005",
                "name": "Back & Biceps",
                "description": "Entrenamiento completo de espalda y bíceps",
                "difficulty": "intermediate",
                "target_muscle": "back",
                "duration_minutes": 55,
                "calories": 320,
                "reason": "Desarrollo equilibrado de espalda",
                "exercises": [
                    {"name": "Pull-ups", "sets": 4, "reps": 8},
                    {"name": "Bent-over Rows", "sets": 4, "reps": 10},
                    {"name": "Lat Pulldowns", "sets": 3, "reps": 12},
                    {"name": "Barbell Curls", "sets": 3, "reps": 12},
                    {"name": "Hammer Curls", "sets": 3, "reps": 12},
                ],
            },
            {
                "id": "workout_006",
                "name": "Core & Abs Destroyer",
                "description": "Entrenamiento intensivo de abdominales y core",
                "difficulty": "beginner",
                "target_muscle": "abs",
                "duration_minutes": 25,
                "calories": 180,
                "reason": "Fortalece el core para mejor postura",
                "exercises": [
                    {"name": "Crunches", "sets": 4, "reps": 20},
                    {"name": "Leg Raises", "sets": 3, "reps": 15},
                    {"name": "Russian Twists", "sets": 3, "reps": 30},
                    {"name": "Plank", "sets": 3, "duration_seconds": 60},
                    {"name": "Bicycle Crunches", "sets": 3, "reps": 20},
                ],
            },
            {
                "id": "workout_007",
                "name": "Endurance Running Program",
                "description": "Programa de carrera para mejorar resistencia",
                "difficulty": "intermediate",
                "target_muscle": "cardio",
                "duration_minutes": 40,
                "calories": 450,
                "reason": "Mejora resistencia cardiovascular",
                "exercises": [
                    {"name": "Warm-up Jog", "duration_seconds": 300},
                    {"name": "Steady Run", "duration_seconds": 1500},
                    {"name": "Sprint Intervals", "sets": 5, "duration_seconds": 60},
                    {"name": "Cool-down Walk", "duration_seconds": 300},
                ],
            },
            {
                "id": "workout_008",
                "name": "Shoulder & Arms Sculpt",
                "description": "Definición de hombros y brazos",
                "difficulty": "intermediate",
                "target_muscle": "shoulders",
                "duration_minutes": 45,
                "calories": 280,
                "reason": "Esculpe hombros y brazos tonificados",
                "exercises": [
                    {"name": "Shoulder Press", "sets": 4, "reps": 10},
                    {"name": "Lateral Raises", "sets": 3, "reps": 15},
                    {"name": "Front Raises", "sets": 3, "reps": 12},
                    {"name": "Tricep Pushdowns", "sets": 3, "reps": 12},
                    {"name": "Overhead Tricep Extension", "sets": 3, "reps": 12},
                ],
            },
        ]
