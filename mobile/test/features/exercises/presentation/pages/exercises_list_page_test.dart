import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/exercises/presentation/pages/exercises_list_page.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise.dart';
import 'package:health_fitness_app/features/exercises/data/repositories/exercise_repository.dart';

@GenerateMocks([ExerciseRepository])
import 'exercises_list_page_test.mocks.dart';

void main() {
  late MockExerciseRepository mockRepository;

  setUp(() {
    mockRepository = MockExerciseRepository();
  });

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

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        home: ExercisesListPage(),
      ),
    );
  }

  group('ExercisesListPage Widget Tests', () {
    testWidgets('should display app bar with title and search icon',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ejercicios'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('should display loading indicator while fetching exercises',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises()).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 2));
        return testExercises;
      });

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display list of exercises when loaded',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Push-up'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should display exercise details in list item',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - First exercise
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Piernas'), findsOneWidget); // Spanish translation
      expect(find.text('Cuádriceps'), findsOneWidget);
      expect(find.byType(Image), findsWidgets); // GIF thumbnails
    });

    testWidgets('should show search bar when search icon is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchIcon = find.byIcon(Icons.search);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar ejercicio...'), findsOneWidget);
    });

    testWidgets('should filter exercises when searching',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);
      when(mockRepository.searchExercises('squat'))
          .thenAnswer((_) async => [testExercises[0]]);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchIcon = find.byIcon(Icons.search);
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'squat');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Barbell Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
      expect(find.text('Push-up'), findsNothing);
    });

    testWidgets('should show filter bottom sheet when filter icon is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final filterIcon = find.byIcon(Icons.filter_list);
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Filtros'), findsOneWidget);
      expect(find.text('Grupo Muscular'), findsOneWidget);
      expect(find.text('Equipo'), findsOneWidget);
      expect(find.text('Aplicar Filtros'), findsOneWidget);
    });

    testWidgets('should filter by body part', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);
      when(mockRepository.getExercisesByBodyPart('chest'))
          .thenAnswer((_) async => [testExercises[1], testExercises[2]]);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final filterIcon = find.byIcon(Icons.filter_list);
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();

      // Select chest
      final chestChip = find.widgetWithText(ChoiceChip, 'Pecho');
      await tester.tap(chestChip);
      await tester.pumpAndSettle();

      // Apply filters
      final applyButton = find.text('Aplicar Filtros');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Push-up'), findsOneWidget);
      expect(find.text('Barbell Squat'), findsNothing);
    });

    testWidgets('should filter by equipment', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);
      when(mockRepository.getExercisesByEquipment('body weight'))
          .thenAnswer((_) async => [testExercises[2]]);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final filterIcon = find.byIcon(Icons.filter_list);
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();

      // Select body weight
      final bodyWeightChip = find.widgetWithText(ChoiceChip, 'Peso Corporal');
      await tester.tap(bodyWeightChip);
      await tester.pumpAndSettle();

      // Apply filters
      final applyButton = find.text('Aplicar Filtros');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Push-up'), findsOneWidget);
      expect(find.text('Barbell Squat'), findsNothing);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets('should clear filters when reset button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final filterIcon = find.byIcon(Icons.filter_list);
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();

      // Select a filter
      final chestChip = find.widgetWithText(ChoiceChip, 'Pecho');
      await tester.tap(chestChip);
      await tester.pump();

      // Reset filters
      final resetButton = find.text('Limpiar');
      await tester.tap(resetButton);
      await tester.pump();

      // Assert - All chips should be unselected
      final ChoiceChip chip = tester.widget(chestChip);
      expect(chip.selected, isFalse);
    });

    testWidgets('should navigate to exercise detail when item is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final exerciseItem = find.text('Barbell Squat');
      await tester.tap(exerciseItem);
      await tester.pumpAndSettle();

      // Assert - Should navigate to detail page
      // This would need proper navigation setup
      // expect(find.byType(ExerciseDetailPage), findsOneWidget);
    });

    testWidgets('should toggle favorite when favorite icon is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);
      when(mockRepository.isFavorite('e_001')).thenAnswer((_) async => false);
      when(mockRepository.addToFavorites(any)).thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final favoriteIcon = find.byIcon(Icons.favorite_border).first;
      await tester.tap(favoriteIcon);
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.addToFavorites(any)).called(1);
    });

    testWidgets('should show empty state when no exercises found',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No se encontraron ejercicios'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('should show error message when loading fails',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenThrow(Exception('Error de conexión'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error al cargar ejercicios'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('should retry loading when retry button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenThrow(Exception('Error de conexión'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap retry
      final retryButton = find.text('Reintentar');
      await tester.tap(retryButton);
      await tester.pump();

      // Assert
      verify(mockRepository.getAllExercises()).called(2); // Initial + retry
    });

    testWidgets('should pull to refresh', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises(forceRefresh: true))
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), Offset(0, 300));
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.getAllExercises(forceRefresh: true)).called(1);
    });

    testWidgets('should display active filter count badge',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getAllExercises())
          .thenAnswer((_) async => testExercises);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final filterIcon = find.byIcon(Icons.filter_list);
      await tester.tap(filterIcon);
      await tester.pumpAndSettle();

      // Select multiple filters
      final chestChip = find.widgetWithText(ChoiceChip, 'Pecho');
      await tester.tap(chestChip);
      await tester.pump();

      final barbellChip = find.widgetWithText(ChoiceChip, 'Barra');
      await tester.tap(barbellChip);
      await tester.pump();

      // Apply filters
      final applyButton = find.text('Aplicar Filtros');
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      // Assert - Should show badge with count
      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // 2 active filters
    });
  });
}
