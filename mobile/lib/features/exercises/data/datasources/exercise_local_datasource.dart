import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';

/// Datasource local para caché de ejercicios usando Hive
class ExerciseLocalDatasource {
  static const String _exercisesBoxName = 'exercises';
  static const String _favoritesBoxName = 'favorite_exercises';
  static const String _metadataBoxName = 'exercises_metadata';

  Box<Map>? _exercisesBox;
  Box<String>? _favoritesBox;
  Box<dynamic>? _metadataBox;

  /// Inicializa los boxes de Hive
  Future<void> init() async {
    await Hive.initFlutter();

    _exercisesBox = await Hive.openBox<Map>(_exercisesBoxName);
    _favoritesBox = await Hive.openBox<String>(_favoritesBoxName);
    _metadataBox = await Hive.openBox(_metadataBoxName);
  }

  /// Guarda ejercicios en caché
  Future<void> saveExercises(List<Exercise> exercises) async {
    final box = _exercisesBox;
    if (box == null) throw Exception('Hive no inicializado');

    // Limpiar caché anterior
    await box.clear();

    // Guardar nuevos ejercicios
    for (final exercise in exercises) {
      await box.put(exercise.id, exercise.toJson());
    }

    // Guardar timestamp de última actualización
    await _metadataBox?.put('last_sync', DateTime.now().toIso8601String());
  }

  /// Obtiene todos los ejercicios del caché
  Future<List<Exercise>> getAllExercises() async {
    final box = _exercisesBox;
    if (box == null) throw Exception('Hive no inicializado');

    final List<Exercise> exercises = [];

    for (final exerciseJson in box.values) {
      try {
        final exercise = Exercise.fromJson(Map<String, dynamic>.from(exerciseJson));

        // Verificar si es favorito
        final isFavorite = await isFavoriteExercise(exercise.id);

        exercises.add(exercise.copyWith(isFavorite: isFavorite));
      } catch (e) {
        print('Error al parsear ejercicio: $e');
      }
    }

    return exercises;
  }

  /// Obtiene un ejercicio por ID
  Future<Exercise?> getExerciseById(String id) async {
    final box = _exercisesBox;
    if (box == null) throw Exception('Hive no inicializado');

    final exerciseJson = box.get(id);
    if (exerciseJson == null) return null;

    final exercise = Exercise.fromJson(Map<String, dynamic>.from(exerciseJson));
    final isFavorite = await isFavoriteExercise(id);

    return exercise.copyWith(isFavorite: isFavorite);
  }

  /// Agrega un ejercicio a favoritos
  Future<void> addToFavorites(String exerciseId) async {
    final box = _favoritesBox;
    if (box == null) throw Exception('Hive no inicializado');

    if (!box.values.contains(exerciseId)) {
      await box.add(exerciseId);
    }
  }

  /// Remueve un ejercicio de favoritos
  Future<void> removeFromFavorites(String exerciseId) async {
    final box = _favoritesBox;
    if (box == null) throw Exception('Hive no inicializado');

    final key = box.keys.firstWhere(
      (k) => box.get(k) == exerciseId,
      orElse: () => null,
    );

    if (key != null) {
      await box.delete(key);
    }
  }

  /// Verifica si un ejercicio es favorito
  Future<bool> isFavoriteExercise(String exerciseId) async {
    final box = _favoritesBox;
    if (box == null) return false;

    return box.values.contains(exerciseId);
  }

  /// Obtiene todos los ejercicios favoritos
  Future<List<Exercise>> getFavoriteExercises() async {
    final favoritesBox = _favoritesBox;
    if (favoritesBox == null) throw Exception('Hive no inicializado');

    final List<Exercise> favorites = [];

    for (final exerciseId in favoritesBox.values) {
      final exercise = await getExerciseById(exerciseId);
      if (exercise != null) {
        favorites.add(exercise);
      }
    }

    return favorites;
  }

  /// Obtiene la fecha de última sincronización
  DateTime? getLastSyncDate() {
    final lastSyncStr = _metadataBox?.get('last_sync');
    if (lastSyncStr == null) return null;

    return DateTime.tryParse(lastSyncStr);
  }

  /// Verifica si el caché necesita actualización (más de 7 días)
  bool needsSync() {
    final lastSync = getLastSyncDate();
    if (lastSync == null) return true;

    final daysSinceSync = DateTime.now().difference(lastSync).inDays;
    return daysSinceSync > 7;
  }

  /// Cuenta total de ejercicios en caché
  int get exerciseCount => _exercisesBox?.length ?? 0;

  /// Cuenta total de favoritos
  int get favoritesCount => _favoritesBox?.length ?? 0;

  /// Limpia todo el caché
  Future<void> clearCache() async {
    await _exercisesBox?.clear();
    await _metadataBox?.clear();
  }

  /// Cierra los boxes
  Future<void> dispose() async {
    await _exercisesBox?.close();
    await _favoritesBox?.close();
    await _metadataBox?.close();
  }
}
