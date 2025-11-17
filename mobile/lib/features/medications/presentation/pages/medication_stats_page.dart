import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../shared/services/supabase_service.dart';
import '../../data/models/medication_stats.dart';
import '../../data/repositories/medication_repository.dart';

/// Pantalla de estadísticas detalladas de medicamentos
class MedicationStatsPage extends ConsumerWidget {
  const MedicationStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = SupabaseService.currentUserId;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Por favor inicia sesión')),
      );
    }

    final statsAsync = ref.watch(medicationStatsProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar reporte',
            onPressed: () {
              // TODO: Implementar exportación a PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportación disponible próximamente'),
                ),
              );
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => _buildStatsContent(context, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(medicationStatsProvider(userId));
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, MedicationStats stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumen general
        _buildOverviewCard(stats),
        const SizedBox(height: 16),

        // Gráfico de adherencia
        _buildAdherenceChart(stats),
        const SizedBox(height: 16),

        // Gráfico de distribución
        _buildDistributionChart(stats),
        const SizedBox(height: 16),

        // Rachas
        _buildStreaksCard(stats),
        const SizedBox(height: 16),

        // Medicamentos activos
        _buildActiveMedicationsCard(stats),
        const SizedBox(height: 16),

        // Estadísticas por período
        _buildPeriodStatsCard(stats),
      ],
    );
  }

  Widget _buildOverviewCard(MedicationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Adherencia',
                    value: '${stats.adherenceRate.toStringAsFixed(0)}%',
                    icon: Icons.show_chart,
                    color: _getAdherenceColor(stats.adherenceRate),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Racha Actual',
                    value: '${stats.currentStreak} días',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Medicamentos',
                    value: '${stats.activeMedications}',
                    icon: Icons.medication,
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Total Tomados',
                    value: '${stats.takenCount}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdherenceChart(MedicationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adherencia (Últimos 30 días)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 == 0) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateAdherenceSpots(stats),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateAdherenceSpots(MedicationStats stats) {
    // Simular datos de adherencia diaria
    // En producción, esto vendría de stats.recentAdherence
    return List.generate(30, (index) {
      final adherence = stats.adherenceRate +
          (index % 7 == 0 ? -10 : 0) +
          (index.isEven ? 5 : -5);
      return FlSpot(
        index.toDouble(),
        adherence.clamp(0, 100).toDouble(),
      );
    });
  }

  Widget _buildDistributionChart(MedicationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribución',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie chart
                  SizedBox(
                    width: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: stats.takenCount.toDouble(),
                            color: Colors.green,
                            title: '${((stats.takenCount / (stats.takenCount + stats.missedCount + stats.skippedCount)) * 100).toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats.missedCount.toDouble(),
                            color: Colors.red,
                            title: '${((stats.missedCount / (stats.takenCount + stats.missedCount + stats.skippedCount)) * 100).toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: stats.skippedCount.toDouble(),
                            color: Colors.orange,
                            title: '${((stats.skippedCount / (stats.takenCount + stats.missedCount + stats.skippedCount)) * 100).toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Leyenda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: Colors.green,
                          label: 'Tomados',
                          value: stats.takenCount,
                        ),
                        const SizedBox(height: 12),
                        _LegendItem(
                          color: Colors.red,
                          label: 'Olvidados',
                          value: stats.missedCount,
                        ),
                        const SizedBox(height: 12),
                        _LegendItem(
                          color: Colors.orange,
                          label: 'Omitidos',
                          value: stats.skippedCount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksCard(MedicationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Rachas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Racha Actual',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.currentStreak}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text(
                          'días',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Mejor Racha',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${stats.longestStreak}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const Text(
                          'días',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (stats.lastTakenDate != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Última toma: ${DateFormat('dd/MM/yyyy HH:mm').format(stats.lastTakenDate!)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMedicationsCard(MedicationStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medication, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Medicamentos Activos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _InfoChip(
                  label: 'Total',
                  value: '${stats.totalMedications}',
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  label: 'Activos',
                  value: '${stats.activeMedications}',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  label: 'Horarios',
                  value: '${stats.totalSchedules}',
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodStatsCard(MedicationStats stats) {
    final total = stats.takenCount + stats.missedCount + stats.skippedCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Últimos 30 Días',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _PeriodStatRow(
              label: 'Total de dosis programadas',
              value: '$total',
              icon: Icons.event_note,
            ),
            const Divider(),

            _PeriodStatRow(
              label: 'Dosis tomadas',
              value: '${stats.takenCount}',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const Divider(),

            _PeriodStatRow(
              label: 'Dosis olvidadas',
              value: '${stats.missedCount}',
              icon: Icons.cancel,
              color: Colors.red,
            ),
            const Divider(),

            _PeriodStatRow(
              label: 'Dosis omitidas',
              value: '${stats.skippedCount}',
              icon: Icons.skip_next,
              color: Colors.orange,
            ),
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
}

// Widgets auxiliares
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PeriodStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _PeriodStatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
