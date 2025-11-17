import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    @JsonKey(name: 'achievement_id') required String achievementId,
    required String name,
    required String description,
    required String icon,
    required String category, // workout, medication, streak, milestone
    @JsonKey(name: 'required_count') required int requiredCount,
    @Default(0) int points,
    required String difficulty, // bronze, silver, gold, platinum
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

extension AchievementExtension on Achievement {
  /// Retorna el color según la dificultad
  String get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'bronze':
        return '#CD7F32';
      case 'silver':
        return '#C0C0C0';
      case 'gold':
        return '#FFD700';
      case 'platinum':
        return '#E5E4E2';
      default:
        return '#808080';
    }
  }

  /// Retorna el nombre de la dificultad en español
  String get difficultySpanish {
    switch (difficulty.toLowerCase()) {
      case 'bronze':
        return 'Bronce';
      case 'silver':
        return 'Plata';
      case 'gold':
        return 'Oro';
      case 'platinum':
        return 'Platino';
      default:
        return difficulty;
    }
  }

  /// Retorna la categoría en español
  String get categorySpanish {
    switch (category.toLowerCase()) {
      case 'workout':
        return 'Entrenamientos';
      case 'medication':
        return 'Medicamentos';
      case 'streak':
        return 'Rachas';
      case 'milestone':
        return 'Hitos';
      default:
        return category;
    }
  }
}
