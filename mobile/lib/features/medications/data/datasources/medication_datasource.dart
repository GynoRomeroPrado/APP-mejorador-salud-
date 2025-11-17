import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/medication.dart';
import '../models/medication_stats.dart';

/// Fuente de datos para medicamentos usando Supabase
class MedicationDataSource {
  final SupabaseClient _supabase;

  MedicationDataSource(this._supabase);

  // ============================================
  // MEDICAMENTOS
  // ============================================

  /// Obtiene todos los medicamentos del usuario
  Future<List<Medication>> getMedications(String userId) async {
    final response = await _supabase
        .from('medications')
        .select('''
          *,
          schedules:medication_schedules(*)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Medication.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene medicamentos activos
  Future<List<Medication>> getActiveMedications(String userId) async {
    final now = DateTime.now().toIso8601String();

    final response = await _supabase
        .from('medications')
        .select('''
          *,
          schedules:medication_schedules(*)
        ''')
        .eq('user_id', userId)
        .or('end_date.is.null,end_date.gte.$now')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Medication.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene un medicamento por ID
  Future<Medication?> getMedicationById(String medId) async {
    final response = await _supabase
        .from('medications')
        .select('''
          *,
          schedules:medication_schedules(*)
        ''')
        .eq('med_id', medId)
        .maybeSingle();

    if (response == null) return null;
    return Medication.fromJson(response);
  }

  /// Crea un nuevo medicamento
  Future<Medication> createMedication(
    String userId,
    CreateMedicationDto dto,
  ) async {
    // Insertar medicamento
    final medResponse = await _supabase
        .from('medications')
        .insert({
          'user_id': userId,
          'name': dto.name,
          'type': dto.type,
          'dosage': dto.dosage,
          'instructions': dto.instructions,
          'start_date': dto.startDate.toIso8601String(),
          'end_date': dto.endDate?.toIso8601String(),
          'refill_date': dto.refillDate?.toIso8601String(),
          'refill_quantity': dto.refillQuantity,
          'refill_reminder_days': dto.refillReminderDays,
          'color_hex': dto.colorHex,
          'icon': dto.icon,
          'notes': dto.notes,
          'photo_url': dto.photoUrl,
        })
        .select()
        .single();

    final medId = medResponse['med_id'] as String;

    // Insertar horarios
    if (dto.schedules.isNotEmpty) {
      final schedules = dto.schedules.map((schedule) => {
            'med_id': medId,
            'time': schedule.time,
            'frequency': schedule.frequency,
            'interval_days': schedule.intervalDays,
            'days_of_week': schedule.daysOfWeek,
            'meal_timing': schedule.mealTiming,
            'water_reminder': schedule.waterReminder,
            'enabled': schedule.enabled,
            'notification_sound': schedule.notificationSound,
            'snooze_duration_minutes': schedule.snoozeDurationMinutes,
          }).toList();

      await _supabase.from('medication_schedules').insert(schedules);
    }

    // Obtener medicamento completo
    return getMedicationById(medId).then((med) => med!);
  }

  /// Actualiza un medicamento
  Future<Medication> updateMedication(
    String medId,
    CreateMedicationDto dto,
  ) async {
    // Actualizar medicamento
    await _supabase
        .from('medications')
        .update({
          'name': dto.name,
          'type': dto.type,
          'dosage': dto.dosage,
          'instructions': dto.instructions,
          'start_date': dto.startDate.toIso8601String(),
          'end_date': dto.endDate?.toIso8601String(),
          'refill_date': dto.refillDate?.toIso8601String(),
          'refill_quantity': dto.refillQuantity,
          'refill_reminder_days': dto.refillReminderDays,
          'color_hex': dto.colorHex,
          'icon': dto.icon,
          'notes': dto.notes,
          'photo_url': dto.photoUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('med_id', medId);

    // Eliminar horarios existentes
    await _supabase
        .from('medication_schedules')
        .delete()
        .eq('med_id', medId);

    // Insertar nuevos horarios
    if (dto.schedules.isNotEmpty) {
      final schedules = dto.schedules.map((schedule) => {
            'med_id': medId,
            'time': schedule.time,
            'frequency': schedule.frequency,
            'interval_days': schedule.intervalDays,
            'days_of_week': schedule.daysOfWeek,
            'meal_timing': schedule.mealTiming,
            'water_reminder': schedule.waterReminder,
            'enabled': schedule.enabled,
            'notification_sound': schedule.notificationSound,
            'snooze_duration_minutes': schedule.snoozeDurationMinutes,
          }).toList();

      await _supabase.from('medication_schedules').insert(schedules);
    }

    return getMedicationById(medId).then((med) => med!);
  }

  /// Elimina un medicamento
  Future<void> deleteMedication(String medId) async {
    await _supabase.from('medications').delete().eq('med_id', medId);
  }

  // ============================================
  // REGISTROS (LOGS)
  // ============================================

  /// Obtiene registros de medicamentos
  Future<List<MedicationLog>> getLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? medId,
  }) async {
    var query = _supabase
        .from('medication_logs')
        .select('''
          *,
          medication:medications!inner(user_id)
        ''')
        .eq('medication.user_id', userId)
        .order('scheduled_time', ascending: false);

    if (startDate != null) {
      query = query.gte('scheduled_time', startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.lte('scheduled_time', endDate.toIso8601String());
    }

    if (medId != null) {
      query = query.eq('med_id', medId);
    }

    final response = await query;

    return (response as List)
        .map((json) => MedicationLog.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene registros de hoy
  Future<List<MedicationLog>> getTodayLogs(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getLogs(
      userId: userId,
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Crea un registro de medicamento
  Future<MedicationLog> createLog(LogMedicationDto dto) async {
    final response = await _supabase
        .from('medication_logs')
        .insert({
          'med_id': dto.medId,
          'schedule_id': dto.scheduleId,
          'scheduled_time': dto.scheduledTime.toIso8601String(),
          'taken_time': dto.takenTime?.toIso8601String(),
          'status': dto.status,
          'notes': dto.notes,
          'photo_url': dto.photoUrl,
        })
        .select()
        .single();

    return MedicationLog.fromJson(response);
  }

  /// Actualiza un registro
  Future<MedicationLog> updateLog(
    String logId,
    LogMedicationDto dto,
  ) async {
    final response = await _supabase
        .from('medication_logs')
        .update({
          'taken_time': dto.takenTime?.toIso8601String(),
          'status': dto.status,
          'notes': dto.notes,
          'photo_url': dto.photoUrl,
        })
        .eq('log_id', logId)
        .select()
        .single();

    return MedicationLog.fromJson(response);
  }

  // ============================================
  // ESTADÍSTICAS
  // ============================================

  /// Obtiene estadísticas de adherencia
  Future<MedicationStats> getStats(String userId, {int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    // Total de medicamentos
    final medsCount = await _supabase
        .from('medications')
        .select('med_id', const FetchOptions(count: CountOption.exact))
        .eq('user_id', userId);

    // Medicamentos activos
    final activeMedsCount = await _supabase
        .from('medications')
        .select('med_id', const FetchOptions(count: CountOption.exact))
        .eq('user_id', userId)
        .or('end_date.is.null,end_date.gte.${DateTime.now().toIso8601String()}');

    // Logs
    final logs = await getLogs(
      userId: userId,
      startDate: startDate,
    );

    final takenCount = logs.where((l) => l.status == 'taken').length;
    final missedCount = logs.where((l) => l.status == 'missed').length;
    final skippedCount = logs.where((l) => l.status == 'skipped').length;
    final totalLogs = logs.length;

    final adherenceRate = totalLogs > 0
        ? (takenCount / totalLogs * 100).clamp(0, 100)
        : 0.0;

    // Calcular racha actual
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    final logsByDate = <DateTime, List<MedicationLog>>{};
    for (final log in logs) {
      final date = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
      );
      logsByDate.putIfAbsent(date, () => []).add(log);
    }

    final sortedDates = logsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    for (int i = 0; i < sortedDates.length; i++) {
      final date = sortedDates[i];
      final dayLogs = logsByDate[date]!;
      final dayTaken = dayLogs.where((l) => l.status == 'taken').length;
      final dayTotal = dayLogs.length;

      if (dayTaken == dayTotal && dayTotal > 0) {
        tempStreak++;
        if (i == 0) currentStreak = tempStreak;
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
      } else {
        tempStreak = 0;
      }
    }

    return MedicationStats(
      userId: userId,
      totalMedications: medsCount.count ?? 0,
      activeMedications: activeMedsCount.count ?? 0,
      totalSchedules: 0, // Calcular según necesidad
      schedulesToday: 0,
      adherenceRate: adherenceRate,
      takenCount: takenCount,
      missedCount: missedCount,
      skippedCount: skippedCount,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastTakenDate: logs
          .where((l) => l.status == 'taken')
          .map((l) => l.takenTime)
          .whereType<DateTime>()
          .fold<DateTime?>(null, (prev, date) =>
              prev == null || date.isAfter(prev) ? date : prev),
      adherenceByMedication: {},
      recentAdherence: [],
    );
  }

  // ============================================
  // INTERACCIONES DE MEDICAMENTOS
  // ============================================

  /// Verifica interacciones entre medicamentos
  Future<List<DrugInteraction>> checkInteractions(
    List<String> medicationNames,
  ) async {
    if (medicationNames.length < 2) return [];

    final interactions = <DrugInteraction>[];

    // Verificar todas las combinaciones
    for (int i = 0; i < medicationNames.length; i++) {
      for (int j = i + 1; j < medicationNames.length; j++) {
        final drugA = medicationNames[i].toLowerCase();
        final drugB = medicationNames[j].toLowerCase();

        final response = await _supabase
            .from('drug_interactions')
            .select()
            .or('and(drug_a.eq.$drugA,drug_b.eq.$drugB),and(drug_a.eq.$drugB,drug_b.eq.$drugA)');

        if (response.isNotEmpty) {
          for (final json in response) {
            interactions.add(DrugInteraction.fromJson(json));
          }
        }
      }
    }

    return interactions;
  }

  // ============================================
  // STREAMING / REAL-TIME
  // ============================================

  /// Stream de medicamentos
  Stream<List<Medication>> watchMedications(String userId) {
    return _supabase
        .from('medications')
        .stream(primaryKey: ['med_id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data
            .map((json) => Medication.fromJson(json))
            .toList());
  }

  /// Stream de logs de hoy
  Stream<List<MedicationLog>> watchTodayLogs(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _supabase
        .from('medication_logs')
        .stream(primaryKey: ['log_id'])
        .order('scheduled_time', ascending: true)
        .asyncMap((data) async {
          // Filtrar solo logs del usuario
          final logs = <MedicationLog>[];
          for (final json in data) {
            final medId = json['med_id'] as String;
            final med = await getMedicationById(medId);
            if (med != null && med.userId == userId) {
              final log = MedicationLog.fromJson(json);
              if (log.scheduledTime.isAfter(startOfDay) &&
                  log.scheduledTime.isBefore(startOfDay.add(const Duration(days: 1)))) {
                logs.add(log);
              }
            }
          }
          return logs;
        });
  }
}
