import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/auth/presentation/pages/register_page.dart';
import 'package:health_fitness_app/features/auth/data/repositories/auth_repository.dart';

@GenerateMocks([AuthRepository])
import 'register_page_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        home: RegisterPage(),
      ),
    );
  }

  group('RegisterPage Widget Tests', () {
    testWidgets('should display registration form with all required fields',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Crear Cuenta'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Email, Password, Confirm
      expect(find.text('Nombre Completo'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar Contraseña'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
    });

    testWidgets('should display terms and conditions checkbox',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.textContaining('Acepto los'), findsOneWidget);
      expect(find.textContaining('Términos y Condiciones'), findsOneWidget);
    });

    testWidgets('should display OAuth registration buttons',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Registrarse con Google'), findsOneWidget);
      expect(find.text('Registrarse con Apple'), findsOneWidget);
    });

    testWidgets('should display "Already have account" link',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('¿Ya tienes cuenta?'), findsOneWidget);
      expect(find.text('Inicia sesión'), findsOneWidget);
    });

    testWidgets('should show error when name field is empty',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(find.text('Por favor ingresa tu nombre'), findsOneWidget);
    });

    testWidgets('should show error when name is too short',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'A');

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(
        find.text('El nombre debe tener al menos 2 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when email is invalid',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'invalid-email');

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('should show error when password is too weak',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'john@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, '123');

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(
        find.text('La contraseña debe tener al menos 8 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when passwords do not match',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'john@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'password123');

      final confirmPasswordField =
          find.widgetWithText(TextFormField, 'Confirmar Contraseña');
      await tester.enterText(confirmPasswordField, 'different123');

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    });

    testWidgets('should show error when terms are not accepted',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'john@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'password123');

      final confirmPasswordField =
          find.widgetWithText(TextFormField, 'Confirmar Contraseña');
      await tester.enterText(confirmPasswordField, 'password123');

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(
        find.text('Debes aceptar los términos y condiciones'),
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
    });

    testWidgets('should toggle terms checkbox when tapped',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final checkbox = find.byType(Checkbox);

      // Initially unchecked
      Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isFalse);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pump();

      // Should now be checked
      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isTrue);

      // Tap again to uncheck
      await tester.tap(checkbox);
      await tester.pump();

      checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, isFalse);
    });

    testWidgets('should show password strength indicator',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');

      // Enter weak password
      await tester.enterText(passwordField, '123');
      await tester.pump();

      // Assert - Should show weak indicator
      expect(find.text('Débil'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Enter medium password
      await tester.enterText(passwordField, 'password');
      await tester.pump();

      // Assert - Should show medium indicator
      expect(find.text('Media'), findsOneWidget);

      // Enter strong password
      await tester.enterText(passwordField, 'Password123!@#');
      await tester.pump();

      // Assert - Should show strong indicator
      expect(find.text('Fuerte'), findsOneWidget);
    });

    testWidgets('should show loading indicator when submitting',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      when(mockAuthRepository.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        fullName: anyNamed('fullName'),
      )).thenAnswer((_) async {
        await Future.delayed(Duration(seconds: 2));
        return null;
      });

      // Act - Fill all fields
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'john@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'password123');

      final confirmPasswordField =
          find.widgetWithText(TextFormField, 'Confirmar Contraseña');
      await tester.enterText(confirmPasswordField, 'password123');

      // Accept terms
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to login when tapping login link',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final loginLink = find.text('Inicia sesión');
      await tester.tap(loginLink);
      await tester.pumpAndSettle();

      // Assert - Should navigate back to login
      // This would need proper navigation setup
    });

    testWidgets('should show snackbar on registration error',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      when(mockAuthRepository.signUpWithEmail(
        email: anyNamed('email'),
        password: anyNamed('password'),
        fullName: anyNamed('fullName'),
      )).thenThrow(Exception('El email ya está en uso'));

      // Act - Fill all fields
      final nameField = find.widgetWithText(TextFormField, 'Nombre Completo');
      await tester.enterText(nameField, 'John Doe');

      final emailField = find.widgetWithText(TextFormField, 'Email');
      await tester.enterText(emailField, 'existing@example.com');

      final passwordField = find.widgetWithText(TextFormField, 'Contraseña');
      await tester.enterText(passwordField, 'password123');

      final confirmPasswordField =
          find.widgetWithText(TextFormField, 'Confirmar Contraseña');
      await tester.enterText(confirmPasswordField, 'password123');

      // Accept terms
      final checkbox = find.byType(Checkbox);
      await tester.tap(checkbox);
      await tester.pump();

      final registerButton = find.text('Registrarse');
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error al crear la cuenta'), findsOneWidget);
    });
  });
}
