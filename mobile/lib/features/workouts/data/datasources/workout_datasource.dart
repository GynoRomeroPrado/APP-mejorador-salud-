import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/exercise_set.dart';

class WorkoutDatasource {
  final SupabaseClient _supabase;

  WorkoutDatasource({required SupabaseClient supabase}) : _supabase = supabase;

  // WORKOUTS

  /// Obtiene todos los workouts del usuario
  Future<List<Workout>> getWorkouts(String userId) async {
    final response = await _supabase
        .from('workouts')
        .select('''
          *,
          workout_exercises (
            *
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene un workout por ID
  Future<Workout?> getWorkoutById(String workoutId) async {
    final response = await _supabase
        .from('workouts')
        .select('''
          *,
          workout_exercises (
            *
          )
        ''')
        .eq('workout_id', workoutId)
        .maybeSingle();

    if (response == null) return null;
    return Workout.fromJson(response as Map<String, dynamic>);
  }

  /// Crea un nuevo workout
  Future<Workout> createWorkout(Workout workout) async {
    final response = await _supabase
        .from('workouts')
        .insert(workout.toJson())
        .select()
        .single();

    return Workout.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza un workout
  Future<Workout> updateWorkout(Workout workout) async {
    final response = await _supabase
        .from('workouts')
        .update(workout.toJson())
        .eq('workout_id', workout.workoutId)
        .select()
        .single();

    return Workout.fromJson(response as Map<String, dynamic>);
  }

  /// Elimina un workout
  Future<void> deleteWorkout(String workoutId) async {
    await _supabase.from('workouts').delete().eq('workout_id', workoutId);
  }

  /// Obtiene workouts template del usuario
  Future<List<Workout>> getTemplates(String userId) async {
    final response = await _supabase
        .from('workouts')
        .select('''
          *,
          workout_exercises (
            *
          )
        ''')
        .eq('user_id', userId)
        .eq('is_template', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Workout.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // WORKOUT SESSIONS

  /// Obtiene las sesiones de entrenamiento del usuario
  Future<List<WorkoutSession>> getSessions(String userId) async {
    final response = await _supabase
        .from('workout_sessions')
        .select('''
          *,
          exercise_sets (
            *
          )
        ''')
        .eq('user_id', userId)
        .order('started_at', ascending: false);

    return (response as List)
        .map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene sesiones activas (en progreso)
  Future<List<WorkoutSession>> getActiveSessions(String userId) async {
    final response = await _supabase
        .from('workout_sessions')
        .select('''
          *,
          exercise_sets (
            *
          )
        ''')
        .eq('user_id', userId)
        .eq('status', 'in_progress')
        .order('started_at', ascending: false);

    return (response as List)
        .map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Crea una nueva sesión de entrenamiento
  Future<WorkoutSession> createSession(WorkoutSession session) async {
    final response = await _supabase
        .from('workout_sessions')
        .insert(session.toJson())
        .select()
        .single();

    return WorkoutSession.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza una sesión
  Future<WorkoutSession> updateSession(WorkoutSession session) async {
    final response = await _supabase
        .from('workout_sessions')
        .update(session.toJson())
        .eq('session_id', session.sessionId)
        .select()
        .single();

    return WorkoutSession.fromJson(response as Map<String, dynamic>);
  }

  /// Completa una sesión
  Future<WorkoutSession> completeSession(String sessionId) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('workout_sessions')
        .update({
          'status': 'completed',
          'completed_at': now.toIso8601String(),
        })
        .eq('session_id', sessionId)
        .select()
        .single();

    return WorkoutSession.fromJson(response as Map<String, dynamic>);
  }

  // EXERCISE SETS

  /// Agrega una serie a una sesión
  Future<ExerciseSet> addSet(ExerciseSet set) async {
    final response = await _supabase
        .from('exercise_sets')
        .insert(set.toJson())
        .select()
        .single();

    return ExerciseSet.fromJson(response as Map<String, dynamic>);
  }

  /// Actualiza una serie
  Future<ExerciseSet> updateSet(ExerciseSet set) async {
    final response = await _supabase
        .from('exercise_sets')
        .update(set.toJson())
        .eq('set_id', set.setId)
        .select()
        .single();

    return ExerciseSet.fromJson(response as Map<String, dynamic>);
  }

  /// Marca una serie como completada
  Future<ExerciseSet> completeSet(String setId, int reps, double? weight) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('exercise_sets')
        .update({
          'reps': reps,
          if (weight != null) 'weight': weight,
          'completed': true,
          'completed_at': now.toIso8601String(),
        })
        .eq('set_id', setId)
        .select()
        .single();

    return ExerciseSet.fromJson(response as Map<String, dynamic>);
  }

  /// Elimina una serie
  Future<void> deleteSet(String setId) async {
    await _supabase.from('exercise_sets').delete().eq('set_id', setId);
  }

  // ESTADÍSTICAS

  /// Obtiene estadísticas de workouts del usuario
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    // Total de sesiones completadas
    final sessions = await _supabase
        .from('workout_sessions')
        .select('session_id')
        .eq('user_id', userId)
        .eq('status', 'completed');

    final totalSessions = (sessions as List).length;

    // Promedio de duración
    final durationsResponse = await _supabase
        .from('workout_sessions')
        .select('duration_minutes')
        .eq('user_id', userId)
        .eq('status', 'completed');

    final durations = (durationsResponse as List)
        .map((e) => e['duration_minutes'] as int?)
        .where((d) => d != null)
        .cast<int>()
        .toList();

    final avgDuration = durations.isEmpty
        ? 0
        : durations.reduce((a, b) => a + b) ~/ durations.length;

    // Total de calorías
    final caloriesResponse = await _supabase
        .from('workout_sessions')
        .select('calories_burned')
        .eq('user_id', userId)
        .eq('status', 'completed');

    final totalCalories = (caloriesResponse as List)
        .map((e) => e['calories_burned'] as int?)
        .where((c) => c != null)
        .fold<int>(0, (sum, c) => sum + c!);

    return {
      'total_sessions': totalSessions,
      'avg_duration_minutes': avgDuration,
      'total_calories': totalCalories,
    };
  }
}
