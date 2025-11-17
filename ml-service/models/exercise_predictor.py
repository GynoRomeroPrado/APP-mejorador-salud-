"""Predictor de ejercicios basado en preferencias y capacidades."""

import joblib
import numpy as np
from pathlib import Path
from typing import List, Dict, Any
import structlog
from sklearn.neighbors import NearestNeighbors

logger = structlog.get_logger()


class ExercisePredictor:
    """Predice ejercicios adecuados para el usuario."""

    def __init__(self):
        self.model = None
        self.exercise_database = None
        self.model_path = Path(__file__).parent / "saved_models"
        self.model_path.mkdir(exist_ok=True)

    async def load_model(self):
        """Carga el modelo de predicción."""
        model_file = self.model_path / "exercise_predictor.joblib"

        try:
            if model_file.exists():
                self.model = joblib.load(model_file)
                logger.info("Exercise predictor model loaded from disk")
            else:
                # Crear modelo KNN para búsqueda de ejercicios similares
                self.model = NearestNeighbors(
                    n_neighbors=10,
                    algorithm="ball_tree",
                    metric="euclidean",
                )
                logger.info("New exercise predictor model created")

            # Cargar base de datos de ejercicios
            self.exercise_database = self._load_exercise_database()

        except Exception as e:
            logger.error("Error loading exercise predictor", exc_info=e)
            raise

    def predict_exercises(
        self,
        user_profile: Dict[str, Any],
        target_muscle: str,
        equipment_available: List[str],
        difficulty: str = "intermediate",
        limit: int = 10,
    ) -> List[Dict[str, Any]]:
        """
        Predice ejercicios adecuados para el usuario.

        Args:
            user_profile: Perfil del usuario
            target_muscle: Grupo muscular objetivo
            equipment_available: Equipamiento disponible
            difficulty: Nivel de dificultad
            limit: Número de ejercicios a retornar

        Returns:
            Lista de ejercicios recomendados
        """
        try:
            # Filtrar ejercicios por músculo objetivo y equipamiento
            candidate_exercises = self._filter_exercises(
                target_muscle, equipment_available, difficulty
            )

            if not candidate_exercises:
                return []

            # Calcular scores basados en perfil del usuario
            scored_exercises = self._score_exercises(
                candidate_exercises, user_profile
            )

            # Ordenar y retornar top N
            scored_exercises.sort(key=lambda x: x["score"], reverse=True)

            return scored_exercises[:limit]

        except Exception as e:
            logger.error("Error predicting exercises", exc_info=e)
            return []

    def _filter_exercises(
        self, target_muscle: str, equipment: List[str], difficulty: str
    ) -> List[Dict[str, Any]]:
        """Filtra ejercicios por criterios."""
        filtered = []

        for exercise in self.exercise_database:
            # Verificar músculo objetivo
            if target_muscle.lower() not in exercise["target_muscles"]:
                continue

            # Verificar equipamiento
            if exercise["equipment"] not in equipment and exercise["equipment"] != "bodyweight":
                continue

            # Verificar dificultad
            if difficulty == "beginner" and exercise["difficulty"] == "advanced":
                continue
            if difficulty == "advanced" and exercise["difficulty"] == "beginner":
                continue

            filtered.append(exercise)

        return filtered

    def _score_exercises(
        self, exercises: List[Dict[str, Any]], user_profile: Dict[str, Any]
    ) -> List[Dict[str, Any]]:
        """Calcula scores para cada ejercicio."""
        scored = []

        for exercise in exercises:
            score = 0.0

            # Popularidad del ejercicio (20%)
            score += exercise.get("popularity", 0.5) * 0.2

            # Match con nivel del usuario (30%)
            difficulty_map = {"beginner": 1, "intermediate": 2, "advanced": 3}
            user_level = user_profile.get("fitness_level", 2)
            exercise_level = difficulty_map.get(exercise["difficulty"], 2)

            level_match = 1.0 - abs(user_level - exercise_level) / 3
            score += level_match * 0.3

            # Variedad (evitar repetir ejercicios recientes) (25%)
            recent_exercises = user_profile.get("recent_exercises", [])
            if exercise["id"] not in recent_exercises:
                score += 0.25
            else:
                # Penalizar si fue usado recientemente
                recency = recent_exercises.index(exercise["id"]) / len(recent_exercises)
                score += recency * 0.25

            # Efectividad del ejercicio (25%)
            score += exercise.get("effectiveness_rating", 0.7) * 0.25

            scored.append({
                **exercise,
                "score": round(score, 3),
            })

        return scored

    def _load_exercise_database(self) -> List[Dict[str, Any]]:
        """Carga la base de datos de ejercicios."""
        # Base de datos inicial de ejercicios
        # En producción, esto vendría de ExerciseDB API
        return [
            {
                "id": "ex_001",
                "name": "Barbell Squat",
                "description": "Sentadilla con barra, ejercicio compuesto para piernas",
                "target_muscles": ["legs", "quadriceps", "glutes"],
                "equipment": "barbell",
                "difficulty": "intermediate",
                "instructions": [
                    "Coloca la barra sobre los trapecios",
                    "Desciende manteniendo la espalda recta",
                    "Baja hasta que los muslos estén paralelos al suelo",
                    "Empuja con los talones para subir",
                ],
                "gif_url": "https://example.com/squats.gif",
                "popularity": 0.95,
                "effectiveness_rating": 0.98,
                "calories_per_rep": 0.5,
            },
            {
                "id": "ex_002",
                "name": "Bench Press",
                "description": "Press de banca con barra, ejercicio principal de pecho",
                "target_muscles": ["chest", "pectorals", "triceps"],
                "equipment": "barbell",
                "difficulty": "intermediate",
                "instructions": [
                    "Acuéstate en el banco",
                    "Agarra la barra con las manos más anchas que los hombros",
                    "Baja la barra hasta el pecho",
                    "Empuja la barra hacia arriba",
                ],
                "gif_url": "https://example.com/bench-press.gif",
                "popularity": 0.98,
                "effectiveness_rating": 0.95,
                "calories_per_rep": 0.4,
            },
            {
                "id": "ex_003",
                "name": "Pull-ups",
                "description": "Dominadas, ejercicio de peso corporal para espalda",
                "target_muscles": ["back", "lats", "biceps"],
                "equipment": "bodyweight",
                "difficulty": "intermediate",
                "instructions": [
                    "Agarra la barra con las palmas hacia afuera",
                    "Cuelga con los brazos extendidos",
                    "Tira hacia arriba hasta que el mentón pase la barra",
                    "Baja controladamente",
                ],
                "gif_url": "https://example.com/pullups.gif",
                "popularity": 0.85,
                "effectiveness_rating": 0.92,
                "calories_per_rep": 0.6,
            },
            {
                "id": "ex_004",
                "name": "Deadlift",
                "description": "Peso muerto, ejercicio compuesto completo",
                "target_muscles": ["back", "legs", "glutes", "hamstrings"],
                "equipment": "barbell",
                "difficulty": "advanced",
                "instructions": [
                    "Coloca los pies debajo de la barra",
                    "Agarra la barra con las manos separadas",
                    "Mantén la espalda recta y levanta la barra",
                    "Extiende completamente las caderas",
                ],
                "gif_url": "https://example.com/deadlift.gif",
                "popularity": 0.90,
                "effectiveness_rating": 0.99,
                "calories_per_rep": 0.8,
            },
            {
                "id": "ex_005",
                "name": "Push-ups",
                "description": "Flexiones de pecho, ejercicio básico de peso corporal",
                "target_muscles": ["chest", "triceps", "shoulders"],
                "equipment": "bodyweight",
                "difficulty": "beginner",
                "instructions": [
                    "Colócate en posición de plancha",
                    "Baja el cuerpo hasta casi tocar el suelo",
                    "Empuja hacia arriba hasta extender los brazos",
                ],
                "gif_url": "https://example.com/pushups.gif",
                "popularity": 0.95,
                "effectiveness_rating": 0.85,
                "calories_per_rep": 0.3,
            },
            {
                "id": "ex_006",
                "name": "Shoulder Press",
                "description": "Press militar, ejercicio para hombros",
                "target_muscles": ["shoulders", "deltoids", "triceps"],
                "equipment": "dumbbell",
                "difficulty": "intermediate",
                "instructions": [
                    "Siéntate con la espalda recta",
                    "Sostén las mancuernas a la altura de los hombros",
                    "Empuja las mancuernas hacia arriba",
                    "Baja controladamente",
                ],
                "gif_url": "https://example.com/shoulder-press.gif",
                "popularity": 0.88,
                "effectiveness_rating": 0.90,
                "calories_per_rep": 0.35,
            },
            {
                "id": "ex_007",
                "name": "Plank",
                "description": "Plancha, ejercicio isométrico de core",
                "target_muscles": ["abs", "core"],
                "equipment": "bodyweight",
                "difficulty": "beginner",
                "instructions": [
                    "Colócate en posición de plancha sobre los antebrazos",
                    "Mantén el cuerpo recto",
                    "Contrae el abdomen",
                    "Mantén la posición",
                ],
                "gif_url": "https://example.com/plank.gif",
                "popularity": 0.92,
                "effectiveness_rating": 0.88,
                "calories_per_rep": 0.2,
            },
            {
                "id": "ex_008",
                "name": "Lunges",
                "description": "Zancadas, ejercicio unilateral de piernas",
                "target_muscles": ["legs", "quadriceps", "glutes"],
                "equipment": "bodyweight",
                "difficulty": "beginner",
                "instructions": [
                    "Da un paso largo hacia adelante",
                    "Baja la rodilla trasera hacia el suelo",
                    "Empuja con el pie delantero para volver",
                    "Alterna las piernas",
                ],
                "gif_url": "https://example.com/lunges.gif",
                "popularity": 0.80,
                "effectiveness_rating": 0.85,
                "calories_per_rep": 0.4,
            },
            {
                "id": "ex_009",
                "name": "Bicep Curls",
                "description": "Curl de bíceps con mancuernas",
                "target_muscles": ["arms", "biceps"],
                "equipment": "dumbbell",
                "difficulty": "beginner",
                "instructions": [
                    "De pie con las mancuernas a los lados",
                    "Curl hacia arriba contrayendo el bíceps",
                    "Baja controladamente",
                ],
                "gif_url": "https://example.com/bicep-curls.gif",
                "popularity": 0.90,
                "effectiveness_rating": 0.80,
                "calories_per_rep": 0.25,
            },
            {
                "id": "ex_010",
                "name": "Burpees",
                "description": "Burpees, ejercicio cardiovascular de cuerpo completo",
                "target_muscles": ["full_body", "cardio"],
                "equipment": "bodyweight",
                "difficulty": "intermediate",
                "instructions": [
                    "Comienza de pie",
                    "Baja a posición de plancha",
                    "Haz una flexión",
                    "Salta hacia arriba con los brazos extendidos",
                ],
                "gif_url": "https://example.com/burpees.gif",
                "popularity": 0.75,
                "effectiveness_rating": 0.95,
                "calories_per_rep": 1.0,
            },
        ]
