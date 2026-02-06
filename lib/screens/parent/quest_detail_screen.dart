import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/quest_model.dart';
import '../../providers/quest_provider.dart';

class QuestDetailScreen extends StatelessWidget {
  final String questId;

  const QuestDetailScreen({super.key, required this.questId});

  @override
  Widget build(BuildContext context) {
    final questProvider = context.watch<QuestProvider>();
    final quest = questProvider.quests.firstWhere(
      (q) => q.id == questId,
      orElse: () => questProvider.quests.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(quest.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, quest),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status & Schwierigkeit
          Row(
            children: [
              _StatusChip(status: quest.status),
              const SizedBox(width: 8),
              _DifficultyChip(difficulty: quest.difficulty),
            ],
          ),
          const SizedBox(height: 16),

          // Beschreibung
          if (quest.description != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Beschreibung',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(quest.description!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Belohnung
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, color: AppTheme.secondaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Belohnung',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quest.reward.displayText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Karte
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.errorColor),
                      const SizedBox(width: 8),
                      Text(
                        'Zielort',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        quest.targetLatitude,
                        quest.targetLongitude,
                      ),
                      initialZoom: 16,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.familygeocaching.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              quest.targetLatitude,
                              quest.targetLongitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: AppTheme.errorColor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Zeitstempel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Erstellt',
                    value: _formatDate(quest.createdAt),
                  ),
                  if (quest.completedAt != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.check_circle,
                      label: 'Abgeschlossen',
                      value: _formatDate(quest.completedAt!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} um ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context, QuestModel quest) {
    String message = 'Möchtest du "${quest.title}" wirklich löschen?';
    if (quest.status == QuestStatus.inProgress) {
      message += '\n\nAchtung: Diese Schatzsuche ist gerade aktiv!';
    } else if (quest.status == QuestStatus.completed) {
      message += '\n\nDiese Schatzsuche wurde bereits abgeschlossen.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schatzsuche löschen?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await context.read<QuestProvider>().deleteQuest(quest.id);
              if (success && context.mounted) {
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final QuestStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case QuestStatus.available:
        color = AppTheme.primaryColor;
        label = 'Verfügbar';
        icon = Icons.check_circle_outline;
        break;
      case QuestStatus.inProgress:
        color = AppTheme.secondaryColor;
        label = 'Aktiv';
        icon = Icons.play_circle_outline;
        break;
      case QuestStatus.completed:
        color = Colors.blue;
        label = 'Abgeschlossen';
        icon = Icons.emoji_events;
        break;
      case QuestStatus.expired:
        color = Colors.grey;
        label = 'Abgelaufen';
        icon = Icons.timer_off;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final QuestDifficulty difficulty;

  const _DifficultyChip({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getDifficultyColor(difficulty.index + 1);
    String label;

    switch (difficulty) {
      case QuestDifficulty.level1:
        label = 'Stufe 1';
        break;
      case QuestDifficulty.level2:
        label = 'Stufe 2';
        break;
      case QuestDifficulty.level3:
        label = 'Stufe 3';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey[600])),
        Text(value),
      ],
    );
  }
}
