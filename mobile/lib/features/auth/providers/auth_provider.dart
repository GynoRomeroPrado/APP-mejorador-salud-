import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/auth_state.dart';
import '../data/models/user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/dto/register_dto.dart';
import '../data/dto/login_dto.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    // Intentar restaurar sesión al iniciar
    final repository = ref.watch(authRepositoryProvider);
    final isAuth = await repository.isAuthenticated();

    if (isAuth) {
      final user = await repository.getCurrentUser();
      if (user != null) {
        final accessToken = await repository.getAccessToken();
        final tokens = AuthTokens(
          accessToken: accessToken ?? '',
          refreshToken: '', // Se obtendrá del refresh
        );
        return AuthState.authenticated(user: user, tokens: tokens);
      }
    }

    return const AuthState.unauthenticated();
  }

  /// Registro con email y password
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);

    final dto = RegisterDto(
      email: email,
      password: password,
      fullName: fullName,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );

    final result = await repository.registerWithEmail(dto);
    state = AsyncValue.data(result);
  }

  /// Login con email y password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);

    final dto = LoginDto(
      email: email,
      password: password,
    );

    final result = await repository.loginWithEmail(dto);
    state = AsyncValue.data(result);
  }

  /// Login con Google
  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.loginWithGoogle();

    state = AsyncValue.data(result);
  }

  /// Login con Apple
  Future<void> loginWithApple() async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.loginWithApple();

    state = AsyncValue.data(result);
  }

  /// Logout
  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }

  /// Actualizar perfil
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final repository = ref.read(authRepositoryProvider);

    try {
      final updatedUser = await repository.updateProfile(updates);

      // Actualizar estado con el nuevo usuario
      state.whenData((authState) {
        authState.maybeWhen(
          authenticated: (_, tokens) {
            state = AsyncValue.data(
              AuthState.authenticated(user: updatedUser, tokens: tokens),
            );
          },
          orElse: () {},
        );
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider para verificar si el usuario está autenticado
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.isAuthenticated,
    orElse: () => false,
  );
}

// Provider para obtener el usuario actual
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authProvider);
  return authState.maybeWhen(
    data: (state) => state.user,
    orElse: () => null,
  );
}

// Provider para obtener el access token
@riverpod
Future<String?> accessToken(AccessTokenRef ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getAccessToken();
}
