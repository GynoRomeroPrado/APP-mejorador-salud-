import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/exercises_provider.dart';

class ExerciseFilterBottomSheet extends ConsumerWidget {
  const ExerciseFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(exerciseFilterStateProvider);
    final filterNotifier = ref.read(exerciseFilterStateProvider.notifier);

    final bodyPartListAsync = ref.watch(bodyPartListProvider);
    final equipmentListAsync = ref.watch(equipmentListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filtros',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        filterNotifier.clearFilters();
                      },
                      child: const Text('Limpiar todo'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Filters list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Toggle filters
                    _SwitchFilterTile(
                      title: 'Solo favoritos',
                      subtitle: 'Mostrar solo ejercicios favoritos',
                      icon: Icons.favorite,
                      value: filter.favoritesOnly,
                      onChanged: (value) {
                        filterNotifier.setFavoritesOnly(value);
                      },
                    ),

                    const SizedBox(height: 12),

                    _SwitchFilterTile(
                      title: 'Ejercicios para casa',
                      subtitle: 'Solo ejercicios sin equipamiento especial',
                      icon: Icons.home,
                      value: filter.homeOnly,
                      onChanged: (value) {
                        filterNotifier.setHomeOnly(value);
                      },
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Body Part filter
                    Text(
                      'Parte del cuerpo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    bodyPartListAsync.when(
                      data: (bodyParts) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: bodyParts.map((bodyPart) {
                            final isSelected = filter.bodyPart == bodyPart;

                            return FilterChip(
                              label: Text(_translateBodyPart(bodyPart)),
                              selected: isSelected,
                              onSelected: (selected) {
                                filterNotifier.setBodyPart(
                                  selected ? bodyPart : null,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Text(
                        'Error al cargar partes del cuerpo',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Equipment filter
                    Text(
                      'Equipamiento',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    equipmentListAsync.when(
                      data: (equipmentList) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: equipmentList.map((equipment) {
                            final isSelected = filter.equipment == equipment;

                            return FilterChip(
                              label: Text(_translateEquipment(equipment)),
                              selected: isSelected,
                              onSelected: (selected) {
                                filterNotifier.setEquipment(
                                  selected ? equipment : null,
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Text(
                        'Error al cargar equipamiento',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Apply button
              Padding(
                padding: const EdgeInsets.all(20),
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    filter.hasActiveFilters
                        ? 'Aplicar filtros (${filter.activeFilterCount})'
                        : 'Cerrar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _translateBodyPart(String bodyPart) {
    final translations = {
      'back': 'Espalda',
      'cardio': 'Cardio',
      'chest': 'Pecho',
      'lower arms': 'Antebrazos',
      'lower legs': 'Piernas inferiores',
      'neck': 'Cuello',
      'shoulders': 'Hombros',
      'upper arms': 'Brazos',
      'upper legs': 'Piernas',
      'waist': 'Abdomen',
    };
    return translations[bodyPart.toLowerCase()] ?? bodyPart;
  }

  String _translateEquipment(String equipment) {
    final translations = {
      'body weight': 'Peso corporal',
      'barbell': 'Barra',
      'dumbbell': 'Mancuernas',
      'cable': 'Polea',
      'machine': 'Máquina',
      'kettlebell': 'Pesa rusa',
      'resistance band': 'Banda elástica',
      'stability ball': 'Balón suizo',
    };
    return translations[equipment.toLowerCase()] ?? equipment;
  }
}

class _SwitchFilterTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchFilterTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        secondary: Icon(icon),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
