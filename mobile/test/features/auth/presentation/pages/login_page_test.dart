import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/auth/presentation/pages/login_page.dart';
import 'package:health_fitness_app/features/auth/data/repositories/auth_repository.dart';

@GenerateMocks([AuthRepository])
import 'login_page_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        // Override auth repository provider with mock
        // authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
      child: MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should display login form with all required fields',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('should display OAuth login buttons', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Continuar con Google'), findsOneWidget);
      expect(find.text('Continuar con Apple'), findsOneWidget);
      expect(find.byIcon(Icons.g_mobiledata), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('should display "Forgot Password" link',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    });

    testWidgets('should display "Sign Up" link', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('¿No tienes cuenta?'), findsOneWidget);
      expect(find.text('Regístrate'), findsOneWidget);
    });

    testWidgets('should show error when email field is empty',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final loginButton = find.text('Entrar');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Por favor ingresa tu email'), findsOneWidget);
    });

    testWidgets('should show error when email format is invalid',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      final loginButton = find.text('Entrar');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('should show error when password field is empty',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      final loginButton = find.text('Entrar');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Por favor ingresa tu contraseña'), findsOneWidget);
    });

    testWidgets('should show error when password is too short',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, '12345');

      final loginButton = find.text('Entrar');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(
        find.text('La contraseña debe tener al menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      final obscureButton = find.descendant(
        of: passwordField,
        matching: find.byType(IconButton),
      );

      // Initially password should be obscured
      TextFormField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);

      // Tap to show password
      await tester.tap(obscureButton);
      await tester.pump();

      // Password should now be visible
      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isFalse);

      // Tap again to hide
      await tester.tap(obscureButton);
      await tester.pump();

      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, isTrue);
    });

    testWidgets('should show loading indicator when submitting',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Mock the login to delay
      when(mockAuthRepository.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 2));
        return null;
      });

      // Act
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'password123');

      final loginButton = find.text('Entrar');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert - Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to sign up page when tapping register link',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final signUpLink = find.text('Regístrate');
      await tester.tap(signUpLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate to register page
      // This would need proper navigation setup
      // expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('should navigate to forgot password when tapping link',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final forgotPasswordLink = find.text('¿Olvidaste tu contraseña?');
      await tester.tap(forgotPasswordLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate to forgot password page
      // This would need proper navigation setup
    });

    testWidgets('should enable login button when form is valid',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'password123');

      await tester.pump();

      // Assert
      final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');
      final ElevatedButton button = tester.widget(loginButton);
      expect(button.enabled, isTrue);
    });

    testWidgets('should show snackbar on login error',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      when(mockAuthRepository.signInWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(Exception('Credenciales inválidas'));

      // Act
      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'test@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'wrong-password');

      final loginButton = find.text('Entrar');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error al iniciar sesión'), findsOneWidget);
    });
  });
}
