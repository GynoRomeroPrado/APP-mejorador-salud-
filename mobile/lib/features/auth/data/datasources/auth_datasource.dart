import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart' as app_user;
import '../models/auth_tokens.dart';
import '../dto/register_dto.dart';
import '../dto/login_dto.dart';

class AuthDatasource {
  final SupabaseClient _supabase;
  final String _backendUrl;

  AuthDatasource({
    required SupabaseClient supabase,
    required String backendUrl,
  })  : _supabase = supabase,
        _backendUrl = backendUrl;

  /// Registro con email y password (usando backend NestJS)
  Future<Map<String, dynamic>> registerWithEmail(RegisterDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode != 201) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error en el registro');
      }

      final data = jsonDecode(response.body);
      return {
        'user': app_user.User.fromJson(data['user']),
        'tokens': AuthTokens.fromJson({
          'access_token': data['access_token'],
          'refresh_token': data['refresh_token'],
        }),
      };
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Login con email y password (usando backend NestJS)
  Future<Map<String, dynamic>> loginWithEmail(LoginDto dto) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto.toJson()),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error en el login');
      }

      final data = jsonDecode(response.body);
      return {
        'user': app_user.User.fromJson(data['user']),
        'tokens': AuthTokens.fromJson({
          'access_token': data['access_token'],
          'refresh_token': data['refresh_token'],
        }),
      };
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Login con Google (usando Supabase Auth)
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'healthfitness://auth/callback',
      );

      if (!response) {
        throw Exception('Error al iniciar sesión con Google');
      }

      // Esperar a que el usuario complete el flujo OAuth
      await Future.delayed(const Duration(seconds: 2));

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No se pudo obtener la sesión');
      }

      // Obtener datos del usuario desde backend
      final userResponse = await http.get(
        Uri.parse('$_backendUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Error al obtener datos del usuario');
      }

      final userData = jsonDecode(userResponse.body);

      return {
        'user': app_user.User.fromJson(userData),
        'tokens': AuthTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
        ),
      };
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  /// Login con Apple (usando Supabase Auth)
  Future<Map<String, dynamic>> loginWithApple() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'healthfitness://auth/callback',
      );

      if (!response) {
        throw Exception('Error al iniciar sesión con Apple');
      }

      await Future.delayed(const Duration(seconds: 2));

      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw Exception('No se pudo obtener la sesión');
      }

      final userResponse = await http.get(
        Uri.parse('$_backendUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Error al obtener datos del usuario');
      }

      final userData = jsonDecode(userResponse.body);

      return {
        'user': app_user.User.fromJson(userData),
        'tokens': AuthTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
        ),
      };
    } catch (e) {
      throw Exception('Error al iniciar sesión con Apple: $e');
    }
  }

  /// Refresh access token
  Future<AuthTokens> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al refrescar token');
      }

      final data = jsonDecode(response.body);
      return AuthTokens.fromJson({
        'access_token': data['access_token'],
        'refresh_token': data['refresh_token'],
      });
    } catch (e) {
      throw Exception('Error al refrescar token: $e');
    }
  }

  /// Logout
  Future<void> logout(String accessToken) async {
    try {
      await http.post(
        Uri.parse('$_backendUrl/auth/logout'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // También cerrar sesión de Supabase si existe
      if (_supabase.auth.currentSession != null) {
        await _supabase.auth.signOut();
      }
    } catch (e) {
      // Ignorar errores de logout, solo limpiar sesión local
      print('Error al cerrar sesión: $e');
    }
  }

  /// Obtener usuario actual
  Future<app_user.User> getCurrentUser(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_backendUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al obtener usuario actual');
      }

      final data = jsonDecode(response.body);
      return app_user.User.fromJson(data);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  /// Actualizar perfil de usuario
  Future<app_user.User> updateProfile(
    String accessToken,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_backendUrl/users/profile'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar perfil');
      }

      final data = jsonDecode(response.body);
      return app_user.User.fromJson(data);
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }
}
