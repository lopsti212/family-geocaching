import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/quest_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quest_provider.dart';
import '../../widgets/quest_card.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadQuests();
  }

  void _loadQuests() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.family != null) {
      context.read<QuestProvider>().loadQuests(authProvider.family!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final questProvider = context.watch<QuestProvider>();

    // Keine Familie? Zur Family-Seite
    if (!authProvider.hasFamily) {
      return _NoFamilyView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hallo, ${authProvider.user?.name ?? ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.family_restroom),
            onPressed: () => context.push('/family'),
            tooltip: 'Familie verwalten',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
            tooltip: 'Profil',
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
      floatingActionButton: authProvider.hasFamily
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/parent/create-quest'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Neue Schatzsuche'),
            )
          : null,
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
                'Keine Familie',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Erstelle zuerst eine Familie, um Schatzsuchen zu erstellen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/family'),
                icon: const Icon(Icons.add),
                label: const Text('Familie erstellen'),
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
              'Erstelle deine erste Schatzsuche für deine Kinder!',
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
    final pendingReview = quests.where((q) => q.status == QuestStatus.pendingReview).toList();
    final completed = quests.where((q) => q.status == QuestStatus.completed).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats
        _QuestStatsCard(
          available: available.length,
          active: inProgress.length,
          completed: completed.length,
          pendingReview: pendingReview.length,
        ),
        const SizedBox(height: 16),

        // Foto-Prüfung Banner
        if (pendingReview.isNotEmpty) ...[
          _SectionHeader(title: 'Foto prüfen', count: pendingReview.length),
          ...pendingReview.map((q) => QuestCard(
                quest: q,
                onTap: () => context.push('/parent/quest/${q.id}'),
              )),
          const SizedBox(height: 16),
        ],

        if (inProgress.isNotEmpty) ...[
          _SectionHeader(title: 'Aktiv', count: inProgress.length),
          ...inProgress.map((q) => QuestCard(
                quest: q,
                onTap: () => context.push('/parent/quest/${q.id}'),
              )),
          const SizedBox(height: 16),
        ],
        if (available.isNotEmpty) ...[
          _SectionHeader(title: 'Verfügbar', count: available.length),
          ...available.map((q) => QuestCard(
                quest: q,
                onTap: () => context.push('/parent/quest/${q.id}'),
              )),
          const SizedBox(height: 16),
        ],
        if (completed.isNotEmpty) ...[
          _SectionHeader(title: 'Abgeschlossen', count: completed.length),
          ...completed.map((q) => QuestCard(
                quest: q,
                onTap: () => context.push('/parent/quest/${q.id}'),
              )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestStatsCard extends StatelessWidget {
  final int available;
  final int active;
  final int completed;
  final int pendingReview;

  const _QuestStatsCard({
    required this.available,
    required this.active,
    required this.completed,
    this.pendingReview = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Verfügbar', value: available),
          Container(height: 32, width: 1, color: Colors.white30),
          _StatItem(label: 'Aktiv', value: active),
          Container(height: 32, width: 1, color: Colors.white30),
          if (pendingReview > 0) ...[
            _StatItem(label: 'Prüfen', value: pendingReview),
            Container(height: 32, width: 1, color: Colors.white30),
          ],
          _StatItem(label: 'Fertig', value: completed),
        ],
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
