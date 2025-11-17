import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/gamification_datasource.dart';
import '../models/achievement.dart';
import '../models/user_achievement.dart';
import '../models/user_stats.dart';

part 'gamification_repository.g.dart';

class GamificationRepository {
  final GamificationDatasource _datasource;

  GamificationRepository({required GamificationDatasource datasource})
      : _datasource = datasource;

  // ACHIEVEMENTS

  Future<List<Achievement>> getAllAchievements() async {
    return await _datasource.getAllAchievements();
  }

  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    return await _datasource.getAchievementsByCategory(category);
  }

  // USER ACHIEVEMENTS

  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    return await _datasource.getUserAchievements(userId);
  }

  Future<List<UserAchievement>> getCompletedAchievements(String userId) async {
    return await _datasource.getCompletedAchievements(userId);
  }

  Future<UserAchievement> updateAchievementProgress(
    String userId,
    String achievementId,
    int progress,
  ) async {
    final updated = await _datasource.updateAchievementProgress(
      userId,
      achievementId,
      progress,
    );

    // Verificar si se completó el logro
    if (updated.requiredCount != null &&
        progress >= updated.requiredCount! &&
        !updated.completed) {
      return await _datasource.completeAchievement(userId, achievementId);
    }

    return updated;
  }

  // USER STATS

  Future<UserStats> getUserStats(String userId) async {
    return await _datasource.getUserStats(userId);
  }

  Future<UserStats> updateUserStats(UserStats stats) async {
    return await _datasource.updateUserStats(stats);
  }

  Future<UserStats> addXP(String userId, int xp, {String? reason}) async {
    final stats = await _datasource.addXP(userId, xp);

    // TODO: Mostrar notificación de XP ganado
    print('✨ +$xp XP ${reason != null ? '($reason)' : ''}');

    return stats;
  }

  Future<UserStats> updateStreak(String userId) async {
    return await _datasource.updateStreak(userId);
  }

  // TRACKING DE ACTIVIDADES

  Future<void> trackWorkoutCompleted(String userId, {
    int? durationMinutes,
    int? caloriesBurned,
  }) async {
    // Incrementar contador
    await _datasource.incrementWorkoutsCompleted(userId);

    // Actualizar racha
    await updateStreak(userId);

    // Dar XP
    int xpEarned = 50; // Base XP

    if (durationMinutes != null && durationMinutes >= 30) {
      xpEarned += 25; // Bonus por workout largo
    }

    await addXP(userId, xpEarned, reason: 'Workout completado');

    // TODO: Verificar logros de workout
  }

  Future<void> trackMedicationTaken(String userId) async {
    // Incrementar contador
    await _datasource.incrementMedicationsTaken(userId);

    // Actualizar racha
    await updateStreak(userId);

    // Dar XP
    await addXP(userId, 10, reason: 'Medicamento tomado');

    // TODO: Verificar logros de medicamentos
  }

  Future<void> trackExerciseCompleted(String userId) async {
    // Dar XP
    await addXP(userId, 15, reason: 'Ejercicio completado');
  }

  Future<void> trackStreakMilestone(String userId, int streakDays) async {
    int xpBonus = 0;

    if (streakDays == 7) xpBonus = 100;
    else if (streakDays == 30) xpBonus = 500;
    else if (streakDays == 100) xpBonus = 2000;
    else if (streakDays % 10 == 0) xpBonus = 50;

    if (xpBonus > 0) {
      await addXP(
        userId,
        xpBonus,
        reason: 'Racha de $streakDays días',
      );
    }
  }
}

// Providers

@riverpod
GamificationDatasource gamificationDatasource(GamificationDatasourceRef ref) {
  // TODO: Obtener Supabase client desde provider
  throw UnimplementedError('Configurar Supabase client');
}

@riverpod
GamificationRepository gamificationRepository(GamificationRepositoryRef ref) {
  return GamificationRepository(
    datasource: ref.watch(gamificationDatasourceProvider),
  );
}
