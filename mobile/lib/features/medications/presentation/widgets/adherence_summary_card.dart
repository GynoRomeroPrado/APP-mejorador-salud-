import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/medication_stats.dart';

/// Card de resumen de adherencia
class AdherenceSummaryCard extends StatelessWidget {
  final MedicationStats stats;

  const AdherenceSummaryCard({
    required this.stats,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Adherencia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getAdherenceColor(stats.adherenceRate).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${stats.adherenceRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getAdherenceColor(stats.adherenceRate),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico circular
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    // Pie chart
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: stats.takenCount.toDouble(),
                              color: Colors.green,
                              title: '',
                              radius: 40,
                            ),
                            PieChartSectionData(
                              value: stats.missedCount.toDouble(),
                              color: Colors.red,
                              title: '',
                              radius: 40,
                            ),
                            PieChartSectionData(
                              value: stats.skippedCount.toDouble(),
                              color: Colors.orange,
                              title: '',
                              radius: 40,
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
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
                          const SizedBox(height: 8),
                          _LegendItem(
                            color: Colors.red,
                            label: 'Olvidados',
                            value: stats.missedCount,
                          ),
                          const SizedBox(height: 8),
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
              const SizedBox(height: 20),

              // Stats adicionales
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      label: 'Racha actual',
                      value: '${stats.currentStreak} días',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: _StatItem(
                      icon: Icons.medication,
                      iconColor: Colors.blue,
                      label: 'Activos',
                      value: '${stats.activeMedications}',
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
        const Spacer(),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
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
