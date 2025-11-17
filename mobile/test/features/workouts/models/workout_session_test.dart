import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout_session.dart';
import 'package:health_fitness_app/features/workouts/data/models/exercise_set.dart';

void main() {
  group('WorkoutSession Model Tests', () {
    test('WorkoutSession should be created from JSON', () {
      final json = {
        'session_id': 's_001',
        'user_id': 'u_123',
        'workout_id': 'w_001',
        'started_at': '2024-01-01T10:00:00.000Z',
        'completed_at': '2024-01-01T11:00:00.000Z',
        'duration_minutes': 60,
        'calories_burned': 350,
        'notes': 'Great workout!',
        'exercise_sets': [],
      };

      final session = WorkoutSession.fromJson(json);

      expect(session.sessionId, 's_001');
      expect(session.userId, 'u_123');
      expect(session.workoutId, 'w_001');
      expect(session.durationMinutes, 60);
      expect(session.caloriesBurned, 350);
      expect(session.notes, 'Great workout!');
    });

    test('WorkoutSession should convert to JSON', () {
      final session = WorkoutSession(
        sessionId: 's_001',
        userId: 'u_123',
        workoutId: 'w_001',
        startedAt: DateTime.parse('2024-01-01T10:00:00.000Z'),
        durationMinutes: 60,
        exerciseSets: [],
      );

      final json = session.toJson();

      expect(json['session_id'], 's_001');
      expect(json['user_id'], 'u_123');
      expect(json['workout_id'], 'w_001');
      expect(json['duration_minutes'], 60);
    });

    group('WorkoutSession Extensions', () {
      test('should check if session is completed', () {
        final completed = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          durationMinutes: 60,
          exerciseSets: [],
        );

        expect(completed.isCompleted, isTrue);

        final inProgress = WorkoutSession(
          sessionId: 's_002',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 0,
          exerciseSets: [],
        );

        expect(inProgress.isCompleted, isFalse);
      });

      test('should check if session is active', () {
        final active = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now().subtract(Duration(minutes: 10)),
          durationMinutes: 0,
          exerciseSets: [],
        );

        expect(active.isActive, isTrue);

        final completed = WorkoutSession(
          sessionId: 's_002',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now().subtract(Duration(hours: 1)),
          completedAt: DateTime.now(),
          durationMinutes: 60,
          exerciseSets: [],
        );

        expect(completed.isActive, isFalse);
      });

      test('should calculate total sets correctly', () {
        final session = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 0,
          exerciseSets: [
            ExerciseSet(
              setId: 'set_1',
              exerciseId: 'e_1',
              setNumber: 1,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_2',
              exerciseId: 'e_1',
              setNumber: 2,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_3',
              exerciseId: 'e_2',
              setNumber: 1,
              reps: 12,
              weight: 30,
            ),
          ],
        );

        expect(session.totalSets, 3);
      });

      test('should calculate total volume correctly', () {
        final session = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 0,
          exerciseSets: [
            ExerciseSet(
              setId: 'set_1',
              exerciseId: 'e_1',
              setNumber: 1,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_2',
              exerciseId: 'e_1',
              setNumber: 2,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_3',
              exerciseId: 'e_2',
              setNumber: 1,
              reps: 12,
              weight: 30,
            ),
          ],
        );

        // (10 × 50) + (10 × 50) + (12 × 30) = 500 + 500 + 360 = 1360
        expect(session.totalVolume, 1360.0);
      });

      test('should calculate average rest time correctly', () {
        final now = DateTime.now();
        final session = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: now,
          durationMinutes: 0,
          exerciseSets: [
            ExerciseSet(
              setId: 'set_1',
              exerciseId: 'e_1',
              setNumber: 1,
              reps: 10,
              weight: 50,
              completedAt: now.add(Duration(seconds: 30)),
            ),
            ExerciseSet(
              setId: 'set_2',
              exerciseId: 'e_1',
              setNumber: 2,
              reps: 10,
              weight: 50,
              completedAt: now.add(Duration(seconds: 120)),
            ),
            ExerciseSet(
              setId: 'set_3',
              exerciseId: 'e_2',
              setNumber: 1,
              reps: 12,
              weight: 30,
              completedAt: now.add(Duration(seconds: 210)),
            ),
          ],
        );

        // Rest times: 90s, 90s
        // Average: 90s
        expect(session.averageRestSeconds, 90);
      });

      test('should get unique exercises count', () {
        final session = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 0,
          exerciseSets: [
            ExerciseSet(
              setId: 'set_1',
              exerciseId: 'e_1',
              setNumber: 1,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_2',
              exerciseId: 'e_1',
              setNumber: 2,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_3',
              exerciseId: 'e_2',
              setNumber: 1,
              reps: 12,
              weight: 30,
            ),
          ],
        );

        expect(session.exerciseCount, 2);
      });

      test('should format duration correctly', () {
        final shortSession = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 45,
          exerciseSets: [],
        );

        expect(shortSession.formattedDuration, '45 min');

        final longSession = WorkoutSession(
          sessionId: 's_002',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 90,
          exerciseSets: [],
        );

        expect(longSession.formattedDuration, '1h 30min');
      });

      test('should get summary text correctly', () {
        final session = WorkoutSession(
          sessionId: 's_001',
          userId: 'u_123',
          workoutId: 'w_001',
          startedAt: DateTime.now(),
          durationMinutes: 60,
          caloriesBurned: 350,
          exerciseSets: [
            ExerciseSet(
              setId: 'set_1',
              exerciseId: 'e_1',
              setNumber: 1,
              reps: 10,
              weight: 50,
            ),
            ExerciseSet(
              setId: 'set_2',
              exerciseId: 'e_2',
              setNumber: 1,
              reps: 12,
              weight: 30,
            ),
            ExerciseSet(
              setId: 'set_3',
              exerciseId: 'e_3',
              setNumber: 1,
              reps: 8,
              weight: 60,
            ),
          ],
        );

        expect(
          session.summaryText,
          '3 ejercicios • 3 series • 60 min • 350 cal',
        );
      });
    });

    test('WorkoutSession should support copyWith', () {
      final session = WorkoutSession(
        sessionId: 's_001',
        userId: 'u_123',
        workoutId: 'w_001',
        startedAt: DateTime.now(),
        durationMinutes: 0,
        exerciseSets: [],
      );

      final updated = session.copyWith(durationMinutes: 60);

      expect(updated.sessionId, 's_001');
      expect(updated.durationMinutes, 60);
    });
  });

  group('ExerciseSet Model Tests', () {
    test('ExerciseSet should be created from JSON', () {
      final json = {
        'set_id': 'set_001',
        'exercise_id': 'e_001',
        'set_number': 1,
        'reps': 10,
        'weight': 50.0,
        'completed_at': '2024-01-01T10:30:00.000Z',
        'notes': 'Felt strong',
      };

      final exerciseSet = ExerciseSet.fromJson(json);

      expect(exerciseSet.setId, 'set_001');
      expect(exerciseSet.exerciseId, 'e_001');
      expect(exerciseSet.setNumber, 1);
      expect(exerciseSet.reps, 10);
      expect(exerciseSet.weight, 50.0);
      expect(exerciseSet.notes, 'Felt strong');
    });

    group('ExerciseSet Extensions', () {
      test('should calculate volume correctly', () {
        final set = ExerciseSet(
          setId: 'set_1',
          exerciseId: 'e_1',
          setNumber: 1,
          reps: 10,
          weight: 50,
        );

        expect(set.volume, 500.0);

        final bodyweight = ExerciseSet(
          setId: 'set_2',
          exerciseId: 'e_2',
          setNumber: 1,
          reps: 15,
        );

        expect(bodyweight.volume, 0.0);
      });

      test('should check if set is completed', () {
        final completed = ExerciseSet(
          setId: 'set_1',
          exerciseId: 'e_1',
          setNumber: 1,
          reps: 10,
          weight: 50,
          completedAt: DateTime.now(),
        );

        expect(completed.isCompleted, isTrue);

        final pending = ExerciseSet(
          setId: 'set_2',
          exerciseId: 'e_2',
          setNumber: 1,
          reps: 10,
          weight: 50,
        );

        expect(pending.isCompleted, isFalse);
      });

      test('should format display text correctly', () {
        final withWeight = ExerciseSet(
          setId: 'set_1',
          exerciseId: 'e_1',
          setNumber: 1,
          reps: 10,
          weight: 50,
        );

        expect(withWeight.displayText, 'Serie 1: 10 reps × 50.0kg');

        final bodyweight = ExerciseSet(
          setId: 'set_2',
          exerciseId: 'e_2',
          setNumber: 2,
          reps: 15,
        );

        expect(bodyweight.displayText, 'Serie 2: 15 reps');
      });

      test('should check if personal record', () {
        final pr = ExerciseSet(
          setId: 'set_1',
          exerciseId: 'e_1',
          setNumber: 1,
          reps: 10,
          weight: 100,
          isPersonalRecord: true,
        );

        expect(pr.isPR, isTrue);

        final normal = ExerciseSet(
          setId: 'set_2',
          exerciseId: 'e_2',
          setNumber: 1,
          reps: 10,
          weight: 50,
        );

        expect(normal.isPR, isFalse);
      });
    });

    test('ExerciseSet should support copyWith', () {
      final set = ExerciseSet(
        setId: 'set_1',
        exerciseId: 'e_1',
        setNumber: 1,
        reps: 10,
        weight: 50,
      );

      final updated = set.copyWith(reps: 12, weight: 55);

      expect(updated.setId, 'set_1');
      expect(updated.reps, 12);
      expect(updated.weight, 55);
    });
  });
}
