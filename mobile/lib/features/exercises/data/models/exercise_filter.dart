import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_filter.freezed.dart';

@freezed
class ExerciseFilter with _$ExerciseFilter {
  const factory ExerciseFilter({
    String? bodyPart,
    String? equipment,
    String? targetMuscle,
    String? searchQuery,
    @Default(false) bool favoritesOnly,
    @Default(false) bool homeOnly,
  }) = _ExerciseFilter;

  const ExerciseFilter._();

  /// Verifica si hay algún filtro activo
  bool get hasActiveFilters {
    return bodyPart != null ||
        equipment != null ||
        targetMuscle != null ||
        (searchQuery != null && searchQuery!.isNotEmpty) ||
        favoritesOnly ||
        homeOnly;
  }

  /// Limpia todos los filtros
  ExerciseFilter clearAll() {
    return const ExerciseFilter();
  }

  /// Cuenta cuántos filtros están activos
  int get activeFilterCount {
    int count = 0;
    if (bodyPart != null) count++;
    if (equipment != null) count++;
    if (targetMuscle != null) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (favoritesOnly) count++;
    if (homeOnly) count++;
    return count;
  }
}
