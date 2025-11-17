import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/auth/data/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User model should be created from JSON', () {
      final json = {
        'user_id': '123',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'height_cm': 175.0,
        'weight_kg': 70.0,
        'date_of_birth': '1990-01-01T00:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.userId, '123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
      expect(user.heightCm, 175.0);
      expect(user.weightKg, 70.0);
    });

    test('User model should convert to JSON', () {
      final user = User(
        userId: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        heightCm: 175.0,
        weightKg: 70.0,
      );

      final json = user.toJson();

      expect(json['user_id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['full_name'], 'Test User');
    });

    group('User Extensions', () {
      test('should calculate BMI correctly', () {
        final user = User(
          userId: '123',
          email: 'test@example.com',
          heightCm: 175.0,
          weightKg: 70.0,
        );

        final bmi = user.bmi;

        expect(bmi, closeTo(22.86, 0.01));
      });

      test('should return null BMI if height or weight is null', () {
        final user = User(
          userId: '123',
          email: 'test@example.com',
        );

        expect(user.bmi, isNull);
      });

      test('should calculate age correctly', () {
        final dateOfBirth = DateTime(1990, 6, 15);
        final user = User(
          userId: '123',
          email: 'test@example.com',
          dateOfBirth: dateOfBirth,
        );

        final age = user.age;

        expect(age, greaterThanOrEqualTo(33));
        expect(age, lessThanOrEqualTo(34));
      });

      test('should return correct BMI category', () {
        // Underweight
        final underweight = User(
          userId: '1',
          email: 'test@example.com',
          heightCm: 175.0,
          weightKg: 50.0,
        );
        expect(underweight.bmiCategory, 'Underweight');

        // Normal
        final normal = User(
          userId: '2',
          email: 'test@example.com',
          heightCm: 175.0,
          weightKg: 70.0,
        );
        expect(normal.bmiCategory, 'Normal');

        // Overweight
        final overweight = User(
          userId: '3',
          email: 'test@example.com',
          heightCm: 175.0,
          weightKg: 85.0,
        );
        expect(overweight.bmiCategory, 'Overweight');

        // Obese
        final obese = User(
          userId: '4',
          email: 'test@example.com',
          heightCm: 175.0,
          weightKg: 100.0,
        );
        expect(obese.bmiCategory, 'Obese');
      });

      test('should check premium status correctly', () {
        final premiumUser = User(
          userId: '123',
          email: 'test@example.com',
          premiumUntil: DateTime.now().add(Duration(days: 30)),
        );

        expect(premiumUser.isPremium, isTrue);

        final expiredPremium = User(
          userId: '124',
          email: 'test2@example.com',
          premiumUntil: DateTime.now().subtract(Duration(days: 1)),
        );

        expect(expiredPremium.isPremium, isFalse);

        final freeUser = User(
          userId: '125',
          email: 'test3@example.com',
        );

        expect(freeUser.isPremium, isFalse);
      });
    });

    test('User model should support copyWith', () {
      final user = User(
        userId: '123',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      final updated = user.copyWith(fullName: 'Updated Name');

      expect(updated.userId, '123');
      expect(updated.email, 'test@example.com');
      expect(updated.fullName, 'Updated Name');
    });

    test('User model should support equality', () {
      final user1 = User(
        userId: '123',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      final user2 = User(
        userId: '123',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      final user3 = User(
        userId: '124',
        email: 'test@example.com',
        fullName: 'Test User',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });
}
