import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/achievement.dart';
import '../models/user_achievement.dart';
import '../models/user_stats.dart';

class GamificationDatasource {
  final SupabaseClient _supabase;

  GamificationDatasource({required SupabaseClient supabase})
      : _supabase = supabase;

  // ACHIEVEMENTS

  /// Obtiene todos los logros disponibles
  Future<List<Achievement>> getAllAchievements() async {
    final response = await _supabase
        .from('achievements')
        .select()
        .order('difficulty, required_count');

    return (response as List)
        .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene logros por categoría
  Future<List<Achievement>> getAchievementsByCategory(String category) async {
    final response = await _supabase
        .from('achievements')
        .select()
        .eq('category', category)
        .order('required_count');

    return (response as List)
        .map((json) => Achievement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // USER ACHIEVEMENTS

  /// Obtiene los logros del usuario
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    final response = await _supabase
        .from('user_achievements')
        .select('''
          *,
          achievements (*)
        ''')
        .eq('user_id', userId)
        .order('completed_at', ascending: false);

    return (response as List)
        .map((json) => UserAchievement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene logros completados del usuario
  Future<List<UserAchievement>> getCompletedAchievements(String userId) async {
    final response = await _supabase
        .from('user_achievements')
        .select('''
          *,
          achievements (*)
        ''')
        .eq('user_id', userId)
        .eq('completed', true)
        .order('completed_at', ascending: false);

    return (response as List)
        .map((json) => UserAchievement.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Actualiza el progreso de un logro
  Future<UserAchievement> updateAchievementProgress(
    String userId,
    String achievementId,
    int progress,
  ) async {
    final response = await _supabase
        .from('user_achievements')
        .update({
          'current_progress': progress,
        })
        .eq('user_id', userId)
        .eq('achievement_id', achievementId)
        .select()
        .single();

    return UserAchievement.fromJson(response as Map<String, dynamic>);
  }

  /// Completa un logro
  Future<UserAchievement> completeAchievement(
    String userId,
    String achievementId,
  ) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('user_achievements')
        .update({
          'completed': true,
          'completed_at': now.toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('achievement_id', achievementId)
        .select()
        .single();

    return UserAchievement.fromJson(response as Map<String, dynamic>);
  }

  // USER STATS

  /// Obtiene las estadísticas del usuario
  Future<UserStats> getUserStats(String userId) async {
    final response = await _supabase
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      // Crear stats iniciales si no existen
      return await _createUserStats(userId);
    }

    return UserStats.fromJson(response as Map<String, dynamic>);
  }

  /// Crea estadísticas iniciales para un usuario
  Future<UserStats> _createUserStats(String userId) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('user_stats')
        .insert({
          'user_id': userId,
          'total_xp': 0,
          'level': 1,
          'current_streak': 0,
          'longest_streak': 0,
          'updated_at': now.toIso8601String(),
        })
        .select()
        .single();

    return UserStats.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza las estadísticas del usuario
  Future<UserStats> updateUserStats(UserStats stats) async {
    final response = await _supabase
        .from('user_stats')
        .update(stats.toJson())
        .eq('user_id', stats.userId)
        .select()
        .single();

    return UserStats.fromJson(response as Map<String, dynamic>);
  }

  /// Añade XP al usuario
  Future<UserStats> addXP(String userId, int xp) async {
    final currentStats = await getUserStats(userId);
    final newTotalXp = currentStats.totalXp + xp;
    final newLevel = currentStats.calculatedLevel;

    final response = await _supabase
        .from('user_stats')
        .update({
          'total_xp': newTotalXp,
          'level': newLevel,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .select()
        .single();

    return UserStats.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza la racha del usuario
  Future<UserStats> updateStreak(String userId) async {
    final stats = await getUserStats(userId);
    final now = DateTime.now();

    int newCurrentStreak = stats.currentStreak;
    int newLongestStreak = stats.longestStreak;

    // Si la última actividad fue ayer, incrementar racha
    if (stats.streakAtRisk) {
      newCurrentStreak += 1;
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }
    }
    // Si la última actividad fue hoy, mantener racha
    else if (stats.isActiveToday) {
      // No hacer nada, racha ya contada
    }
    // Si fue hace más de un día, resetear racha
    else {
      newCurrentStreak = 1;
    }

    final response = await _supabase
        .from('user_stats')
        .update({
          'current_streak': newCurrentStreak,
          'longest_streak': newLongestStreak,
          'last_activity_date': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        })
        .eq('user_id', userId)
        .select()
        .single();

    return UserStats.fromJson(response as Map<String, dynamic>);
  }

  /// Incrementa contador de workouts completados
  Future<void> incrementWorkoutsCompleted(String userId) async {
    await _supabase.rpc('increment_user_stat', params: {
      'p_user_id': userId,
      'p_stat_name': 'workouts_completed',
    });
  }

  /// Incrementa contador de medicamentos tomados
  Future<void> incrementMedicationsTaken(String userId) async {
    await _supabase.rpc('increment_user_stat', params: {
      'p_user_id': userId,
      'p_stat_name': 'medications_taken',
    });
  }
}
