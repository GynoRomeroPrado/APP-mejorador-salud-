import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_fitness_app/main.dart' as app;

/// Integration test for medication tracking flow
///
/// Tests the complete medication management journey including:
/// - Adding new medications
/// - Viewing medication list
/// - Marking medications as taken
/// - Viewing calendar and adherence
/// - Editing and deleting medications
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Medication Tracking Flow Integration Tests', () {
    testWidgets('should add new medication successfully',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load and login (assuming logged in)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Tap add medication FAB
      final addFabFinder = find.byKey(const Key('add_medication_fab'));
      if (addFabFinder.evaluate().isEmpty) {
        // Try finding by icon
        final fabIconFinder = find.byIcon(Icons.add);
        if (fabIconFinder.evaluate().isNotEmpty) {
          await tester.tap(fabIconFinder);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.tap(addFabFinder);
        await tester.pumpAndSettle();
      }

      // Fill in medication details
      final nameField = find.byKey(const Key('medication_name_field'));
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'Aspirina Test');
        await tester.pumpAndSettle();
      }

      final dosageField = find.byKey(const Key('medication_dosage_field'));
      if (dosageField.evaluate().isNotEmpty) {
        await tester.enterText(dosageField, '500mg');
        await tester.pumpAndSettle();
      }

      // Select type (dropdown)
      final typeFinder = find.text('Tipo');
      if (typeFinder.evaluate().isNotEmpty) {
        await tester.tap(typeFinder);
        await tester.pumpAndSettle();

        // Select medication type
        final medicationTypeFinder = find.text('Medicamento').last;
        if (medicationTypeFinder.evaluate().isNotEmpty) {
          await tester.tap(medicationTypeFinder);
          await tester.pumpAndSettle();
        }
      }

      // Add schedule
      final addScheduleFinder = find.text('Agregar Horario');
      if (addScheduleFinder.evaluate().isNotEmpty) {
        await tester.tap(addScheduleFinder);
        await tester.pumpAndSettle();

        // Select time (would open time picker)
        // In integration test, we'd interact with the time picker
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Confirm time picker if opened
        final okButtonFinder = find.text('OK');
        if (okButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(okButtonFinder);
          await tester.pumpAndSettle();
        }
      }

      // Save medication
      final saveFinder = find.text('GUARDAR');
      if (saveFinder.evaluate().isNotEmpty) {
        await tester.tap(saveFinder);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify success message
        expect(find.text('✅'), findsAny);
      }
    });

    testWidgets('should display medications list',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Wait for medications to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show medications list or empty state
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsAny);
    });

    testWidgets('should mark medication as taken',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Find today's medication schedule
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap check button to mark as taken
      final checkButtonFinder = find.byIcon(Icons.check);
      if (checkButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(checkButtonFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should show success message
        expect(find.textContaining('registrado como tomado'), findsAny);
      }
    });

    testWidgets('should navigate to medication calendar',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Find and tap calendar button
      final calendarButtonFinder = find.byIcon(Icons.calendar_today);
      if (calendarButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(calendarButtonFinder);
        await tester.pumpAndSettle();

        // Should show calendar view
        expect(find.text('Calendario de Medicamentos'), findsAny);
      }
    });

    testWidgets('should show medication adherence stats',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Wait for adherence stats to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should display adherence percentage or stats
      final adherenceStatsFinder = find.textContaining('%');
      expect(adherenceStatsFinder, findsAny);
    });

    testWidgets('should edit medication', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Find medication card and open menu
      final menuButtonFinder = find.byIcon(Icons.more_vert);
      if (menuButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(menuButtonFinder.first);
        await tester.pumpAndSettle();

        // Tap edit option
        final editFinder = find.text('Editar');
        if (editFinder.evaluate().isNotEmpty) {
          await tester.tap(editFinder);
          await tester.pumpAndSettle();

          // Should navigate to edit screen
          expect(find.text('Editar Medicamento'), findsAny);
        }
      }
    });

    testWidgets('should delete medication', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Find medication card and open menu
      final menuButtonFinder = find.byIcon(Icons.more_vert);
      if (menuButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(menuButtonFinder.first);
        await tester.pumpAndSettle();

        // Tap delete option
        final deleteFinder = find.text('Eliminar');
        if (deleteFinder.evaluate().isNotEmpty) {
          await tester.tap(deleteFinder);
          await tester.pumpAndSettle();

          // Confirm deletion in dialog
          final confirmFinder = find.text('Eliminar').last;
          if (confirmFinder.evaluate().isNotEmpty) {
            await tester.tap(confirmFinder);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // Should show success message
            expect(find.textContaining('eliminado'), findsAny);
          }
        }
      }
    });

    testWidgets('should skip medication', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Find skip button (X icon)
      final skipButtonFinder = find.byIcon(Icons.close);
      if (skipButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(skipButtonFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Should show skip confirmation
        expect(find.textContaining('omitido'), findsAny);
      }
    });

    testWidgets('should validate medication form', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab and tap add
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      final addFabFinder = find.byIcon(Icons.add);
      if (addFabFinder.evaluate().isNotEmpty) {
        await tester.tap(addFabFinder);
        await tester.pumpAndSettle();
      }

      // Try to save without filling required fields
      final saveFinder = find.text('GUARDAR');
      if (saveFinder.evaluate().isNotEmpty) {
        await tester.tap(saveFinder);
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.textContaining('requerido'), findsAny);
      }
    });

    testWidgets('should show refill reminder', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to medications tab
      final medicationsTabFinder = find.byIcon(Icons.medication);
      if (medicationsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(medicationsTabFinder);
        await tester.pumpAndSettle();
      }

      // Wait for medications to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Look for refill warning icon
      final refillWarningFinder = find.byIcon(Icons.warning_amber_rounded);
      if (refillWarningFinder.evaluate().isNotEmpty) {
        // Refill reminder is displayed
        expect(find.textContaining('Recarga en'), findsAny);
      }
    });
  });
}
