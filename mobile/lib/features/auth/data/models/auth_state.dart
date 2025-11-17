import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';
import 'auth_tokens.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.authenticated({
    required User user,
    required AuthTokens tokens,
  }) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}

extension AuthStateExtension on AuthState {
  bool get isAuthenticated => this is AuthStateAuthenticated;
  bool get isLoading => this is AuthStateLoading;
  bool get isError => this is AuthStateError;

  User? get user => maybeWhen(
        authenticated: (user, _) => user,
        orElse: () => null,
      );

  AuthTokens? get tokens => maybeWhen(
        authenticated: (_, tokens) => tokens,
        orElse: () => null,
      );
}
