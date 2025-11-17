import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/gamification/providers/gamification_providers.dart';
import 'package:health_fitness_app/features/gamification/data/repositories/gamification_repository.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_stats.dart';
import 'package:health_fitness_app/features/gamification/data/models/achievement.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_achievement.dart';
import 'package:health_fitness_app/features/gamification/data/models/daily_quote.dart';

@GenerateMocks([GamificationRepository])
import 'gamification_providers_test.mocks.dart';

void main() {
  late MockGamificationRepository mockRepository;
  late ProviderContainer container;

  final testStats = UserStats(
    userId: 'u_123',
    totalXp: 400,
    level: 3,
    currentStreak: 5,
    longestStreak: 10,
    workoutsCompleted: 20,
    medicationsTaken: 50,
    totalSets: 150,
    totalVolume: 15000.0,
    totalWorkoutMinutes: 600,
    totalCaloriesBurned: 3500,
    averageWorkoutDuration: 30,
    lastActivityDate: DateTime.now(),
  );

  final testAchievement = Achievement(
    achievementId: 'ach_001',
    name: 'First Workout',
    description: 'Complete your first workout',
    icon: 'fitness_center',
    category: 'workout',
    difficulty: 'bronze',
    requirementValue: 1,
    xpReward: 50,
  );

  final testUserAchievement = UserAchievement(
    userAchievementId: 'ua_001',
    userId: 'u_123',
    achievementId: 'ach_001',
    progress: 1,
    unlockedAt: DateTime.now(),
  );

  final testQuote = DailyQuote(
    text: 'Test motivational quote',
    author: 'Test Author',
    category: 'fitness',
  );

  setUp(() {
    mockRepository = MockGamificationRepository();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        gamificationRepositoryProvider.overrideWithValue(
          AsyncValue.data(mockRepository),
        ),
      ],
    );
  }

  group('User Stats Provider Tests', () {
    test('should return user stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => testStats);
      container = createContainer();

      // Act
      final stats = await container.read(userStatsProvider.future);

      // Assert
      expect(stats, isNotNull);
      expect(stats.userId, 'u_123');
      expect(stats.totalXp, 400);
      expect(stats.level, 3);
      verify(mockRepository.getUserStats()).called(1);
    });

    test('should handle stats not found', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final stats = await container.read(userStatsProvider.future);

      // Assert
      expect(stats, isNull);
    });
  });

  group('User Level Provider Tests', () {
    test('should return user level from stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => testStats);
      container = createContainer();

      // Act
      final level = await container.read(userLevelProvider.future);

      // Assert
      expect(level, 3);
    });

    test('should return 1 when no stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final level = await container.read(userLevelProvider.future);

      // Assert
      expect(level, 1);
    });
  });

  group('User XP Provider Tests', () {
    test('should return user XP from stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => testStats);
      container = createContainer();

      // Act
      final xp = await container.read(userXpProvider.future);

      // Assert
      expect(xp, 400);
    });

    test('should return 0 when no stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final xp = await container.read(userXpProvider.future);

      // Assert
      expect(xp, 0);
    });
  });

  group('Current Streak Provider Tests', () {
    test('should return current streak from stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => testStats);
      container = createContainer();

      // Act
      final streak = await container.read(currentStreakProvider.future);

      // Assert
      expect(streak, 5);
    });

    test('should return 0 when no stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final streak = await container.read(currentStreakProvider.future);

      // Assert
      expect(streak, 0);
    });
  });

  group('Achievements Provider Tests', () {
    test('should return all achievements', () async {
      // Arrange
      when(mockRepository.getAllAchievements())
          .thenAnswer((_) async => [testAchievement]);
      container = createContainer();

      // Act
      final achievements = await container.read(achievementsProvider.future);

      // Assert
      expect(achievements.length, 1);
      expect(achievements[0].achievementId, 'ach_001');
      verify(mockRepository.getAllAchievements()).called(1);
    });
  });

  group('User Achievements Provider Tests', () {
    test('should return user achievements', () async {
      // Arrange
      when(mockRepository.getUserAchievements())
          .thenAnswer((_) async => [testUserAchievement]);
      container = createContainer();

      // Act
      final userAchievements =
          await container.read(userAchievementsProvider.future);

      // Assert
      expect(userAchievements.length, 1);
      expect(userAchievements[0].achievementId, 'ach_001');
      verify(mockRepository.getUserAchievements()).called(1);
    });
  });

  group('Unlocked Achievements Provider Tests', () {
    test('should return only unlocked achievements', () async {
      // Arrange
      final unlocked = testUserAchievement;
      final locked = UserAchievement(
        userAchievementId: 'ua_002',
        userId: 'u_123',
        achievementId: 'ach_002',
        progress: 5,
      );

      when(mockRepository.getUserAchievements())
          .thenAnswer((_) async => [unlocked, locked]);
      container = createContainer();

      // Act
      final unlockedAchievements =
          await container.read(unlockedAchievementsProvider.future);

      // Assert
      expect(unlockedAchievements.length, 1);
      expect(unlockedAchievements[0].unlockedAt, isNotNull);
    });
  });

  group('Daily Quote Provider Tests', () {
    test('should return daily quote', () async {
      // Arrange
      when(mockRepository.getDailyQuote()).thenAnswer((_) async => testQuote);
      container = createContainer();

      // Act
      final quote = await container.read(dailyQuoteProvider.future);

      // Assert
      expect(quote, isNotNull);
      expect(quote.text, 'Test motivational quote');
      verify(mockRepository.getDailyQuote()).called(1);
    });
  });

  group('Gamification Actions Provider Tests', () {
    test('should add XP', () async {
      // Arrange
      final updatedStats = testStats.copyWith(totalXp: 450);
      when(mockRepository.addXp(50)).thenAnswer((_) async => updatedStats);
      when(mockRepository.getUserStats()).thenAnswer((_) async => updatedStats);

      container = createContainer();

      // Act
      await container.read(gamificationActionsProvider.notifier).addXp(50);

      // Assert
      verify(mockRepository.addXp(50)).called(1);
    });

    test('should track workout', () async {
      // Arrange
      final updatedStats = testStats.copyWith(
        workoutsCompleted: 21,
        totalXp: 450,
      );
      when(mockRepository.trackWorkout(
        duration: anyNamed('duration'),
        caloriesBurned: anyNamed('caloriesBurned'),
      )).thenAnswer((_) async => updatedStats);
      when(mockRepository.getUserStats()).thenAnswer((_) async => updatedStats);

      container = createContainer();

      // Act
      await container
          .read(gamificationActionsProvider.notifier)
          .trackWorkout(duration: 60, caloriesBurned: 350);

      // Assert
      verify(mockRepository.trackWorkout(
        duration: 60,
        caloriesBurned: 350,
      )).called(1);
    });

    test('should track medication', () async {
      // Arrange
      final updatedStats = testStats.copyWith(
        medicationsTaken: 51,
        totalXp: 410,
      );
      when(mockRepository.trackMedication()).thenAnswer((_) async => updatedStats);
      when(mockRepository.getUserStats()).thenAnswer((_) async => updatedStats);

      container = createContainer();

      // Act
      await container
          .read(gamificationActionsProvider.notifier)
          .trackMedication();

      // Assert
      verify(mockRepository.trackMedication()).called(1);
    });

    test('should check and unlock achievements', () async {
      // Arrange
      when(mockRepository.checkAndUnlockAchievements())
          .thenAnswer((_) async => [testUserAchievement]);
      when(mockRepository.getUserAchievements())
          .thenAnswer((_) async => [testUserAchievement]);

      container = createContainer();

      // Act
      final unlocked = await container
          .read(gamificationActionsProvider.notifier)
          .checkAndUnlockAchievements();

      // Assert
      expect(unlocked.length, 1);
      verify(mockRepository.checkAndUnlockAchievements()).called(1);
    });
  });

  group('Leaderboard Provider Tests', () {
    test('should return leaderboard data', () async {
      // Arrange
      final leaderboard = [
        {
          'userId': 'u_1',
          'userName': 'User 1',
          'totalXp': 1000,
          'level': 10,
        },
        {
          'userId': 'u_2',
          'userName': 'User 2',
          'totalXp': 900,
          'level': 9,
        },
      ];
      when(mockRepository.getLeaderboard(limit: anyNamed('limit')))
          .thenAnswer((_) async => leaderboard);

      container = createContainer();

      // Act
      final result = await container.read(leaderboardProvider.future);

      // Assert
      expect(result.length, 2);
      expect(result[0]['totalXp'], 1000);
      verify(mockRepository.getLeaderboard(limit: 100)).called(1);
    });
  });

  group('User Rank Provider Tests', () {
    test('should return user rank', () async {
      // Arrange
      when(mockRepository.getUserRank()).thenAnswer((_) async => 42);
      container = createContainer();

      // Act
      final rank = await container.read(userRankProvider.future);

      // Assert
      expect(rank, 42);
      verify(mockRepository.getUserRank()).called(1);
    });

    test('should return 0 when rank not available', () async {
      // Arrange
      when(mockRepository.getUserRank()).thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final rank = await container.read(userRankProvider.future);

      // Assert
      expect(rank, 0);
    });
  });

  group('Achievement Progress Provider Tests', () {
    test('should return progress for specific achievement', () async {
      // Arrange
      when(mockRepository.getAchievementProgress('ach_001'))
          .thenAnswer((_) async => testUserAchievement);
      container = createContainer();

      // Act
      final progress = await container
          .read(achievementProgressProvider('ach_001').future);

      // Assert
      expect(progress, isNotNull);
      expect(progress?.progress, 1);
      verify(mockRepository.getAchievementProgress('ach_001')).called(1);
    });

    test('should return null when achievement not started', () async {
      // Arrange
      when(mockRepository.getAchievementProgress('ach_999'))
          .thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final progress = await container
          .read(achievementProgressProvider('ach_999').future);

      // Assert
      expect(progress, isNull);
    });
  });

  group('Gamification Stats Provider Tests', () {
    test('should return comprehensive stats', () async {
      // Arrange
      when(mockRepository.getUserStats()).thenAnswer((_) async => testStats);
      when(mockRepository.getAllAchievements())
          .thenAnswer((_) async => [testAchievement]);
      when(mockRepository.getUserAchievements())
          .thenAnswer((_) async => [testUserAchievement]);

      container = createContainer();

      // Act
      final stats = await container.read(gamificationStatsProvider.future);

      // Assert
      expect(stats['total_xp'], 400);
      expect(stats['level'], 3);
      expect(stats['current_streak'], 5);
      expect(stats['total_achievements'], 1);
      expect(stats['unlocked_achievements'], 1);
      expect(stats['completion_rate'], 100.0);
    });

    test('should calculate completion rate correctly', () async {
      // Arrange
      final achievements = List.generate(
        10,
        (i) => Achievement(
          achievementId: 'ach_$i',
          name: 'Achievement $i',
          description: 'Description',
          icon: 'icon',
          category: 'test',
          difficulty: 'bronze',
          requirementValue: 1,
          xpReward: 50,
        ),
      );

      final userAchievements = [
        testUserAchievement, // 1 unlocked out of 10
      ];

      when(mockRepository.getUserStats()).thenAnswer((_) async => testStats);
      when(mockRepository.getAllAchievements())
          .thenAnswer((_) async => achievements);
      when(mockRepository.getUserAchievements())
          .thenAnswer((_) async => userAchievements);

      container = createContainer();

      // Act
      final stats = await container.read(gamificationStatsProvider.future);

      // Assert
      expect(stats['total_achievements'], 10);
      expect(stats['unlocked_achievements'], 1);
      expect(stats['completion_rate'], 10.0); // 1/10 = 10%
    });
  });
}
