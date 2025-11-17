import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_exercise.freezed.dart';
part 'workout_exercise.g.dart';

@freezed
class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    @JsonKey(name: 'workout_exercise_id') String? workoutExerciseId,
    @JsonKey(name: 'workout_id') String? workoutId,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'exercise_name') String? exerciseName,
    @JsonKey(name: 'exercise_gif_url') String? exerciseGifUrl,
    @Default(0) int order,
    @Default(3) int sets,
    @JsonKey(name: 'target_reps') int? targetReps,
    @JsonKey(name: 'target_weight') double? targetWeight,
    @JsonKey(name: 'rest_seconds') @Default(90) int restSeconds,
    String? notes,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}

extension WorkoutExerciseExtension on WorkoutExercise {
  /// Retorna el tiempo estimado para este ejercicio en minutos
  int get estimatedTimeMinutes {
    // 30 segundos por rep (promedio) + descanso entre series
    final workTime = sets * (targetReps ?? 10) * 0.5 / 60; // en minutos
    final restTime = (sets - 1) * restSeconds / 60; // en minutos
    return (workTime + restTime).ceil();
  }

  /// Retorna el volumen total (sets × reps × peso)
  double get totalVolume {
    if (targetWeight == null || targetReps == null) return 0;
    return sets * targetReps! * targetWeight!;
  }

  /// Retorna descripción legible del ejercicio
  String get description {
    final parts = <String>[];

    parts.add('$sets series');

    if (targetReps != null) {
      parts.add('$targetReps reps');
    }

    if (targetWeight != null) {
      parts.add('${targetWeight}kg');
    }

    return parts.join(' × ');
  }

  /// Retorna el tiempo de descanso formateado
  String get restTimeFormatted {
    if (restSeconds < 60) {
      return '${restSeconds}s';
    }
    final minutes = restSeconds ~/ 60;
    final seconds = restSeconds % 60;
    if (seconds == 0) {
      return '${minutes}min';
    }
    return '${minutes}min ${seconds}s';
  }
}
