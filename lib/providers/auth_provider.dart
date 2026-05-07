import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/auth_service.dart';
import '../models/profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  Profile? profile;
  List<Profile> users = [];
  bool isLoading = false;
  bool isUsersLoading = false;
  bool isRoleUpdating = false;
  String? error;

  bool get isLoggedIn => _service.currentUser != null;
  String? get role => profile?.role;
  Stream<AuthState> get authChanges => _service.onAuthStateChange;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    error = null;
    try {
      await _service.signIn(email: email.trim().toLowerCase(), password: password);
      await loadProfile();
    } on AuthException catch (e) {
      error = _mapError(e.message);
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    error = null;
    try {
      await _service.signUp(email: email.trim().toLowerCase(), password: password);
    } on AuthException catch (e) {
      error = _mapError(e.message);
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile() async {
    final user = _service.currentUser;
    if (user == null) return;
    error = null;
    try {
      profile = await _service.fetchOrCreateProfile(user.id, user.email ?? '');
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.signOut();
    profile = null;
    users = [];
    notifyListeners();
  }

  Future<void> loadUsers() async {
    isUsersLoading = true;
    error = null;
    notifyListeners();
    try {
      users = await _service.fetchProfiles();
    } catch (e) {
      error = e.toString();
    } finally {
      isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<String?> changeUserRole({
    required String userId,
    required String role,
  }) async {
    final existing = users.where((u) => u.id == userId).cast<Profile?>().firstWhere(
          (u) => u != null,
          orElse: () => null,
        );
    if (existing != null && existing.role.toLowerCase() == role.toLowerCase()) {
      return null;
    }

    isRoleUpdating = true;
    error = null;
    notifyListeners();
    try {
      await _service.updateRole(userId, role);
      await loadUsers();
      if (profile?.id == userId && profile != null) {
        profile = Profile(id: profile!.id, email: profile!.email, role: role);
      }
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isRoleUpdating = false;
      notifyListeners();
    }
  }

  Future<String?> createUserProfile({
    required String userId,
    required String email,
    required String role,
  }) async {
    isUsersLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.createProfile(userId: userId.trim(), email: email.trim().toLowerCase(), role: role);
      await loadUsers();
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateUserProfile({
    required String userId,
    required String email,
    required String role,
  }) async {
    isUsersLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.updateProfile(userId: userId, email: email.trim().toLowerCase(), role: role);
      await loadUsers();
      if (profile?.id == userId && profile != null) {
        profile = Profile(id: profile!.id, email: email.trim().toLowerCase(), role: role);
      }
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isUsersLoading = false;
      notifyListeners();
    }
  }

  Future<String?> deleteUserProfile(String userId) async {
    isUsersLoading = true;
    error = null;
    notifyListeners();
    try {
      await _service.deleteProfile(userId);
      await loadUsers();
      return null;
    } catch (e) {
      final msg = e.toString();
      error = msg;
      return msg;
    } finally {
      isUsersLoading = false;
      notifyListeners();
    }
  }

  String _mapError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials')) return 'Invalid email or password';
    if (msg.contains('email not confirmed')) return 'Please verify your email first';
    if (msg.contains('already registered')) return 'This email is already registered';
    return 'Authentication failed. Please try again.';
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
