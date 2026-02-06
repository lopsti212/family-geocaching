import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../models/family_model.dart';
import '../models/quest_model.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // Initialisierung
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }

  // ============ AUTH ============

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // ============ USERS ============

  Future<UserModel?> getUserProfile(String userId) async {
    final response = await client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  Future<void> createUserProfile(UserModel user) async {
    await client.from(SupabaseConfig.usersTable).insert(user.toJson());
  }

  Future<void> updateUserProfile(UserModel user) async {
    await client
        .from(SupabaseConfig.usersTable)
        .update(user.toJson())
        .eq('id', user.id);
  }

  Future<List<UserModel>> getFamilyMembers(String familyId) async {
    final response = await client
        .from(SupabaseConfig.usersTable)
        .select()
        .eq('family_id', familyId);

    return (response as List)
        .map((json) => UserModel.fromJson(json))
        .toList();
  }

  // ============ FAMILIES ============

  Future<FamilyModel> createFamily(String name, String userId) async {
    final inviteCode = _generateInviteCode();
    final family = {
      'name': name,
      'created_by': userId,
      'invite_code': inviteCode,
      'created_at': DateTime.now().toIso8601String(),
    };

    final response = await client
        .from(SupabaseConfig.familiesTable)
        .insert(family)
        .select()
        .single();

    return FamilyModel.fromJson(response);
  }

  Future<FamilyModel?> getFamilyByInviteCode(String inviteCode) async {
    final response = await client
        .from(SupabaseConfig.familiesTable)
        .select()
        .eq('invite_code', inviteCode)
        .maybeSingle();

    if (response == null) return null;
    return FamilyModel.fromJson(response);
  }

  Future<FamilyModel?> getFamily(String familyId) async {
    final response = await client
        .from(SupabaseConfig.familiesTable)
        .select()
        .eq('id', familyId)
        .maybeSingle();

    if (response == null) return null;
    return FamilyModel.fromJson(response);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i * 7) % chars.length];
    }
    return code;
  }

  // ============ QUESTS ============

  Future<QuestModel> createQuest(QuestModel quest) async {
    final response = await client
        .from(SupabaseConfig.questsTable)
        .insert(quest.toJson())
        .select()
        .single();

    return QuestModel.fromJson(response);
  }

  Future<void> updateQuest(QuestModel quest) async {
    await client
        .from(SupabaseConfig.questsTable)
        .update(quest.toJson())
        .eq('id', quest.id);
  }

  Future<void> deleteQuest(String questId) async {
    await client
        .from(SupabaseConfig.questsTable)
        .delete()
        .eq('id', questId);
  }

  Future<List<QuestModel>> getQuestsForFamily(String familyId) async {
    final response = await client
        .from(SupabaseConfig.questsTable)
        .select()
        .eq('family_id', familyId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => QuestModel.fromJson(json))
        .toList();
  }

  Future<List<QuestModel>> getAvailableQuestsForChild(
    String familyId,
    String childId,
  ) async {
    final response = await client
        .from(SupabaseConfig.questsTable)
        .select()
        .eq('family_id', familyId)
        .inFilter('status', [QuestStatus.available.name, QuestStatus.inProgress.name, QuestStatus.completed.name])
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => QuestModel.fromJson(json))
        .toList();
  }

  Future<QuestModel?> getQuest(String questId) async {
    final response = await client
        .from(SupabaseConfig.questsTable)
        .select()
        .eq('id', questId)
        .maybeSingle();

    if (response == null) return null;
    return QuestModel.fromJson(response);
  }

  // Quest als abgeschlossen markieren
  Future<void> completeQuest(String questId) async {
    await client
        .from(SupabaseConfig.questsTable)
        .update({
          'status': QuestStatus.completed.name,
          'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', questId);
  }

  // Echtzeit-Updates für Quests
  Stream<List<QuestModel>> questsStream(String familyId) {
    return client
        .from(SupabaseConfig.questsTable)
        .stream(primaryKey: ['id'])
        .eq('family_id', familyId)
        .map((data) => data.map((json) => QuestModel.fromJson(json)).toList());
  }
}
