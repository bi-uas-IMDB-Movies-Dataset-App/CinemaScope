import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_config.dart';
import '../../models/profile.dart';
import 'supabase_service.dart';

class AuthService {
  final _sb = SupabaseService();
  SupabaseClient get _client => _sb.client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    final response = await _client.auth.signUp(email: email, password: password);
    final user = response.user;
    if (user == null) return;
    await _client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'role': 'viewer',
    });
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Profile> fetchOrCreateProfile(String userId, String email) async {
    final data = await _client.from('profiles').select().eq('id', userId).maybeSingle();

    if (data != null) return Profile.fromMap(data);

    await _client.from('profiles').upsert({
      'id': userId,
      'email': email,
      'role': 'viewer',
    });

    final created = await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromMap(created);
  }

  Future<List<Profile>> fetchProfiles() async {
    final data = await _client.from('profiles').select().order('created_at', ascending: false);
    final raw = (data as List).map((e) => Profile.fromMap(e)).toList();

    // Defensive deduplication by id in case legacy data contains duplicates in view results.
    final byId = <String, Profile>{};
    for (final profile in raw) {
      byId.putIfAbsent(profile.id, () => profile);
    }
    return byId.values.toList();
  }

  Future<void> updateRole(String userId, String role) async {
    await _client.from('profiles').update({'role': role}).eq('id', userId).select().single();
  }

  Future<void> createProfile({
    required String userId,
    required String email,
    required String role,
  }) async {
    await _client.from('profiles').insert({
      'id': userId,
      'email': email,
      'role': role,
    });
  }

  Future<void> createUserWithPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    final tempClient = SupabaseClient(
      SupabaseConfig.url,
      SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        detectSessionInUri: false,
      ),
    );

    final result = await tempClient.auth.signUp(email: email, password: password);
    final user = result.user;
    if (user == null) {
      throw Exception('Create user failed');
    }

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': email,
      'role': role,
    });
  }

  Future<void> updateProfile({
    required String userId,
    required String email,
    required String role,
  }) async {
    await _client.from('profiles').update({
      'email': email,
      'role': role,
    }).eq('id', userId).select().single();
  }

  Future<void> deleteProfile(String userId) async {
    final deleted = await _client
        .from('profiles')
        .delete()
        .eq('id', userId)
        .select('id')
        .maybeSingle();
    if (deleted == null) {
      throw Exception(
        'Delete failed on server. Ensure admin DELETE policy exists for profiles.',
      );
    }
  }
}

