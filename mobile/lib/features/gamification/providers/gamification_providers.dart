import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/achievement.dart';
import '../data/models/user_achievement.dart';
import '../data/models/user_stats.dart';
import '../data/models/daily_quote.dart';
import '../data/repositories/gamification_repository.dart';

part 'gamification_providers.g.dart';

// ACHIEVEMENTS

@riverpod
Future<List<Achievement>> achievements(AchievementsRef ref) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return await repository.getAllAchievements();
}

@riverpod
Future<List<Achievement>> achievementsByCategory(
  AchievementsByCategoryRef ref,
  String category,
) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return await repository.getAchievementsByCategory(category);
}

// USER ACHIEVEMENTS

@riverpod
Future<List<UserAchievement>> userAchievements(
  UserAchievementsRef ref,
  String userId,
) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return await repository.getUserAchievements(userId);
}

@riverpod
Future<List<UserAchievement>> completedAchievements(
  CompletedAchievementsRef ref,
  String userId,
) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return await repository.getCompletedAchievements(userId);
}

// USER STATS

@riverpod
Future<UserStats> userStats(UserStatsRef ref, String userId) async {
  final repository = ref.watch(gamificationRepositoryProvider);
  return await repository.getUserStats(userId);
}

// DAILY QUOTE

@riverpod
DailyQuote dailyQuote(DailyQuoteRef ref) {
  return DailyQuotes.getQuoteOfTheDay();
}

// GAMIFICATION ACTIONS

@riverpod
class GamificationActions extends _$GamificationActions {
  @override
  void build() {}

  Future<void> trackWorkoutCompleted(
    String userId, {
    int? durationMinutes,
    int? caloriesBurned,
  }) async {
    final repository = ref.read(gamificationRepositoryProvider);
    await repository.trackWorkoutCompleted(
      userId,
      durationMinutes: durationMinutes,
      caloriesBurned: caloriesBurned,
    );

    // Invalidar providers para refrescar UI
    ref.invalidate(userStatsProvider(userId));
    ref.invalidate(userAchievementsProvider(userId));
  }

  Future<void> trackMedicationTaken(String userId) async {
    final repository = ref.read(gamificationRepositoryProvider);
    await repository.trackMedicationTaken(userId);

    // Invalidar providers
    ref.invalidate(userStatsProvider(userId));
    ref.invalidate(userAchievementsProvider(userId));
  }

  Future<void> trackExerciseCompleted(String userId) async {
    final repository = ref.read(gamificationRepositoryProvider);
    await repository.trackExerciseCompleted(userId);

    // Invalidar providers
    ref.invalidate(userStatsProvider(userId));
  }

  Future<void> updateStreak(String userId) async {
    final repository = ref.read(gamificationRepositoryProvider);
    final stats = await repository.updateStreak(userId);

    // Verificar milestone de racha
    if (stats.currentStreak > 0) {
      await repository.trackStreakMilestone(userId, stats.currentStreak);
    }

    // Invalidar providers
    ref.invalidate(userStatsProvider(userId));
  }

  Future<void> addXP(String userId, int xp, {String? reason}) async {
    final repository = ref.read(gamificationRepositoryProvider);
    await repository.addXP(userId, xp, reason: reason);

    // Invalidar providers
    ref.invalidate(userStatsProvider(userId));
  }
}

// COMPUTED PROVIDERS

/// Provider que agrupa logros por categoría
@riverpod
Future<Map<String, List<UserAchievement>>> achievementsByCategories(
  AchievementsByCategoriesRef ref,
  String userId,
) async {
  final achievements = await ref.watch(userAchievementsProvider(userId).future);

  final Map<String, List<UserAchievement>> grouped = {};

  for (final achievement in achievements) {
    // Usar la categoría del achievement si está disponible
    final category = 'general'; // TODO: Obtener de achievement

    if (!grouped.containsKey(category)) {
      grouped[category] = [];
    }

    grouped[category]!.add(achievement);
  }

  return grouped;
}

/// Provider que retorna el progreso general
@riverpod
Future<double> overallProgress(OverallProgressRef ref, String userId) async {
  final achievements = await ref.watch(userAchievementsProvider(userId).future);

  if (achievements.isEmpty) return 0;

  final completed = achievements.where((a) => a.completed).length;
  return (completed / achievements.length) * 100;
}
