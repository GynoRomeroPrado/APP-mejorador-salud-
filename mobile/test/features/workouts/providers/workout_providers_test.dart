import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/workouts/providers/workout_providers.dart';
import 'package:health_fitness_app/features/workouts/data/repositories/workout_repository.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout_exercise.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout_session.dart';
import 'package:health_fitness_app/features/workouts/data/models/exercise_set.dart';

@GenerateMocks([WorkoutRepository])
import 'workout_providers_test.mocks.dart';

void main() {
  late MockWorkoutRepository mockRepository;
  late ProviderContainer container;

  final testWorkout = Workout(
    workoutId: 'w_001',
    userId: 'u_123',
    name: 'Push Day',
    description: 'Chest and triceps',
    exercises: [
      WorkoutExercise(
        exerciseId: 'e_001',
        exerciseName: 'Bench Press',
        sets: 3,
        targetReps: 10,
        targetWeight: 100.0,
        restSeconds: 90,
      ),
    ],
    isTemplate: false,
    createdAt: DateTime.now(),
  );

  final testWorkouts = [
    testWorkout,
    Workout(
      workoutId: 'w_002',
      userId: 'u_123',
      name: 'Pull Day',
      description: 'Back and biceps',
      exercises: [],
      isTemplate: false,
      createdAt: DateTime.now(),
    ),
  ];

  final testSession = WorkoutSession(
    sessionId: 's_001',
    userId: 'u_123',
    workoutId: 'w_001',
    startedAt: DateTime.now(),
    durationMinutes: 60,
    caloriesBurned: 350,
    exerciseSets: [],
  );

  setUp(() {
    mockRepository = MockWorkoutRepository();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(
          AsyncValue.data(mockRepository),
        ),
      ],
    );
  }

  group('Workouts Provider Tests', () {
    test('should return all workouts', () async {
      // Arrange
      when(mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);
      container = createContainer();

      // Act
      final workouts = await container.read(workoutsProvider.future);

      // Assert
      expect(workouts.length, 2);
      expect(workouts[0].name, 'Push Day');
      verify(mockRepository.getWorkouts()).called(1);
    });

    test('should return empty list when no workouts', () async {
      // Arrange
      when(mockRepository.getWorkouts()).thenAnswer((_) async => []);
      container = createContainer();

      // Act
      final workouts = await container.read(workoutsProvider.future);

      // Assert
      expect(workouts, isEmpty);
    });
  });

  group('Workout Provider (Single) Tests', () {
    test('should return workout by id', () async {
      // Arrange
      when(mockRepository.getWorkoutById('w_001'))
          .thenAnswer((_) async => testWorkout);
      container = createContainer();

      // Act
      final workout = await container.read(workoutProvider('w_001').future);

      // Assert
      expect(workout, isNotNull);
      expect(workout?.workoutId, 'w_001');
      expect(workout?.name, 'Push Day');
      verify(mockRepository.getWorkoutById('w_001')).called(1);
    });

    test('should return null when workout not found', () async {
      // Arrange
      when(mockRepository.getWorkoutById('w_999'))
          .thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final workout = await container.read(workoutProvider('w_999').future);

      // Assert
      expect(workout, isNull);
    });
  });

  group('Workout Templates Provider Tests', () {
    test('should return only templates', () async {
      // Arrange
      final templates = [
        testWorkout.copyWith(isTemplate: true),
      ];
      when(mockRepository.getTemplates()).thenAnswer((_) async => templates);
      container = createContainer();

      // Act
      final result = await container.read(workoutTemplatesProvider.future);

      // Assert
      expect(result.length, 1);
      expect(result[0].isTemplate, isTrue);
      verify(mockRepository.getTemplates()).called(1);
    });
  });

  group('Workout Sessions Provider Tests', () {
    test('should return all sessions', () async {
      // Arrange
      when(mockRepository.getSessions()).thenAnswer((_) async => [testSession]);
      container = createContainer();

      // Act
      final sessions = await container.read(workoutSessionsProvider.future);

      // Assert
      expect(sessions.length, 1);
      expect(sessions[0].sessionId, 's_001');
      verify(mockRepository.getSessions()).called(1);
    });

    test('should return sessions for specific workout', () async {
      // Arrange
      when(mockRepository.getSessionsByWorkout('w_001'))
          .thenAnswer((_) async => [testSession]);
      container = createContainer();

      // Act
      final sessions =
          await container.read(workoutSessionsByWorkoutProvider('w_001').future);

      // Assert
      expect(sessions.length, 1);
      expect(sessions[0].workoutId, 'w_001');
      verify(mockRepository.getSessionsByWorkout('w_001')).called(1);
    });
  });

  group('Active Session Provider Tests', () {
    test('should return active session if exists', () async {
      // Arrange
      when(mockRepository.getActiveSession())
          .thenAnswer((_) async => testSession);
      container = createContainer();

      // Act
      final session = await container.read(activeSessionProvider.future);

      // Assert
      expect(session, isNotNull);
      expect(session?.sessionId, 's_001');
      verify(mockRepository.getActiveSession()).called(1);
    });

    test('should return null if no active session', () async {
      // Arrange
      when(mockRepository.getActiveSession()).thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final session = await container.read(activeSessionProvider.future);

      // Assert
      expect(session, isNull);
    });
  });

  group('Workout Actions Provider Tests', () {
    test('should create workout', () async {
      // Arrange
      when(mockRepository.createWorkout(any))
          .thenAnswer((_) async => testWorkout);
      when(mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);

      container = createContainer();

      // Act
      final result = await container
          .read(workoutActionsProvider.notifier)
          .createWorkout(testWorkout);

      // Assert
      expect(result.workoutId, 'w_001');
      verify(mockRepository.createWorkout(any)).called(1);
    });

    test('should update workout', () async {
      // Arrange
      final updatedWorkout = testWorkout.copyWith(name: 'Updated Push Day');
      when(mockRepository.updateWorkout(any))
          .thenAnswer((_) async => updatedWorkout);
      when(mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);
      when(mockRepository.getWorkoutById('w_001'))
          .thenAnswer((_) async => updatedWorkout);

      container = createContainer();

      // Act
      final result = await container
          .read(workoutActionsProvider.notifier)
          .updateWorkout(updatedWorkout);

      // Assert
      expect(result.name, 'Updated Push Day');
      verify(mockRepository.updateWorkout(any)).called(1);
    });

    test('should delete workout', () async {
      // Arrange
      when(mockRepository.deleteWorkout('w_001')).thenAnswer((_) async => {});
      when(mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);

      container = createContainer();

      // Act
      await container
          .read(workoutActionsProvider.notifier)
          .deleteWorkout('w_001');

      // Assert
      verify(mockRepository.deleteWorkout('w_001')).called(1);
    });

    test('should start session', () async {
      // Arrange
      when(mockRepository.startSession(any))
          .thenAnswer((_) async => testSession);
      when(mockRepository.getActiveSession())
          .thenAnswer((_) async => testSession);

      container = createContainer();

      // Act
      final result = await container
          .read(workoutActionsProvider.notifier)
          .startSession('w_001');

      // Assert
      expect(result.workoutId, 'w_001');
      verify(mockRepository.startSession(any)).called(1);
    });

    test('should complete session', () async {
      // Arrange
      final completedSession = testSession.copyWith(
        completedAt: DateTime.now(),
      );
      when(mockRepository.completeSession('s_001'))
          .thenAnswer((_) async => completedSession);
      when(mockRepository.getSessions()).thenAnswer((_) async => [completedSession]);
      when(mockRepository.getActiveSession()).thenAnswer((_) async => null);

      container = createContainer();

      // Act
      final result = await container
          .read(workoutActionsProvider.notifier)
          .completeSession('s_001');

      // Assert
      expect(result.completedAt, isNotNull);
      verify(mockRepository.completeSession('s_001')).called(1);
    });

    test('should add set to session', () async {
      // Arrange
      final exerciseSet = ExerciseSet(
        setId: 'set_001',
        exerciseId: 'e_001',
        setNumber: 1,
        reps: 10,
        weight: 100.0,
      );

      when(mockRepository.addSet(any)).thenAnswer((_) async => exerciseSet);
      when(mockRepository.getActiveSession())
          .thenAnswer((_) async => testSession);

      container = createContainer();

      // Act
      final result = await container
          .read(workoutActionsProvider.notifier)
          .addSet(exerciseSet);

      // Assert
      expect(result.setId, 'set_001');
      verify(mockRepository.addSet(any)).called(1);
    });
  });

  group('Workout Stats Provider Tests', () {
    test('should return workout statistics', () async {
      // Arrange
      when(mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);
      when(mockRepository.getSessions()).thenAnswer((_) async => [testSession]);

      container = createContainer();

      // Act
      final stats = await container.read(workoutStatsProvider.future);

      // Assert
      expect(stats['total_workouts'], 2);
      expect(stats['total_sessions'], 1);
      expect(stats['total_exercises'], isA<int>());
      expect(stats['total_volume'], isA<double>());
      expect(stats['total_calories'], isA<int>());
    });

    test('should calculate total volume correctly', () async {
      // Arrange
      final sessionWithSets = testSession.copyWith(
        exerciseSets: [
          ExerciseSet(
            setId: 'set_1',
            exerciseId: 'e_001',
            setNumber: 1,
            reps: 10,
            weight: 100.0,
          ),
          ExerciseSet(
            setId: 'set_2',
            exerciseId: 'e_001',
            setNumber: 2,
            reps: 10,
            weight: 100.0,
          ),
        ],
      );

      when(mockRepository.getWorkouts()).thenAnswer((_) async => testWorkouts);
      when(mockRepository.getSessions())
          .thenAnswer((_) async => [sessionWithSets]);

      container = createContainer();

      // Act
      final stats = await container.read(workoutStatsProvider.future);

      // Assert
      // Volume = (10 * 100) + (10 * 100) = 2000
      expect(stats['total_volume'], 2000.0);
    });
  });

  group('Recent Sessions Provider Tests', () {
    test('should return recent sessions limited to 10', () async {
      // Arrange
      final sessions = List.generate(
        15,
        (i) => testSession.copyWith(
          sessionId: 's_$i',
          startedAt: DateTime.now().subtract(Duration(days: i)),
        ),
      );

      when(mockRepository.getSessions()).thenAnswer((_) async => sessions);
      container = createContainer();

      // Act
      final recent = await container.read(recentSessionsProvider.future);

      // Assert
      expect(recent.length, 10);
      verify(mockRepository.getSessions()).called(1);
    });

    test('should return sessions sorted by date (newest first)', () async {
      // Arrange
      final sessions = [
        testSession.copyWith(
          sessionId: 's_old',
          startedAt: DateTime.now().subtract(Duration(days: 5)),
        ),
        testSession.copyWith(
          sessionId: 's_new',
          startedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getSessions()).thenAnswer((_) async => sessions);
      container = createContainer();

      // Act
      final recent = await container.read(recentSessionsProvider.future);

      // Assert
      expect(recent.first.sessionId, 's_new');
      expect(recent.last.sessionId, 's_old');
    });
  });
}
