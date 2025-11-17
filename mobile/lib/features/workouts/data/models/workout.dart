import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_exercise.dart';

part 'workout.freezed.dart';
part 'workout.g.dart';

@freezed
class Workout with _$Workout {
  const factory Workout({
    @JsonKey(name: 'workout_id') required String workoutId,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? description,
    @JsonKey(name: 'target_muscle_group') String? targetMuscleGroup,
    @Default([]) List<WorkoutExercise> exercises,
    @JsonKey(name: 'is_template') @Default(false) bool isTemplate,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Workout;

  factory Workout.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFromJson(json);
}

extension WorkoutExtension on Workout {
  /// Retorna la duración estimada del workout en minutos
  int get estimatedDuration {
    if (exercises.isEmpty) return 0;

    // Estimar 2 minutos por ejercicio + 1 minuto de descanso
    return exercises.length * 3;
  }

  /// Retorna el total de series del workout
  int get totalSets {
    return exercises.fold(0, (total, exercise) => total + exercise.sets);
  }

  /// Retorna las calorías estimadas a quemar
  int get estimatedCalories {
    // Estimación básica: 5 calorías por set
    return totalSets * 5;
  }

  /// Verifica si el workout está vacío
  bool get isEmpty => exercises.isEmpty;

  /// Obtiene los grupos musculares trabajados
  Set<String> get muscleGroups {
    final groups = <String>{};
    if (targetMuscleGroup != null) groups.add(targetMuscleGroup!);
    return groups;
  }

  /// Retorna el nivel de dificultad estimado
  String get difficulty {
    if (exercises.isEmpty) return 'easy';
    if (totalSets >= 20) return 'hard';
    if (totalSets >= 12) return 'medium';
    return 'easy';
  }
}
