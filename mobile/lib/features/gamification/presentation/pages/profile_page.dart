import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/gamification_providers.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/user_stats_card.dart';
import '../widgets/daily_quote_card.dart';
import '../widgets/streak_card.dart';
import '../widgets/level_progress_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final userStatsAsync = ref.watch(userStatsProvider(user.userId));
    final quote = ref.watch(dailyQuoteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStatsProvider(user.userId));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar y nombre
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName ?? 'Usuario',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    userStatsAsync.when(
                      data: (stats) => Text(
                        stats.userTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Daily Quote
              DailyQuoteCard(quote: quote),

              const SizedBox(height: 16),

              // Stats principales
              userStatsAsync.when(
                data: (stats) => Column(
                  children: [
                    // Level Progress
                    LevelProgressCard(stats: stats),
                    const SizedBox(height: 12),

                    // Streak
                    StreakCard(stats: stats),
                    const SizedBox(height: 12),

                    // Stats generales
                    UserStatsCard(stats: stats),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Error al cargar estadísticas',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de logros
              FilledButton.icon(
                onPressed: () {
                  context.push('/achievements');
                },
                icon: const Icon(Icons.emoji_events),
                label: const Text('Ver Logros'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón de historial
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/workouts/history');
                },
                icon: const Icon(Icons.history),
                label: const Text('Historial de Entrenamientos'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Información de la cuenta
              Text(
                'Cuenta',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              _InfoTile(
                icon: Icons.email,
                label: 'Email',
                value: user.email,
              ),

              if (user.dateOfBirth != null)
                _InfoTile(
                  icon: Icons.cake,
                  label: 'Edad',
                  value: '${user.age} años',
                ),

              if (user.heightCm != null && user.weightKg != null) ...[
                _InfoTile(
                  icon: Icons.straighten,
                  label: 'Altura',
                  value: '${user.heightCm!.toStringAsFixed(0)} cm',
                ),
                _InfoTile(
                  icon: Icons.monitor_weight,
                  label: 'Peso',
                  value: '${user.weightKg!.toStringAsFixed(1)} kg',
                ),
                _InfoTile(
                  icon: Icons.analytics,
                  label: 'IMC',
                  value: '${user.bmi?.toStringAsFixed(1)} (${user.bmiCategory})',
                ),
              ],

              const SizedBox(height: 24),

              // Botón de cerrar sesión
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Cerrar Sesión'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: theme.colorScheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
