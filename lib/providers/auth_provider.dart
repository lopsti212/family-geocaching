import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import '../models/user_model.dart';
import '../models/family_model.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  UserModel? _user;
  FamilyModel? _family;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<AuthState>? _authSubscription;

  UserModel? get user => _user;
  FamilyModel? get family => _family;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get hasFamily => _family != null;
  bool get isParent => _user?.role == UserRole.parent;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authSubscription = _supabaseService.authStateChanges.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        await _loadUserProfile();
      } else if (event.event == AuthChangeEvent.signedOut) {
        _user = null;
        _family = null;
        notifyListeners();
      }
    });

    // Prüfen ob bereits eingeloggt
    final currentUser = _supabaseService.currentUser;
    if (currentUser != null) {
      await _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    final authUser = _supabaseService.currentUser;
    if (authUser == null) return;

    _user = await _supabaseService.getUserProfile(authUser.id);
    if (_user?.familyId != null) {
      _family = await _supabaseService.getFamily(_user!.familyId!);
    }
    notifyListeners();
  }

  // Registrierung
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final newUser = UserModel(
          id: response.user!.id,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );

        await _supabaseService.createUserProfile(newUser);
        _user = newUser;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Registrierung fehlgeschlagen';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Login fehlgeschlagen';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _supabaseService.signOut();
    _user = null;
    _family = null;
    notifyListeners();
  }

  // Familie erstellen (für Eltern)
  Future<bool> createFamily(String familyName) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _family = await _supabaseService.createFamily(familyName, _user!.id);
      _user = _user!.copyWith(familyId: _family!.id);
      await _supabaseService.updateUserProfile(_user!);

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

  // Familie beitreten (für Kinder)
  Future<bool> joinFamily(String inviteCode) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final family = await _supabaseService.getFamilyByInviteCode(inviteCode);
      if (family == null) {
        _error = 'Ungültiger Einladungscode';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _family = family;
      _user = _user!.copyWith(familyId: family.id);
      await _supabaseService.updateUserProfile(_user!);

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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
