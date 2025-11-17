import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../data/models/medication.dart';
import '../../data/repositories/medication_repository.dart';

/// Pantalla de calendario de medicamentos
class MedicationCalendarPage extends ConsumerStatefulWidget {
  const MedicationCalendarPage({super.key});

  @override
  ConsumerState<MedicationCalendarPage> createState() =>
      _MedicationCalendarPageState();
}

class _MedicationCalendarPageState
    extends ConsumerState<MedicationCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Por favor inicia sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Ir a hoy',
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendario
          _buildCalendar(userId),

          const Divider(height: 1),

          // Detalles del día seleccionado
          Expanded(
            child: _buildDayDetails(userId),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(String userId) {
    final logsAsync = ref.watch(medicationLogsRangeProvider(
      userId,
      _getMonthRange(_focusedDay),
    ));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'es_ES',
          headerStyle: const HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              return logsAsync.when(
                data: (logs) {
                  final dayLogs = logs.where((log) {
                    final logDate = log.scheduledTime;
                    return logDate.year == date.year &&
                        logDate.month == date.month &&
                        logDate.day == date.day;
                  }).toList();

                  if (dayLogs.isEmpty) return null;

                  final takenCount =
                      dayLogs.where((l) => l.status == 'taken').length;
                  final totalCount = dayLogs.length;

                  final adherenceRate = takenCount / totalCount;
                  Color color;

                  if (adherenceRate >= 1.0) {
                    color = Colors.green;
                  } else if (adherenceRate >= 0.5) {
                    color = Colors.orange;
                  } else {
                    color = Colors.red;
                  }

                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
                loading: () => null,
                error: (_, __) => null,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayDetails(String userId) {
    final dayStart = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final logsAsync = ref.watch(medicationLogsDayProvider(
      userId,
      dayStart,
    ));

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_available,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin medicamentos programados',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('d \'de\' MMMM \'de\' y', 'es_ES')
                      .format(_selectedDay),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        // Calcular estadísticas del día
        final takenCount = logs.where((l) => l.status == 'taken').length;
        final missedCount = logs.where((l) => l.status == 'missed').length;
        final skippedCount = logs.where((l) => l.status == 'skipped').length;
        final adherenceRate = (takenCount / logs.length * 100).toStringAsFixed(0);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Resumen del día
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d \'de\' MMMM', 'es_ES')
                          .format(_selectedDay),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatChip(
                          label: 'Adherencia',
                          value: '$adherenceRate%',
                          color: _getAdherenceColor(double.parse(adherenceRate)),
                        ),
                        _StatChip(
                          label: 'Tomados',
                          value: '$takenCount',
                          color: Colors.green,
                        ),
                        _StatChip(
                          label: 'Olvidados',
                          value: '$missedCount',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de logs del día
            const Text(
              'Medicamentos del día',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            ...logs.map((log) => _DayLogCard(log: log)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
    );
  }

  Color _getAdherenceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }

  DateTimeRange _getMonthRange(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return DateTimeRange(start: firstDay, end: lastDay);
  }
}

/// Chip de estadística
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Card de log del día
class _DayLogCard extends ConsumerWidget {
  final MedicationLog log;

  const _DayLogCard({required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationAsync = ref.watch(medicationByIdProvider(log.medId));

    return medicationAsync.when(
      data: (medication) {
        if (medication == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(log.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _getStatusEmoji(log.status),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            title: Text(
              medication.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: log.status == 'taken' || log.status == 'skipped'
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.dosage),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm').format(log.scheduledTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (log.takenTime != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tomado a las ${DateFormat('HH:mm').format(log.takenTime!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(log.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusLabel(log.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(log.status),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Cargando...'),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'missed':
        return Colors.red;
      case 'skipped':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status) {
      case 'taken':
        return '✅';
      case 'missed':
        return '❌';
      case 'skipped':
        return '⏭️';
      default:
        return '⚪';
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'taken':
        return 'Tomado';
      case 'missed':
        return 'Olvidado';
      case 'skipped':
        return 'Omitido';
      default:
        return status;
    }
  }
}

// Providers adicionales para el calendario
final medicationLogsRangeProvider = FutureProvider.family<
    List<MedicationLog>,
    (String, DateTimeRange)
>((ref, params) async {
  final (userId, range) = params;
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getLogs(
    userId: userId,
    startDate: range.start,
    endDate: range.end,
  );
});

final medicationLogsDayProvider = FutureProvider.family<
    List<MedicationLog>,
    (String, DateTime)
>((ref, params) async {
  final (userId, day) = params;
  final repository = ref.watch(medicationRepositoryProvider);
  final dayEnd = day.add(const Duration(days: 1));
  return repository.getLogs(
    userId: userId,
    startDate: day,
    endDate: dayEnd,
  );
});
