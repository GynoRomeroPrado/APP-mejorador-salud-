import 'package:flutter/material.dart';
import '../../data/models/medication_stats.dart';

/// Diálogo para agregar/editar horario de medicamento
class ScheduleFormDialog extends StatefulWidget {
  final CreateScheduleDto? initialSchedule;

  const ScheduleFormDialog({
    this.initialSchedule,
    super.key,
  });

  @override
  State<ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<ScheduleFormDialog> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _frequency = 'daily';
  int _intervalDays = 1;
  List<int> _selectedDaysOfWeek = [];
  String? _mealTiming;
  bool _waterReminder = false;
  int _snoozeDurationMinutes = 10;

  @override
  void initState() {
    super.initState();

    if (widget.initialSchedule != null) {
      final schedule = widget.initialSchedule!;
      final timeParts = schedule.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _frequency = schedule.frequency;
      _intervalDays = schedule.intervalDays ?? 1;
      _selectedDaysOfWeek = schedule.daysOfWeek ?? [];
      _mealTiming = schedule.mealTiming;
      _waterReminder = schedule.waterReminder;
      _snoozeDurationMinutes = schedule.snoozeDurationMinutes;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialSchedule != null
          ? 'Editar Horario'
          : 'Agregar Horario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hora
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Hora'),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
            const Divider(),

            // Frecuencia
            const Text(
              'Frecuencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Diario'),
              value: 'daily',
              groupValue: _frequency,
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Semanal (días específicos)'),
              value: 'weekly',
              groupValue: _frequency,
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),

            if (_frequency == 'weekly') ...[
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final day = index + 1;
                    final isSelected = _selectedDaysOfWeek.contains(day);

                    return FilterChip(
                      label: Text(_getDayShortName(day)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDaysOfWeek.add(day);
                          } else {
                            _selectedDaysOfWeek.remove(day);
                          }
                          _selectedDaysOfWeek.sort();
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
            ],

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Cada X días'),
              value: 'every_x_days',
              groupValue: _frequency,
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),

            if (_frequency == 'every_x_days') ...[
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    const Text('Cada'),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: DropdownButton<int>(
                        value: _intervalDays,
                        isExpanded: true,
                        items: List.generate(30, (index) => index + 1)
                            .map((days) => DropdownMenuItem(
                                  value: days,
                                  child: Text('$days'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _intervalDays = value!);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('días'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Según sea necesario'),
              value: 'as_needed',
              groupValue: _frequency,
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),
            const Divider(),

            // Momento de comida
            const Text(
              'Momento de comida',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String?>(
              value: _mealTiming,
              decoration: const InputDecoration(
                hintText: 'Selecciona...',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Sin preferencia'),
                ),
                ...MealTiming.values.map((timing) {
                  return DropdownMenuItem(
                    value: timing.value,
                    child: Row(
                      children: [
                        Text(timing.emoji),
                        const SizedBox(width: 8),
                        Text(timing.label),
                      ],
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() => _mealTiming = value);
              },
            ),
            const SizedBox(height: 16),

            // Recordatorio de agua
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordar tomar con agua'),
              value: _waterReminder,
              onChanged: (value) {
                setState(() => _waterReminder = value);
              },
            ),

            // Duración de posponer
            const Text(
              'Duración de posponer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<int>(
              value: _snoozeDurationMinutes,
              decoration: const InputDecoration(
                isDense: true,
              ),
              items: [5, 10, 15, 30, 60]
                  .map((minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes minutos'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _snoozeDurationMinutes = value!);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _saveSchedule() {
    // Validaciones
    if (_frequency == 'weekly' && _selectedDaysOfWeek.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos un día de la semana'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final schedule = CreateScheduleDto(
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      frequency: _frequency,
      intervalDays: _frequency == 'every_x_days' ? _intervalDays : null,
      daysOfWeek: _frequency == 'weekly' ? _selectedDaysOfWeek : null,
      mealTiming: _mealTiming,
      waterReminder: _waterReminder,
      enabled: true,
      notificationSound: 'default',
      snoozeDurationMinutes: _snoozeDurationMinutes,
    );

    Navigator.pop(context, schedule);
  }

  String _getDayShortName(int day) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[day - 1];
  }
}
