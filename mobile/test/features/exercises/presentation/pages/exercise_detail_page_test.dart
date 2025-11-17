import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/exercises/presentation/pages/exercise_detail_page.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise.dart';
import 'package:health_fitness_app/features/exercises/data/repositories/exercise_repository.dart';
import 'package:health_fitness_app/features/exercises/providers/exercises_provider.dart';

@GenerateMocks([ExerciseRepository])
import 'exercise_detail_page_test.mocks.dart';

void main() {
  late MockExerciseRepository mockRepository;

  final testExercise = Exercise(
    id: 'e_001',
    name: 'Barbell Squat',
    bodyPart: 'legs',
    equipment: 'barbell',
    gifUrl: 'https://example.com/squat.gif',
    target: 'quadriceps',
    secondaryMuscles: ['glutes', 'hamstrings'],
    instructions: [
      'Stand with feet shoulder-width apart',
      'Lower your body by bending knees',
      'Push through heels to return to start',
    ],
  );

  setUp(() {
    mockRepository = MockExerciseRepository();
  });

  Widget createWidgetUnderTest(String exerciseId) {
    return ProviderScope(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(
          AsyncValue.data(mockRepository),
        ),
      ],
      child: MaterialApp(
        home: ExerciseDetailPage(exerciseId: exerciseId),
      ),
    );
  }

  group('ExerciseDetailPage Tests', () {
    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => await Future.delayed(
                const Duration(seconds: 5),
                () => testExercise,
              ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display exercise name in app bar',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Barbell Squat'), findsOneWidget);
    });

    testWidgets('should display exercise GIF', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is NetworkImage),
          findsWidgets);
    });

    testWidgets('should display favorite button',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(
          find.byWidgetPredicate((widget) =>
              widget is IconButton &&
              widget.icon is Icon &&
              ((widget.icon as Icon).icon == Icons.favorite ||
                  (widget.icon as Icon).icon == Icons.favorite_border)),
          findsOneWidget);
    });

    testWidgets('should display body part chip', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('should display target muscle chip',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('should display equipment chip', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('should display instructions section',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Instrucciones'), findsOneWidget);
    });

    testWidgets('should display all instruction steps',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Stand with feet shoulder-width apart'), findsOneWidget);
      expect(find.text('Lower your body by bending knees'), findsOneWidget);
      expect(find.text('Push through heels to return to start'), findsOneWidget);
    });

    testWidgets('should display share button', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('should display add to routine button',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Agregar a mi rutina'), findsOneWidget);
    });

    testWidgets('should display start exercise button',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Comenzar ahora'), findsOneWidget);
    });

    testWidgets('should handle exercise not found',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_999'))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_999'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ejercicio no encontrado'), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenThrow(Exception('Network error'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Error al cargar ejercicio'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display home badge for home exercises',
        (WidgetTester tester) async {
      // Arrange
      final homeExercise = Exercise(
        id: 'e_002',
        name: 'Push-up',
        bodyPart: 'chest',
        equipment: 'body weight',
        gifUrl: 'https://example.com/pushup.gif',
        target: 'pectorals',
        secondaryMuscles: ['triceps'],
        instructions: ['Step 1'],
      );

      when(mockRepository.getExerciseById('e_002'))
          .thenAnswer((_) async => homeExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_002'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Para casa'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsWidgets);
    });

    testWidgets('should display difficulty badge',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Chip), findsWidgets);
    });

    testWidgets('should use SliverAppBar for scrolling effect',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('should display secondary muscles info',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Músculos secundarios'), findsOneWidget);
    });

    testWidgets('should display calories per minute info',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Calorías por minuto'), findsOneWidget);
    });

    testWidgets('should scroll to reveal all content',
        (WidgetTester tester) async {
      // Arrange
      when(mockRepository.getExerciseById('e_001'))
          .thenAnswer((_) async => testExercise);

      // Act
      await tester.pumpWidget(createWidgetUnderTest('e_001'));
      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(
          find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Comenzar ahora'), findsOneWidget);
    });
  });
}
