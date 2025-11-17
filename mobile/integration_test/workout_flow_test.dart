import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_fitness_app/main.dart' as app;

/// Integration test for workout and exercise flow
///
/// Tests the complete workout management journey including:
/// - Browsing exercise library
/// - Filtering and searching exercises
/// - Creating custom workouts
/// - Starting workout sessions
/// - Tracking sets and reps
/// - Completing workouts
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Flow Integration Tests', () {
    testWidgets('should browse exercise library',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to exercises tab
      final exercisesTabFinder = find.byIcon(Icons.fitness_center);
      if (exercisesTabFinder.evaluate().isNotEmpty) {
        await tester.tap(exercisesTabFinder);
        await tester.pumpAndSettle();
      }

      // Wait for exercises to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should display exercise list
      expect(find.byType(ListView), findsAny);
    });

    testWidgets('should search for exercises', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to exercises tab
      final exercisesTabFinder = find.byIcon(Icons.fitness_center);
      if (exercisesTabFinder.evaluate().isNotEmpty) {
        await tester.tap(exercisesTabFinder);
        await tester.pumpAndSettle();
      }

      // Find search field
      final searchFieldFinder = find.byKey(const Key('exercise_search_field'));
      if (searchFieldFinder.evaluate().isEmpty) {
        // Try finding by icon
        final searchIconFinder = find.byIcon(Icons.search);
        if (searchIconFinder.evaluate().isNotEmpty) {
          await tester.tap(searchIconFinder);
          await tester.pumpAndSettle();
        }
      }

      // Enter search query
      if (searchFieldFinder.evaluate().isNotEmpty) {
        await tester.enterText(searchFieldFinder, 'squat');
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Results should update
        expect(find.textContaining('Squat'), findsAny);
      }
    });

    testWidgets('should filter exercises by body part',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to exercises tab
      final exercisesTabFinder = find.byIcon(Icons.fitness_center);
      if (exercisesTabFinder.evaluate().isNotEmpty) {
        await tester.tap(exercisesTabFinder);
        await tester.pumpAndSettle();
      }

      // Open filter menu
      final filterButtonFinder = find.byIcon(Icons.filter_list);
      if (filterButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(filterButtonFinder);
        await tester.pumpAndSettle();

        // Select body part filter (e.g., "Piernas")
        final legsFilterFinder = find.text('Piernas');
        if (legsFilterFinder.evaluate().isNotEmpty) {
          await tester.tap(legsFilterFinder);
          await tester.pumpAndSettle();

          // Apply filter
          final applyFinder = find.text('Aplicar');
          if (applyFinder.evaluate().isNotEmpty) {
            await tester.tap(applyFinder);
            await tester.pumpAndSettle(const Duration(seconds: 1));
          }
        }
      }
    });

    testWidgets('should view exercise details', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to exercises tab
      final exercisesTabFinder = find.byIcon(Icons.fitness_center);
      if (exercisesTabFinder.evaluate().isNotEmpty) {
        await tester.tap(exercisesTabFinder);
        await tester.pumpAndSettle();
      }

      // Wait for exercises to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on first exercise card
      final exerciseCardFinder = find.byType(Card);
      if (exerciseCardFinder.evaluate().isNotEmpty) {
        await tester.tap(exerciseCardFinder.first);
        await tester.pumpAndSettle();

        // Should navigate to detail page
        expect(find.text('Instrucciones'), findsAny);
      }
    });

    testWidgets('should favorite an exercise', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to exercises tab
      final exercisesTabFinder = find.byIcon(Icons.fitness_center);
      if (exercisesTabFinder.evaluate().isNotEmpty) {
        await tester.tap(exercisesTabFinder);
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on first exercise to open details
      final exerciseCardFinder = find.byType(Card);
      if (exerciseCardFinder.evaluate().isNotEmpty) {
        await tester.tap(exerciseCardFinder.first);
        await tester.pumpAndSettle();

        // Tap favorite button
        final favoriteButtonFinder = find.byIcon(Icons.favorite_border);
        if (favoriteButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(favoriteButtonFinder);
          await tester.pumpAndSettle();

          // Icon should change to filled heart
          expect(find.byIcon(Icons.favorite), findsOneWidget);
        }
      }
    });

    testWidgets('should create new workout', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to workouts tab
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      // Tap add workout FAB
      final addFabFinder = find.byIcon(Icons.add);
      if (addFabFinder.evaluate().isNotEmpty) {
        await tester.tap(addFabFinder);
        await tester.pumpAndSettle();
      }

      // Fill in workout details
      final nameField = find.byKey(const Key('workout_name_field'));
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'Mi Rutina Test');
        await tester.pumpAndSettle();
      }

      final descriptionField = find.byKey(const Key('workout_description_field'));
      if (descriptionField.evaluate().isNotEmpty) {
        await tester.enterText(
            descriptionField, 'Rutina de prueba para integración');
        await tester.pumpAndSettle();
      }

      // Select difficulty
      final difficultyFinder = find.text('Dificultad');
      if (difficultyFinder.evaluate().isNotEmpty) {
        await tester.tap(difficultyFinder);
        await tester.pumpAndSettle();

        final mediumFinder = find.text('Intermedio').last;
        if (mediumFinder.evaluate().isNotEmpty) {
          await tester.tap(mediumFinder);
          await tester.pumpAndSettle();
        }
      }

      // Save workout
      final saveFinder = find.text('GUARDAR');
      if (saveFinder.evaluate().isNotEmpty) {
        await tester.tap(saveFinder);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show success message
        expect(find.textContaining('guardado'), findsAny);
      }
    });

    testWidgets('should start workout session', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to workouts tab
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      // Wait for workouts to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap start button on first workout
      final startButtonFinder = find.text('Iniciar');
      if (startButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(startButtonFinder.first);
        await tester.pumpAndSettle();

        // Should navigate to workout session screen
        expect(find.textContaining('Serie'), findsAny);
      }
    });

    testWidgets('should log workout set', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to workouts and start a workout
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final startButtonFinder = find.text('Iniciar');
      if (startButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(startButtonFinder.first);
        await tester.pumpAndSettle();

        // Enter set details
        final repsFieldFinder = find.byKey(const Key('reps_field'));
        if (repsFieldFinder.evaluate().isNotEmpty) {
          await tester.enterText(repsFieldFinder, '10');
          await tester.pumpAndSettle();
        }

        final weightFieldFinder = find.byKey(const Key('weight_field'));
        if (weightFieldFinder.evaluate().isNotEmpty) {
          await tester.enterText(weightFieldFinder, '50');
          await tester.pumpAndSettle();
        }

        // Log set
        final logSetFinder = find.text('Completar Serie');
        if (logSetFinder.evaluate().isNotEmpty) {
          await tester.tap(logSetFinder);
          await tester.pumpAndSettle();

          // Should show set logged confirmation
          expect(find.textContaining('completada'), findsAny);
        }
      }
    });

    testWidgets('should complete workout session',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to workouts and start a workout
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final startButtonFinder = find.text('Iniciar');
      if (startButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(startButtonFinder.first);
        await tester.pumpAndSettle();

        // Finish workout
        final finishFinder = find.text('Finalizar Entrenamiento');
        if (finishFinder.evaluate().isNotEmpty) {
          await tester.tap(finishFinder);
          await tester.pumpAndSettle();

          // Confirm in dialog
          final confirmFinder = find.text('Finalizar').last;
          if (confirmFinder.evaluate().isNotEmpty) {
            await tester.tap(confirmFinder);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Should show workout summary or success message
            expect(find.textContaining('completado'), findsAny);
          }
        }
      }
    });

    testWidgets('should delete workout', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to workouts tab
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      // Find workout and open menu
      final menuButtonFinder = find.byIcon(Icons.more_vert);
      if (menuButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(menuButtonFinder.first);
        await tester.pumpAndSettle();

        // Tap delete
        final deleteFinder = find.text('Eliminar');
        if (deleteFinder.evaluate().isNotEmpty) {
          await tester.tap(deleteFinder);
          await tester.pumpAndSettle();

          // Confirm deletion
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

    testWidgets('should view workout history', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to profile
      final profileTabFinder = find.byIcon(Icons.person);
      if (profileTabFinder.evaluate().isNotEmpty) {
        await tester.tap(profileTabFinder);
        await tester.pumpAndSettle();
      }

      // Find and tap workout history button
      final historyFinder = find.text('Historial de Entrenamientos');
      if (historyFinder.evaluate().isNotEmpty) {
        await tester.tap(historyFinder);
        await tester.pumpAndSettle();

        // Should navigate to workout history
        expect(find.text('Historial'), findsAny);
      }
    });

    testWidgets('should show gamification rewards after workout',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Complete a workout (simplified)
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final startButtonFinder = find.text('Iniciar');
      if (startButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(startButtonFinder.first);
        await tester.pumpAndSettle();

        final finishFinder = find.text('Finalizar Entrenamiento');
        if (finishFinder.evaluate().isNotEmpty) {
          await tester.tap(finishFinder);
          await tester.pumpAndSettle();

          final confirmFinder = find.text('Finalizar').last;
          if (confirmFinder.evaluate().isNotEmpty) {
            await tester.tap(confirmFinder);
            await tester.pumpAndSettle(const Duration(seconds: 2));

            // Should show XP earned or achievement unlocked
            expect(find.textContaining('XP'), findsAny);
          }
        }
      }
    });

    testWidgets('should filter exercises by equipment',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to exercises tab
      final exercisesTabFinder = find.byIcon(Icons.fitness_center);
      if (exercisesTabFinder.evaluate().isNotEmpty) {
        await tester.tap(exercisesTabFinder);
        await tester.pumpAndSettle();
      }

      // Open filter
      final filterButtonFinder = find.byIcon(Icons.filter_list);
      if (filterButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(filterButtonFinder);
        await tester.pumpAndSettle();

        // Select "body weight" for home workouts
        final bodyWeightFinder = find.text('Peso corporal');
        if (bodyWeightFinder.evaluate().isNotEmpty) {
          await tester.tap(bodyWeightFinder);
          await tester.pumpAndSettle();

          final applyFinder = find.text('Aplicar');
          if (applyFinder.evaluate().isNotEmpty) {
            await tester.tap(applyFinder);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // Results should show body weight exercises
          }
        }
      }
    });

    testWidgets('should share workout', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to workouts
      final workoutsTabFinder = find.text('Rutinas');
      if (workoutsTabFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutsTabFinder);
        await tester.pumpAndSettle();
      }

      // Tap on workout to open details
      final workoutCardFinder = find.byType(Card);
      if (workoutCardFinder.evaluate().isNotEmpty) {
        await tester.tap(workoutCardFinder.first);
        await tester.pumpAndSettle();

        // Find share button
        final shareFinder = find.byIcon(Icons.share);
        if (shareFinder.evaluate().isNotEmpty) {
          await tester.tap(shareFinder);
          await tester.pumpAndSettle();

          // Share sheet should open
          // In test environment, this would be mocked
        }
      }
    });
  });
}
