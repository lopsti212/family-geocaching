import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quest_provider.dart';
import '../../utils/level_system.dart';
import '../../utils/streak_calculator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profilbild und Name
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: user?.role == UserRole.parent
                        ? AppTheme.primaryColor
                        : AppTheme.secondaryColor,
                    child: Icon(
                      user?.role == UserRole.parent
                          ? Icons.person
                          : Icons.child_care,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Unbekannt',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      user?.role == UserRole.parent ? 'Elternteil' : 'Kind',
                    ),
                    backgroundColor: (user?.role == UserRole.parent
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryColor)
                        .withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistiken (nur für Kinder)
          if (user?.role == UserRole.child) ...[
            Builder(builder: (context) {
              final questProvider = context.watch<QuestProvider>();
              final streak = user != null
                  ? questProvider.getStreakForChild(user.id)
                  : StreakData(currentStreak: 0, longestStreak: 0);

              final currentLevel = LevelSystem.getLevelForXp(user!.xp);
              final nextLevel = LevelSystem.getNextLevel(user.xp);
              final progress = LevelSystem.progressToNextLevel(user.xp);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, color: AppTheme.secondaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Deine Erfolge',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Level-Anzeige
                      Center(
                        child: Column(
                          children: [
                            Icon(currentLevel.icon, size: 40, color: AppTheme.primaryColor),
                            const SizedBox(height: 4),
                            Text(
                              currentLevel.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Level ${currentLevel.level}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // XP-Fortschrittsbalken
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          color: AppTheme.primaryColor,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          nextLevel != null
                              ? '${user.xp} / ${nextLevel.xpRequired} XP'
                              : '${user.xp} XP - Max Level!',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Streak-Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _AchievementStat(
                            icon: Icons.local_fire_department,
                            value: '${streak.currentStreak}',
                            label: 'Tage in Folge',
                            color: Colors.deepOrange,
                          ),
                          _AchievementStat(
                            icon: Icons.emoji_events,
                            value: '${streak.longestStreak}',
                            label: 'Längste Serie',
                            color: AppTheme.secondaryColor,
                          ),
                          _AchievementStat(
                            icon: Icons.star,
                            value: '${user.xp}',
                            label: 'XP gesamt',
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Einstellungen
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.family_restroom),
                  title: const Text('Familie'),
                  subtitle: Text(
                    authProvider.family?.name ?? 'Keine Familie',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/family'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Benachrichtigungen'),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: Implementieren
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Info
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Über die App'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Family Geocaching',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.explore,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                      children: [
                        const Text(
                          'Eine App für Familien-Schatzsuchen mit Belohnungen.',
                        ),
                      ],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Datenschutz'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/privacy'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          ElevatedButton.icon(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Abmelden?'),
                  content: const Text('Möchtest du dich wirklich abmelden?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Abbrechen'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Abmelden'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await authProvider.signOut();
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.errorColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Abmelden'),
          ),
          const SizedBox(height: 12),

          // Konto löschen
          TextButton.icon(
            onPressed: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konto löschen?'),
                  content: const Text(
                    'Dein gesamtes Konto wird unwiderruflich gelöscht:\n\n'
                    '- Alle deine erstellten Schatzsuchen\n'
                    '- Alle hochgeladenen Fotos\n'
                    '- Dein Spielfortschritt (XP, Level)\n'
                    '- Deine Account-Daten\n\n'
                    'Dieser Vorgang kann nicht rückgängig gemacht werden.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Abbrechen'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Endgültig löschen'),
                    ),
                  ],
                ),
              );

              if (shouldDelete == true && context.mounted) {
                final success = await authProvider.deleteAccount();
                if (success && context.mounted) {
                  context.go('/login');
                } else if (context.mounted && authProvider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fehler: ${authProvider.error}'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Konto löschen'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _AchievementStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 4),
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
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
