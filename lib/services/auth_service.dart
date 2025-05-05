import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Registro de usuario
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  /// Login de usuario
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream de sesión para escuchar cambios (útil si querés navegación reactiva)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
