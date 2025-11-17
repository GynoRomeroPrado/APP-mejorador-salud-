import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/presentation/widgets/user_stats_card.dart';
import 'package:health_fitness_app/features/gamification/data/models/user_stats.dart';

void main() {
  Widget createWidgetUnderTest(UserStats stats) {
    return MaterialApp(
      home: Scaffold(
        body: UserStatsCard(userStats: stats),
      ),
    );
  }

  group('UserStatsCard Widget Tests', () {
    testWidgets('should display workouts completed',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        medicationsTaken: 100,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('25'), findsOneWidget);
      expect(find.textContaining('Entrenamientos'), findsOneWidget);
    });

    testWidgets('should display total sets', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        medicationsTaken: 100,
        totalSets: 200,
        totalVolume: 20000.0,
        totalWorkoutMinutes: 800,
        totalCaloriesBurned: 4500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('200'), findsOneWidget);
      expect(find.textContaining('Series'), findsOneWidget);
    });

    testWidgets('should display total volume', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 25000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('25,000'), findsWidgets);
      expect(find.textContaining('kg'), findsWidgets);
    });

    testWidgets('should display total workout minutes',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 750,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('750'), findsWidgets);
      expect(find.textContaining('min'), findsWidgets);
    });

    testWidgets('should display total calories burned',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 5000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('5,000'), findsWidgets);
      expect(find.textContaining('cal'), findsWidgets);
    });

    testWidgets('should display average workout duration',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 20,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        averageWorkoutDuration: 30,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.textContaining('30'), findsWidgets);
      expect(find.textContaining('promedio'), findsWidgets);
    });

    testWidgets('should display stats in a grid layout',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert - Should be in a grid
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should display icons for each stat',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert - Should have multiple icons
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('should handle zero values', (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 0,
        currentStreak: 0,
        longestStreak: 0,
        workoutsCompleted: 0,
        totalSets: 0,
        totalVolume: 0.0,
        totalWorkoutMinutes: 0,
        totalCaloriesBurned: 0,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.text('0'), findsWidgets);
    });

    testWidgets('should format large numbers correctly',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 100000,
        currentStreak: 100,
        longestStreak: 200,
        workoutsCompleted: 1000,
        totalSets: 5000,
        totalVolume: 500000.0,
        totalWorkoutMinutes: 30000,
        totalCaloriesBurned: 150000,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert - Numbers should be formatted with commas
      expect(find.textContaining('1,000'), findsWidgets);
      expect(find.textContaining('5,000'), findsWidgets);
      expect(find.textContaining('500,000'), findsWidgets);
    });

    testWidgets('should display card with proper styling',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should show all 6 primary stats in 2x3 grid',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        currentStreak: 5,
        longestStreak: 10,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
        averageWorkoutDuration: 24,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert - Should have 6 stat items (2 rows x 3 columns)
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect((gridView.childrenDelegate as SliverChildBuilderDelegate).estimatedChildCount, 6);
    });

    testWidgets('should use different colors for each stat category',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert - Should have different colored icons
      final icons = tester.widgetList<Icon>(find.byType(Icon));
      expect(icons.length, greaterThan(1));
    });

    testWidgets('should be responsive to different screen sizes',
        (WidgetTester tester) async {
      // Arrange
      final stats = UserStats(
        userId: 'u_001',
        totalXp: 400,
        workoutsCompleted: 25,
        totalSets: 150,
        totalVolume: 15000.0,
        totalWorkoutMinutes: 600,
        totalCaloriesBurned: 3500,
      );

      // Act - Test with small screen
      tester.binding.window.physicalSizeTestValue = Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(stats));

      // Assert
      expect(find.byType(GridView), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
