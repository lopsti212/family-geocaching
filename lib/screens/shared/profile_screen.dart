import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

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
                        .withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistiken (nur für Kinder)
          if (user?.role == UserRole.child) ...[
            Card(
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
                    // Hier könnten Statistiken stehen
                    Center(
                      child: Text(
                        'Statistiken kommen bald!',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  onTap: () {
                    // TODO: Datenschutz-Seite
                  },
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
        ],
      ),
    );
  }
}
