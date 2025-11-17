import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_set.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    @JsonKey(name: 'session_id') required String sessionId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'workout_id') String? workoutId,
    @JsonKey(name: 'workout_name') String? workoutName,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'duration_minutes') int? durationMinutes,
    @JsonKey(name: 'calories_burned') int? caloriesBurned,
    @Default([]) List<ExerciseSet> sets,
    String? notes,
    @Default('in_progress') String status, // in_progress, completed, cancelled
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSessionFromJson(json);
}

extension WorkoutSessionExtension on WorkoutSession {
  /// Verifica si la sesión está completada
  bool get isCompleted => status == 'completed' && completedAt != null;

  /// Verifica si la sesión está en progreso
  bool get isInProgress => status == 'in_progress';

  /// Retorna la duración real en minutos
  int get actualDuration {
    if (durationMinutes != null) return durationMinutes!;
    if (completedAt != null) {
      return completedAt!.difference(startedAt).inMinutes;
    }
    return DateTime.now().difference(startedAt).inMinutes;
  }

  /// Retorna el total de series completadas
  int get totalSetsCompleted {
    return sets.where((set) => set.completed).length;
  }

  /// Retorna el total de series
  int get totalSets => sets.length;

  /// Retorna el porcentaje de progreso
  double get progressPercentage {
    if (totalSets == 0) return 0;
    return (totalSetsCompleted / totalSets) * 100;
  }

  /// Retorna el volumen total levantado
  double get totalVolume {
    return sets.fold(0.0, (sum, set) {
      if (set.completed && set.weight != null && set.reps != null) {
        return sum + (set.weight! * set.reps!);
      }
      return sum;
    });
  }

  /// Retorna el total de repeticiones
  int get totalReps {
    return sets.fold(0, (sum, set) {
      if (set.completed && set.reps != null) {
        return sum + set.reps!;
      }
      return sum;
    });
  }

  /// Agrupa sets por ejercicio
  Map<String, List<ExerciseSet>> get setsByExercise {
    final Map<String, List<ExerciseSet>> grouped = {};

    for (final set in sets) {
      final exerciseId = set.exerciseId;
      if (!grouped.containsKey(exerciseId)) {
        grouped[exerciseId] = [];
      }
      grouped[exerciseId]!.add(set);
    }

    return grouped;
  }

  /// Retorna el número de ejercicios únicos
  int get uniqueExerciseCount => setsByExercise.keys.length;
}
