import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_set.freezed.dart';
part 'exercise_set.g.dart';

@freezed
class ExerciseSet with _$ExerciseSet {
  const factory ExerciseSet({
    @JsonKey(name: 'set_id') String? setId,
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'exercise_name') String? exerciseName,
    @JsonKey(name: 'set_number') required int setNumber,
    int? reps,
    double? weight,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'rest_seconds') int? restSeconds,
    @Default(false) bool completed,
    @Default(false) bool skipped,
    String? notes,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
  }) = _ExerciseSet;

  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);
}

extension ExerciseSetExtension on ExerciseSet {
  /// Retorna el volumen de esta serie (reps × weight)
  double get volume {
    if (reps == null || weight == null) return 0;
    return reps! * weight!;
  }

  /// Retorna descripción de la serie
  String get description {
    final parts = <String>[];

    if (reps != null) {
      parts.add('$reps reps');
    }

    if (weight != null) {
      parts.add('${weight}kg');
    }

    if (durationSeconds != null) {
      parts.add('${durationSeconds}s');
    }

    if (parts.isEmpty) {
      return 'Serie ${setNumber}';
    }

    return parts.join(' × ');
  }

  /// Verifica si la serie tiene datos válidos
  bool get hasValidData {
    return (reps != null && reps! > 0) ||
        (weight != null && weight! > 0) ||
        (durationSeconds != null && durationSeconds! > 0);
  }

  /// Retorna el estado de la serie
  String get status {
    if (skipped) return 'Saltada';
    if (completed) return 'Completada';
    return 'Pendiente';
  }

  /// Retorna el color según el estado
  String get statusColor {
    if (skipped) return 'grey';
    if (completed) return 'green';
    return 'orange';
  }
}
