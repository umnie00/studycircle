import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String emailRedirectTo =
      'studycircle://login-callback/';

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return 'Something went wrong.';
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: emailRedirectTo,
        queryParams: {
          'hd': 'umindanao.edu.ph',
          'prompt': 'select_account',
        },
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return 'Could not start Google sign-in.';
    }
  }

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return 'Something went wrong.';
    }
  }

  Future<String?> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: emailRedirectTo,
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return 'Could not send the password reset email.';
    }
  }

  Future<String?> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return 'Could not update your password.';
    }
  }

  Future<String?> logout() async {
    try {
      await _supabase.auth.signOut();

      return null;
    } on AuthException catch (error) {
      return error.message;
    } catch (error) {
      return 'Could not log out.';
    }
  }
}