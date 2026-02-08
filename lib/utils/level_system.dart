import 'package:flutter/material.dart';

import '../models/quest_model.dart';

class LevelSystem {
  static int xpForDifficulty(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.level1:
        return 10;
      case QuestDifficulty.level2:
        return 25;
      case QuestDifficulty.level3:
        return 50;
      case QuestDifficulty.level4:
        return 100;
    }
  }

  static const List<LevelDefinition> levels = [
    LevelDefinition(level: 1, name: 'Entdecker', xpRequired: 0, icon: Icons.search),
    LevelDefinition(level: 2, name: 'Pfadfinder', xpRequired: 50, icon: Icons.directions_walk),
    LevelDefinition(level: 3, name: 'Abenteurer', xpRequired: 150, icon: Icons.hiking),
    LevelDefinition(level: 4, name: 'Schatzjäger', xpRequired: 350, icon: Icons.diamond),
    LevelDefinition(level: 5, name: 'Meister-Geocacher', xpRequired: 700, icon: Icons.military_tech),
  ];

  static LevelDefinition getLevelForXp(int xp) {
    LevelDefinition current = levels.first;
    for (final level in levels) {
      if (xp >= level.xpRequired) {
        current = level;
      } else {
        break;
      }
    }
    return current;
  }

  static LevelDefinition? getNextLevel(int xp) {
    for (final level in levels) {
      if (xp < level.xpRequired) return level;
    }
    return null; // Max Level erreicht
  }

  static double progressToNextLevel(int xp) {
    final current = getLevelForXp(xp);
    final next = getNextLevel(xp);
    if (next == null) return 1.0; // Max Level
    final range = next.xpRequired - current.xpRequired;
    final progress = xp - current.xpRequired;
    return progress / range;
  }
}

class LevelDefinition {
  final int level;
  final String name;
  final int xpRequired;
  final IconData icon;

  const LevelDefinition({
    required this.level,
    required this.name,
    required this.xpRequired,
    required this.icon,
  });
}
