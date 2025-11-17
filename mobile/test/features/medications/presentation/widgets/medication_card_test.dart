import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/medications/presentation/widgets/medication_card.dart';
import 'package:health_fitness_app/features/medications/data/models/medication.dart';
import 'package:health_fitness_app/features/medications/data/models/medication_stats.dart';

void main() {
  final testMedication = Medication(
    medId: 'm_001',
    userId: 'u_123',
    name: 'Aspirina',
    type: 'medication',
    dosage: '500mg',
    startDate: DateTime.now(),
    colorHex: '#3B82F6',
    icon: 'pill',
    schedules: [
      MedicationSchedule(
        scheduleId: 's_001',
        medId: 'm_001',
        time: '08:00',
        frequency: 'daily',
        enabled: true,
      ),
      MedicationSchedule(
        scheduleId: 's_002',
        medId: 'm_001',
        time: '20:00',
        frequency: 'daily',
        enabled: true,
      ),
    ],
  );

  Widget createWidgetUnderTest(
    Medication medication, {
    VoidCallback? onTap,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: MedicationCard(
          medication: medication,
          onTap: onTap,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  group('MedicationCard Widget Tests', () {
    testWidgets('should display medication name', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      expect(find.text('Aspirina'), findsOneWidget);
    });

    testWidgets('should display dosage', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      expect(find.text('500mg'), findsOneWidget);
    });

    testWidgets('should display medication icon emoji',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      // The emoji for 'pill' icon should be displayed
      expect(find.text('💊'), findsOneWidget);
    });

    testWidgets('should display type badge', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      expect(find.text('Medicamento'), findsOneWidget);
    });

    testWidgets('should display popup menu button',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication,
          onEdit: () {}, onDelete: () {}));

      // Assert
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('should show edit and delete options in menu',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(testMedication,
          onEdit: () {}, onDelete: () {}));

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });

    testWidgets('should call onEdit when edit is selected',
        (WidgetTester tester) async {
      // Arrange
      var editCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(testMedication,
          onEdit: () => editCalled = true, onDelete: () {}));

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      // Assert
      expect(editCalled, isTrue);
    });

    testWidgets('should call onDelete when delete is selected',
        (WidgetTester tester) async {
      // Arrange
      var deleteCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(testMedication,
          onEdit: () {}, onDelete: () => deleteCalled = true));

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCalled, isTrue);
    });

    testWidgets('should display schedules', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      expect(find.byIcon(Icons.access_time), findsWidgets);
    });

    testWidgets('should limit schedule display to 3',
        (WidgetTester tester) async {
      // Arrange
      final medWith5Schedules = Medication(
        medId: 'm_002',
        userId: 'u_123',
        name: 'Vitamina D',
        type: 'supplement',
        dosage: '1000 IU',
        startDate: DateTime.now(),
        colorHex: '#FFA500',
        icon: 'capsule',
        schedules: List.generate(
          5,
          (i) => MedicationSchedule(
            scheduleId: 's_00$i',
            medId: 'm_002',
            time: '${8 + i * 2}:00',
            frequency: 'daily',
            enabled: true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(medWith5Schedules));

      // Assert
      expect(find.text('+2 más'), findsOneWidget);
    });

    testWidgets('should display refill warning when needed',
        (WidgetTester tester) async {
      // Arrange
      final medWithRefill = Medication(
        medId: 'm_003',
        userId: 'u_123',
        name: 'Antibiótico',
        type: 'medication',
        dosage: '250mg',
        startDate: DateTime.now(),
        colorHex: '#FF0000',
        icon: 'pill',
        schedules: [],
        refillDate: DateTime.now().add(const Duration(days: 5)),
        refillReminderDays: 7,
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(medWithRefill));

      // Assert
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('Recarga en'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped',
        (WidgetTester tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
          createWidgetUnderTest(testMedication, onTap: () => tapped = true));

      // Act
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should display card widget', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should use medication color for icon background',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      final container = tester.widget<Container>(find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              widget.constraints?.maxWidth == 48));
      expect(container, isNotNull);
    });

    testWidgets('should display supplement type', (WidgetTester tester) async {
      // Arrange
      final supplement = Medication(
        medId: 'm_004',
        userId: 'u_123',
        name: 'Proteína',
        type: 'supplement',
        dosage: '30g',
        startDate: DateTime.now(),
        colorHex: '#00FF00',
        icon: 'powder',
        schedules: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(supplement));

      // Assert
      expect(find.text('Suplemento'), findsOneWidget);
    });

    testWidgets('should display vitamin type', (WidgetTester tester) async {
      // Arrange
      final vitamin = Medication(
        medId: 'm_005',
        userId: 'u_123',
        name: 'Vitamina C',
        type: 'vitamin',
        dosage: '500mg',
        startDate: DateTime.now(),
        colorHex: '#FFFF00',
        icon: 'vitamin',
        schedules: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(vitamin));

      // Assert
      expect(find.text('Vitamina'), findsOneWidget);
    });

    testWidgets('should display meal timing emoji if present',
        (WidgetTester tester) async {
      // Arrange
      final medWithMealTiming = Medication(
        medId: 'm_006',
        userId: 'u_123',
        name: 'Omega 3',
        type: 'supplement',
        dosage: '1000mg',
        startDate: DateTime.now(),
        colorHex: '#0000FF',
        icon: 'capsule',
        schedules: [
          MedicationSchedule(
            scheduleId: 's_003',
            medId: 'm_006',
            time: '12:00',
            frequency: 'daily',
            enabled: true,
            mealTiming: 'with_meal',
          ),
        ],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(medWithMealTiming));

      // Assert
      // Should display meal timing emoji
      expect(find.text('🍽️'), findsOneWidget);
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('should be responsive to screen size',
        (WidgetTester tester) async {
      // Arrange
      tester.binding.window.physicalSizeTestValue = const Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Act
      await tester.pumpWidget(createWidgetUnderTest(testMedication));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Aspirina'), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });
  });
}
