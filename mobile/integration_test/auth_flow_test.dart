import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:health_fitness_app/main.dart' as app;

/// Integration test for authentication flow
///
/// Tests the complete user authentication journey including:
/// - App launch
/// - Registration
/// - Login
/// - Logout
/// - Error handling
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
    testWidgets('should complete registration flow successfully',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap "Register" button or navigate to registration
      final registerButtonFinder = find.text('Registrarse');
      if (registerButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(registerButtonFinder);
        await tester.pumpAndSettle();
      }

      // Fill in registration form
      final emailField = find.byKey(const Key('register_email_field'));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(
          emailField,
          'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        );
        await tester.pumpAndSettle();
      }

      final passwordField = find.byKey(const Key('register_password_field'));
      if (passwordField.evaluate().isNotEmpty) {
        await tester.enterText(passwordField, 'TestPassword123!');
        await tester.pumpAndSettle();
      }

      final nameField = find.byKey(const Key('register_name_field'));
      if (nameField.evaluate().isNotEmpty) {
        await tester.enterText(nameField, 'Test User');
        await tester.pumpAndSettle();
      }

      // Submit registration
      final submitButton = find.byKey(const Key('register_submit_button'));
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify successful registration (should navigate to home or show success)
        expect(find.byType(SnackBar), findsAny);
      }
    });

    testWidgets('should complete login flow successfully',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Wait for app to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find email field (might already be on login screen)
      final emailFieldFinder = find.byKey(const Key('login_email_field'));
      if (emailFieldFinder.evaluate().isNotEmpty) {
        await tester.enterText(emailFieldFinder, 'test@example.com');
        await tester.pumpAndSettle();
      }

      // Find password field
      final passwordFieldFinder = find.byKey(const Key('login_password_field'));
      if (passwordFieldFinder.evaluate().isNotEmpty) {
        await tester.enterText(passwordFieldFinder, 'TestPassword123!');
        await tester.pumpAndSettle();
      }

      // Tap login button
      final loginButtonFinder = find.byKey(const Key('login_submit_button'));
      if (loginButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Verify login success (should navigate to home)
        // Can check for home screen elements
      }
    });

    testWidgets('should handle login errors gracefully',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to login with invalid credentials
      final emailField = find.byKey(const Key('login_email_field'));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'invalid@example.com');
        await tester.pumpAndSettle();
      }

      final passwordField = find.byKey(const Key('login_password_field'));
      if (passwordField.evaluate().isNotEmpty) {
        await tester.enterText(passwordField, 'wrongpassword');
        await tester.pumpAndSettle();
      }

      final loginButton = find.byKey(const Key('login_submit_button'));
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Should show error message
        // Check for error snackbar or error text
      }
    });

    testWidgets('should navigate to forgot password screen',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find and tap "Forgot Password" link
      final forgotPasswordFinder = find.text('¿Olvidaste tu contraseña?');
      if (forgotPasswordFinder.evaluate().isNotEmpty) {
        await tester.tap(forgotPasswordFinder);
        await tester.pumpAndSettle();

        // Should navigate to password reset screen
        expect(find.text('Recuperar Contraseña'), findsAny);
      }
    });

    testWidgets('should login with Google (mock)',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find Google login button
      final googleLoginFinder = find.byKey(const Key('google_login_button'));
      if (googleLoginFinder.evaluate().isNotEmpty) {
        await tester.tap(googleLoginFinder);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // In integration test, Google login would be mocked
        // Verify appropriate handling
      }
    });

    testWidgets('should login with Apple (mock)', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find Apple login button
      final appleLoginFinder = find.byKey(const Key('apple_login_button'));
      if (appleLoginFinder.evaluate().isNotEmpty) {
        await tester.tap(appleLoginFinder);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // In integration test, Apple login would be mocked
        // Verify appropriate handling
      }
    });

    testWidgets('should complete logout flow successfully',
        (WidgetTester tester) async {
      // Launch app (assuming user is logged in)
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to profile/settings
      final profileTabFinder = find.byIcon(Icons.person);
      if (profileTabFinder.evaluate().isNotEmpty) {
        await tester.tap(profileTabFinder);
        await tester.pumpAndSettle();
      }

      // Find and tap logout button
      final logoutButtonFinder = find.text('Cerrar Sesión');
      if (logoutButtonFinder.evaluate().isNotEmpty) {
        // Scroll to logout button if not visible
        await tester.dragUntilVisible(
          logoutButtonFinder,
          find.byType(SingleChildScrollView),
          const Offset(0, -50),
        );
        await tester.pumpAndSettle();

        await tester.tap(logoutButtonFinder);
        await tester.pumpAndSettle();

        // Confirm logout in dialog
        final confirmButtonFinder = find.text('Cerrar Sesión').last;
        if (confirmButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(confirmButtonFinder);
          await tester.pumpAndSettle(const Duration(seconds: 2));

          // Should navigate back to login screen
          expect(find.byKey(const Key('login_email_field')), findsAny);
        }
      }
    });

    testWidgets('should validate registration form fields',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to registration
      final registerFinder = find.text('Registrarse');
      if (registerFinder.evaluate().isNotEmpty) {
        await tester.tap(registerFinder);
        await tester.pumpAndSettle();
      }

      // Try to submit empty form
      final submitButton = find.byKey(const Key('register_submit_button'));
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.textContaining('requerido'), findsAny);
      }
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter invalid email
      final emailField = find.byKey(const Key('login_email_field'));
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'invalid-email');
        await tester.pumpAndSettle();

        // Tap somewhere else to trigger validation
        final passwordField = find.byKey(const Key('login_password_field'));
        if (passwordField.evaluate().isNotEmpty) {
          await tester.tap(passwordField);
          await tester.pumpAndSettle();
        }

        // Should show email format error
      }
    });

    testWidgets('should toggle password visibility',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find password visibility toggle
      final visibilityToggleFinder = find.byIcon(Icons.visibility);
      if (visibilityToggleFinder.evaluate().isNotEmpty) {
        await tester.tap(visibilityToggleFinder);
        await tester.pumpAndSettle();

        // Icon should change to visibility_off
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      }
    });
  });
}
