import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../data/models/medication.dart';
import '../../data/models/medication_stats.dart';
import '../../data/repositories/medication_repository.dart';
import '../widgets/medication_card.dart';
import '../widgets/adherence_summary_card.dart';
import '../widgets/today_schedule_card.dart';

/// Pantalla principal de medicamentos
class MedicationsListPage extends ConsumerWidget {
  const MedicationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Por favor inicia sesión'),
        ),
      );
    }

    final medicationsAsync = ref.watch(medicationsProvider(userId));
    final todayLogsAsync = ref.watch(todayLogsProvider(userId));
    final statsAsync = ref.watch(medicationStatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Ver calendario',
            onPressed: () {
              context.push('/medication-calendar');
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Estadísticas',
            onPressed: () {
              context.push('/medication-stats');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(medicationsProvider(userId));
          ref.invalidate(todayLogsProvider(userId));
          ref.invalidate(medicationStatsProvider(userId));
        },
        child: CustomScrollView(
          slivers: [
            // Resumen de adherencia
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => AdherenceSummaryCard(stats: stats),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Horarios de hoy
            SliverToBoxAdapter(
              child: todayLogsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.green,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '¡Todo listo por hoy!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No tienes medicamentos programados para hoy',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return TodayScheduleCard(logs: logs);
                },
                loading: () => const SizedBox(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error: $error'),
                    ),
                  ),
                ),
              ),
            ),

            // Sección: Mis medicamentos
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Mis Medicamentos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Lista de medicamentos
            medicationsAsync.when(
              data: (medications) {
                if (medications.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes medicamentos registrados',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Medicamento'),
                            onPressed: () {
                              context.push('/add-medication');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final medication = medications[index];
                        return MedicationCard(
                          medication: medication,
                          onTap: () {
                            context.push('/medication/${medication.medId}');
                          },
                          onEdit: () {
                            context.push('/edit-medication/${medication.medId}');
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Eliminar medicamento'),
                                content: Text(
                                  '¿Estás seguro de que deseas eliminar "${medication.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Eliminar'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final repository = ref.read(medicationRepositoryProvider);
                              await repository.deleteMedication(medication.medId);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Medicamento eliminado'),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                      childCount: medications.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar medicamentos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(medicationsProvider(userId));
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Espacio al final
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-medication');
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
