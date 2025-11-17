import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/exercises_provider.dart';
import '../widgets/exercise_instructions_list.dart';

class ExerciseDetailPage extends ConsumerWidget {
  final String exerciseId;

  const ExerciseDetailPage({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final exerciseAsync = ref.watch(exerciseProvider(exerciseId));
    final exerciseActions = ref.read(exerciseActionsProvider.notifier);

    return Scaffold(
      body: exerciseAsync.when(
        data: (exercise) {
          if (exercise == null) {
            return const Center(
              child: Text('Ejercicio no encontrado'),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar con imagen GIF
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    exercise.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        exercise.gifUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.fitness_center,
                              size: 100,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      exercise.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: exercise.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      exerciseActions.toggleFavorite(exerciseId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implementar compartir
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad próximamente'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips de información
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.fitness_center, size: 18),
                            label: Text(exercise.bodyPartSpanish),
                            backgroundColor:
                                theme.colorScheme.primaryContainer,
                          ),
                          Chip(
                            avatar: const Icon(Icons.sports_gymnastics, size: 18),
                            label: Text(exercise.targetSpanish),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          ),
                          Chip(
                            avatar: const Icon(Icons.construction, size: 18),
                            label: Text(exercise.equipmentSpanish),
                            backgroundColor:
                                theme.colorScheme.tertiaryContainer,
                          ),
                          Chip(
                            label: Text(exercise.estimatedDifficulty.toUpperCase()),
                            backgroundColor: _getDifficultyColor(
                              theme,
                              exercise.estimatedDifficulty,
                            ),
                          ),
                          if (exercise.canDoAtHome)
                            Chip(
                              avatar: const Icon(Icons.home, size: 18),
                              label: const Text('Para casa'),
                              backgroundColor: Colors.green.withOpacity(0.2),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tipo de ejercicio
                      _buildInfoRow(
                        theme,
                        'Tipo',
                        exercise.exerciseType == 'compound'
                            ? 'Compuesto'
                            : 'Aislamiento',
                        Icons.category,
                      ),

                      const SizedBox(height: 12),

                      // Músculos secundarios
                      if (exercise.secondaryMuscles.isNotEmpty) ...[
                        _buildInfoRow(
                          theme,
                          'Músculos secundarios',
                          exercise.secondaryMuscles.join(', '),
                          Icons.accessibility_new,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Calorías estimadas
                      _buildInfoRow(
                        theme,
                        'Calorías por minuto',
                        '~${exercise.estimatedCaloriesPerMinute.toStringAsFixed(1)} kcal',
                        Icons.local_fire_department,
                      ),

                      const SizedBox(height: 32),

                      // Instrucciones
                      Text(
                        'Instrucciones',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ExerciseInstructionsList(
                        instructions: exercise.instructions,
                      ),

                      const SizedBox(height: 32),

                      // Botón de agregar a rutina
                      FilledButton.icon(
                        onPressed: () {
                          // TODO: Agregar a rutina/workout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Agregar a rutina - Próximamente'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar a mi rutina'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Botón de comenzar ejercicio
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Iniciar timer/tracking de ejercicio
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comenzar ejercicio - Próximamente'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Comenzar ahora'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar ejercicio',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
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
