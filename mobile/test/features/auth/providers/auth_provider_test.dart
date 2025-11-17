import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:health_fitness_app/features/auth/providers/auth_provider.dart';
import 'package:health_fitness_app/features/auth/data/repositories/auth_repository.dart';
import 'package:health_fitness_app/features/auth/data/models/user.dart';
import 'package:health_fitness_app/features/auth/data/models/auth_state.dart';
import 'package:health_fitness_app/features/auth/data/models/auth_tokens.dart';
import 'package:health_fitness_app/features/auth/data/dto/register_dto.dart';
import 'package:health_fitness_app/features/auth/data/dto/login_dto.dart';

@GenerateMocks([AuthRepository])
import 'auth_provider_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  }

  group('Auth Provider Tests', () {
    group('build (initial state)', () {
      test('should return unauthenticated when not authenticated', () async {
        // Arrange
        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        container = createContainer();

        // Act
        final authState = await container.read(authProvider.future);

        // Assert
        expect(authState, isA<UnauthenticatedAuthState>());
        verify(mockAuthRepository.isAuthenticated()).called(1);
      });

      test('should return authenticated when user is logged in', () async {
        // Arrange
        final testUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
        when(mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'test_access_token');

        container = createContainer();

        // Act
        final authState = await container.read(authProvider.future);

        // Assert
        expect(authState, isA<AuthenticatedAuthState>());
        authState.maybeWhen(
          authenticated: (user, tokens) {
            expect(user.userId, 'u_123');
            expect(user.email, 'test@example.com');
            expect(tokens.accessToken, 'test_access_token');
          },
          orElse: () => fail('Expected authenticated state'),
        );

        verify(mockAuthRepository.isAuthenticated()).called(1);
        verify(mockAuthRepository.getCurrentUser()).called(1);
        verify(mockAuthRepository.getAccessToken()).called(1);
      });

      test('should return unauthenticated when getCurrentUser returns null',
          () async {
        // Arrange
        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);

        container = createContainer();

        // Act
        final authState = await container.read(authProvider.future);

        // Assert
        expect(authState, isA<UnauthenticatedAuthState>());
      });
    });

    group('registerWithEmail', () {
      test('should register user successfully', () async {
        // Arrange
        final testUser = User(
          userId: 'u_new',
          email: 'newuser@example.com',
          fullName: 'New User',
        );

        final authState = AuthState.authenticated(
          user: testUser,
          tokens: AuthTokens(
            accessToken: 'new_access_token',
            refreshToken: 'new_refresh_token',
          ),
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(mockAuthRepository.registerWithEmail(any))
            .thenAnswer((_) async => authState);

        container = createContainer();

        // Wait for initial state
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).registerWithEmail(
              email: 'newuser@example.com',
              password: 'password123',
              fullName: 'New User',
            );

        // Assert
        final result = await container.read(authProvider.future);
        expect(result, isA<AuthenticatedAuthState>());

        verify(mockAuthRepository.registerWithEmail(any)).called(1);
      });

      test('should handle registration error', () async {
        // Arrange
        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(mockAuthRepository.registerWithEmail(any))
            .thenThrow(Exception('Email already exists'));

        container = createContainer();
        await container.read(authProvider.future);

        // Act & Assert
        expect(
          () => container.read(authProvider.notifier).registerWithEmail(
                email: 'existing@example.com',
                password: 'password123',
                fullName: 'Existing User',
              ),
          throwsException,
        );
      });
    });

    group('loginWithEmail', () {
      test('should login user successfully', () async {
        // Arrange
        final testUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        final authState = AuthState.authenticated(
          user: testUser,
          tokens: AuthTokens(
            accessToken: 'access_token',
            refreshToken: 'refresh_token',
          ),
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(mockAuthRepository.loginWithEmail(any))
            .thenAnswer((_) async => authState);

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).loginWithEmail(
              email: 'test@example.com',
              password: 'password123',
            );

        // Assert
        final result = await container.read(authProvider.future);
        expect(result, isA<AuthenticatedAuthState>());

        result.maybeWhen(
          authenticated: (user, tokens) {
            expect(user.email, 'test@example.com');
            expect(tokens.accessToken, 'access_token');
          },
          orElse: () => fail('Expected authenticated state'),
        );

        verify(mockAuthRepository.loginWithEmail(any)).called(1);
      });

      test('should handle login error', () async {
        // Arrange
        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(mockAuthRepository.loginWithEmail(any))
            .thenThrow(Exception('Invalid credentials'));

        container = createContainer();
        await container.read(authProvider.future);

        // Act & Assert
        expect(
          () => container.read(authProvider.notifier).loginWithEmail(
                email: 'wrong@example.com',
                password: 'wrongpassword',
              ),
          throwsException,
        );
      });
    });

    group('loginWithGoogle', () {
      test('should login with Google successfully', () async {
        // Arrange
        final testUser = User(
          userId: 'u_google',
          email: 'google@example.com',
          fullName: 'Google User',
        );

        final authState = AuthState.authenticated(
          user: testUser,
          tokens: AuthTokens(
            accessToken: 'google_access_token',
            refreshToken: 'google_refresh_token',
          ),
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(mockAuthRepository.loginWithGoogle())
            .thenAnswer((_) async => authState);

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).loginWithGoogle();

        // Assert
        final result = await container.read(authProvider.future);
        expect(result, isA<AuthenticatedAuthState>());
        verify(mockAuthRepository.loginWithGoogle()).called(1);
      });
    });

    group('loginWithApple', () {
      test('should login with Apple successfully', () async {
        // Arrange
        final testUser = User(
          userId: 'u_apple',
          email: 'apple@example.com',
          fullName: 'Apple User',
        );

        final authState = AuthState.authenticated(
          user: testUser,
          tokens: AuthTokens(
            accessToken: 'apple_access_token',
            refreshToken: 'apple_refresh_token',
          ),
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
        when(mockAuthRepository.loginWithApple())
            .thenAnswer((_) async => authState);

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).loginWithApple();

        // Assert
        final result = await container.read(authProvider.future);
        expect(result, isA<AuthenticatedAuthState>());
        verify(mockAuthRepository.loginWithApple()).called(1);
      });
    });

    group('logout', () {
      test('should logout user successfully', () async {
        // Arrange
        final testUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
        when(mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'access_token');
        when(mockAuthRepository.logout()).thenAnswer((_) async => {});

        container = createContainer();

        // Wait for authenticated state
        final initialState = await container.read(authProvider.future);
        expect(initialState, isA<AuthenticatedAuthState>());

        // Act
        await container.read(authProvider.notifier).logout();

        // Assert
        final result = await container.read(authProvider.future);
        expect(result, isA<UnauthenticatedAuthState>());
        verify(mockAuthRepository.logout()).called(1);
      });
    });

    group('updateProfile', () {
      test('should update user profile successfully', () async {
        // Arrange
        final initialUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
          heightCm: 170.0,
          weightKg: 70.0,
        );

        final updatedUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
          heightCm: 175.0,
          weightKg: 75.0,
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => initialUser);
        when(mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'access_token');
        when(mockAuthRepository.updateProfile(any))
            .thenAnswer((_) async => updatedUser);

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).updateProfile({
          'heightCm': 175.0,
          'weightKg': 75.0,
        });

        // Assert
        final result = await container.read(authProvider.future);
        result.maybeWhen(
          authenticated: (user, _) {
            expect(user.heightCm, 175.0);
            expect(user.weightKg, 75.0);
          },
          orElse: () => fail('Expected authenticated state'),
        );

        verify(mockAuthRepository.updateProfile(any)).called(1);
      });
    });

    group('isAuthenticated provider', () {
      test('should return true when authenticated', () async {
        // Arrange
        final testUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
        when(mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'access_token');

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        final isAuth = container.read(isAuthenticatedProvider);

        // Assert
        expect(isAuth, isTrue);
      });

      test('should return false when not authenticated', () async {
        // Arrange
        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        final isAuth = container.read(isAuthenticatedProvider);

        // Assert
        expect(isAuth, isFalse);
      });
    });

    group('currentUser provider', () {
      test('should return user when authenticated', () async {
        // Arrange
        final testUser = User(
          userId: 'u_123',
          email: 'test@example.com',
          fullName: 'Test User',
        );

        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
        when(mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'access_token');

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        final user = container.read(currentUserProvider);

        // Assert
        expect(user, isNotNull);
        expect(user?.userId, 'u_123');
        expect(user?.email, 'test@example.com');
      });

      test('should return null when not authenticated', () async {
        // Arrange
        when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);

        container = createContainer();
        await container.read(authProvider.future);

        // Act
        final user = container.read(currentUserProvider);

        // Assert
        expect(user, isNull);
      });
    });

    group('accessToken provider', () {
      test('should return access token when available', () async {
        // Arrange
        when(mockAuthRepository.getAccessToken())
            .thenAnswer((_) async => 'test_access_token');

        container = createContainer();

        // Act
        final token = await container.read(accessTokenProvider.future);

        // Assert
        expect(token, 'test_access_token');
        verify(mockAuthRepository.getAccessToken()).called(1);
      });

      test('should return null when no access token', () async {
        // Arrange
        when(mockAuthRepository.getAccessToken()).thenAnswer((_) async => null);

        container = createContainer();

        // Act
        final token = await container.read(accessTokenProvider.future);

        // Assert
        expect(token, isNull);
      });
    });
  });
}
