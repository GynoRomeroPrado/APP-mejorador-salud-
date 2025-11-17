import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/exercises/providers/exercises_provider.dart';
import 'package:health_fitness_app/features/exercises/data/repositories/exercise_repository.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise_filter.dart';

@GenerateMocks([ExerciseRepository])
import 'exercises_provider_test.mocks.dart';

void main() {
  late MockExerciseRepository mockRepository;
  late ProviderContainer container;

  final testExercises = [
    Exercise(
      id: 'e_001',
      name: 'Barbell Squat',
      bodyPart: 'legs',
      equipment: 'barbell',
      gifUrl: 'https://example.com/squat.gif',
      target: 'quadriceps',
      secondaryMuscles: ['glutes', 'hamstrings'],
      instructions: ['Step 1', 'Step 2'],
    ),
    Exercise(
      id: 'e_002',
      name: 'Bench Press',
      bodyPart: 'chest',
      equipment: 'barbell',
      gifUrl: 'https://example.com/bench.gif',
      target: 'pectorals',
      secondaryMuscles: ['triceps', 'shoulders'],
      instructions: ['Step 1', 'Step 2'],
    ),
    Exercise(
      id: 'e_003',
      name: 'Push-up',
      bodyPart: 'chest',
      equipment: 'body weight',
      gifUrl: 'https://example.com/pushup.gif',
      target: 'pectorals',
      secondaryMuscles: ['triceps'],
      instructions: ['Step 1', 'Step 2'],
    ),
  ];

  setUp(() {
    mockRepository = MockExerciseRepository();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(
          AsyncValue.data(mockRepository),
        ),
      ],
    );
  }

  group('ExerciseFilterState Provider Tests', () {
    test('should have empty filter as initial state', () {
      // Arrange
      container = createContainer();

      // Act
      final filter = container.read(exerciseFilterStateProvider);

      // Assert
      expect(filter, const ExerciseFilter());
      expect(filter.bodyPart, isNull);
      expect(filter.equipment, isNull);
      expect(filter.searchQuery, isNull);
      expect(filter.favoritesOnly, isFalse);
      expect(filter.homeOnly, isFalse);
    });

    test('should set body part filter', () {
      // Arrange
      container = createContainer();

      // Act
      container.read(exerciseFilterStateProvider.notifier).setBodyPart('legs');

      // Assert
      final filter = container.read(exerciseFilterStateProvider);
      expect(filter.bodyPart, 'legs');
    });

    test('should set equipment filter', () {
      // Arrange
      container = createContainer();

      // Act
      container
          .read(exerciseFilterStateProvider.notifier)
          .setEquipment('barbell');

      // Assert
      final filter = container.read(exerciseFilterStateProvider);
      expect(filter.equipment, 'barbell');
    });

    test('should set search query', () {
      // Arrange
      container = createContainer();

      // Act
      container
          .read(exerciseFilterStateProvider.notifier)
          .setSearchQuery('squat');

      // Assert
      final filter = container.read(exerciseFilterStateProvider);
      expect(filter.searchQuery, 'squat');
    });

    test('should set favorites only filter', () {
      // Arrange
      container = createContainer();

      // Act
      container
          .read(exerciseFilterStateProvider.notifier)
          .setFavoritesOnly(true);

      // Assert
      final filter = container.read(exerciseFilterStateProvider);
      expect(filter.favoritesOnly, isTrue);
    });

    test('should set home only filter', () {
      // Arrange
      container = createContainer();

      // Act
      container.read(exerciseFilterStateProvider.notifier).setHomeOnly(true);

      // Assert
      final filter = container.read(exerciseFilterStateProvider);
      expect(filter.homeOnly, isTrue);
    });

    test('should clear all filters', () {
      // Arrange
      container = createContainer();
      final notifier = container.read(exerciseFilterStateProvider.notifier);

      // Set multiple filters
      notifier.setBodyPart('legs');
      notifier.setEquipment('barbell');
      notifier.setSearchQuery('squat');
      notifier.setFavoritesOnly(true);

      // Act
      notifier.clearFilters();

      // Assert
      final filter = container.read(exerciseFilterStateProvider);
      expect(filter, const ExerciseFilter());
      expect(filter.bodyPart, isNull);
      expect(filter.equipment, isNull);
      expect(filter.searchQuery, isNull);
      expect(filter.favoritesOnly, isFalse);
    });
  });

  group('Exercises Provider Tests', () {
    test('should return all exercises when no filters', () async {
      // Arrange
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);
      container = createContainer();

      // Act
      final exercises = await container.read(exercisesProvider.future);

      // Assert
      expect(exercises.length, 3);
      expect(exercises, testExercises);
      verify(mockRepository.getExercises()).called(1);
    });

    test('should return filtered exercises when filter is active', () async {
      // Arrange
      final filter = ExerciseFilter(bodyPart: 'legs');
      when(mockRepository.searchExercises(filter))
          .thenAnswer((_) async => [testExercises[0]]);

      container = createContainer();

      // Set filter
      container.read(exerciseFilterStateProvider.notifier).setBodyPart('legs');

      // Act
      final exercises = await container.read(exercisesProvider.future);

      // Assert
      expect(exercises.length, 1);
      expect(exercises[0].bodyPart, 'legs');
      verify(mockRepository.searchExercises(any)).called(1);
    });
  });

  group('Exercise Provider (Single) Tests', () {
    test('should return exercise by id', () async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercises[0]);
      container = createContainer();

      // Act
      final exercise =
          await container.read(exerciseProvider('e_001').future);

      // Assert
      expect(exercise, isNotNull);
      expect(exercise?.id, 'e_001');
      expect(exercise?.name, 'Barbell Squat');
      verify(mockRepository.getExerciseById('e_001')).called(1);
    });

    test('should return null when exercise not found', () async {
      // Arrange
      when(mockRepository.getExerciseById('e_999'))
          .thenAnswer((_) async => null);
      container = createContainer();

      // Act
      final exercise =
          await container.read(exerciseProvider('e_999').future);

      // Assert
      expect(exercise, isNull);
    });
  });

  group('Favorite Exercises Provider Tests', () {
    test('should return favorite exercises', () async {
      // Arrange
      when(mockRepository.getFavorites())
          .thenAnswer((_) async => [testExercises[0], testExercises[2]]);
      container = createContainer();

      // Act
      final favorites = await container.read(favoriteExercisesProvider.future);

      // Assert
      expect(favorites.length, 2);
      verify(mockRepository.getFavorites()).called(1);
    });

    test('should return empty list when no favorites', () async {
      // Arrange
      when(mockRepository.getFavorites()).thenAnswer((_) async => []);
      container = createContainer();

      // Act
      final favorites = await container.read(favoriteExercisesProvider.future);

      // Assert
      expect(favorites, isEmpty);
    });
  });

  group('Filter Lists Provider Tests', () {
    test('should return body part list', () async {
      // Arrange
      when(mockRepository.getBodyPartList())
          .thenAnswer((_) async => ['legs', 'chest', 'back']);
      container = createContainer();

      // Act
      final bodyParts = await container.read(bodyPartListProvider.future);

      // Assert
      expect(bodyParts.length, 3);
      expect(bodyParts, contains('legs'));
      verify(mockRepository.getBodyPartList()).called(1);
    });

    test('should return equipment list', () async {
      // Arrange
      when(mockRepository.getEquipmentList())
          .thenAnswer((_) async => ['barbell', 'dumbbell', 'body weight']);
      container = createContainer();

      // Act
      final equipment = await container.read(equipmentListProvider.future);

      // Assert
      expect(equipment.length, 3);
      expect(equipment, contains('barbell'));
      verify(mockRepository.getEquipmentList()).called(1);
    });

    test('should return target muscle list', () async {
      // Arrange
      when(mockRepository.getTargetList())
          .thenAnswer((_) async => ['quadriceps', 'pectorals', 'lats']);
      container = createContainer();

      // Act
      final targets = await container.read(targetMuscleListProvider.future);

      // Assert
      expect(targets.length, 3);
      expect(targets, contains('quadriceps'));
      verify(mockRepository.getTargetList()).called(1);
    });
  });

  group('Exercise Actions Provider Tests', () {
    test('should toggle favorite', () async {
      // Arrange
      when(mockRepository.toggleFavorite('e_001'))
          .thenAnswer((_) async => {});
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);
      when(mockRepository.getFavorites()).thenAnswer((_) async => []);
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercises[0]);

      container = createContainer();

      // Act
      await container
          .read(exerciseActionsProvider.notifier)
          .toggleFavorite('e_001');

      // Assert
      verify(mockRepository.toggleFavorite('e_001')).called(1);
    });

    test('should refresh exercises', () async {
      // Arrange
      when(mockRepository.getExercises(forceRefresh: true))
          .thenAnswer((_) async => testExercises);
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);

      container = createContainer();

      // Act
      await container
          .read(exerciseActionsProvider.notifier)
          .refreshExercises();

      // Assert
      verify(mockRepository.getExercises(forceRefresh: true)).called(1);
    });

    test('should clear cache', () async {
      // Arrange
      when(mockRepository.clearCache()).thenAnswer((_) async => {});
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);
      when(mockRepository.getFavorites()).thenAnswer((_) async => []);

      container = createContainer();

      // Act
      await container.read(exerciseActionsProvider.notifier).clearCache();

      // Assert
      verify(mockRepository.clearCache()).called(1);
    });
  });

  group('Exercise Stats Provider Tests', () {
    test('should return exercise statistics', () async {
      // Arrange
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);
      when(mockRepository.cachedExerciseCount).thenReturn(1000);
      when(mockRepository.favoritesCount).thenReturn(5);
      when(mockRepository.getLastSyncDate())
          .thenReturn(DateTime(2024, 1, 1));

      container = createContainer();

      // Act
      final stats = await container.read(exerciseStatsProvider.future);

      // Assert
      expect(stats['total_exercises'], 3);
      expect(stats['cached_count'], 1000);
      expect(stats['favorites_count'], 5);
      expect(stats['last_sync'], isA<DateTime>());
      expect(stats['by_body_part'], isA<Map<String, int>>());
      expect(stats['by_equipment'], isA<Map<String, int>>());
    });

    test('should group exercises by body part correctly', () async {
      // Arrange
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);
      when(mockRepository.cachedExerciseCount).thenReturn(1000);
      when(mockRepository.favoritesCount).thenReturn(5);
      when(mockRepository.getLastSyncDate())
          .thenReturn(DateTime(2024, 1, 1));

      container = createContainer();

      // Act
      final stats = await container.read(exerciseStatsProvider.future);
      final byBodyPart = stats['by_body_part'] as Map<String, int>;

      // Assert
      expect(byBodyPart['legs'], 1); // Squat
      expect(byBodyPart['chest'], 2); // Bench Press + Push-up
    });

    test('should group exercises by equipment correctly', () async {
      // Arrange
      when(mockRepository.getExercises()).thenAnswer((_) async => testExercises);
      when(mockRepository.cachedExerciseCount).thenReturn(1000);
      when(mockRepository.favoritesCount).thenReturn(5);
      when(mockRepository.getLastSyncDate())
          .thenReturn(DateTime(2024, 1, 1));

      container = createContainer();

      // Act
      final stats = await container.read(exerciseStatsProvider.future);
      final byEquipment = stats['by_equipment'] as Map<String, int>;

      // Assert
      expect(byEquipment['barbell'], 2); // Squat + Bench Press
      expect(byEquipment['body weight'], 1); // Push-up
    });
  });
}
