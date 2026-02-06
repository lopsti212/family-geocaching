import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/quest_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quest_provider.dart';
import '../../widgets/quest_card.dart';

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  void _loadQuests() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.family != null && authProvider.user != null) {
      context.read<QuestProvider>().loadAvailableQuestsForChild(
            authProvider.family!.id,
            authProvider.user!.id,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final questProvider = context.watch<QuestProvider>();

    // Keine Familie?
    if (!authProvider.hasFamily) {
      return _NoFamilyView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hallo, ${authProvider.user?.name ?? ""}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.family_restroom),
            onPressed: () => context.push('/family'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: questProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadQuests(),
              child: questProvider.quests.isEmpty
                  ? _EmptyQuestsView()
                  : _QuestListView(quests: questProvider.quests),
            ),
    );
  }
}

class _NoFamilyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Geocaching')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.family_restroom,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Tritt einer Familie bei',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Frage deine Eltern nach dem Familien-Code, um Schatzsuchen zu sehen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/family'),
                icon: const Icon(Icons.group_add),
                label: const Text('Familie beitreten'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyQuestsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Keine Schatzsuchen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Deine Eltern haben noch keine Schatzsuche für dich erstellt.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestListView extends StatelessWidget {
  final List<QuestModel> quests;

  const _QuestListView({required this.quests});

  @override
  Widget build(BuildContext context) {
    final available = quests.where((q) => q.status == QuestStatus.available).toList();
    final inProgress = quests.where((q) => q.status == QuestStatus.inProgress).toList();
    final completed = quests.where((q) => q.status == QuestStatus.completed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        _QuestStatsCard(
          completed: completed.length,
          open: available.length + inProgress.length,
        ),
        const SizedBox(height: 16),

        // Aktive Quests
        if (inProgress.isNotEmpty) ...[
          Text(
            'Aktive Schatzsuchen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...inProgress.map((q) => _ActiveQuestBanner(quest: q)),
          const SizedBox(height: 24),
        ],

        // Verfügbare Quests
        if (available.isNotEmpty) ...[
          Text(
            'Verfügbare Schatzsuchen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...available.map((q) => _ChildQuestCard(quest: q)),
          const SizedBox(height: 24),
        ],

        // Abgeschlossene Quests
        if (completed.isNotEmpty) ...[
          Text(
            'Geschafft!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...completed.map((q) => _CompletedQuestCard(quest: q)),
        ],
      ],
    );
  }
}

class _ActiveQuestBanner extends StatelessWidget {
  final QuestModel quest;

  const _ActiveQuestBanner({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.secondaryColor,
      child: InkWell(
        onTap: () => context.push('/child/hunt/${quest.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_run,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aktive Schatzsuche',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          quest.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Weiter suchen',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildQuestCard extends StatelessWidget {
  final QuestModel quest;

  const _ChildQuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final difficultyColor = AppTheme.getDifficultyColor(quest.difficulty.index + 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStartDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Schwierigkeitsindikator
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      quest.difficulty == QuestDifficulty.level1
                          ? Icons.location_on
                          : quest.difficulty == QuestDifficulty.level2
                              ? Icons.radar
                              : Icons.explore,
                      color: difficultyColor,
                    ),
                    Text(
                      'Stufe ${quest.difficulty.index + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        color: difficultyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_filled,
                size: 40,
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(quest.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (quest.description != null) ...[
              Text(quest.description!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Icon(Icons.card_giftcard, color: AppTheme.secondaryColor),
                const SizedBox(width: 8),
                Text(
                  'Belohnung: ${quest.reward.displayText}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quest.difficultyDisplayText,
              style: TextStyle(
                color: AppTheme.getDifficultyColor(quest.difficulty.index + 1),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<QuestProvider>().startQuest(quest.id);
              if (context.mounted) {
                context.push('/child/hunt/${quest.id}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Starten!'),
          ),
        ],
      ),
    );
  }
}

class _CompletedQuestCard extends StatelessWidget {
  final QuestModel quest;

  const _CompletedQuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    quest.reward.displayText,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class _QuestStatsCard extends StatelessWidget {
  final int completed;
  final int open;

  const _QuestStatsCard({required this.completed, required this.open});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(label: 'Geschafft', value: completed),
            Container(
              height: 32,
              width: 1,
              color: Colors.white38,
            ),
            _StatItem(label: 'Offen', value: open),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
