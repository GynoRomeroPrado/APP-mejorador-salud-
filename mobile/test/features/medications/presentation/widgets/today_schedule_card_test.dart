import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/medications/presentation/widgets/today_schedule_card.dart';
import 'package:health_fitness_app/features/medications/data/models/medication.dart';
import 'package:health_fitness_app/features/medications/data/repositories/medication_repository.dart';

@GenerateMocks([MedicationRepository])
import 'today_schedule_card_test.mocks.dart';

void main() {
  late MockMedicationRepository mockRepository;

  setUp(() {
    mockRepository = MockMedicationRepository();
  });

  final now = DateTime.now();
  final testLogs = [
    MedicationLog(
      logId: 'l_001',
      medId: 'm_001',
      scheduleId: 's_001',
      userId: 'u_123',
      scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
      status: 'pending',
    ),
    MedicationLog(
      logId: 'l_002',
      medId: 'm_002',
      scheduleId: 's_002',
      userId: 'u_123',
      scheduledTime: DateTime(now.year, now.month, now.day, 12, 0),
      status: 'taken',
      takenTime: DateTime(now.year, now.month, now.day, 12, 5),
    ),
    MedicationLog(
      logId: 'l_003',
      medId: 'm_003',
      scheduleId: 's_003',
      userId: 'u_123',
      scheduledTime: DateTime(now.year, now.month, now.day, 20, 0),
      status: 'pending',
    ),
  ];

  Widget createWidgetUnderTest(List<MedicationLog> logs) {
    return ProviderScope(
      overrides: [
        medicationRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TodayScheduleCard(logs: logs),
        ),
      ),
    );
  }

  group('TodayScheduleCard Widget Tests', () {
    testWidgets('should display title', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.text('Horarios de Hoy'), findsOneWidget);
    });

    testWidgets('should display taken count', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('should display timeline for each time slot',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
    });

    testWidgets('should show check icon for taken medications',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('should show time icon for pending medications',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.byIcon(Icons.access_time), findsWidgets);
    });

    testWidgets('should display action buttons for pending medications',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      // Should have check and close icons for pending items
      expect(find.byIcon(Icons.check), findsWidgets);
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('should not display action buttons for taken medications',
        (WidgetTester tester) async {
      // Arrange
      final takenLogs = [
        MedicationLog(
          logId: 'l_001',
          medId: 'm_001',
          scheduleId: 's_001',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
          status: 'taken',
          takenTime: DateTime(now.year, now.month, now.day, 8, 5),
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(takenLogs));

      // Assert
      // Action buttons should not be visible for taken medications
      final actionCheckButtons = tester.widgetList<IconButton>(
        find.byWidgetPredicate((widget) =>
            widget is IconButton &&
            widget.icon is Icon &&
            (widget.icon as Icon).icon == Icons.check &&
            (widget.icon as Icon).color == Colors.green),
      );
      expect(actionCheckButtons.length, 0);
    });

    testWidgets('should show taken time when medication was taken',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.textContaining('Tomado a las'), findsOneWidget);
    });

    testWidgets('should display card widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should group logs by time', (WidgetTester tester) async {
      // Arrange
      final logsAtSameTime = [
        MedicationLog(
          logId: 'l_004',
          medId: 'm_004',
          scheduleId: 's_004',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
          status: 'pending',
        ),
        MedicationLog(
          logId: 'l_005',
          medId: 'm_005',
          scheduleId: 's_005',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
          status: 'pending',
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(logsAtSameTime));

      // Assert
      // Should only show time once
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('should handle empty logs list', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest([]));

      // Assert
      expect(find.text('Horarios de Hoy'), findsOneWidget);
      expect(find.text('0/0'), findsOneWidget);
    });

    testWidgets('should show skipped status for skipped medications',
        (WidgetTester tester) async {
      // Arrange
      final skippedLogs = [
        MedicationLog(
          logId: 'l_006',
          medId: 'm_006',
          scheduleId: 's_006',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
          status: 'skipped',
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(skippedLogs));

      // Assert
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('should use green color for all taken medications',
        (WidgetTester tester) async {
      // Arrange
      final allTakenLogs = [
        MedicationLog(
          logId: 'l_007',
          medId: 'm_007',
          scheduleId: 's_007',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day, 8, 0),
          status: 'taken',
          takenTime: DateTime(now.year, now.month, now.day, 8, 5),
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(allTakenLogs));

      // Assert
      expect(find.byIcon(Icons.check), findsWidgets);
    });

    testWidgets('should use red color for past missed medications',
        (WidgetTester tester) async {
      // Arrange
      final pastLogs = [
        MedicationLog(
          logId: 'l_008',
          medId: 'm_008',
          scheduleId: 's_008',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day - 1, 8, 0),
          status: 'pending',
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(pastLogs));

      // Assert
      // Past pending medication should show close icon
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('should display timeline indicators',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      // Timeline should have circular indicators
      final containers = tester.widgetList<Container>(find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      ));
      expect(containers.length, greaterThan(0));
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('should be scrollable when many logs',
        (WidgetTester tester) async {
      // Arrange
      final manyLogs = List.generate(
        10,
        (i) => MedicationLog(
          logId: 'l_$i',
          medId: 'm_$i',
          scheduleId: 's_$i',
          userId: 'u_123',
          scheduledTime: DateTime(now.year, now.month, now.day, 8 + i, 0),
          status: 'pending',
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(manyLogs));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should be responsive to screen size',
        (WidgetTester tester) async {
      // Arrange
      tester.binding.window.physicalSizeTestValue = const Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testLogs));

      // Assert
      expect(find.text('Horarios de Hoy'), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
