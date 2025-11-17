import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/auth/data/repositories/auth_repository.dart';
import 'package:health_fitness_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:health_fitness_app/features/auth/data/models/user.dart';
import 'package:health_fitness_app/features/auth/data/models/auth_tokens.dart';

@GenerateMocks([AuthDatasource])
import 'auth_repository_test.mocks.dart';

void main() {
  late AuthRepository repository;
  late MockAuthDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockAuthDatasource();
    repository = AuthRepository(datasource: mockDatasource);
  });

  group('AuthRepository Tests', () {
    group('signInWithEmail', () {
      test('should return tokens when sign in is successful', () async {
        // Arrange
        final expectedTokens = AuthTokens(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
          expiresIn: 3600,
        );

        when(mockDatasource.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => expectedTokens);

        // Act
        final result = await repository.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, expectedTokens);
        verify(mockDatasource.signInWithEmail(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should throw exception when credentials are invalid', () async {
        // Arrange
        when(mockDatasource.signInWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(Exception('Invalid credentials'));

        // Act & Assert
        expect(
          () => repository.signInWithEmail(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          ),
          throwsException,
        );
      });
    });

    group('signUpWithEmail', () {
      test('should return tokens when sign up is successful', () async {
        // Arrange
        final expectedTokens = AuthTokens(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
          expiresIn: 3600,
        );

        when(mockDatasource.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          fullName: anyNamed('fullName'),
        )).thenAnswer((_) async => expectedTokens);

        // Act
        final result = await repository.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'password123',
          fullName: 'New User',
        );

        // Assert
        expect(result, expectedTokens);
        verify(mockDatasource.signUpWithEmail(
          email: 'newuser@example.com',
          password: 'password123',
          fullName: 'New User',
        )).called(1);
      });

      test('should throw exception when email already exists', () async {
        // Arrange
        when(mockDatasource.signUpWithEmail(
          email: anyNamed('email'),
          password: anyNamed('password'),
          fullName: anyNamed('fullName'),
        )).thenThrow(Exception('Email already exists'));

        // Act & Assert
        expect(
          () => repository.signUpWithEmail(
            email: 'existing@example.com',
            password: 'password123',
            fullName: 'Existing User',
          ),
          throwsException,
        );
      });
    });

    group('getCurrentUser', () {
      test('should return user when authenticated', () async {
        // Arrange
        final expectedUser = User(
          userId: '123',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        when(mockDatasource.getCurrentUser())
            .thenAnswer((_) async => expectedUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, expectedUser);
        verify(mockDatasource.getCurrentUser()).called(1);
      });

      test('should return null when not authenticated', () async {
        // Arrange
        when(mockDatasource.getCurrentUser()).thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('refreshToken', () {
      test('should return new tokens when refresh is successful', () async {
        // Arrange
        final expectedTokens = AuthTokens(
          accessToken: 'new_access_token',
          refreshToken: 'new_refresh_token',
          expiresIn: 3600,
        );

        when(mockDatasource.refreshToken(any))
            .thenAnswer((_) async => expectedTokens);

        // Act
        final result = await repository.refreshToken('old_refresh_token');

        // Assert
        expect(result, expectedTokens);
        verify(mockDatasource.refreshToken('old_refresh_token')).called(1);
      });

      test('should throw exception when refresh token is invalid', () async {
        // Arrange
        when(mockDatasource.refreshToken(any))
            .thenThrow(Exception('Invalid refresh token'));

        // Act & Assert
        expect(
          () => repository.refreshToken('invalid_token'),
          throwsException,
        );
      });
    });

    group('signOut', () {
      test('should call datasource signOut', () async {
        // Arrange
        when(mockDatasource.signOut()).thenAnswer((_) async => {});

        // Act
        await repository.signOut();

        // Assert
        verify(mockDatasource.signOut()).called(1);
      });
    });

    group('updateProfile', () {
      test('should return updated user', () async {
        // Arrange
        final updatedUser = User(
          userId: '123',
          email: 'test@example.com',
          fullName: 'Updated Name',
          heightCm: 175.0,
          weightKg: 70.0,
        );

        when(mockDatasource.updateProfile(
          fullName: anyNamed('fullName'),
          heightCm: anyNamed('heightCm'),
          weightKg: anyNamed('weightKg'),
        )).thenAnswer((_) async => updatedUser);

        // Act
        final result = await repository.updateProfile(
          fullName: 'Updated Name',
          heightCm: 175.0,
          weightKg: 70.0,
        );

        // Assert
        expect(result, updatedUser);
        expect(result.fullName, 'Updated Name');
        verify(mockDatasource.updateProfile(
          fullName: 'Updated Name',
          heightCm: 175.0,
          weightKg: 70.0,
        )).called(1);
      });
    });
  });
}
