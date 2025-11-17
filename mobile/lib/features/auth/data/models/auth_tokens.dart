import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';
part 'auth_tokens.g.dart';

@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_in') int? expiresIn,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

extension AuthTokensExtension on AuthTokens {
  DateTime get expiryDate {
    if (expiresIn == null) {
      // Default: 1 hora
      return DateTime.now().add(const Duration(hours: 1));
    }
    return DateTime.now().add(Duration(seconds: expiresIn!));
  }

  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  bool get willExpireSoon {
    // Considerar "soon" como menos de 5 minutos
    final fiveMinutesFromNow = DateTime.now().add(const Duration(minutes: 5));
    return expiryDate.isBefore(fiveMinutesFromNow);
  }
}
