import 'package:flutter/material.dart';
import '../../data/models/exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Imagen GIF
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
              ),
              child: Image.network(
                exercise.gifUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fitness_center,
                    size: 40,
                    color: theme.colorScheme.onSurfaceVariant,
                  );
                },
              ),
            ),

            // Información
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      exercise.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Músculo objetivo
                    Row(
                      children: [
                        Icon(
                          Icons.sports_gymnastics,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.targetSpanish,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Equipamiento
                    Row(
                      children: [
                        Icon(
                          Icons.construction,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            exercise.equipmentSpanish,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badges
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        // Body part badge
                        _Badge(
                          label: exercise.bodyPartSpanish,
                          color: theme.colorScheme.primaryContainer,
                        ),

                        // Dificultad badge
                        _Badge(
                          label: exercise.estimatedDifficulty.toUpperCase(),
                          color: _getDifficultyColor(
                            theme,
                            exercise.estimatedDifficulty,
                          ),
                        ),

                        // Home badge
                        if (exercise.canDoAtHome)
                          _Badge(
                            label: 'Casa',
                            color: Colors.green.withOpacity(0.2),
                            icon: Icons.home,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Botón favorito
            if (onFavoriteTap != null)
              IconButton(
                icon: Icon(
                  exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: exercise.isFavorite ? Colors.red : null,
                ),
                onPressed: onFavoriteTap,
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(ThemeData theme, String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green.withOpacity(0.2);
      case 'intermediate':
        return Colors.orange.withOpacity(0.2);
      case 'advanced':
        return Colors.red.withOpacity(0.2);
      default:
        return theme.colorScheme.surfaceVariant;
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
