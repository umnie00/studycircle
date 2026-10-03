import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

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

  Future<String?> register({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(
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