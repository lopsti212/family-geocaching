import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _familyNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  List<UserModel> _familyMembers = [];
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyMembers() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.family == null) return;

    setState(() => _isLoadingMembers = true);

    try {
      final members = await SupabaseService()
          .getFamilyMembers(authProvider.family!.id);
      setState(() {
        _familyMembers = members;
        _isLoadingMembers = false;
      });
    } catch (e) {
      setState(() => _isLoadingMembers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Familie'),
      ),
      body: authProvider.hasFamily
          ? _FamilyInfoView(
              family: authProvider.family!,
              members: _familyMembers,
              isLoadingMembers: _isLoadingMembers,
              onRefresh: _loadFamilyMembers,
            )
          : authProvider.isParent
              ? _CreateFamilyView(controller: _familyNameController)
              : _JoinFamilyView(controller: _inviteCodeController),
    );
  }
}

// Familieninfo anzeigen
class _FamilyInfoView extends StatelessWidget {
  final dynamic family;
  final List<UserModel> members;
  final bool isLoadingMembers;
  final VoidCallback onRefresh;

  const _FamilyInfoView({
    required this.family,
    required this.members,
    required this.isLoadingMembers,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Familienname
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.family_restroom,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    family.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Einladungscode (nur für Eltern)
          if (authProvider.isParent) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.vpn_key, color: AppTheme.secondaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Einladungscode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Teile diesen Code mit deinen Kindern:',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              family.inviteCode,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: family.inviteCode),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code kopiert!')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          tooltip: 'Kopieren',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Familienmitglieder
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Mitglieder',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isLoadingMembers)
                    const Center(child: CircularProgressIndicator())
                  else if (members.isEmpty)
                    const Text('Keine Mitglieder gefunden')
                  else
                    ...members.map((member) => _MemberTile(member: member)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserModel member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: member.role == UserRole.parent
            ? AppTheme.primaryColor
            : AppTheme.secondaryColor,
        child: Icon(
          member.role == UserRole.parent ? Icons.person : Icons.child_care,
          color: Colors.white,
        ),
      ),
      title: Text(member.name),
      subtitle: Text(
        member.role == UserRole.parent ? 'Elternteil' : 'Kind',
      ),
    );
  }
}

// Familie erstellen (Eltern)
class _CreateFamilyView extends StatelessWidget {
  final TextEditingController controller;

  const _CreateFamilyView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Padding(
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
            'Erstelle deine Familie',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Gib deiner Familie einen Namen. Danach erhältst du einen Code zum Teilen mit deinen Kindern.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Familienname',
              hintText: 'z.B. Familie Müller',
              prefixIcon: Icon(Icons.home),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      if (controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bitte Namen eingeben'),
                          ),
                        );
                        return;
                      }
                      await authProvider.createFamily(controller.text.trim());
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Familie erstellen'),
            ),
          ),
        ],
      ),
    );
  }
}

// Familie beitreten (Kinder)
class _JoinFamilyView extends StatelessWidget {
  final TextEditingController controller;

  const _JoinFamilyView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Familie beitreten',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Frage deine Eltern nach dem Familien-Code und gib ihn hier ein.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Einladungscode',
              hintText: 'z.B. ABC123',
              prefixIcon: Icon(Icons.vpn_key),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      if (controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bitte Code eingeben')),
                        );
                        return;
                      }
                      final success = await authProvider
                          .joinFamily(controller.text.trim().toUpperCase());
                      if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              authProvider.error ?? 'Fehler beim Beitreten',
                            ),
                            backgroundColor: AppTheme.errorColor,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Beitreten'),
            ),
          ),
        ],
      ),
    );
  }
}
