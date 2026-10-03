import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Student?> getProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final List<dynamic> data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id);

    if (data.isEmpty) {
      return null;
    }

    return Student.fromMap(data.first);
  }

  Future<void> saveProfile(Student student) async {
    await _supabase
        .from('profiles')
        .upsert(
          student.toMap(),
          onConflict: 'id',
        );
  }
}