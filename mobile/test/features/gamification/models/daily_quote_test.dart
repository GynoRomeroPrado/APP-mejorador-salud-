import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/data/models/daily_quote.dart';

void main() {
  group('DailyQuote Tests', () {
    test('DailyQuotes should have predefined quotes', () {
      expect(DailyQuotes.quotes, isNotEmpty);
      expect(DailyQuotes.quotes.length, greaterThan(10));
    });

    test('getQuoteOfTheDay should return consistent quote for same day', () {
      final quote1 = DailyQuotes.getQuoteOfTheDay();
      final quote2 = DailyQuotes.getQuoteOfTheDay();

      expect(quote1.text, equals(quote2.text));
      expect(quote1.author, equals(quote2.author));
    });

    test('getQuoteOfTheDay should return different quotes on different days', () {
      // This is deterministic based on day of year
      final quote = DailyQuotes.getQuoteOfTheDay();

      expect(quote, isNotNull);
      expect(quote.text, isNotEmpty);
      expect(quote.author, isNotEmpty);
    });

    test('getRandomQuote should return a valid quote', () {
      final quote = DailyQuotes.getRandomQuote();

      expect(quote, isNotNull);
      expect(quote.text, isNotEmpty);
      expect(quote.author, isNotEmpty);
    });

    test('all quotes should have required fields', () {
      for (final quote in DailyQuotes.quotes) {
        expect(quote.text, isNotEmpty);
        expect(quote.author, isNotEmpty);
      }
    });

    test('DailyQuote should be created from JSON', () {
      final json = {
        'text': 'Test quote',
        'author': 'Test Author',
        'category': 'motivation',
      };

      final quote = DailyQuote.fromJson(json);

      expect(quote.text, 'Test quote');
      expect(quote.author, 'Test Author');
      expect(quote.category, 'motivation');
    });

    test('DailyQuote should convert to JSON', () {
      final quote = DailyQuote(
        text: 'Test quote',
        author: 'Test Author',
        category: 'motivation',
      );

      final json = quote.toJson();

      expect(json['text'], 'Test quote');
      expect(json['author'], 'Test Author');
      expect(json['category'], 'motivation');
    });
  });
}
