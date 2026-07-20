import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService([SupabaseClient? client])
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  User? get currentUser => _auth.currentUser;

  Session? get currentSession => _auth.currentSession;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _auth.signUp(
      email: email,
      password: password,
    );
    final User? user = response.user;
    if (response.session != null && user != null) {
      await ensureUserProfile(user);
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> ensureUserProfile(User user) {
    final Map<String, String> profile = <String, String>{
      'id': user.id,
      'email': user.email ?? '',
    };
    return _client
        .from('users')
        .upsert(profile, onConflict: 'id', ignoreDuplicates: true);
  }
}
