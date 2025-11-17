import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_stats.dart';

void main() {
  group('UserStats Model Tests', () {
    test('UserStats model should be created from JSON', () {
      final json = {
        'user_id': '123',
        'total_xp': 500,
        'level': 3,
        'current_streak': 7,
        'longest_streak': 15,
        'workouts_completed': 10,
        'medications_taken': 50,
      };

      final stats = UserStats.fromJson(json);

      expect(stats.userId, '123');
      expect(stats.totalXp, 500);
      expect(stats.level, 3);
      expect(stats.currentStreak, 7);
    });

    group('UserStats Extensions', () {
      test('should calculate level correctly based on XP', () {
        final stats1 = UserStats(userId: '1', totalXp: 0);
        expect(stats1.calculatedLevel, 1);

        final stats2 = UserStats(userId: '2', totalXp: 100);
        expect(stats2.calculatedLevel, 2);

        final stats3 = UserStats(userId: '3', totalXp: 400);
        expect(stats3.calculatedLevel, 3);

        final stats4 = UserStats(userId: '4', totalXp: 900);
        expect(stats4.calculatedLevel, 4);
      });

      test('should calculate XP for next level correctly', () {
        final stats = UserStats(userId: '1', totalXp: 500, level: 3);

        // Level 3: 3² × 100 = 900 XP needed
        expect(stats.xpForNextLevel, 900);
      });

      test('should calculate XP for current level correctly', () {
        final stats = UserStats(userId: '1', totalXp: 500, level: 3);

        // Level 2: (3-1)² × 100 = 400 XP
        expect(stats.xpForCurrentLevel, 400);
      });

      test('should calculate level progress percentage correctly', () {
        // Level 3: needs 400-900 XP (500 XP range)
        // Current: 500 XP (100 XP into level)
        // Progress: 100/500 = 20%
        final stats = UserStats(userId: '1', totalXp: 500, level: 3);

        expect(stats.levelProgress, closeTo(20.0, 0.1));
      });

      test('should calculate XP to next level correctly', () {
        final stats = UserStats(userId: '1', totalXp: 500, level: 3);

        // Next level at 900, current at 500
        expect(stats.xpToNextLevel, 400);
      });

      test('should check if user is active today', () {
        final activeToday = UserStats(
          userId: '1',
          lastActivityDate: DateTime.now(),
        );

        expect(activeToday.isActiveToday, isTrue);

        final inactiveToday = UserStats(
          userId: '2',
          lastActivityDate: DateTime.now().subtract(Duration(days: 1)),
        );

        expect(inactiveToday.isActiveToday, isFalse);
      });

      test('should check if streak is at risk', () {
        final yesterday = DateTime.now().subtract(Duration(days: 1));
        final atRisk = UserStats(
          userId: '1',
          lastActivityDate: yesterday,
        );

        expect(atRisk.streakAtRisk, isTrue);

        final today = DateTime.now();
        final notAtRisk = UserStats(
          userId: '2',
          lastActivityDate: today,
        );

        expect(notAtRisk.streakAtRisk, isFalse);
      });

      test('should calculate average workout minutes correctly', () {
        final stats = UserStats(
          userId: '1',
          workoutsCompleted: 10,
          totalWorkoutMinutes: 500,
        );

        expect(stats.avgWorkoutMinutes, 50.0);

        final noWorkouts = UserStats(
          userId: '2',
          workoutsCompleted: 0,
          totalWorkoutMinutes: 0,
        );

        expect(noWorkouts.avgWorkoutMinutes, 0.0);
      });

      test('should calculate average calories per workout correctly', () {
        final stats = UserStats(
          userId: '1',
          workoutsCompleted: 10,
          totalCaloriesBurned: 5000,
        );

        expect(stats.avgCaloriesPerWorkout, 500.0);
      });

      test('should return correct user title based on level', () {
        expect(
          UserStats(userId: '1', level: 1).userTitle,
          'Principiante',
        );

        expect(
          UserStats(userId: '2', level: 5).userTitle,
          'Aprendiz Motivado',
        );

        expect(
          UserStats(userId: '3', level: 10).userTitle,
          'Entusiasta Comprometido',
        );

        expect(
          UserStats(userId: '4', level: 20).userTitle,
          'Guerrero Fitness',
        );

        expect(
          UserStats(userId: '5', level: 30).userTitle,
          'Experto Dedicado',
        );

        expect(
          UserStats(userId: '6', level: 40).userTitle,
          'Maestro Atleta',
        );

        expect(
          UserStats(userId: '7', level: 50).userTitle,
          'Leyenda del Fitness',
        );
      });
    });

    test('UserStats should support copyWith', () {
      final stats = UserStats(
        userId: '123',
        totalXp: 500,
        level: 3,
      );

      final updated = stats.copyWith(totalXp: 600);

      expect(updated.userId, '123');
      expect(updated.totalXp, 600);
      expect(updated.level, 3);
    });
  });
}
