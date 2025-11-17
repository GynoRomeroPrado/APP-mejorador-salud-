import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/auth/data/models/auth_tokens.dart';

void main() {
  group('AuthTokens Model Tests', () {
    test('AuthTokens should be created from JSON', () {
      final json = {
        'access_token': 'test_access_token',
        'refresh_token': 'test_refresh_token',
        'expires_in': 3600,
        'token_type': 'Bearer',
      };

      final tokens = AuthTokens.fromJson(json);

      expect(tokens.accessToken, 'test_access_token');
      expect(tokens.refreshToken, 'test_refresh_token');
      expect(tokens.expiresIn, 3600);
      expect(tokens.tokenType, 'Bearer');
    });

    test('AuthTokens should convert to JSON', () {
      final tokens = AuthTokens(
        accessToken: 'test_access_token',
        refreshToken: 'test_refresh_token',
        expiresIn: 3600,
        tokenType: 'Bearer',
      );

      final json = tokens.toJson();

      expect(json['access_token'], 'test_access_token');
      expect(json['refresh_token'], 'test_refresh_token');
      expect(json['expires_in'], 3600);
      expect(json['token_type'], 'Bearer');
    });

    test('should check if token is expired', () {
      final notExpired = AuthTokens(
        accessToken: 'test',
        refreshToken: 'test',
        expiresIn: 3600,
        createdAt: DateTime.now(),
      );

      expect(notExpired.isExpired, isFalse);

      final expired = AuthTokens(
        accessToken: 'test',
        refreshToken: 'test',
        expiresIn: 3600,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      );

      expect(expired.isExpired, isTrue);
    });

    test('should calculate expiry date correctly', () {
      final createdAt = DateTime.now();
      final tokens = AuthTokens(
        accessToken: 'test',
        refreshToken: 'test',
        expiresIn: 3600,
        createdAt: createdAt,
      );

      final expectedExpiry = createdAt.add(Duration(seconds: 3600));

      expect(
        tokens.expiryDate.difference(expectedExpiry).inSeconds,
        lessThan(1),
      );
    });

    test('should calculate time until expiry correctly', () {
      final tokens = AuthTokens(
        accessToken: 'test',
        refreshToken: 'test',
        expiresIn: 3600,
        createdAt: DateTime.now(),
      );

      final timeUntilExpiry = tokens.timeUntilExpiry;

      expect(timeUntilExpiry.inSeconds, greaterThan(3500));
      expect(timeUntilExpiry.inSeconds, lessThanOrEqualTo(3600));
    });

    test('should check if token needs refresh', () {
      // Token with 10 minutes left (should need refresh)
      final needsRefresh = AuthTokens(
        accessToken: 'test',
        refreshToken: 'test',
        expiresIn: 600,
        createdAt: DateTime.now(),
      );

      expect(needsRefresh.needsRefresh, isTrue);

      // Token with 1 hour left (should not need refresh)
      final doesNotNeedRefresh = AuthTokens(
        accessToken: 'test',
        refreshToken: 'test',
        expiresIn: 3600,
        createdAt: DateTime.now(),
      );

      expect(doesNotNeedRefresh.needsRefresh, isFalse);
    });

    test('AuthTokens should support copyWith', () {
      final tokens = AuthTokens(
        accessToken: 'old_token',
        refreshToken: 'old_refresh',
        expiresIn: 3600,
      );

      final updated = tokens.copyWith(
        accessToken: 'new_token',
      );

      expect(updated.accessToken, 'new_token');
      expect(updated.refreshToken, 'old_refresh');
      expect(updated.expiresIn, 3600);
    });
  });
}
