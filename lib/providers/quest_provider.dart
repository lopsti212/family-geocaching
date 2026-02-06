import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/quest_model.dart';
import '../services/supabase_service.dart';

class QuestProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();

  List<QuestModel> _quests = [];
  QuestModel? _selectedQuest;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _questSubscription;

  List<QuestModel> get quests => _quests;
  QuestModel? get selectedQuest => _selectedQuest;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Gefilterte Listen
  List<QuestModel> get availableQuests =>
      _quests.where((q) => q.status == QuestStatus.available).toList();

  List<QuestModel> get completedQuests =>
      _quests.where((q) => q.status == QuestStatus.completed).toList();

  List<QuestModel> get inProgressQuests =>
      _quests.where((q) => q.status == QuestStatus.inProgress).toList();

  // Quests für eine Familie laden
  Future<void> loadQuests(String familyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quests = await _supabaseService.getQuestsForFamily(familyId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verfügbare Quests für ein Kind laden
  Future<void> loadAvailableQuestsForChild(String familyId, String childId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _quests = await _supabaseService.getAvailableQuestsForChild(familyId, childId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Echtzeit-Updates starten
  void startRealtimeUpdates(String familyId) {
    _questSubscription?.cancel();
    _questSubscription = _supabaseService.questsStream(familyId).listen((quests) {
      _quests = quests;
      notifyListeners();
    });
  }

  // Neue Quest erstellen (Eltern)
  Future<bool> createQuest({
    required String title,
    String? description,
    required String createdBy,
    String? assignedTo,
    required String familyId,
    required double latitude,
    required double longitude,
    required QuestDifficulty difficulty,
    required Reward reward,
    DateTime? expiresAt,
    double? hintRadius,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final quest = QuestModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        createdBy: createdBy,
        assignedTo: assignedTo,
        familyId: familyId,
        targetLatitude: latitude,
        targetLongitude: longitude,
        difficulty: difficulty,
        reward: reward,
        status: QuestStatus.available,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
        hintRadiusValue: hintRadius,
      );

      final createdQuest = await _supabaseService.createQuest(quest);
      _quests.insert(0, createdQuest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Quest auswählen
  Future<void> selectQuest(String questId) async {
    _selectedQuest = _quests.firstWhere(
      (q) => q.id == questId,
      orElse: () => _quests.first,
    );
    notifyListeners();
  }

  // Quest starten (Kind)
  Future<bool> startQuest(String questId) async {
    try {
      final questIndex = _quests.indexWhere((q) => q.id == questId);
      if (questIndex == -1) return false;

      final updatedQuest = _quests[questIndex].copyWith(
        status: QuestStatus.inProgress,
      );

      await _supabaseService.updateQuest(updatedQuest);
      _quests[questIndex] = updatedQuest;
      _selectedQuest = updatedQuest;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Quest abschließen (Kind hat Ziel erreicht)
  Future<bool> completeQuest(String questId) async {
    try {
      await _supabaseService.completeQuest(questId);

      final questIndex = _quests.indexWhere((q) => q.id == questId);
      if (questIndex != -1) {
        _quests[questIndex] = _quests[questIndex].copyWith(
          status: QuestStatus.completed,
          completedAt: DateTime.now(),
        );
        _selectedQuest = _quests[questIndex];
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Quest löschen (Eltern)
  Future<bool> deleteQuest(String questId) async {
    try {
      await _supabaseService.deleteQuest(questId);
      _quests.removeWhere((q) => q.id == questId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _questSubscription?.cancel();
    super.dispose();
  }
}
