import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/workout_datasource.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/exercise_set.dart';

part 'workout_repository.g.dart';

class WorkoutRepository {
  final WorkoutDatasource _datasource;

  WorkoutRepository({required WorkoutDatasource datasource})
      : _datasource = datasource;

  // WORKOUTS

  Future<List<Workout>> getWorkouts(String userId) async {
    return await _datasource.getWorkouts(userId);
  }

  Future<Workout?> getWorkoutById(String workoutId) async {
    return await _datasource.getWorkoutById(workoutId);
  }

  Future<Workout> createWorkout(Workout workout) async {
    return await _datasource.createWorkout(workout);
  }

  Future<Workout> updateWorkout(Workout workout) async {
    return await _datasource.updateWorkout(workout);
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _datasource.deleteWorkout(workoutId);
  }

  Future<List<Workout>> getTemplates(String userId) async {
    return await _datasource.getTemplates(userId);
  }

  // WORKOUT SESSIONS

  Future<List<WorkoutSession>> getSessions(String userId) async {
    return await _datasource.getSessions(userId);
  }

  Future<List<WorkoutSession>> getActiveSessions(String userId) async {
    return await _datasource.getActiveSessions(userId);
  }

  Future<WorkoutSession> createSession(WorkoutSession session) async {
    return await _datasource.createSession(session);
  }

  Future<WorkoutSession> updateSession(WorkoutSession session) async {
    return await _datasource.updateSession(session);
  }

  Future<WorkoutSession> completeSession(String sessionId) async {
    return await _datasource.completeSession(sessionId);
  }

  // EXERCISE SETS

  Future<ExerciseSet> addSet(ExerciseSet set) async {
    return await _datasource.addSet(set);
  }

  Future<ExerciseSet> updateSet(ExerciseSet set) async {
    return await _datasource.updateSet(set);
  }

  Future<ExerciseSet> completeSet(
    String setId,
    int reps,
    double? weight,
  ) async {
    return await _datasource.completeSet(setId, reps, weight);
  }

  Future<void> deleteSet(String setId) async {
    await _datasource.deleteSet(setId);
  }

  // ESTADÍSTICAS

  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    return await _datasource.getWorkoutStats(userId);
  }

  // HELPER METHODS

  /// Inicia una sesión de workout desde un template
  Future<WorkoutSession> startWorkoutFromTemplate(
    Workout template,
    String userId,
  ) async {
    // Crear sesión
    final session = WorkoutSession(
      sessionId: '', // Se generará en Supabase
      userId: userId,
      workoutId: template.workoutId,
      workoutName: template.name,
      startedAt: DateTime.now(),
      status: 'in_progress',
    );

    final createdSession = await createSession(session);

    // Crear sets para cada ejercicio
    final sets = <ExerciseSet>[];
    for (final workoutExercise in template.exercises) {
      for (int i = 0; i < workoutExercise.sets; i++) {
        final set = ExerciseSet(
          sessionId: createdSession.sessionId,
          exerciseId: workoutExercise.exerciseId,
          exerciseName: workoutExercise.exerciseName,
          setNumber: i + 1,
          restSeconds: workoutExercise.restSeconds,
        );

        final createdSet = await addSet(set);
        sets.add(createdSet);
      }
    }

    return createdSession.copyWith(sets: sets);
  }

  /// Duplica un workout como template
  Future<Workout> duplicateWorkout(Workout workout, String userId) async {
    final newWorkout = workout.copyWith(
      workoutId: '', // Se generará nuevo ID
      userId: userId,
      name: '${workout.name} (Copia)',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createWorkout(newWorkout);
  }
}

// Providers

@riverpod
WorkoutDatasource workoutDatasource(WorkoutDatasourceRef ref) {
  // TODO: Obtener Supabase client desde provider
  throw UnimplementedError('Configurar Supabase client');
}

@riverpod
WorkoutRepository workoutRepository(WorkoutRepositoryRef ref) {
  return WorkoutRepository(
    datasource: ref.watch(workoutDatasourceProvider),
  );
}
