import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout_exercise.dart';

void main() {
  group('Workout Model Tests', () {
    test('Workout model should be created from JSON', () {
      final json = {
        'workout_id': 'w_001',
        'user_id': 'u_123',
        'name': 'Full Body Workout',
        'description': 'Complete body workout',
        'target_muscle_group': 'full_body',
        'exercises': [],
        'is_template': true,
      };

      final workout = Workout.fromJson(json);

      expect(workout.workoutId, 'w_001');
      expect(workout.userId, 'u_123');
      expect(workout.name, 'Full Body Workout');
      expect(workout.isTemplate, isTrue);
    });

    group('Workout Extensions', () {
      test('should calculate estimated duration correctly', () {
        final workout = Workout(
          workoutId: 'w_001',
          userId: 'u_123',
          name: 'Test Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 3),
            WorkoutExercise(exerciseId: 'e2', sets: 3),
            WorkoutExercise(exerciseId: 'e3', sets: 3),
          ],
        );

        // 3 exercises × 3 minutes each = 9 minutes
        expect(workout.estimatedDuration, 9);
      });

      test('should calculate total sets correctly', () {
        final workout = Workout(
          workoutId: 'w_001',
          userId: 'u_123',
          name: 'Test Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 3),
            WorkoutExercise(exerciseId: 'e2', sets: 4),
            WorkoutExercise(exerciseId: 'e3', sets: 5),
          ],
        );

        expect(workout.totalSets, 12);
      });

      test('should calculate estimated calories correctly', () {
        final workout = Workout(
          workoutId: 'w_001',
          userId: 'u_123',
          name: 'Test Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 3),
            WorkoutExercise(exerciseId: 'e2', sets: 4),
          ],
        );

        // 7 sets × 5 calories = 35 calories
        expect(workout.estimatedCalories, 35);
      });

      test('should check if workout is empty', () {
        final emptyWorkout = Workout(
          workoutId: 'w_001',
          userId: 'u_123',
          name: 'Empty Workout',
          exercises: [],
        );

        expect(emptyWorkout.isEmpty, isTrue);

        final nonEmptyWorkout = Workout(
          workoutId: 'w_002',
          userId: 'u_123',
          name: 'Non-empty Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 3),
          ],
        );

        expect(nonEmptyWorkout.isEmpty, isFalse);
      });

      test('should determine difficulty correctly', () {
        final easy = Workout(
          workoutId: 'w_001',
          userId: 'u_123',
          name: 'Easy Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 2),
            WorkoutExercise(exerciseId: 'e2', sets: 2),
          ],
        );

        expect(easy.difficulty, 'easy');

        final medium = Workout(
          workoutId: 'w_002',
          userId: 'u_123',
          name: 'Medium Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 3),
            WorkoutExercise(exerciseId: 'e2', sets: 3),
            WorkoutExercise(exerciseId: 'e3', sets: 3),
            WorkoutExercise(exerciseId: 'e4', sets: 3),
          ],
        );

        expect(medium.difficulty, 'medium');

        final hard = Workout(
          workoutId: 'w_003',
          userId: 'u_123',
          name: 'Hard Workout',
          exercises: [
            WorkoutExercise(exerciseId: 'e1', sets: 4),
            WorkoutExercise(exerciseId: 'e2', sets: 4),
            WorkoutExercise(exerciseId: 'e3', sets: 4),
            WorkoutExercise(exerciseId: 'e4', sets: 4),
            WorkoutExercise(exerciseId: 'e5', sets: 4),
          ],
        );

        expect(hard.difficulty, 'hard');
      });
    });

    test('Workout should support copyWith', () {
      final workout = Workout(
        workoutId: 'w_001',
        userId: 'u_123',
        name: 'Original Name',
        exercises: [],
      );

      final updated = workout.copyWith(name: 'Updated Name');

      expect(updated.workoutId, 'w_001');
      expect(updated.name, 'Updated Name');
    });
  });

  group('WorkoutExercise Model Tests', () {
    test('WorkoutExercise should calculate estimated time correctly', () {
      final exercise = WorkoutExercise(
        exerciseId: 'e1',
        sets: 3,
        targetReps: 10,
        restSeconds: 90,
      );

      // 3 sets × 10 reps × 0.5s/rep / 60 + (3-1) × 90s / 60
      // = 15s / 60 + 180s / 60 = 0.25 + 3 = 3.25 minutes → rounds to 4
      expect(exercise.estimatedTimeMinutes, greaterThanOrEqualTo(3));
    });

    test('WorkoutExercise should calculate total volume correctly', () {
      final exercise = WorkoutExercise(
        exerciseId: 'e1',
        sets: 3,
        targetReps: 10,
        targetWeight: 50.0,
      );

      // 3 × 10 × 50 = 1500
      expect(exercise.totalVolume, 1500.0);

      final noWeight = WorkoutExercise(
        exerciseId: 'e2',
        sets: 3,
        targetReps: 10,
      );

      expect(noWeight.totalVolume, 0.0);
    });

    test('WorkoutExercise should format description correctly', () {
      final withWeight = WorkoutExercise(
        exerciseId: 'e1',
        sets: 3,
        targetReps: 10,
        targetWeight: 50.0,
      );

      expect(withWeight.description, '3 series × 10 reps × 50.0kg');

      final noWeight = WorkoutExercise(
        exerciseId: 'e2',
        sets: 4,
        targetReps: 12,
      );

      expect(noWeight.description, '4 series × 12 reps');
    });

    test('WorkoutExercise should format rest time correctly', () {
      final seconds = WorkoutExercise(
        exerciseId: 'e1',
        sets: 3,
        restSeconds: 45,
      );

      expect(seconds.restTimeFormatted, '45s');

      final minutes = WorkoutExercise(
        exerciseId: 'e2',
        sets: 3,
        restSeconds: 120,
      );

      expect(minutes.restTimeFormatted, '2min');

      final mixed = WorkoutExercise(
        exerciseId: 'e3',
        sets: 3,
        restSeconds: 135,
      );

      expect(mixed.restTimeFormatted, '2min 15s');
    });
  });
}
