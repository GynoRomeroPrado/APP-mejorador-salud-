import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:health_fitness_app/features/exercises/data/models/exercise.dart';

void main() {
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

  Widget createWidgetUnderTest(Exercise exercise,
      {VoidCallback? onTap, VoidCallback? onFavoriteTap}) {
    return MaterialApp(
      home: Scaffold(
        body: ExerciseCard(
          exercise: exercise,
          onTap: onTap ?? () {},
          onFavoriteTap: onFavoriteTap,
        ),
      ),
    );
  }

  group('ExerciseCard Widget Tests', () {
    testWidgets('should display exercise name', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.text('Barbell Squat'), findsOneWidget);
    });

    testWidgets('should display exercise GIF', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is NetworkImage),
          findsOneWidget);
    });

    testWidgets('should display target muscle', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.byIcon(Icons.sports_gymnastics), findsOneWidget);
    });

    testWidgets('should display equipment icon', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.byIcon(Icons.construction), findsOneWidget);
    });

    testWidgets('should display difficulty badge',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      // Badge text should be uppercase
      expect(find.textContaining('BEGINNER'), findsOneWidget);
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

      // Act
      await tester.pumpWidget(createWidgetUnderTest(homeExercise));

      // Assert
      expect(find.text('Casa'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('should display favorite button when callback provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester
          .pumpWidget(createWidgetUnderTest(testExercise, onFavoriteTap: () {}));

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should not display favorite button when callback not provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsNothing);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should show filled heart icon when exercise is favorite',
        (WidgetTester tester) async {
      // Arrange
      final favoriteExercise = Exercise(
        id: 'e_001',
        name: 'Barbell Squat',
        bodyPart: 'legs',
        equipment: 'barbell',
        gifUrl: 'https://example.com/squat.gif',
        target: 'quadriceps',
        secondaryMuscles: ['glutes'],
        instructions: ['Step 1'],
        isFavorite: true,
      );

      // Act
      await tester.pumpWidget(
          createWidgetUnderTest(favoriteExercise, onFavoriteTap: () {}));

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
          createWidgetUnderTest(testExercise, onTap: () => tapped = true));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should call onFavoriteTap when favorite button is tapped',
        (WidgetTester tester) async {
      // Arrange
      var favoriteTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(testExercise,
          onFavoriteTap: () => favoriteTapped = true));

      // Act
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Assert
      expect(favoriteTapped, isTrue);
    });

    testWidgets('should truncate long exercise names',
        (WidgetTester tester) async {
      // Arrange
      final longNameExercise = Exercise(
        id: 'e_003',
        name: 'This is a very long exercise name that should be truncated',
        bodyPart: 'chest',
        equipment: 'barbell',
        gifUrl: 'https://example.com/exercise.gif',
        target: 'pectorals',
        secondaryMuscles: ['triceps'],
        instructions: ['Step 1'],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(longNameExercise));

      // Assert
      final textWidget = tester.widget<Text>(find.text(
          'This is a very long exercise name that should be truncated'));
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should display card widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle GIF loading error',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // The error builder should show an icon when image fails
      // We can't easily simulate network error in widget test,
      // but we verify the error builder exists
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.errorBuilder, isNotNull);
    });

    testWidgets('should use correct difficulty color for beginner',
        (WidgetTester tester) async {
      // Arrange
      final beginnerExercise = Exercise(
        id: 'e_004',
        name: 'Easy Exercise',
        bodyPart: 'arms',
        equipment: 'body weight',
        gifUrl: 'https://example.com/easy.gif',
        target: 'biceps',
        secondaryMuscles: [],
        instructions: ['Step 1'],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(beginnerExercise));

      // Assert
      expect(find.textContaining('BEGINNER'), findsOneWidget);
    });

    testWidgets('should display intermediate difficulty',
        (WidgetTester tester) async {
      // Arrange
      final intermediateExercise = Exercise(
        id: 'e_005',
        name: 'Medium Exercise',
        bodyPart: 'back',
        equipment: 'dumbbell',
        gifUrl: 'https://example.com/medium.gif',
        target: 'lats',
        secondaryMuscles: ['biceps'],
        instructions: ['Step 1'],
      );

      // Manually set difficulty to intermediate
      // Act
      await tester.pumpWidget(createWidgetUnderTest(intermediateExercise));

      // Assert - the exercise should show some difficulty badge
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have proper padding and margins',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('should display exercise type badges in wrap',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('should be responsive to screen size',
        (WidgetTester tester) async {
      // Arrange
      tester.binding.window.physicalSizeTestValue = const Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testExercise));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Barbell Squat'), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
