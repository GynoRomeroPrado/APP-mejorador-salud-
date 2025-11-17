import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_achievement.freezed.dart';
part 'user_achievement.g.dart';

@freezed
class UserAchievement with _$UserAchievement {
  const factory UserAchievement({
    @JsonKey(name: 'user_achievement_id') String? userAchievementId,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'achievement_id') required String achievementId,
    @JsonKey(name: 'achievement_name') String? achievementName,
    @JsonKey(name: 'achievement_description') String? achievementDescription,
    @JsonKey(name: 'achievement_icon') String? achievementIcon,
    @JsonKey(name: 'achievement_points') int? achievementPoints,
    @JsonKey(name: 'current_progress') @Default(0) int currentProgress,
    @JsonKey(name: 'required_count') int? requiredCount,
    @Default(false) bool completed,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'unlocked_at') DateTime? unlockedAt,
  }) = _UserAchievement;

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);
}

extension UserAchievementExtension on UserAchievement {
  /// Retorna el porcentaje de progreso
  double get progressPercentage {
    if (requiredCount == null || requiredCount == 0) return 0;
    return (currentProgress / requiredCount!) * 100;
  }

  /// Verifica si el logro está bloqueado
  bool get isLocked => !completed && unlockedAt == null;

  /// Verifica si el logro está desbloqueado pero no completado
  bool get isUnlocked => !completed && unlockedAt != null;

  /// Retorna el estado del logro
  String get status {
    if (completed) return 'Completado';
    if (isUnlocked) return 'En progreso';
    return 'Bloqueado';
  }

  /// Retorna cuánto falta para completar
  int get remainingCount {
    if (requiredCount == null) return 0;
    return requiredCount! - currentProgress;
  }

  /// Verifica si está cerca de completarse (>75%)
  bool get isAlmostComplete {
    return progressPercentage >= 75 && !completed;
  }
}
