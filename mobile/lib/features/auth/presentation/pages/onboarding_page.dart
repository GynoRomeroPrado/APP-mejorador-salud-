import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Datos del formulario
  String? _selectedGender;
  DateTime? _selectedDate;
  double? _heightCm;
  double? _weightKg;
  String? _selectedGoal;
  String? _selectedActivityLevel;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Información Básica',
      'subtitle': 'Cuéntanos un poco sobre ti',
      'icon': Icons.person_outline,
    },
    {
      'title': 'Medidas',
      'subtitle': 'Tus datos físicos',
      'icon': Icons.straighten,
    },
    {
      'title': 'Objetivos',
      'subtitle': '¿Qué quieres lograr?',
      'icon': Icons.flag_outlined,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Actualizar perfil con los datos recopilados
    final updates = <String, dynamic>{};

    if (_selectedGender != null) updates['gender'] = _selectedGender;
    if (_selectedDate != null) {
      updates['date_of_birth'] = _selectedDate!.toIso8601String();
    }
    if (_heightCm != null) updates['height_cm'] = _heightCm;
    if (_weightKg != null) updates['weight_kg'] = _weightKg;
    if (_selectedGoal != null) updates['fitness_goal'] = _selectedGoal;
    if (_selectedActivityLevel != null) {
      updates['activity_level'] = _selectedActivityLevel;
    }

    try {
      await ref.read(authProvider.notifier).updateProfile(updates);

      if (!mounted) return;

      // Ir a la pantalla principal
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar datos: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Omitir'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _pages.length,
              backgroundColor: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Page view
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildBasicInfoPage(theme),
                _buildMeasurementsPage(theme),
                _buildGoalsPage(theme),
              ],
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(
              onPressed: _canProceed() ? _nextPage : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Comenzar' : 'Continuar',
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
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGender != null && _selectedDate != null;
      case 1:
        return _heightCm != null && _weightKg != null;
      case 2:
        return _selectedGoal != null && _selectedActivityLevel != null;
      default:
        return false;
    }
  }

  Widget _buildBasicInfoPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Información Básica',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuéntanos un poco sobre ti',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Género
          Text(
            'Género',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'male', label: Text('Hombre')),
              ButtonSegment(value: 'female', label: Text('Mujer')),
              ButtonSegment(value: 'other', label: Text('Otro')),
            ],
            selected: _selectedGender != null ? {_selectedGender!} : {},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _selectedGender = selection.first;
              });
            },
          ),
          const SizedBox(height: 24),

          // Fecha de nacimiento
          Text(
            'Fecha de Nacimiento',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Seleccionar fecha',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              alignment: Alignment.centerLeft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.straighten,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Medidas',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tus datos físicos nos ayudan a personalizar',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Altura
          Text(
            'Altura (cm)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '170',
              suffixText: 'cm',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _heightCm = double.tryParse(value);
              });
            },
          ),
          const SizedBox(height: 24),

          // Peso
          Text(
            'Peso (kg)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '70',
              suffixText: 'kg',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _weightKg = double.tryParse(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Objetivos',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¿Qué quieres lograr?',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Objetivo
          Text(
            'Mi objetivo principal es',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...['weight_loss', 'muscle_gain', 'endurance', 'general_fitness'].map(
            (goal) {
              final labels = {
                'weight_loss': 'Perder peso',
                'muscle_gain': 'Ganar músculo',
                'endurance': 'Mejorar resistencia',
                'general_fitness': 'Fitness general',
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  value: goal,
                  groupValue: _selectedGoal,
                  onChanged: (value) {
                    setState(() => _selectedGoal = value);
                  },
                  title: Text(labels[goal]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Nivel de actividad
          Text(
            'Mi nivel de actividad actual es',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...['sedentary', 'light', 'moderate', 'active', 'very_active'].map(
            (level) {
              final labels = {
                'sedentary': 'Sedentario (poco o nada)',
                'light': 'Ligero (1-2 días/semana)',
                'moderate': 'Moderado (3-5 días/semana)',
                'active': 'Activo (6-7 días/semana)',
                'very_active': 'Muy activo (atleta)',
              };

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RadioListTile<String>(
                  value: level,
                  groupValue: _selectedActivityLevel,
                  onChanged: (value) {
                    setState(() => _selectedActivityLevel = value);
                  },
                  title: Text(labels[level]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
