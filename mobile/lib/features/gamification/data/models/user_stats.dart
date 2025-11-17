import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats.freezed.dart';
part 'user_stats.g.dart';

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'total_xp') @Default(0) int totalXp,
    @Default(1) int level,
    @JsonKey(name: 'current_streak') @Default(0) int currentStreak,
    @JsonKey(name: 'longest_streak') @Default(0) int longestStreak,
    @JsonKey(name: 'workouts_completed') @Default(0) int workoutsCompleted,
    @JsonKey(name: 'medications_taken') @Default(0) int medicationsTaken,
    @JsonKey(name: 'achievements_unlocked') @Default(0) int achievementsUnlocked,
    @JsonKey(name: 'total_workout_minutes') @Default(0) int totalWorkoutMinutes,
    @JsonKey(name: 'total_calories_burned') @Default(0) int totalCaloriesBurned,
    @JsonKey(name: 'last_activity_date') DateTime? lastActivityDate,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

extension UserStatsExtension on UserStats {
  /// Calcula el nivel basado en XP
  /// Fórmula: Nivel = floor(sqrt(XP / 100))
  int get calculatedLevel {
    if (totalXp == 0) return 1;
    return (totalXp / 100).sqrt().floor() + 1;
  }

  /// XP requerido para el siguiente nivel
  int get xpForNextLevel {
    return (level * level) * 100;
  }

  /// XP requerido en el nivel actual
  int get xpForCurrentLevel {
    return ((level - 1) * (level - 1)) * 100;
  }

  /// Progreso en el nivel actual (0-100)
  double get levelProgress {
    final xpInCurrentLevel = totalXp - xpForCurrentLevel;
    final xpNeededForLevel = xpForNextLevel - xpForCurrentLevel;

    if (xpNeededForLevel == 0) return 0;
    return (xpInCurrentLevel / xpNeededForLevel) * 100;
  }

  /// XP restante para subir de nivel
  int get xpToNextLevel {
    return xpForNextLevel - totalXp;
  }

  /// Verifica si el usuario está activo hoy
  bool get isActiveToday {
    if (lastActivityDate == null) return false;

    final now = DateTime.now();
    final lastActivity = lastActivityDate!;

    return lastActivity.year == now.year &&
        lastActivity.month == now.month &&
        lastActivity.day == now.day;
  }

  /// Verifica si la racha está en riesgo (última actividad fue ayer)
  bool get streakAtRisk {
    if (lastActivityDate == null) return false;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final lastActivity = lastActivityDate!;

    return lastActivity.year == yesterday.year &&
        lastActivity.month == yesterday.month &&
        lastActivity.day == yesterday.day;
  }

  /// Promedio de minutos de workout por sesión
  double get avgWorkoutMinutes {
    if (workoutsCompleted == 0) return 0;
    return totalWorkoutMinutes / workoutsCompleted;
  }

  /// Promedio de calorías por workout
  double get avgCaloriesPerWorkout {
    if (workoutsCompleted == 0) return 0;
    return totalCaloriesBurned / workoutsCompleted;
  }

  /// Título del usuario basado en nivel
  String get userTitle {
    if (level >= 50) return 'Leyenda del Fitness';
    if (level >= 40) return 'Maestro Atleta';
    if (level >= 30) return 'Experto Dedicado';
    if (level >= 20) return 'Guerrero Fitness';
    if (level >= 10) return 'Entusiasta Comprometido';
    if (level >= 5) return 'Aprendiz Motivado';
    return 'Principiante';
  }
}
