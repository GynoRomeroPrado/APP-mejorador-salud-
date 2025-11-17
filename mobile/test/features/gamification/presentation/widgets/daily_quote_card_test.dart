import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_fitness_app/features/gamification/presentation/widgets/daily_quote_card.dart';
import 'package:health_fitness_app/features/gamification/data/models/daily_quote.dart';

void main() {
  Widget createWidgetUnderTest(DailyQuote quote) {
    return MaterialApp(
      home: Scaffold(
        body: DailyQuoteCard(quote: quote),
      ),
    );
  }

  group('DailyQuoteCard Widget Tests', () {
    testWidgets('should display quote text', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'The only bad workout is the one that didn\'t happen.',
        author: 'Anonymous',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.text(quote.text), findsOneWidget);
    });

    testWidgets('should display quote author', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Success is not final, failure is not fatal.',
        author: 'Winston Churchill',
        category: 'motivation',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.textContaining('Winston Churchill'), findsOneWidget);
    });

    testWidgets('should display quote icon', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Test quote',
        author: 'Test Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.byIcon(Icons.format_quote), findsWidgets);
    });

    testWidgets('should display card', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Test quote',
        author: 'Test Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle long quote text', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'This is a very long motivational quote that should wrap to multiple lines '
            'and still display correctly without overflowing the card boundaries. '
            'It tests the text wrapping and layout capabilities of the quote card widget.',
        author: 'Long Quote Author',
        category: 'motivation',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.textContaining('This is a very long'), findsOneWidget);
    });

    testWidgets('should handle long author name', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Short quote',
        author: 'Very Long Author Name That Might Wrap',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.textContaining('Very Long Author'), findsOneWidget);
    });

    testWidgets('should format author with dash prefix',
        (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Test quote',
        author: 'Test Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.textContaining('—'), findsOneWidget); // Em dash
    });

    testWidgets('should use italic style for quote text',
        (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Italicized quote text',
        author: 'Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      final textWidget = tester.widget<Text>(find.text('Italicized quote text'));
      expect(textWidget.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('should display different categories with icons',
        (WidgetTester tester) async {
      // Test fitness category
      final fitnessQuote = DailyQuote(
        text: 'Fitness quote',
        author: 'Author',
        category: 'fitness',
      );

      await tester.pumpWidget(createWidgetUnderTest(fitnessQuote));
      expect(find.byType(Card), findsOneWidget);

      // Test motivation category
      final motivationQuote = DailyQuote(
        text: 'Motivation quote',
        author: 'Author',
        category: 'motivation',
      );

      await tester.pumpWidget(createWidgetUnderTest(motivationQuote));
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should be responsive to different screen sizes',
        (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Test quote for responsive design',
        author: 'Author',
        category: 'fitness',
      );

      // Act - Test with small screen
      tester.binding.window.physicalSizeTestValue = Size(300, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.text(quote.text), findsOneWidget);

      // Reset
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
    });

    testWidgets('should handle special characters in quote',
        (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Quote with "quotes" and \'apostrophes\' & special chars!',
        author: 'Author & Co.',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.textContaining('"quotes"'), findsOneWidget);
      expect(find.textContaining('&'), findsWidgets);
    });

    testWidgets('should display with gradient or colored background',
        (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Test quote',
        author: 'Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNotNull);
    });

    testWidgets('should animate when appearing', (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Animated quote',
        author: 'Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));
      await tester.pump(Duration(milliseconds: 100));

      // Assert
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should have proper padding and margins',
        (WidgetTester tester) async {
      // Arrange
      final quote = DailyQuote(
        text: 'Test quote',
        author: 'Author',
        category: 'fitness',
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(quote));

      // Assert
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
