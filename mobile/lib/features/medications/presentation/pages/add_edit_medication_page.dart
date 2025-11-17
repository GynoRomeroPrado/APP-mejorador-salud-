import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../data/models/medication.dart';
import '../../data/models/medication_stats.dart';
import '../../data/repositories/medication_repository.dart';
import '../widgets/color_picker_dialog.dart';
import '../widgets/schedule_form_dialog.dart';

/// Pantalla de agregar/editar medicamento
class AddEditMedicationPage extends ConsumerStatefulWidget {
  final String? medicationId; // null = agregar, con valor = editar

  const AddEditMedicationPage({
    this.medicationId,
    super.key,
  });

  @override
  ConsumerState<AddEditMedicationPage> createState() =>
      _AddEditMedicationPageState();
}

class _AddEditMedicationPageState
    extends ConsumerState<AddEditMedicationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _notesController = TextEditingController();
  final _refillQuantityController = TextEditingController();

  // Estado del formulario
  String _type = 'supplement';
  String _icon = 'pill';
  String _colorHex = '#3B82F6';
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  DateTime? _refillDate;
  int _refillReminderDays = 7;
  List<CreateScheduleDto> _schedules = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.medicationId != null;

    if (_isEditing) {
      _loadMedication();
    }
  }

  Future<void> _loadMedication() async {
    if (widget.medicationId == null) return;

    setState(() => _isLoading = true);

    try {
      final medication = await ref
          .read(medicationRepositoryProvider)
          .getMedicationById(widget.medicationId!);

      if (medication != null && mounted) {
        setState(() {
          _nameController.text = medication.name;
          _dosageController.text = medication.dosage;
          _instructionsController.text = medication.instructions ?? '';
          _notesController.text = medication.notes ?? '';
          _type = medication.type;
          _icon = medication.icon;
          _colorHex = medication.colorHex;
          _startDate = medication.startDate;
          _endDate = medication.endDate;
          _refillDate = medication.refillDate;
          _refillQuantityController.text = medication.refillQuantity?.toString() ?? '';
          _refillReminderDays = medication.refillReminderDays;

          // Convertir schedules a DTOs
          _schedules = medication.schedules
              .map((s) => CreateScheduleDto(
                    time: s.time,
                    frequency: s.frequency,
                    intervalDays: s.intervalDays,
                    daysOfWeek: s.daysOfWeek,
                    mealTiming: s.mealTiming,
                    waterReminder: s.waterReminder,
                    enabled: s.enabled,
                    notificationSound: s.notificationSound,
                    snoozeDurationMinutes: s.snoozeDurationMinutes,
                  ))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar medicamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    _notesController.dispose();
    _refillQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Medicamento' : 'Agregar Medicamento'),
        actions: [
          TextButton(
            onPressed: _saveMedication,
            child: const Text('GUARDAR'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nombre del medicamento
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del medicamento *',
                hintText: 'Ej: Aspirina, Vitamina D, Proteína...',
                prefixIcon: Icon(Icons.medication),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo y dosaje en fila
            Row(
              children: [
                // Tipo
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: MedicationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type.value,
                        child: Row(
                          children: [
                            Text(type.emoji),
                            const SizedBox(width: 8),
                            Text(type.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _type = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Icono
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _icon,
                    decoration: const InputDecoration(
                      labelText: 'Icono',
                      prefixIcon: Icon(Icons.emoji_emotions),
                    ),
                    items: MedicationIcon.values.map((icon) {
                      return DropdownMenuItem(
                        value: icon.value,
                        child: Row(
                          children: [
                            Text(icon.emoji),
                            const SizedBox(width: 8),
                            Text(icon.value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _icon = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dosaje
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosaje *',
                hintText: 'Ej: 500mg, 2 tabletas, 1 cucharada...',
                prefixIcon: Icon(Icons.scale),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El dosaje es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Color del medicamento
            InkWell(
              onTap: () async {
                final color = await showDialog<Color>(
                  context: context,
                  builder: (context) => ColorPickerDialog(
                    initialColor: Color(
                      int.parse('FF${_colorHex.replaceAll('#', '')}', radix: 16),
                    ),
                  ),
                );

                if (color != null) {
                  setState(() {
                    _colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Color',
                  prefixIcon: Icon(Icons.palette),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(int.parse('FF${_colorHex.replaceAll('#', '')}', radix: 16)),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_colorHex),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sección: Fechas
            const Text(
              'Fechas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Fecha de inicio
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Fecha de inicio'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  locale: const Locale('es', 'ES'),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),

            // Fecha de fin (opcional)
            SwitchListTile(
              secondary: const Icon(Icons.stop),
              title: const Text('Fecha de fin'),
              subtitle: _endDate != null
                  ? Text(DateFormat('dd/MM/yyyy').format(_endDate!))
                  : const Text('Sin fecha de fin'),
              value: _endDate != null,
              onChanged: (value) async {
                if (value) {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate.add(const Duration(days: 30)),
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    locale: const Locale('es', 'ES'),
                  );
                  if (date != null) {
                    setState(() => _endDate = date);
                  }
                } else {
                  setState(() => _endDate = null);
                }
              },
            ),
            const SizedBox(height: 24),

            // Sección: Horarios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Horarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  onPressed: _addSchedule,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Lista de horarios
            if (_schedules.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.access_time, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'No hay horarios configurados',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Horario'),
                        onPressed: _addSchedule,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._schedules.asMap().entries.map((entry) {
                final index = entry.key;
                final schedule = entry.value;
                return _ScheduleCard(
                  schedule: schedule,
                  onEdit: () => _editSchedule(index),
                  onDelete: () => _deleteSchedule(index),
                );
              }).toList(),
            const SizedBox(height: 24),

            // Sección: Recarga (opcional)
            SwitchListTile(
              secondary: const Icon(Icons.refresh),
              title: const Text('Recordatorio de recarga'),
              subtitle: _refillDate != null
                  ? Text(
                      'Recarga el ${DateFormat('dd/MM/yyyy').format(_refillDate!)}')
                  : const Text('Sin recordatorio de recarga'),
              value: _refillDate != null,
              onChanged: (value) async {
                if (value) {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('es', 'ES'),
                  );
                  if (date != null) {
                    setState(() => _refillDate = date);
                  }
                } else {
                  setState(() => _refillDate = null);
                }
              },
            ),

            if (_refillDate != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _refillQuantityController,
                      decoration: const InputDecoration(
                        labelText: 'Cantidad de recarga',
                        hintText: 'Ej: 30 tabletas',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _refillReminderDays,
                      decoration: const InputDecoration(
                        labelText: 'Recordar con',
                      ),
                      items: [3, 5, 7, 10, 14]
                          .map((days) => DropdownMenuItem(
                                value: days,
                                child: Text('$days días de anticipación'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _refillReminderDays = value!);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Instrucciones
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instrucciones (opcional)',
                hintText: 'Ej: Tomar con agua, evitar alcohol...',
                prefixIcon: Icon(Icons.info_outline),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Notas
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notas personales (opcional)',
                hintText: 'Cualquier observación adicional...',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Botón guardar
            ElevatedButton(
              onPressed: _saveMedication,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isEditing ? 'Actualizar Medicamento' : 'Guardar Medicamento',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _addSchedule() async {
    final schedule = await showDialog<CreateScheduleDto>(
      context: context,
      builder: (context) => const ScheduleFormDialog(),
    );

    if (schedule != null) {
      setState(() {
        _schedules.add(schedule);
      });
    }
  }

  Future<void> _editSchedule(int index) async {
    final schedule = await showDialog<CreateScheduleDto>(
      context: context,
      builder: (context) => ScheduleFormDialog(
        initialSchedule: _schedules[index],
      ),
    );

    if (schedule != null) {
      setState(() {
        _schedules[index] = schedule;
      });
    }
  }

  void _deleteSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos un horario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final dto = CreateMedicationDto(
        name: _nameController.text.trim(),
        type: _type,
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim().isEmpty
            ? null
            : _instructionsController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        refillDate: _refillDate,
        refillQuantity: _refillQuantityController.text.isEmpty
            ? null
            : int.tryParse(_refillQuantityController.text),
        refillReminderDays: _refillReminderDays,
        colorHex: _colorHex,
        icon: _icon,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        schedules: _schedules,
      );

      final repository = ref.read(medicationRepositoryProvider);

      if (_isEditing && widget.medicationId != null) {
        await repository.updateMedication(widget.medicationId!, dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Medicamento actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await repository.createMedication(userId, dto);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Medicamento guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

/// Card de horario
class _ScheduleCard extends StatelessWidget {
  final CreateScheduleDto schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.access_time),
        title: Text(
          schedule.time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getFrequencyLabel(schedule)),
            if (schedule.mealTiming != null)
              Text(MealTiming.fromValue(schedule.mealTiming).label),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyLabel(CreateScheduleDto schedule) {
    switch (schedule.frequency) {
      case 'daily':
        return 'Diario';
      case 'weekly':
        if (schedule.daysOfWeek != null) {
          final days = schedule.daysOfWeek!.map((d) => _getDayName(d)).join(', ');
          return 'Semanal: $days';
        }
        return 'Semanal';
      case 'every_x_days':
        return 'Cada ${schedule.intervalDays} días';
      case 'as_needed':
        return 'Según sea necesario';
      default:
        return schedule.frequency;
    }
  }

  String _getDayName(int day) {
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return days[day - 1];
  }
}
