import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/workout.dart';
import '../data/models/workout_session.dart';
import '../data/repositories/workout_repository.dart';

part 'workout_providers.g.dart';

// WORKOUTS

@riverpod
Future<List<Workout>> workouts(WorkoutsRef ref, String userId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getWorkouts(userId);
}

@riverpod
Future<Workout?> workout(WorkoutRef ref, String workoutId) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getWorkoutById(workoutId);
}

@riverpod
Future<List<Workout>> workoutTemplates(
  WorkoutTemplatesRef ref,
  String userId,
) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getTemplates(userId);
}

// WORKOUT SESSIONS

@riverpod
Future<List<WorkoutSession>> workoutSessions(
  WorkoutSessionsRef ref,
  String userId,
) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getSessions(userId);
}

@riverpod
Future<List<WorkoutSession>> activeWorkoutSessions(
  ActiveWorkoutSessionsRef ref,
  String userId,
) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getActiveSessions(userId);
}

// WORKOUT STATS

@riverpod
Future<Map<String, dynamic>> workoutStats(
  WorkoutStatsRef ref,
  String userId,
) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getWorkoutStats(userId);
}

// WORKOUT ACTIONS

@riverpod
class WorkoutActions extends _$WorkoutActions {
  @override
  void build() {}

  Future<Workout> createWorkout(Workout workout) async {
    final repository = ref.read(workoutRepositoryProvider);
    final created = await repository.createWorkout(workout);

    // Invalidar providers para refrescar UI
    ref.invalidate(workoutsProvider(workout.userId));
    ref.invalidate(workoutTemplatesProvider(workout.userId));

    return created;
  }

  Future<Workout> updateWorkout(Workout workout) async {
    final repository = ref.read(workoutRepositoryProvider);
    final updated = await repository.updateWorkout(workout);

    // Invalidar providers
    ref.invalidate(workoutsProvider(workout.userId));
    ref.invalidate(workoutProvider(workout.workoutId));
    ref.invalidate(workoutTemplatesProvider(workout.userId));

    return updated;
  }

  Future<void> deleteWorkout(String workoutId, String userId) async {
    final repository = ref.read(workoutRepositoryProvider);
    await repository.deleteWorkout(workoutId);

    // Invalidar providers
    ref.invalidate(workoutsProvider(userId));
    ref.invalidate(workoutTemplatesProvider(userId));
  }

  Future<WorkoutSession> startWorkout(Workout workout, String userId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final session = await repository.startWorkoutFromTemplate(workout, userId);

    // Invalidar providers
    ref.invalidate(activeWorkoutSessionsProvider(userId));
    ref.invalidate(workoutSessionsProvider(userId));

    return session;
  }

  Future<WorkoutSession> completeSession(String sessionId, String userId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final completed = await repository.completeSession(sessionId);

    // Invalidar providers
    ref.invalidate(activeWorkoutSessionsProvider(userId));
    ref.invalidate(workoutSessionsProvider(userId));
    ref.invalidate(workoutStatsProvider(userId));

    return completed;
  }

  Future<Workout> duplicateWorkout(Workout workout, String userId) async {
    final repository = ref.read(workoutRepositoryProvider);
    final duplicated = await repository.duplicateWorkout(workout, userId);

    // Invalidar providers
    ref.invalidate(workoutsProvider(userId));
    ref.invalidate(workoutTemplatesProvider(userId));

    return duplicated;
  }
}
