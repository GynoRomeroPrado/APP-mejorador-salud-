import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/presentation/widgets/level_progress_card.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_stats.dart';

void main() {
  Widget createWidgetUnderTest(UserStats stats) {
    return MaterialApp(
      home: Scaffold(
        body: LevelProgressCard(userStats: stats),
      ),
    );
  }

  group('LevelProgressCard Widget Tests', () {
    testWidgets('should display user level', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400, // Level 3
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('Nivel 3'), findsOneWidget);
    });

    testWidgets('should display user title based on level',
        (WidgetTester tester) async {
      // Arrange - Level 5
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 2500,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('Atleta Dedicado'), findsOneWidget);
    });

    testWidgets('should display current XP and XP for next level',
        (WidgetTester tester) async {
      // Arrange - Level 2 (100 XP)
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 100,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('100 XP'), findsOneWidget);
      expect(find.text('400 XP'), findsOneWidget); // Next level at 400
    });

    testWidgets('should display progress bar', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 200, // 50% to next level
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      final progressIndicator =
          tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressIndicator.value, closeTo(0.5, 0.01)); // 50% progress
    });

    testWidgets('should display progress percentage',
        (WidgetTester tester) async {
      // Arrange - 75% progress
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 300,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('should use correct color based on level',
        (WidgetTester tester) async {
      // Arrange - Low level
      final lowLevelStats = UserStats(
        userId: 'u_001',
        totalXp: 100,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(lowLevelStats));

      // Assert - Should use green for low levels
      final progressIndicator = tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(progressIndicator.color, Colors.green);
    });

    testWidgets('should display level up icon when close to next level',
        (WidgetTester tester) async {
      // Arrange - 95% progress
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 380, // Very close to 400
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byIcon(Icons.celebration), findsOneWidget);
      expect(find.text('¡Casi subes de nivel!'), findsOneWidget);
    });

    testWidgets('should display beginner title for level 1',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 0,
        currentStreak: 0,
        longestStreak: 0,
        workoutsCompleted: 0,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('Nivel 1'), findsOneWidget);
      expect(find.text('Principiante'), findsOneWidget);
    });

    testWidgets('should display champion title for high level',
        (WidgetTester tester) async {
      // Arrange - Level 20+
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 40000,
        currentStreak: 50,
        longestStreak: 100,
        workoutsCompleted: 500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('Nivel'), findsOneWidget);
      expect(find.text('Campeón'), findsOneWidget);
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
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, greaterThan(0));
    });

    testWidgets('should handle very high XP values',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 1000000, // Very high XP
        currentStreak: 500,
        longestStreak: 1000,
        workoutsCompleted: 5000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('Nivel'), findsOneWidget);
      expect(find.textContaining('XP'), findsWidgets);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should display XP gained animation when tapped',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 100,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      final card = find.byType(Card);
      await tester.tap(card);
      await tester.pump();

      // Assert - Should show some visual feedback
      // This would depend on the actual implementation
    });

    testWidgets('should be responsive to different screen sizes',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
      );

      // Act - Test with small screen
      tester.binding.window.physicalSizeTestValue = Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert - Should still display all elements
      expect(find.textContaining('Nivel'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
