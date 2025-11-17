import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../../../shared/services/notification_service.dart';
import '../datasources/medication_datasource.dart';
import '../models/medication.dart';
import '../models/medication_stats.dart';

/// Repositorio de medicamentos
class MedicationRepository {
  final MedicationDataSource _dataSource;

  MedicationRepository(this._dataSource);

  // ============================================
  // MEDICAMENTOS
  // ============================================

  /// Obtiene todos los medicamentos
  Future<List<Medication>> getMedications(String userId) async {
    return _dataSource.getMedications(userId);
  }

  /// Obtiene medicamentos activos
  Future<List<Medication>> getActiveMedications(String userId) async {
    return _dataSource.getActiveMedications(userId);
  }

  /// Obtiene un medicamento por ID
  Future<Medication?> getMedicationById(String medId) async {
    return _dataSource.getMedicationById(medId);
  }

  /// Crea un nuevo medicamento
  Future<Medication> createMedication(
    String userId,
    CreateMedicationDto dto,
  ) async {
    final medication = await _dataSource.createMedication(userId, dto);

    // Programar notificaciones
    await _scheduleNotifications(medication);

    return medication;
  }

  /// Actualiza un medicamento
  Future<Medication> updateMedication(
    String medId,
    CreateMedicationDto dto,
  ) async {
    // Cancelar notificaciones anteriores
    await NotificationService.cancelNotification(medId.hashCode);

    final medication = await _dataSource.updateMedication(medId, dto);

    // Reprogramar notificaciones
    await _scheduleNotifications(medication);

    return medication;
  }

  /// Elimina un medicamento
  Future<void> deleteMedication(String medId) async {
    // Cancelar notificaciones
    await NotificationService.cancelNotification(medId.hashCode);

    await _dataSource.deleteMedication(medId);
  }

  /// Programa todas las notificaciones de un medicamento
  Future<void> _scheduleNotifications(Medication medication) async {
    for (final schedule in medication.activeSchedules) {
      await NotificationService.scheduleRecurringMedicationReminder(
        medicationId: medication.medId,
        medicationName: medication.name,
        dosage: medication.dosage,
        time: schedule.timeOfDay,
        mealTiming: schedule.mealTiming,
        repeatInterval: _getRepeatInterval(schedule.frequency),
        daysOfWeek: schedule.daysOfWeek,
      );
    }

    // Programar recordatorio de recarga
    if (medication.refillDate != null) {
      await NotificationService.scheduleRefillReminder(
        medicationName: medication.name,
        refillDate: medication.refillDate!,
        daysBeforeReminder: medication.refillReminderDays,
      );
    }
  }

  /// Convierte frecuencia a RepeatInterval
  RepeatInterval _getRepeatInterval(String frequency) {
    switch (frequency) {
      case 'daily':
        return RepeatInterval.daily;
      case 'weekly':
        return RepeatInterval.weekly;
      default:
        return RepeatInterval.custom;
    }
  }

  /// Reprograma todas las notificaciones del usuario
  Future<void> rescheduleAllNotifications(String userId) async {
    final medications = await getActiveMedications(userId);

    // Cancelar todas las notificaciones
    await NotificationService.cancelAllNotifications();

    // Reprogramar
    for (final medication in medications) {
      await _scheduleNotifications(medication);
    }
  }

  // ============================================
  // REGISTROS (LOGS)
  // ============================================

  /// Obtiene registros
  Future<List<MedicationLog>> getLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? medId,
  }) async {
    return _dataSource.getLogs(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      medId: medId,
    );
  }

  /// Obtiene registros de hoy
  Future<List<MedicationLog>> getTodayLogs(String userId) async {
    return _dataSource.getTodayLogs(userId);
  }

  /// Registra medicamento como tomado
  Future<MedicationLog> logTaken({
    required String medId,
    String? scheduleId,
    required DateTime scheduledTime,
    String? notes,
    String? photoUrl,
  }) async {
    return _dataSource.createLog(
      LogMedicationDto(
        medId: medId,
        scheduleId: scheduleId,
        scheduledTime: scheduledTime,
        takenTime: DateTime.now(),
        status: 'taken',
        notes: notes,
        photoUrl: photoUrl,
      ),
    );
  }

  /// Registra medicamento como omitido
  Future<MedicationLog> logSkipped({
    required String medId,
    String? scheduleId,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    return _dataSource.createLog(
      LogMedicationDto(
        medId: medId,
        scheduleId: scheduleId,
        scheduledTime: scheduledTime,
        status: 'skipped',
        notes: notes,
      ),
    );
  }

  /// Registra medicamento como olvidado
  Future<MedicationLog> logMissed({
    required String medId,
    String? scheduleId,
    required DateTime scheduledTime,
  }) async {
    return _dataSource.createLog(
      LogMedicationDto(
        medId: medId,
        scheduleId: scheduleId,
        scheduledTime: scheduledTime,
        status: 'missed',
      ),
    );
  }

  /// Pospone un medicamento
  Future<void> snoozeMedication({
    required String medId,
    required int minutes,
  }) async {
    await NotificationService.snoozeReminder(medId.hashCode, minutes);
  }

  // ============================================
  // ESTADÍSTICAS
  // ============================================

  /// Obtiene estadísticas de adherencia
  Future<MedicationStats> getStats(String userId, {int days = 30}) async {
    return _dataSource.getStats(userId, days: days);
  }

  /// Calcula la adherencia de hoy
  Future<double> getTodayAdherence(String userId) async {
    final logs = await getTodayLogs(userId);

    if (logs.isEmpty) return 0;

    final taken = logs.where((l) => l.status == 'taken').length;
    return (taken / logs.length * 100).clamp(0, 100);
  }

  // ============================================
  // INTERACCIONES
  // ============================================

  /// Verifica interacciones entre medicamentos del usuario
  Future<List<DrugInteraction>> checkUserInteractions(String userId) async {
    final medications = await getActiveMedications(userId);
    final medicationNames = medications.map((m) => m.name).toList();

    return _dataSource.checkInteractions(medicationNames);
  }

  /// Verifica interacciones al agregar un nuevo medicamento
  Future<List<DrugInteraction>> checkInteractionsForNew({
    required String userId,
    required String newMedicationName,
  }) async {
    final medications = await getActiveMedications(userId);
    final medicationNames = [
      ...medications.map((m) => m.name),
      newMedicationName,
    ];

    return _dataSource.checkInteractions(medicationNames);
  }

  // ============================================
  // STREAMING
  // ============================================

  /// Stream de medicamentos
  Stream<List<Medication>> watchMedications(String userId) {
    return _dataSource.watchMedications(userId);
  }

  /// Stream de logs de hoy
  Stream<List<MedicationLog>> watchTodayLogs(String userId) {
    return _dataSource.watchTodayLogs(userId);
  }
}

// ============================================
// PROVIDERS
// ============================================

/// Provider del datasource
final medicationDataSourceProvider = Provider<MedicationDataSource>((ref) {
  return MedicationDataSource(SupabaseService.client);
});

/// Provider del repositorio
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final dataSource = ref.watch(medicationDataSourceProvider);
  return MedicationRepository(dataSource);
});

/// Provider de medicamentos del usuario
final medicationsProvider = StreamProvider.family<List<Medication>, String>(
  (ref, userId) {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.watchMedications(userId);
  },
);

/// Provider de medicamentos activos
final activeMedicationsProvider = FutureProvider.family<List<Medication>, String>(
  (ref, userId) async {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.getActiveMedications(userId);
  },
);

/// Provider de logs de hoy
final todayLogsProvider = StreamProvider.family<List<MedicationLog>, String>(
  (ref, userId) {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.watchTodayLogs(userId);
  },
);

/// Provider de estadísticas
final medicationStatsProvider = FutureProvider.family<MedicationStats, String>(
  (ref, userId) async {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.getStats(userId);
  },
);

/// Provider de adherencia de hoy
final todayAdherenceProvider = FutureProvider.family<double, String>(
  (ref, userId) async {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.getTodayAdherence(userId);
  },
);

/// Provider de interacciones
final drugInteractionsProvider = FutureProvider.family<List<DrugInteraction>, String>(
  (ref, userId) async {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.checkUserInteractions(userId);
  },
);

/// Provider de medicamento específico
final medicationByIdProvider = FutureProvider.family<Medication?, String>(
  (ref, medId) async {
    final repository = ref.watch(medicationRepositoryProvider);
    return repository.getMedicationById(medId);
  },
);
