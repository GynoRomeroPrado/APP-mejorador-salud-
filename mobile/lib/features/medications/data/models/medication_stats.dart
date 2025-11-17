import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_stats.freezed.dart';
part 'medication_stats.g.dart';

/// Estadísticas de adherencia de medicamentos
@freezed
class MedicationStats with _$MedicationStats {
  const factory MedicationStats({
    required String userId,
    required int totalMedications,
    required int activeMedications,
    required int totalSchedules,
    required int schedulesToday,
    required double adherenceRate, // Porcentaje 0-100
    required int takenCount,
    required int missedCount,
    required int skippedCount,
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastTakenDate,
    required Map<String, int> adherenceByMedication,
    required List<MedicationAdherence> recentAdherence,
  }) = _MedicationStats;

  factory MedicationStats.fromJson(Map<String, dynamic> json) =>
      _$MedicationStatsFromJson(json);

  factory MedicationStats.empty() => MedicationStats(
        userId: '',
        totalMedications: 0,
        activeMedications: 0,
        totalSchedules: 0,
        schedulesToday: 0,
        adherenceRate: 0,
        takenCount: 0,
        missedCount: 0,
        skippedCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastTakenDate: null,
        adherenceByMedication: {},
        recentAdherence: [],
      );
}

/// Adherencia diaria
@freezed
class MedicationAdherence with _$MedicationAdherence {
  const factory MedicationAdherence({
    required DateTime date,
    required int scheduled,
    required int taken,
    required int missed,
    required int skipped,
    required double rate,
  }) = _MedicationAdherence;

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) =>
      _$MedicationAdherenceFromJson(json);
}

/// DTO para crear medicamento
@freezed
class CreateMedicationDto with _$CreateMedicationDto {
  const factory CreateMedicationDto({
    required String name,
    required String type,
    required String dosage,
    String? instructions,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? refillDate,
    int? refillQuantity,
    @Default(7) int refillReminderDays,
    @Default('#3B82F6') String colorHex,
    @Default('pill') String icon,
    String? notes,
    String? photoUrl,
    required List<CreateScheduleDto> schedules,
  }) = _CreateMedicationDto;

  factory CreateMedicationDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMedicationDtoFromJson(json);
}

/// DTO para crear horario
@freezed
class CreateScheduleDto with _$CreateScheduleDto {
  const factory CreateScheduleDto({
    required String time,
    required String frequency,
    int? intervalDays,
    List<int>? daysOfWeek,
    String? mealTiming,
    @Default(false) bool waterReminder,
    @Default(true) bool enabled,
    @Default('default') String notificationSound,
    @Default(10) int snoozeDurationMinutes,
  }) = _CreateScheduleDto;

  factory CreateScheduleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateScheduleDtoFromJson(json);
}

/// DTO para registrar toma de medicamento
@freezed
class LogMedicationDto with _$LogMedicationDto {
  const factory LogMedicationDto({
    required String medId,
    String? scheduleId,
    required DateTime scheduledTime,
    DateTime? takenTime,
    required String status,
    String? notes,
    String? photoUrl,
  }) = _LogMedicationDto;

  factory LogMedicationDto.fromJson(Map<String, dynamic> json) =>
      _$LogMedicationDtoFromJson(json);
}

/// Tipos de medicamentos
enum MedicationType {
  prescription('prescription', 'Receta médica', '💊'),
  supplement('supplement', 'Suplemento', '🌿'),
  vitamin('vitamin', 'Vitamina', '🍊'),
  protein('protein', 'Proteína', '💪'),
  other('other', 'Otro', '⚕️');

  const MedicationType(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;

  static MedicationType fromValue(String value) {
    return MedicationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MedicationType.other,
    );
  }
}

/// Iconos de medicamentos
enum MedicationIcon {
  pill('pill', '💊'),
  capsule('capsule', '💊'),
  liquid('liquid', '🧪'),
  powder('powder', '🥄'),
  injection('injection', '💉'),
  tablet('tablet', '⚪'),
  spray('spray', '🌊');

  const MedicationIcon(this.value, this.emoji);

  final String value;
  final String emoji;

  static MedicationIcon fromValue(String value) {
    return MedicationIcon.values.firstWhere(
      (icon) => icon.value == value,
      orElse: () => MedicationIcon.pill,
    );
  }
}

/// Frecuencia de medicamentos
enum MedicationFrequency {
  daily('daily', 'Diario'),
  weekly('weekly', 'Semanal'),
  everyXDays('every_x_days', 'Cada X días'),
  asNeeded('as_needed', 'Según sea necesario');

  const MedicationFrequency(this.value, this.label);

  final String value;
  final String label;

  static MedicationFrequency fromValue(String value) {
    return MedicationFrequency.values.firstWhere(
      (freq) => freq.value == value,
      orElse: () => MedicationFrequency.daily,
    );
  }
}

/// Momento de comida
enum MealTiming {
  beforeMeal('before_meal', 'Antes de comer', '🍽️'),
  withMeal('with_meal', 'Con comida', '🍽️'),
  afterMeal('after_meal', 'Después de comer', '🍽️'),
  emptyStomach('empty_stomach', 'Estómago vacío', '⏰'),
  anytime('anytime', 'Cualquier momento', '⏰');

  const MealTiming(this.value, this.label, this.emoji);

  final String value;
  final String label;
  final String emoji;

  static MealTiming fromValue(String? value) {
    if (value == null) return MealTiming.anytime;
    return MealTiming.values.firstWhere(
      (timing) => timing.value == value,
      orElse: () => MealTiming.anytime,
    );
  }
}

/// Estado de registro de medicamento
enum LogStatus {
  taken('taken', 'Tomado', '✅', '#10B981'),
  missed('missed', 'Olvidado', '❌', '#EF4444'),
  skipped('skipped', 'Omitido', '⏭️', '#F59E0B'),
  snoozed('snoozed', 'Pospuesto', '💤', '#6366F1');

  const LogStatus(this.value, this.label, this.emoji, this.color);

  final String value;
  final String label;
  final String emoji;
  final String color;

  static LogStatus fromValue(String value) {
    return LogStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => LogStatus.missed,
    );
  }
}
