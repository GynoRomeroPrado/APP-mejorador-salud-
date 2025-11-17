import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../datasources/exercisedb_api.dart';
import '../datasources/exercise_local_datasource.dart';
import '../models/exercise.dart';
import '../models/exercise_filter.dart';

part 'exercise_repository.g.dart';

class ExerciseRepository {
  final ExerciseDBApi _api;
  final ExerciseLocalDatasource _localDatasource;

  ExerciseRepository({
    required ExerciseDBApi api,
    required ExerciseLocalDatasource localDatasource,
  })  : _api = api,
        _localDatasource = localDatasource;

  /// Obtiene ejercicios (primero del caché, luego de la API si es necesario)
  Future<List<Exercise>> getExercises({
    bool forceRefresh = false,
  }) async {
    // Si hay caché y no se fuerza refresh, usar caché
    if (!forceRefresh &&
        !_localDatasource.needsSync() &&
        _localDatasource.exerciseCount > 0) {
      return await _localDatasource.getAllExercises();
    }

    // Obtener de la API
    final exercises = await _api.getAllExercises();

    // Guardar en caché
    await _localDatasource.saveExercises(exercises);

    return exercises;
  }

  /// Busca ejercicios con filtros
  Future<List<Exercise>> searchExercises(ExerciseFilter filter) async {
    List<Exercise> exercises;

    // Si hay bodyPart específico, usar endpoint optimizado
    if (filter.bodyPart != null) {
      exercises = await _api.getExercisesByBodyPart(filter.bodyPart!);
    }
    // Si hay equipment específico, usar endpoint optimizado
    else if (filter.equipment != null) {
      exercises = await _api.getExercisesByEquipment(filter.equipment!);
    }
    // Si hay target específico, usar endpoint optimizado
    else if (filter.targetMuscle != null) {
      exercises = await _api.getExercisesByTarget(filter.targetMuscle!);
    }
    // Si hay búsqueda por nombre
    else if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      exercises = await _api.searchExercisesByName(filter.searchQuery!);
    }
    // Caso default: obtener todos del caché
    else {
      exercises = await _localDatasource.getAllExercises();
    }

    // Aplicar filtros adicionales
    return _applyFilters(exercises, filter);
  }

  /// Aplica filtros locales a la lista de ejercicios
  List<Exercise> _applyFilters(List<Exercise> exercises, ExerciseFilter filter) {
    var filtered = exercises;

    // Filtrar por búsqueda
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      filtered = filtered.where((exercise) {
        return exercise.name.toLowerCase().contains(query) ||
            exercise.bodyPart.toLowerCase().contains(query) ||
            exercise.target.toLowerCase().contains(query) ||
            exercise.equipment.toLowerCase().contains(query);
      }).toList();
    }

    // Filtrar por bodyPart
    if (filter.bodyPart != null) {
      filtered = filtered
          .where((e) => e.bodyPart.toLowerCase() == filter.bodyPart!.toLowerCase())
          .toList();
    }

    // Filtrar por equipment
    if (filter.equipment != null) {
      filtered = filtered
          .where((e) => e.equipment.toLowerCase() == filter.equipment!.toLowerCase())
          .toList();
    }

    // Filtrar por target
    if (filter.targetMuscle != null) {
      filtered = filtered
          .where((e) => e.target.toLowerCase() == filter.targetMuscle!.toLowerCase())
          .toList();
    }

    // Filtrar solo favoritos
    if (filter.favoritesOnly) {
      filtered = filtered.where((e) => e.isFavorite).toList();
    }

    // Filtrar solo ejercicios para casa
    if (filter.homeOnly) {
      filtered = filtered.where((e) => e.canDoAtHome).toList();
    }

    return filtered;
  }

  /// Obtiene un ejercicio por ID
  Future<Exercise?> getExerciseById(String id) async {
    // Intentar del caché primero
    final cachedExercise = await _localDatasource.getExerciseById(id);
    if (cachedExercise != null) return cachedExercise;

    // Si no está en caché, obtener de API
    try {
      return await _api.getExerciseById(id);
    } catch (e) {
      return null;
    }
  }

  /// Agrega/remueve ejercicio de favoritos
  Future<void> toggleFavorite(String exerciseId) async {
    final isFavorite = await _localDatasource.isFavoriteExercise(exerciseId);

    if (isFavorite) {
      await _localDatasource.removeFromFavorites(exerciseId);
    } else {
      await _localDatasource.addToFavorites(exerciseId);
    }
  }

  /// Obtiene ejercicios favoritos
  Future<List<Exercise>> getFavorites() async {
    return await _localDatasource.getFavoriteExercises();
  }

  /// Obtiene listas de filtros disponibles
  Future<List<String>> getBodyPartList() async {
    return await _api.getBodyPartList();
  }

  Future<List<String>> getEquipmentList() async {
    return await _api.getEquipmentList();
  }

  Future<List<String>> getTargetList() async {
    return await _api.getTargetList();
  }

  /// Información de caché
  DateTime? getLastSyncDate() => _localDatasource.getLastSyncDate();

  int get cachedExerciseCount => _localDatasource.exerciseCount;

  int get favoritesCount => _localDatasource.favoritesCount;

  /// Limpia el caché
  Future<void> clearCache() async {
    await _localDatasource.clearCache();
  }
}

// Providers

@riverpod
ExerciseDBApi exerciseDbApi(ExerciseDbApiRef ref) {
  // TODO: Obtener API key desde configuración/env
  const apiKey = 'YOUR_EXERCISEDB_API_KEY_HERE';
  return ExerciseDBApi(apiKey: apiKey);
}

@riverpod
Future<ExerciseLocalDatasource> exerciseLocalDatasource(
  ExerciseLocalDatasourceRef ref,
) async {
  final datasource = ExerciseLocalDatasource();
  await datasource.init();
  return datasource;
}

@riverpod
Future<ExerciseRepository> exerciseRepository(ExerciseRepositoryRef ref) async {
  final api = ref.watch(exerciseDbApiProvider);
  final localDatasource = await ref.watch(exerciseLocalDatasourceProvider.future);

  return ExerciseRepository(
    api: api,
    localDatasource: localDatasource,
  );
}
