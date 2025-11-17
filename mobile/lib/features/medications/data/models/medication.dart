import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication.freezed.dart';
part 'medication.g.dart';

/// Modelo de medicamento/suplemento
@freezed
class Medication with _$Medication {
  const factory Medication({
    required String medId,
    required String userId,
    required String name,
    required String type, // 'prescription', 'supplement', 'vitamin', 'protein', 'other'
    required String dosage, // '500mg', '2 scoops', '1 tablet'
    String? instructions,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? refillDate,
    int? refillQuantity,
    @Default(7) int refillReminderDays,
    @Default('#3B82F6') String colorHex,
    @Default('pill') String icon, // 'pill', 'capsule', 'liquid', 'powder', 'injection'
    String? notes,
    String? photoUrl,
    required List<MedicationSchedule> schedules,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}

/// Horario de medicamento
@freezed
class MedicationSchedule with _$MedicationSchedule {
  const factory MedicationSchedule({
    required String scheduleId,
    required String medId,
    required String time, // Format: 'HH:mm' (24h)
    required String frequency, // 'daily', 'weekly', 'every_x_days', 'as_needed'
    int? intervalDays, // Para 'every_x_days'
    List<int>? daysOfWeek, // [1,2,3,4,5] = Lun-Vie, null = todos los días
    String? mealTiming, // 'before_meal', 'with_meal', 'after_meal', 'empty_stomach', 'anytime'
    @Default(false) bool waterReminder,
    @Default(true) bool enabled,
    @Default('default') String notificationSound,
    @Default(10) int snoozeDurationMinutes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MedicationSchedule;

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicationScheduleFromJson(json);
}

/// Registro de toma de medicamento
@freezed
class MedicationLog with _$MedicationLog {
  const factory MedicationLog({
    required String logId,
    required String medId,
    String? scheduleId,
    required DateTime scheduledTime,
    DateTime? takenTime,
    required String status, // 'taken', 'missed', 'skipped', 'snoozed'
    @Default(0) int snoozeCount,
    String? notes,
    String? photoUrl,
    required DateTime createdAt,
  }) = _MedicationLog;

  factory MedicationLog.fromJson(Map<String, dynamic> json) =>
      _$MedicationLogFromJson(json);
}

/// Interacción de medicamentos
@freezed
class DrugInteraction with _$DrugInteraction {
  const factory DrugInteraction({
    required String interactionId,
    required String drugA,
    required String drugB,
    required String severity, // 'major', 'moderate', 'minor'
    required String description,
    String? source,
    String? sourceUrl,
    required DateTime createdAt,
  }) = _DrugInteraction;

  factory DrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionFromJson(json);
}

/// Extensiones útiles
extension MedicationExtensions on Medication {
  /// Verifica si el medicamento está activo
  bool get isActive {
    final now = DateTime.now();
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }
    return true;
  }

  /// Obtiene los horarios habilitados
  List<MedicationSchedule> get activeSchedules {
    return schedules.where((s) => s.enabled).toList();
  }

  /// Verifica si necesita recarga pronto
  bool get needsRefillSoon {
    if (refillDate == null) return false;
    final now = DateTime.now();
    final daysUntilRefill = refillDate!.difference(now).inDays;
    return daysUntilRefill <= refillReminderDays && daysUntilRefill >= 0;
  }

  /// Días hasta la recarga
  int get daysUntilRefill {
    if (refillDate == null) return -1;
    return refillDate!.difference(DateTime.now()).inDays;
  }
}

extension MedicationScheduleExtensions on MedicationSchedule {
  /// Convierte el string de tiempo a TimeOfDay
  TimeOfDay get timeOfDay {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  /// Verifica si el horario aplica para hoy
  bool get appliesToday {
    if (frequency == 'as_needed') return false;
    if (frequency == 'daily') return true;

    if (frequency == 'weekly' && daysOfWeek != null) {
      final today = DateTime.now().weekday;
      return daysOfWeek!.contains(today);
    }

    return true;
  }

  /// Obtiene el nombre legible de la frecuencia
  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return 'Diario';
      case 'weekly':
        return 'Semanal';
      case 'every_x_days':
        return 'Cada $intervalDays días';
      case 'as_needed':
        return 'Según sea necesario';
      default:
        return frequency;
    }
  }

  /// Obtiene el label del momento de comida
  String get mealTimingLabel {
    switch (mealTiming) {
      case 'before_meal':
        return '🍽️ Antes de comer';
      case 'with_meal':
        return '🍽️ Con comida';
      case 'after_meal':
        return '🍽️ Después de comer';
      case 'empty_stomach':
        return '⏰ Estómago vacío';
      case 'anytime':
        return '⏰ Cualquier momento';
      default:
        return '';
    }
  }
}

extension MedicationLogExtensions on MedicationLog {
  /// Verifica si fue tomado a tiempo
  bool get takenOnTime {
    if (status != 'taken' || takenTime == null) return false;
    final difference = takenTime!.difference(scheduledTime).abs();
    return difference.inMinutes <= 30; // Tolerancia de 30 minutos
  }

  /// Obtiene el color según el estado
  String get statusColor {
    switch (status) {
      case 'taken':
        return '#10B981'; // Verde
      case 'missed':
        return '#EF4444'; // Rojo
      case 'skipped':
        return '#F59E0B'; // Naranja
      case 'snoozed':
        return '#6366F1'; // Azul
      default:
        return '#6B7280'; // Gris
    }
  }

  /// Obtiene el emoji según el estado
  String get statusEmoji {
    switch (status) {
      case 'taken':
        return '✅';
      case 'missed':
        return '❌';
      case 'skipped':
        return '⏭️';
      case 'snoozed':
        return '💤';
      default:
        return '⚪';
    }
  }

  /// Obtiene el label del estado
  String get statusLabel {
    switch (status) {
      case 'taken':
        return 'Tomado';
      case 'missed':
        return 'Olvidado';
      case 'skipped':
        return 'Omitido';
      case 'snoozed':
        return 'Pospuesto';
      default:
        return status;
    }
  }
}

/// Clase auxiliar para TimeOfDay
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String toDisplayString() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
