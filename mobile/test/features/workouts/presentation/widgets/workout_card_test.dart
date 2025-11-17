import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/workouts/presentation/widgets/workout_card.dart';
import 'package:health_fitness_app/features/workouts/data/models/workout.dart';

void main() {
  final testWorkout = Workout(
    workoutId: 'w_001',
    userId: 'u_123',
    name: 'Full Body Workout',
    description: 'Complete workout for all muscle groups',
    difficulty: 'medium',
    exercises: [
      WorkoutExercise(
        exerciseId: 'e_001',
        sets: 3,
        reps: 10,
        restSeconds: 60,
      ),
      WorkoutExercise(
        exerciseId: 'e_002',
        sets: 3,
        reps: 12,
        restSeconds: 45,
      ),
    ],
  );

  Widget createWidgetUnderTest(
    Workout workout, {
    VoidCallback? onTap,
    VoidCallback? onStart,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WorkoutCard(
          workout: workout,
          onTap: onTap ?? () {},
          onStart: onStart,
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('WorkoutCard Widget Tests', () {
    testWidgets('should display workout name', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.text('Full Body Workout'), findsOneWidget);
    });

    testWidgets('should display workout description',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(
          find.text('Complete workout for all muscle groups'), findsOneWidget);
    });

    testWidgets('should not display description when null',
        (WidgetTester tester) async {
      // Arrange
      final workoutNoDesc = Workout(
        workoutId: 'w_002',
        userId: 'u_123',
        name: 'Simple Workout',
        difficulty: 'easy',
        exercises: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(workoutNoDesc));

      // Assert
      expect(find.text('Simple Workout'), findsOneWidget);
    });

    testWidgets('should display exercise count', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.text('2 ejercicios'), findsOneWidget);
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
    });

    testWidgets('should display estimated duration',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.textContaining('min'), findsOneWidget);
    });

    testWidgets('should display estimated calories',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
      expect(find.textContaining('kcal'), findsOneWidget);
    });

    testWidgets('should display difficulty badge',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.text('Intermedio'), findsOneWidget);
    });

    testWidgets('should display easy difficulty badge',
        (WidgetTester tester) async {
      // Arrange
      final easyWorkout = Workout(
        workoutId: 'w_003',
        userId: 'u_123',
        name: 'Beginner Workout',
        difficulty: 'easy',
        exercises: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(easyWorkout));

      // Assert
      expect(find.text('Fácil'), findsOneWidget);
      expect(find.byIcon(Icons.signal_cellular_alt_1_bar), findsOneWidget);
    });

    testWidgets('should display hard difficulty badge',
        (WidgetTester tester) async {
      // Arrange
      final hardWorkout = Workout(
        workoutId: 'w_004',
        userId: 'u_123',
        name: 'Advanced Workout',
        difficulty: 'hard',
        exercises: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(hardWorkout));

      // Assert
      expect(find.text('Difícil'), findsOneWidget);
      expect(find.byIcon(Icons.signal_cellular_alt), findsOneWidget);
    });

    testWidgets('should display start button when callback provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout, onStart: () {}));

      // Assert
      expect(find.text('Iniciar'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should not display start button when callback not provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.text('Iniciar'), findsNothing);
    });

    testWidgets('should call onStart when start button is tapped',
        (WidgetTester tester) async {
      // Arrange
      var startCalled = false;
      await tester.pumpWidget(
          createWidgetUnderTest(testWorkout, onStart: () => startCalled = true));

      // Act
      await tester.tap(find.text('Iniciar'));
      await tester.pump();

      // Assert
      expect(startCalled, isTrue);
    });

    testWidgets('should display delete menu when callback provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester
          .pumpWidget(createWidgetUnderTest(testWorkout, onDelete: () {}));

      // Assert
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('should not display delete menu when callback not provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.byType(PopupMenuButton<String>), findsNothing);
    });

    testWidgets('should show delete option in menu',
        (WidgetTester tester) async {
      // Arrange
      await tester
          .pumpWidget(createWidgetUnderTest(testWorkout, onDelete: () {}));

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('should call onDelete when delete is selected',
        (WidgetTester tester) async {
      // Arrange
      var deleteCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(testWorkout,
          onDelete: () => deleteCalled = true));

      // Act
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCalled, isTrue);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
          createWidgetUnderTest(testWorkout, onTap: () => tapped = true));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should display card widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display fitness icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('should truncate long workout names',
        (WidgetTester tester) async {
      // Arrange
      final longNameWorkout = Workout(
        workoutId: 'w_005',
        userId: 'u_123',
        name: 'This is a very long workout name that should be truncated',
        difficulty: 'medium',
        exercises: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(longNameWorkout));

      // Assert
      final textWidget = tester.widget<Text>(find.text(
          'This is a very long workout name that should be truncated'));
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should truncate long descriptions',
        (WidgetTester tester) async {
      // Arrange
      final longDescWorkout = Workout(
        workoutId: 'w_006',
        userId: 'u_123',
        name: 'Workout',
        description:
            'This is a very long description that should be truncated to prevent overflow',
        difficulty: 'easy',
        exercises: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(longDescWorkout));

      // Assert
      final textWidget = tester.widget<Text>(find.text(
          'This is a very long description that should be truncated to prevent overflow'));
      expect(textWidget.maxLines, 1);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should have proper padding and margins',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('should display all stat chips', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      // Should have 3 stat chips (exercises, duration, calories)
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('should be responsive to screen size',
        (WidgetTester tester) async {
      // Arrange
      tester.binding.window.physicalSizeTestValue = const Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testWorkout));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Full Body Workout'), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
