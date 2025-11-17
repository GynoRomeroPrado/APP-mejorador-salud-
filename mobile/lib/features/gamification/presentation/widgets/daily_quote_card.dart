import 'package:flutter/material.dart';
import '../../data/models/daily_quote.dart';

class DailyQuoteCard extends StatelessWidget {
  final DailyQuote quote;

  const DailyQuoteCard({
    super.key,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Frase del Día',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              '"${quote.text}"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${quote.author}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
