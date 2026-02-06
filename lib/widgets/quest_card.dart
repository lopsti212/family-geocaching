import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/quest_model.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;
  final VoidCallback? onTap;

  const QuestCard({
    super.key,
    required this.quest,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = AppTheme.getDifficultyColor(quest.difficulty.index + 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Titel und Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusBadge(status: quest.status),
                ],
              ),
              if (quest.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  quest.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),

              // Footer: Schwierigkeit und Belohnung
              Row(
                children: [
                  // Schwierigkeit
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDifficultyIcon(quest.difficulty),
                          size: 14,
                          color: difficultyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Stufe ${quest.difficulty.index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: difficultyColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Belohnung
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 16,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        quest.reward.displayText,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDifficultyIcon(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.level1:
        return Icons.location_on;
      case QuestDifficulty.level2:
        return Icons.radar;
      case QuestDifficulty.level3:
        return Icons.explore;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final QuestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case QuestStatus.available:
        color = AppTheme.primaryColor;
        label = 'Offen';
        icon = Icons.check_circle_outline;
        break;
      case QuestStatus.inProgress:
        color = AppTheme.secondaryColor;
        label = 'Aktiv';
        icon = Icons.play_circle_outline;
        break;
      case QuestStatus.completed:
        color = Colors.blue;
        label = 'Fertig';
        icon = Icons.emoji_events;
        break;
      case QuestStatus.expired:
        color = Colors.grey;
        label = 'Abgelaufen';
        icon = Icons.timer_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
