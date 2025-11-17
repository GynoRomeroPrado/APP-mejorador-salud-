import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/exercises/data/repositories/exercise_repository.dart';
import 'package:health_fitness_app/features/exercises/data/datasources/exercisedb_api.dart';
import 'package:health_fitness_app/features/exercises/data/datasources/exercise_local_datasource.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise.dart';

@GenerateMocks([ExerciseDBApi, ExerciseLocalDatasource])
import 'exercise_repository_test.mocks.dart';

void main() {
  late ExerciseRepository repository;
  late MockExerciseDBApi mockApi;
  late MockExerciseLocalDatasource mockLocalDatasource;

  setUp(() {
    mockApi = MockExerciseDBApi();
    mockLocalDatasource = MockExerciseLocalDatasource();
    repository = ExerciseRepository(
      api: mockApi,
      localDatasource: mockLocalDatasource,
    );
  });

  group('ExerciseRepository Tests', () {
    final testExercise = Exercise(
      id: 'e_001',
      name: 'Barbell Squat',
      bodyPart: 'legs',
      equipment: 'barbell',
      gifUrl: 'https://example.com/squat.gif',
      target: 'quadriceps',
      secondaryMuscles: ['glutes', 'hamstrings'],
      instructions: ['Step 1', 'Step 2'],
    );

    group('getAllExercises', () {
      test('should return cached exercises when cache is fresh', () async {
        // Arrange
        when(mockLocalDatasource.isCacheFresh()).thenReturn(true);
        when(mockLocalDatasource.getCachedExercises())
            .thenAnswer((_) async => [testExercise]);

        // Act
        final result = await repository.getAllExercises();

        // Assert
        expect(result, [testExercise]);
        verify(mockLocalDatasource.isCacheFresh()).called(1);
        verify(mockLocalDatasource.getCachedExercises()).called(1);
        verifyNever(mockApi.getAllExercises());
      });

      test('should fetch from API when cache is stale', () async {
        // Arrange
        when(mockLocalDatasource.isCacheFresh()).thenReturn(false);
        when(mockApi.getAllExercises())
            .thenAnswer((_) async => [testExercise]);
        when(mockLocalDatasource.cacheExercises(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getAllExercises();

        // Assert
        expect(result, [testExercise]);
        verify(mockLocalDatasource.isCacheFresh()).called(1);
        verify(mockApi.getAllExercises()).called(1);
        verify(mockLocalDatasource.cacheExercises([testExercise])).called(1);
      });

      test('should fetch from API when forceRefresh is true', () async {
        // Arrange
        when(mockApi.getAllExercises())
            .thenAnswer((_) async => [testExercise]);
        when(mockLocalDatasource.cacheExercises(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getAllExercises(forceRefresh: true);

        // Assert
        expect(result, [testExercise]);
        verifyNever(mockLocalDatasource.isCacheFresh());
        verify(mockApi.getAllExercises()).called(1);
        verify(mockLocalDatasource.cacheExercises([testExercise])).called(1);
      });
    });

    group('getExerciseById', () {
      test('should return exercise from API', () async {
        // Arrange
        when(mockApi.getExerciseById('e_001'))
            .thenAnswer((_) async => testExercise);

        // Act
        final result = await repository.getExerciseById('e_001');

        // Assert
        expect(result, testExercise);
        verify(mockApi.getExerciseById('e_001')).called(1);
      });
    });

    group('getExercisesByBodyPart', () {
      test('should return filtered exercises from API', () async {
        // Arrange
        when(mockApi.getExercisesByBodyPart('legs'))
            .thenAnswer((_) async => [testExercise]);

        // Act
        final result = await repository.getExercisesByBodyPart('legs');

        // Assert
        expect(result, [testExercise]);
        verify(mockApi.getExercisesByBodyPart('legs')).called(1);
      });
    });

    group('getExercisesByTarget', () {
      test('should return exercises by target muscle', () async {
        // Arrange
        when(mockApi.getExercisesByTarget('quadriceps'))
            .thenAnswer((_) async => [testExercise]);

        // Act
        final result = await repository.getExercisesByTarget('quadriceps');

        // Assert
        expect(result, [testExercise]);
        verify(mockApi.getExercisesByTarget('quadriceps')).called(1);
      });
    });

    group('getExercisesByEquipment', () {
      test('should return exercises by equipment', () async {
        // Arrange
        when(mockApi.getExercisesByEquipment('barbell'))
            .thenAnswer((_) async => [testExercise]);

        // Act
        final result = await repository.getExercisesByEquipment('barbell');

        // Assert
        expect(result, [testExercise]);
        verify(mockApi.getExercisesByEquipment('barbell')).called(1);
      });
    });

    group('searchExercises', () {
      test('should return exercises matching search query', () async {
        // Arrange
        when(mockApi.searchExercises('squat'))
            .thenAnswer((_) async => [testExercise]);

        // Act
        final result = await repository.searchExercises('squat');

        // Assert
        expect(result, [testExercise]);
        verify(mockApi.searchExercises('squat')).called(1);
      });
    });

    group('Favorites', () {
      test('should add exercise to favorites', () async {
        // Arrange
        when(mockLocalDatasource.addToFavorites(testExercise))
            .thenAnswer((_) async => {});

        // Act
        await repository.addToFavorites(testExercise);

        // Assert
        verify(mockLocalDatasource.addToFavorites(testExercise)).called(1);
      });

      test('should remove exercise from favorites', () async {
        // Arrange
        when(mockLocalDatasource.removeFromFavorites('e_001'))
            .thenAnswer((_) async => {});

        // Act
        await repository.removeFromFavorites('e_001');

        // Assert
        verify(mockLocalDatasource.removeFromFavorites('e_001')).called(1);
      });

      test('should get all favorite exercises', () async {
        // Arrange
        when(mockLocalDatasource.getFavorites())
            .thenAnswer((_) async => [testExercise]);

        // Act
        final result = await repository.getFavorites();

        // Assert
        expect(result, [testExercise]);
        verify(mockLocalDatasource.getFavorites()).called(1);
      });

      test('should check if exercise is favorite', () async {
        // Arrange
        when(mockLocalDatasource.isFavorite('e_001'))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isFavorite('e_001');

        // Assert
        expect(result, isTrue);
        verify(mockLocalDatasource.isFavorite('e_001')).called(1);
      });
    });

    group('Filtering', () {
      test('should filter exercises by multiple criteria', () async {
        // Arrange
        final exercises = [
          testExercise,
          Exercise(
            id: 'e_002',
            name: 'Push-up',
            bodyPart: 'chest',
            equipment: 'body weight',
            gifUrl: '',
            target: 'pectorals',
            secondaryMuscles: [],
            instructions: [],
          ),
        ];

        when(mockLocalDatasource.getCachedExercises())
            .thenAnswer((_) async => exercises);
        when(mockLocalDatasource.isCacheFresh()).thenReturn(true);

        // Act
        final result = await repository.getFilteredExercises(
          bodyPart: 'legs',
          equipment: 'barbell',
        );

        // Assert
        expect(result.length, 1);
        expect(result.first.id, 'e_001');
      });

      test('should filter exercises for home workouts', () async {
        // Arrange
        final exercises = [
          Exercise(
            id: 'e_001',
            name: 'Push-up',
            bodyPart: 'chest',
            equipment: 'body weight',
            gifUrl: '',
            target: 'pectorals',
            secondaryMuscles: [],
            instructions: [],
          ),
          Exercise(
            id: 'e_002',
            name: 'Leg Press',
            bodyPart: 'legs',
            equipment: 'machine',
            gifUrl: '',
            target: 'quadriceps',
            secondaryMuscles: [],
            instructions: [],
          ),
        ];

        when(mockLocalDatasource.getCachedExercises())
            .thenAnswer((_) async => exercises);
        when(mockLocalDatasource.isCacheFresh()).thenReturn(true);

        // Act
        final result = await repository.getHomeExercises();

        // Assert
        expect(result.length, 1);
        expect(result.first.equipment, 'body weight');
      });
    });
  });
}
