import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/exercises_provider.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_filter_chip.dart';
import '../widgets/exercise_filter_bottom_sheet.dart';

class ExercisesListPage extends ConsumerStatefulWidget {
  const ExercisesListPage({super.key});

  @override
  ConsumerState<ExercisesListPage> createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends ConsumerState<ExercisesListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ExerciseFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercisesAsync = ref.watch(exercisesProvider);
    final filter = ref.watch(exerciseFilterStateProvider);
    final exerciseActions = ref.read(exerciseActionsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios'),
        actions: [
          // Botón de favoritos
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Navegar a página de favoritos
              context.push('/exercises/favorites');
            },
          ),
          // Botón de filtros
          IconButton(
            icon: Badge(
              label: Text('${filter.activeFilterCount}'),
              isLabelVisible: filter.hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ejercicios...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(exerciseFilterStateProvider.notifier)
                              .setSearchQuery(null);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              onChanged: (value) {
                ref
                    .read(exerciseFilterStateProvider.notifier)
                    .setSearchQuery(value.isEmpty ? null : value);
              },
            ),
          ),

          // Chips de filtros activos
          if (filter.hasActiveFilters)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (filter.bodyPart != null)
                    ExerciseFilterChip(
                      label: filter.bodyPart!,
                      onDeleted: () {
                        ref
                            .read(exerciseFilterStateProvider.notifier)
                            .setBodyPart(null);
                      },
                    ),
                  if (filter.equipment != null)
                    ExerciseFilterChip(
                      label: filter.equipment!,
                      onDeleted: () {
                        ref
                            .read(exerciseFilterStateProvider.notifier)
                            .setEquipment(null);
                      },
                    ),
                  if (filter.targetMuscle != null)
                    ExerciseFilterChip(
                      label: filter.targetMuscle!,
                      onDeleted: () {
                        ref
                            .read(exerciseFilterStateProvider.notifier)
                            .setTargetMuscle(null);
                      },
                    ),
                  if (filter.favoritesOnly)
                    ExerciseFilterChip(
                      label: 'Favoritos',
                      onDeleted: () {
                        ref
                            .read(exerciseFilterStateProvider.notifier)
                            .setFavoritesOnly(false);
                      },
                    ),
                  if (filter.homeOnly)
                    ExerciseFilterChip(
                      label: 'Para casa',
                      onDeleted: () {
                        ref
                            .read(exerciseFilterStateProvider.notifier)
                            .setHomeOnly(false);
                      },
                    ),
                  // Botón limpiar todos
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(exerciseFilterStateProvider.notifier)
                          .clearFilters();
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpiar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Lista de ejercicios
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center_outlined,
                          size: 64,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron ejercicios',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (filter.hasActiveFilters)
                          TextButton.icon(
                            onPressed: () {
                              ref
                                  .read(exerciseFilterStateProvider.notifier)
                                  .clearFilters();
                              _searchController.clear();
                            },
                            icon: const Icon(Icons.filter_list_off),
                            label: const Text('Limpiar filtros'),
                          )
                        else
                          TextButton.icon(
                            onPressed: () {
                              exerciseActions.refreshExercises();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Actualizar ejercicios'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await exerciseActions.refreshExercises();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ExerciseCard(
                        exercise: exercise,
                        onTap: () {
                          context.push('/exercises/${exercise.id}');
                        },
                        onFavoriteTap: () {
                          exerciseActions.toggleFavorite(exercise.id);
                        },
                      );
                    },
                  ),
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
                      'Error al cargar ejercicios',
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
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(exercisesProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
