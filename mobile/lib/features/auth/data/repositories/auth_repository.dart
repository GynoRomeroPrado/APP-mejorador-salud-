import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/auth_datasource.dart';
import '../models/user.dart';
import '../models/auth_tokens.dart';
import '../models/auth_state.dart';
import '../dto/register_dto.dart';
import '../dto/login_dto.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final AuthDatasource _datasource;
  final FlutterSecureStorage _secureStorage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  AuthRepository({
    required AuthDatasource datasource,
    required FlutterSecureStorage secureStorage,
  })  : _datasource = datasource,
        _secureStorage = secureStorage;

  /// Registro con email y password
  Future<AuthState> registerWithEmail(RegisterDto dto) async {
    try {
      final result = await _datasource.registerWithEmail(dto);
      final user = result['user'] as User;
      final tokens = result['tokens'] as AuthTokens;

      // Guardar tokens de forma segura
      await _saveTokens(tokens);
      await _saveUser(user);

      return AuthState.authenticated(user: user, tokens: tokens);
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Login con email y password
  Future<AuthState> loginWithEmail(LoginDto dto) async {
    try {
      final result = await _datasource.loginWithEmail(dto);
      final user = result['user'] as User;
      final tokens = result['tokens'] as AuthTokens;

      await _saveTokens(tokens);
      await _saveUser(user);

      return AuthState.authenticated(user: user, tokens: tokens);
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Login con Google
  Future<AuthState> loginWithGoogle() async {
    try {
      final result = await _datasource.loginWithGoogle();
      final user = result['user'] as User;
      final tokens = result['tokens'] as AuthTokens;

      await _saveTokens(tokens);
      await _saveUser(user);

      return AuthState.authenticated(user: user, tokens: tokens);
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Login con Apple
  Future<AuthState> loginWithApple() async {
    try {
      final result = await _datasource.loginWithApple();
      final user = result['user'] as User;
      final tokens = result['tokens'] as AuthTokens;

      await _saveTokens(tokens);
      await _saveUser(user);

      return AuthState.authenticated(user: user, tokens: tokens);
    } catch (e) {
      return AuthState.error(e.toString());
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken != null) {
        await _datasource.logout(accessToken);
      }
    } finally {
      // Siempre limpiar datos locales
      await _clearLocalData();
    }
  }

  /// Refrescar token automáticamente
  Future<AuthTokens?> refreshTokenIfNeeded() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (accessToken == null || refreshToken == null) {
        return null;
      }

      // TODO: Verificar si el token necesita refresh
      // Por ahora, solo retornamos los tokens actuales
      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      print('Error al refrescar token: $e');
      return null;
    }
  }

  /// Obtener usuario actual (desde storage o API)
  Future<User?> getCurrentUser() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken == null) return null;

      // Intentar obtener desde API
      return await _datasource.getCurrentUser(accessToken);
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return null;
    }
  }

  /// Actualizar perfil
  Future<User> updateProfile(Map<String, dynamic> updates) async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    if (accessToken == null) {
      throw Exception('No autenticado');
    }

    final updatedUser = await _datasource.updateProfile(accessToken, updates);
    await _saveUser(updatedUser);
    return updatedUser;
  }

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final accessToken = await _secureStorage.read(key: _accessTokenKey);
    return accessToken != null;
  }

  /// Obtener access token actual
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  // Métodos privados

  Future<void> _saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: tokens.accessToken,
    );
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: tokens.refreshToken,
    );
  }

  Future<void> _saveUser(User user) async {
    // TODO: Serializar y guardar usuario
    // Por ahora, solo guardamos el userId
    await _secureStorage.write(
      key: _userDataKey,
      value: user.userId,
    );
  }

  Future<void> _clearLocalData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userDataKey);
  }
}

// Providers

@riverpod
AuthDatasource authDatasource(AuthDatasourceRef ref) {
  // TODO: Obtener supabase client y backend URL desde config
  throw UnimplementedError('Configurar Supabase client y backend URL');
}

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    datasource: ref.watch(authDatasourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
}
