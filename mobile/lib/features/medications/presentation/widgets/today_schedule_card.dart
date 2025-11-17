import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/medication.dart';
import '../../data/repositories/medication_repository.dart';

/// Card con horarios de medicamentos de hoy
class TodayScheduleCard extends ConsumerWidget {
  final List<MedicationLog> logs;

  const TodayScheduleCard({
    required this.logs,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedLogs = _groupLogsByTime(logs);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Horarios de Hoy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_takenCount(logs)}/${logs.length}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Timeline de medicamentos
              ...groupedLogs.entries.map((entry) {
                final time = entry.key;
                final logsAtTime = entry.value;

                return _TimelineItem(
                  time: time,
                  logs: logsAtTime,
                  onTakeMedication: (log) async {
                    await _takeMedication(context, ref, log);
                  },
                  onSkipMedication: (log) async {
                    await _skipMedication(context, ref, log);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Map<DateTime, List<MedicationLog>> _groupLogsByTime(List<MedicationLog> logs) {
    final Map<DateTime, List<MedicationLog>> grouped = {};

    for (final log in logs) {
      final timeKey = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
        log.scheduledTime.hour,
        log.scheduledTime.minute,
      );

      grouped.putIfAbsent(timeKey, () => []).add(log);
    }

    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  int _takenCount(List<MedicationLog> logs) {
    return logs.where((l) => l.status == 'taken').length;
  }

  Future<void> _takeMedication(
    BuildContext context,
    WidgetRef ref,
    MedicationLog log,
  ) async {
    try {
      final repository = ref.read(medicationRepositoryProvider);
      await repository.logTaken(
        medId: log.medId,
        scheduleId: log.scheduleId,
        scheduledTime: log.scheduledTime,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Medicamento registrado como tomado'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _skipMedication(
    BuildContext context,
    WidgetRef ref,
    MedicationLog log,
  ) async {
    try {
      final repository = ref.read(medicationRepositoryProvider);
      await repository.logSkipped(
        medId: log.medId,
        scheduleId: log.scheduleId,
        scheduledTime: log.scheduledTime,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏭️ Medicamento omitido'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TimelineItem extends StatelessWidget {
  final DateTime time;
  final List<MedicationLog> logs;
  final Function(MedicationLog) onTakeMedication;
  final Function(MedicationLog) onSkipMedication;

  const _TimelineItem({
    required this.time,
    required this.logs,
    required this.onTakeMedication,
    required this.onSkipMedication,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = time.isBefore(DateTime.now());
    final allTaken = logs.every((l) => l.status == 'taken');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: allTaken
                      ? Colors.green.withOpacity(0.1)
                      : isPast
                          ? Colors.red.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  border: Border.all(
                    color: allTaken
                        ? Colors.green
                        : isPast
                            ? Colors.red
                            : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    allTaken
                        ? Icons.check
                        : isPast
                            ? Icons.close
                            : Icons.access_time,
                    color: allTaken
                        ? Colors.green
                        : isPast
                            ? Colors.red
                            : Colors.blue,
                    size: 20,
                  ),
                ),
              ),
              if (logs != logs.last)
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('HH:mm').format(time),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Medications at this time
                ...logs.map((log) => _MedicationLogItem(
                      log: log,
                      onTake: () => onTakeMedication(log),
                      onSkip: () => onSkipMedication(log),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationLogItem extends StatelessWidget {
  final MedicationLog log;
  final VoidCallback onTake;
  final VoidCallback onSkip;

  const _MedicationLogItem({
    required this.log,
    required this.onTake,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isTaken = log.status == 'taken';
    final isSkipped = log.status == 'skipped';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTaken
              ? Colors.green
              : isSkipped
                  ? Colors.orange
                  : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          if (isTaken || isSkipped)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                isTaken ? Icons.check_circle : Icons.cancel,
                color: isTaken ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),

          // Med name (placeholder - would need to fetch medication details)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicamento ${log.medId.substring(0, 8)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: isTaken || isSkipped
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (log.takenTime != null)
                  Text(
                    'Tomado a las ${DateFormat('HH:mm').format(log.takenTime!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Actions
          if (!isTaken && !isSkipped) ...[
            IconButton(
              icon: const Icon(Icons.check),
              color: Colors.green,
              tooltip: 'Tomar',
              onPressed: onTake,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.orange,
              tooltip: 'Omitir',
              onPressed: onSkip,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ],
      ),
    );
  }
}
