import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise.dart';

void main() {
  group('Exercise Model Tests', () {
    test('Exercise model should be created from JSON', () {
      final json = {
        'id': 'ex_001',
        'name': 'Barbell Squat',
        'body_part': 'legs',
        'equipment': 'barbell',
        'gif_url': 'https://example.com/squat.gif',
        'target': 'quadriceps',
        'secondary_muscles': ['glutes', 'hamstrings'],
        'instructions': [
          'Step 1',
          'Step 2',
          'Step 3',
        ],
      };

      final exercise = Exercise.fromJson(json);

      expect(exercise.id, 'ex_001');
      expect(exercise.name, 'Barbell Squat');
      expect(exercise.bodyPart, 'legs');
      expect(exercise.equipment, 'barbell');
      expect(exercise.secondaryMuscles.length, 2);
      expect(exercise.instructions.length, 3);
    });

    group('Exercise Extensions', () {
      test('should estimate difficulty correctly', () {
        final bodyweight = Exercise(
          id: '1',
          name: 'Push-up',
          bodyPart: 'chest',
          equipment: 'body weight',
          gifUrl: '',
          target: 'pectorals',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(bodyweight.estimatedDifficulty, 'beginner');

        final barbell = Exercise(
          id: '2',
          name: 'Barbell Squat',
          bodyPart: 'legs',
          equipment: 'barbell',
          gifUrl: '',
          target: 'quadriceps',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(barbell.estimatedDifficulty, 'advanced');

        final dumbbell = Exercise(
          id: '3',
          name: 'Dumbbell Curl',
          bodyPart: 'arms',
          equipment: 'dumbbell',
          gifUrl: '',
          target: 'biceps',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(dumbbell.estimatedDifficulty, 'intermediate');
      });

      test('should identify exercise type correctly', () {
        final compound = Exercise(
          id: '1',
          name: 'Squat',
          bodyPart: 'legs',
          equipment: 'barbell',
          gifUrl: '',
          target: 'quadriceps',
          secondaryMuscles: ['glutes', 'hamstrings'],
          instructions: [],
        );

        expect(compound.exerciseType, 'compound');

        final isolation = Exercise(
          id: '2',
          name: 'Bicep Curl',
          bodyPart: 'arms',
          equipment: 'dumbbell',
          gifUrl: '',
          target: 'biceps',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(isolation.exerciseType, 'isolation');
      });

      test('should translate body parts to Spanish', () {
        final exercise = Exercise(
          id: '1',
          name: 'Exercise',
          bodyPart: 'chest',
          equipment: 'barbell',
          gifUrl: '',
          target: 'pectorals',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(exercise.bodyPartSpanish, 'Pecho');
      });

      test('should translate equipment to Spanish', () {
        final exercise = Exercise(
          id: '1',
          name: 'Exercise',
          bodyPart: 'chest',
          equipment: 'body weight',
          gifUrl: '',
          target: 'pectorals',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(exercise.equipmentSpanish, 'Peso corporal');
      });

      test('should identify exercises that can be done at home', () {
        final bodyweight = Exercise(
          id: '1',
          name: 'Push-up',
          bodyPart: 'chest',
          equipment: 'body weight',
          gifUrl: '',
          target: 'pectorals',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(bodyweight.canDoAtHome, isTrue);

        final dumbbell = Exercise(
          id: '2',
          name: 'Dumbbell Curl',
          bodyPart: 'arms',
          equipment: 'dumbbell',
          gifUrl: '',
          target: 'biceps',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(dumbbell.canDoAtHome, isTrue);

        final machine = Exercise(
          id: '3',
          name: 'Leg Press',
          bodyPart: 'legs',
          equipment: 'machine',
          gifUrl: '',
          target: 'quadriceps',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(machine.canDoAtHome, isFalse);
      });

      test('should estimate calories per minute correctly', () {
        final cardio = Exercise(
          id: '1',
          name: 'Running',
          bodyPart: 'cardio',
          equipment: 'body weight',
          gifUrl: '',
          target: 'cardiovascular system',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(cardio.estimatedCaloriesPerMinute, 8.0);

        final compound = Exercise(
          id: '2',
          name: 'Squat',
          bodyPart: 'legs',
          equipment: 'barbell',
          gifUrl: '',
          target: 'quadriceps',
          secondaryMuscles: ['glutes', 'hamstrings'],
          instructions: [],
        );

        expect(compound.estimatedCaloriesPerMinute, 5.0);

        final isolation = Exercise(
          id: '3',
          name: 'Bicep Curl',
          bodyPart: 'arms',
          equipment: 'dumbbell',
          gifUrl: '',
          target: 'biceps',
          secondaryMuscles: [],
          instructions: [],
        );

        expect(isolation.estimatedCaloriesPerMinute, 3.5);
      });
    });

    test('Exercise should support equality', () {
      final exercise1 = Exercise(
        id: '1',
        name: 'Squat',
        bodyPart: 'legs',
        equipment: 'barbell',
        gifUrl: '',
        target: 'quadriceps',
        secondaryMuscles: [],
        instructions: [],
      );

      final exercise2 = Exercise(
        id: '1',
        name: 'Squat',
        bodyPart: 'legs',
        equipment: 'barbell',
        gifUrl: '',
        target: 'quadriceps',
        secondaryMuscles: [],
        instructions: [],
      );

      final exercise3 = Exercise(
        id: '2',
        name: 'Push-up',
        bodyPart: 'chest',
        equipment: 'body weight',
        gifUrl: '',
        target: 'pectorals',
        secondaryMuscles: [],
        instructions: [],
      );

      expect(exercise1, equals(exercise2));
      expect(exercise1, isNot(equals(exercise3)));
    });
  });
}
