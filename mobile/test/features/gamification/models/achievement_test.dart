import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/data/models/achievement.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_achievement.dart';

void main() {
  group('Achievement Model Tests', () {
    test('Achievement should be created from JSON', () {
      final json = {
        'achievement_id': 'ach_001',
        'name': 'First Workout',
        'description': 'Complete your first workout',
        'icon': 'fitness_center',
        'category': 'workout',
        'difficulty': 'bronze',
        'requirement_value': 1,
        'xp_reward': 50,
      };

      final achievement = Achievement.fromJson(json);

      expect(achievement.achievementId, 'ach_001');
      expect(achievement.name, 'First Workout');
      expect(achievement.category, 'workout');
      expect(achievement.difficulty, 'bronze');
      expect(achievement.requirementValue, 1);
      expect(achievement.xpReward, 50);
    });

    test('Achievement should convert to JSON', () {
      final achievement = Achievement(
        achievementId: 'ach_001',
        name: 'First Workout',
        description: 'Complete your first workout',
        icon: 'fitness_center',
        category: 'workout',
        difficulty: 'bronze',
        requirementValue: 1,
        xpReward: 50,
      );

      final json = achievement.toJson();

      expect(json['achievement_id'], 'ach_001');
      expect(json['name'], 'First Workout');
      expect(json['category'], 'workout');
    });

    group('Achievement Extensions', () {
      test('should return correct color for difficulty', () {
        final bronze = Achievement(
          achievementId: '1',
          name: 'Bronze',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        );

        expect(bronze.difficultyColor.value, 0xFFCD7F32);

        final silver = Achievement(
          achievementId: '2',
          name: 'Silver',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'silver',
          requirementValue: 5,
          xpReward: 100,
        );

        expect(silver.difficultyColor.value, 0xFFC0C0C0);

        final gold = Achievement(
          achievementId: '3',
          name: 'Gold',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'gold',
          requirementValue: 10,
          xpReward: 200,
        );

        expect(gold.difficultyColor.value, 0xFFFFD700);

        final platinum = Achievement(
          achievementId: '4',
          name: 'Platinum',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'platinum',
          requirementValue: 50,
          xpReward: 500,
        );

        expect(platinum.difficultyColor.value, 0xFFE5E4E2);
      });

      test('should return correct icon for category', () {
        final workout = Achievement(
          achievementId: '1',
          name: 'Workout',
          description: 'Test',
          icon: '',
          category: 'workout',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        );

        expect(workout.categoryIcon, 'fitness_center');

        final streak = Achievement(
          achievementId: '2',
          name: 'Streak',
          description: 'Test',
          icon: '',
          category: 'streak',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        );

        expect(streak.categoryIcon, 'local_fire_department');

        final medication = Achievement(
          achievementId: '3',
          name: 'Medication',
          description: 'Test',
          icon: '',
          category: 'medication',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        );

        expect(medication.categoryIcon, 'medication');

        final level = Achievement(
          achievementId: '4',
          name: 'Level',
          description: 'Test',
          icon: '',
          category: 'level',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        );

        expect(level.categoryIcon, 'star');
      });

      test('should format display text correctly', () {
        final achievement = Achievement(
          achievementId: '1',
          name: 'Workout Master',
          description: 'Complete 100 workouts',
          icon: 'test',
          category: 'workout',
          difficulty: 'gold',
          requirementValue: 100,
          xpReward: 500,
        );

        expect(achievement.displayText, 'Workout Master - 500 XP');
      });

      test('should check if achievement is rare', () {
        final common = Achievement(
          achievementId: '1',
          name: 'Common',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        );

        expect(common.isRare, isFalse);

        final rare = Achievement(
          achievementId: '2',
          name: 'Rare',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'platinum',
          requirementValue: 100,
          xpReward: 1000,
        );

        expect(rare.isRare, isTrue);
      });
    });
  });

  group('UserAchievement Model Tests', () {
    test('UserAchievement should be created from JSON', () {
      final json = {
        'user_achievement_id': 'ua_001',
        'user_id': 'u_123',
        'achievement_id': 'ach_001',
        'progress': 5,
        'unlocked_at': '2024-01-01T12:00:00.000Z',
      };

      final userAchievement = UserAchievement.fromJson(json);

      expect(userAchievement.userAchievementId, 'ua_001');
      expect(userAchievement.userId, 'u_123');
      expect(userAchievement.achievementId, 'ach_001');
      expect(userAchievement.progress, 5);
      expect(userAchievement.unlockedAt, isNotNull);
    });

    group('UserAchievement Extensions', () {
      test('should check if achievement is unlocked', () {
        final unlocked = UserAchievement(
          userAchievementId: '1',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 10,
          unlockedAt: DateTime.now(),
        );

        expect(unlocked.isUnlocked, isTrue);

        final locked = UserAchievement(
          userAchievementId: '2',
          userId: 'u_1',
          achievementId: 'a_2',
          progress: 5,
        );

        expect(locked.isUnlocked, isFalse);
      });

      test('should calculate progress percentage correctly', () {
        final achievement = Achievement(
          achievementId: 'a_1',
          name: 'Test',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'bronze',
          requirementValue: 10,
          xpReward: 100,
        );

        final userAchievement = UserAchievement(
          userAchievementId: '1',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 5,
        );

        expect(
          userAchievement.progressPercentage(achievement),
          closeTo(50.0, 0.1),
        );

        // Progress capped at 100%
        final completed = UserAchievement(
          userAchievementId: '2',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 15,
        );

        expect(
          completed.progressPercentage(achievement),
          100.0,
        );
      });

      test('should calculate remaining progress correctly', () {
        final achievement = Achievement(
          achievementId: 'a_1',
          name: 'Test',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'bronze',
          requirementValue: 10,
          xpReward: 100,
        );

        final userAchievement = UserAchievement(
          userAchievementId: '1',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 7,
        );

        expect(userAchievement.remainingProgress(achievement), 3);

        // Already completed
        final completed = UserAchievement(
          userAchievementId: '2',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 15,
        );

        expect(completed.remainingProgress(achievement), 0);
      });

      test('should check if achievement is almost complete', () {
        final achievement = Achievement(
          achievementId: 'a_1',
          name: 'Test',
          description: 'Test',
          icon: 'test',
          category: 'test',
          difficulty: 'bronze',
          requirementValue: 10,
          xpReward: 100,
        );

        // 95% complete
        final almostComplete = UserAchievement(
          userAchievementId: '1',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 9,
        );

        expect(almostComplete.isAlmostComplete(achievement), isTrue);

        // 80% complete
        final notAlmostComplete = UserAchievement(
          userAchievementId: '2',
          userId: 'u_1',
          achievementId: 'a_1',
          progress: 8,
        );

        expect(notAlmostComplete.isAlmostComplete(achievement), isFalse);
      });
    });

    test('UserAchievement should support copyWith', () {
      final userAchievement = UserAchievement(
        userAchievementId: '1',
        userId: 'u_1',
        achievementId: 'a_1',
        progress: 5,
      );

      final updated = userAchievement.copyWith(progress: 10);

      expect(updated.progress, 10);
      expect(updated.userId, 'u_1');
    });
  });
}
