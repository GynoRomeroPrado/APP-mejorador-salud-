import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/exercise.dart';
import '../data/models/exercise_filter.dart';
import '../data/repositories/exercise_repository.dart';

part 'exercises_provider.g.dart';

// Estado del filtro de ejercicios
@riverpod
class ExerciseFilterState extends _$ExerciseFilterState {
  @override
  ExerciseFilter build() {
    return const ExerciseFilter();
  }

  void setBodyPart(String? bodyPart) {
    state = state.copyWith(bodyPart: bodyPart);
  }

  void setEquipment(String? equipment) {
    state = state.copyWith(equipment: equipment);
  }

  void setTargetMuscle(String? target) {
    state = state.copyWith(targetMuscle: target);
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFavoritesOnly(bool value) {
    state = state.copyWith(favoritesOnly: value);
  }

  void setHomeOnly(bool value) {
    state = state.copyWith(homeOnly: value);
  }

  void clearFilters() {
    state = const ExerciseFilter();
  }
}

// Proveedor de lista de ejercicios
@riverpod
Future<List<Exercise>> exercises(ExercisesRef ref) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  final filter = ref.watch(exerciseFilterStateProvider);

  if (filter.hasActiveFilters) {
    return await repository.searchExercises(filter);
  }

  return await repository.getExercises();
}

// Proveedor de un ejercicio específico
@riverpod
Future<Exercise?> exercise(ExerciseRef ref, String id) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  return await repository.getExerciseById(id);
}

// Proveedor de ejercicios favoritos
@riverpod
Future<List<Exercise>> favoriteExercises(FavoriteExercisesRef ref) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  return await repository.getFavorites();
}

// Proveedor de listas de filtros
@riverpod
Future<List<String>> bodyPartList(BodyPartListRef ref) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  return await repository.getBodyPartList();
}

@riverpod
Future<List<String>> equipmentList(EquipmentListRef ref) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  return await repository.getEquipmentList();
}

@riverpod
Future<List<String>> targetMuscleList(TargetMuscleListRef ref) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  return await repository.getTargetList();
}

// Acciones de ejercicios
@riverpod
class ExerciseActions extends _$ExerciseActions {
  @override
  void build() {}

  Future<void> toggleFavorite(String exerciseId) async {
    final repository = await ref.read(exerciseRepositoryProvider.future);
    await repository.toggleFavorite(exerciseId);

    // Invalidar providers para refrescar UI
    ref.invalidate(exercisesProvider);
    ref.invalidate(favoriteExercisesProvider);
    ref.invalidate(exerciseProvider(exerciseId));
  }

  Future<void> refreshExercises() async {
    final repository = await ref.read(exerciseRepositoryProvider.future);
    await repository.getExercises(forceRefresh: true);

    // Invalidar providers
    ref.invalidate(exercisesProvider);
  }

  Future<void> clearCache() async {
    final repository = await ref.read(exerciseRepositoryProvider.future);
    await repository.clearCache();

    // Invalidar providers
    ref.invalidate(exercisesProvider);
    ref.invalidate(favoriteExercisesProvider);
  }
}

// Estadísticas de ejercicios
@riverpod
Future<Map<String, dynamic>> exerciseStats(ExerciseStatsRef ref) async {
  final repository = await ref.watch(exerciseRepositoryProvider.future);
  final exercises = await ref.watch(exercisesProvider.future);

  return {
    'total_exercises': exercises.length,
    'cached_count': repository.cachedExerciseCount,
    'favorites_count': repository.favoritesCount,
    'last_sync': repository.getLastSyncDate(),
    'by_body_part': _groupByBodyPart(exercises),
    'by_equipment': _groupByEquipment(exercises),
  };
}

Map<String, int> _groupByBodyPart(List<Exercise> exercises) {
  final Map<String, int> groups = {};

  for (final exercise in exercises) {
    final bodyPart = exercise.bodyPart;
    groups[bodyPart] = (groups[bodyPart] ?? 0) + 1;
  }

  return groups;
}

Map<String, int> _groupByEquipment(List<Exercise> exercises) {
  final Map<String, int> groups = {};

  for (final exercise in exercises) {
    final equipment = exercise.equipment;
    groups[equipment] = (groups[equipment] ?? 0) + 1;
  }

  return groups;
}
