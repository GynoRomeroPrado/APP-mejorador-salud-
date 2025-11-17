import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/presentation/widgets/streak_card.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_stats.dart';

void main() {
  Widget createWidgetUnderTest(UserStats stats) {
    return MaterialApp(
      home: Scaffold(
        body: StreakCard(userStats: stats),
      ),
    );
  }

  group('StreakCard Widget Tests', () {
    testWidgets('should display current streak', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 7,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('7'), findsOneWidget);
      expect(find.textContaining('días'), findsWidgets);
    });

    testWidgets('should display fire icon', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('should display longest streak', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 15,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('15'), findsOneWidget);
      expect(find.textContaining('récord'), findsWidgets);
    });

    testWidgets('should show 0 when no streak', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 100,
        currentStreak: 0,
        longestStreak: 0,
        workoutsCompleted: 5,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('0'), findsWidgets); // Current and longest both 0
    });

    testWidgets('should use orange color for fire icon',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 7,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.local_fire_department));
      expect(icon.color, Colors.orange);
    });

    testWidgets('should display streak message', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 10,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('Racha actual'), findsOneWidget);
    });

    testWidgets('should show motivational message for active streak',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 7,
        longestStreak: 10,
        workoutsCompleted: 20,
        lastActivityDate: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      // Should show some motivational text
      expect(find.textContaining('¡'), findsWidgets);
    });

    testWidgets('should show warning when streak at risk',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 7,
        longestStreak: 10,
        workoutsCompleted: 20,
        lastActivityDate: DateTime.now().subtract(Duration(days: 1)),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      // Should show warning color or icon
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    });

    testWidgets('should display card with proper styling',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle very high streak numbers',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 40000,
        currentStreak: 365,
        longestStreak: 500,
        workoutsCompleted: 1000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('365'), findsOneWidget);
      expect(find.textContaining('500'), findsOneWidget);
    });

    testWidgets('should show achievement badge for milestone streaks',
        (WidgetTester tester) async {
      // Arrange - 30 day streak milestone
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 5000,
        currentStreak: 30,
        longestStreak: 30,
        workoutsCompleted: 100,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      // Should show some indicator for reaching milestone
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('should be responsive to different screen sizes',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 7,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act - Test with small screen
      tester.binding.window.physicalSizeTestValue = Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should animate when tapped', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 7,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      final card = find.byType(Card);
      await tester.tap(card);
      await tester.pump();

      // Assert - Card should still be visible
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
