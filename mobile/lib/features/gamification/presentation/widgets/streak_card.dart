import 'package:flutter/material.dart';
import '../../data/models/user_stats.dart';

class StreakCard extends StatelessWidget {
  final UserStats stats;

  const StreakCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icono con animación de fuego
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: stats.currentStreak > 0
                    ? Colors.orange.withOpacity(0.2)
                    : theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_fire_department,
                color: stats.currentStreak > 0
                    ? Colors.orange
                    : theme.colorScheme.onSurfaceVariant,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Info de racha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Racha Actual',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (stats.streakAtRisk) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber,
                                size: 12,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '¡En riesgo!',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${stats.currentStreak} días',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: stats.currentStreak > 0
                              ? Colors.orange
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '• Récord: ${stats.longestStreak}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
