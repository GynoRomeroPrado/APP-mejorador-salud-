import 'package:flutter/material.dart';
import '../../data/models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;
  final VoidCallback? onStart;
  final VoidCallback? onDelete;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
    this.onStart,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (workout.description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            workout.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Botón de menú
                  if (onDelete != null)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20),
                              SizedBox(width: 12),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Estadísticas
              Row(
                children: [
                  _StatChip(
                    icon: Icons.list_alt,
                    label: '${workout.exercises.length} ejercicios',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: '${workout.estimatedDuration} min',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.local_fire_department,
                    label: '~${workout.estimatedCalories} kcal',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Badge de dificultad
              Row(
                children: [
                  _DifficultyBadge(difficulty: workout.difficulty),
                  const Spacer(),

                  // Botón de iniciar
                  if (onStart != null)
                    FilledButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Iniciar'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final config = _getDifficultyConfig(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 14,
            color: config['color'],
          ),
          const SizedBox(width: 4),
          Text(
            config['label'] as String,
            style: theme.textTheme.labelSmall?.copyWith(
              color: config['color'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDifficultyConfig(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return {
          'label': 'Fácil',
          'icon': Icons.signal_cellular_alt_1_bar,
          'color': Colors.green,
        };
      case 'medium':
        return {
          'label': 'Intermedio',
          'icon': Icons.signal_cellular_alt_2_bar,
          'color': Colors.orange,
        };
      case 'hard':
        return {
          'label': 'Difícil',
          'icon': Icons.signal_cellular_alt,
          'color': Colors.red,
        };
      default:
        return {
          'label': difficulty,
          'icon': Icons.signal_cellular_alt_2_bar,
          'color': Colors.grey,
        };
    }
  }
}
