import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student.dart';
import '../models/message.dart';
import '../models/study_group.dart';

class GroupService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  Future<List<StudyGroup>> getGroups() async {
    final List<dynamic> data =
        await _supabase
            .from('study_groups')
            .select()
            .order(
              'created_at',
              ascending: false,
            );

    return data
        .map(
          (group) => StudyGroup.fromMap(
            Map<String, dynamic>.from(
              group,
            ),
          ),
        )
        .toList();
  }

  Future<List<StudyGroup>> getMyGroups() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final List<dynamic> data =
        await _supabase
            .from('group_members')
            .select('study_groups(*)')
            .eq(
              'user_id',
              user.id,
            )
            .order(
              'joined_at',
              ascending: false,
            );

    final List<StudyGroup> groups = [];

    for (final item in data) {
      final dynamic groupData =
          item['study_groups'];

      if (groupData is Map) {
        groups.add(
          StudyGroup.fromMap(
            Map<String, dynamic>.from(
              groupData,
            ),
          ),
        );
      }
    }

    return groups;
  }

  Future<List<StudyGroup>> getCreatedGroups() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final List<dynamic> data =
        await _supabase
            .from('study_groups')
            .select()
            .eq(
              'creator_id',
              user.id,
            )
            .order(
              'created_at',
              ascending: false,
            );

    return data
        .map(
          (group) => StudyGroup.fromMap(
            Map<String, dynamic>.from(
              group,
            ),
          ),
        )
        .toList();
  }

  Future<List<StudyGroup>> getJoinedGroups() async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final List<dynamic> data =
        await _supabase
            .from('group_members')
            .select(
              'group_id, user_id, study_groups(*)',
            )
            .eq(
              'user_id',
              user.id,
            )
            .order(
              'joined_at',
              ascending: false,
            );

    final List<StudyGroup> groups = [];

    for (final item in data) {
      final dynamic groupData =
          item['study_groups'];

      if (groupData is! Map) {
        continue;
      }

      final StudyGroup group =
          StudyGroup.fromMap(
        Map<String, dynamic>.from(
          groupData,
        ),
      );

      if (group.creatorId != user.id) {
        groups.add(group);
      }
    }

    return groups;
  }

  Future<void> createGroup({
    required String subject,
    required String title,
    required String description,
    required String location,
    required String schedule,
  }) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final Map<String, dynamic> groupData =
        await _supabase
            .from('study_groups')
            .insert({
              'creator_id': user.id,
              'subject': subject,
              'title': title,
              'description': description,
              'location': location,
              'schedule': schedule,
            })
            .select('id')
            .single();

    final int groupId =
        groupData['id'] as int;

    // Creator automatically becomes
    // a member of the group.
    await _supabase
        .from('group_members')
        .insert({
          'group_id': groupId,
          'user_id': user.id,
        });
  }

  Future<void> joinGroup(
    int groupId,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final Map<String, dynamic>?
        groupData =
        await _supabase
            .from('study_groups')
            .select('creator_id')
            .eq(
              'id',
              groupId,
            )
            .maybeSingle();

    if (groupData == null) {
      throw Exception(
        'Study group not found.',
      );
    }

    final String creatorId =
        groupData['creator_id'].toString();

    // Creator cannot join their own group.
    if (creatorId == user.id) {
      throw Exception(
        'You created this group.',
      );
    }

    final Map<String, dynamic>?
        existingMembership =
        await _supabase
            .from('group_members')
            .select('id')
            .eq(
              'group_id',
              groupId,
            )
            .eq(
              'user_id',
              user.id,
            )
            .maybeSingle();

    if (existingMembership != null) {
      throw Exception(
        'You are already a member of this group.',
      );
    }

    await _supabase
        .from('group_members')
        .insert({
          'group_id': groupId,
          'user_id': user.id,
        });
  }

  Future<void> leaveGroup(
    int groupId,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final Map<String, dynamic>?
        groupData =
        await _supabase
            .from('study_groups')
            .select('creator_id')
            .eq(
              'id',
              groupId,
            )
            .maybeSingle();

    if (groupData == null) {
      throw Exception(
        'Study group not found.',
      );
    }

    final String creatorId =
        groupData['creator_id'].toString();

    // Creator must delete the group instead
    // of leaving it.
    if (creatorId == user.id) {
      throw Exception(
        'The group creator cannot leave the group.',
      );
    }

    await _supabase
        .from('group_members')
        .delete()
        .eq(
          'group_id',
          groupId,
        )
        .eq(
          'user_id',
          user.id,
        );
  }

  Future<void> deleteGroup(
    int groupId,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final Map<String, dynamic>?
        groupData =
        await _supabase
            .from('study_groups')
            .select('creator_id')
            .eq(
              'id',
              groupId,
            )
            .maybeSingle();

    if (groupData == null) {
      throw Exception(
        'Study group not found.',
      );
    }

    final String creatorId =
        groupData['creator_id'].toString();

    // Only the creator can delete the group.
    if (creatorId != user.id) {
      throw Exception(
        'Only the group creator can delete this group.',
      );
    }

    // Delete chat messages first.
    await _supabase
        .from('messages')
        .delete()
        .eq(
          'group_id',
          groupId,
        );

    // Delete all members.
    await _supabase
        .from('group_members')
        .delete()
        .eq(
          'group_id',
          groupId,
        );

    // Finally delete the study group.
    await _supabase
        .from('study_groups')
        .delete()
        .eq(
          'id',
          groupId,
        )
        .eq(
          'creator_id',
          user.id,
        );
  }

  Future<int> getMemberCount(
    int groupId,
  ) async {
    final response =
        await _supabase
            .from('group_members')
            .select('id')
            .eq(
              'group_id',
              groupId,
            )
            .count();

    return response.count;
  }

  Future<bool> isMember(
    int groupId,
  ) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      return false;
    }

    // The creator is always treated as a member.
    final Map<String, dynamic>?
        groupData =
        await _supabase
            .from('study_groups')
            .select('creator_id')
            .eq(
              'id',
              groupId,
            )
            .maybeSingle();

    if (groupData != null &&
        groupData['creator_id']
                .toString() ==
            user.id) {
      return true;
    }

    final Map<String, dynamic>?
        membership =
        await _supabase
            .from('group_members')
            .select('id')
            .eq(
              'group_id',
              groupId,
            )
            .eq(
              'user_id',
              user.id,
            )
            .maybeSingle();

    return membership != null;
  }

  Future<List<Student>> getGroupMembers(
    int groupId,
  ) async {
    final List<dynamic> memberData =
        await _supabase
            .from('group_members')
            .select('user_id')
            .eq(
              'group_id',
              groupId,
            )
            .order(
              'joined_at',
              ascending: true,
            );

    if (memberData.isEmpty) {
      return [];
    }

    final List<String> userIds =
        memberData
            .map(
              (item) =>
                  item['user_id'] as String,
            )
            .toList();

    final List<dynamic> profileData =
        await _supabase
            .from('profiles')
            .select(
              'id, first_name, middle_initial, '
              'last_name, display_name, '
              'full_name, course, year_level',
            )
            .inFilter(
              'id',
              userIds,
            );

    return profileData
        .map(
          (profile) => Student.fromMap(
            Map<String, dynamic>.from(
              profile,
            ),
          ),
        )
        .toList();
  }

  Future<Student?> getStudentById(
    String userId,
  ) async {
    final List<dynamic> data =
        await _supabase
            .from('profiles')
            .select(
              'id, first_name, middle_initial, '
              'last_name, display_name, '
              'full_name, course, year_level',
            )
            .eq(
              'id',
              userId,
            )
            .limit(1);

    if (data.isEmpty) {
      return null;
    }

    return Student.fromMap(
      Map<String, dynamic>.from(
        data.first,
      ),
    );
  }

  Future<List<Message>> getMessages(
    int groupId,
  ) async {
    final List<dynamic> data =
        await _supabase
            .from('messages')
            .select()
            .eq(
              'group_id',
              groupId,
            )
            .order(
              'created_at',
              ascending: true,
            );

    final List<Map<String, dynamic>>
        sortedData = data
            .map(
              (message) =>
                  Map<String, dynamic>.from(
                message,
              ),
            )
            .toList();

    sortedData.sort((a, b) {
      final DateTime timeA =
          DateTime.tryParse(
                a['created_at']
                        ?.toString() ??
                    '',
              ) ??
              DateTime
                  .fromMillisecondsSinceEpoch(
                0,
              );

      final DateTime timeB =
          DateTime.tryParse(
                b['created_at']
                        ?.toString() ??
                    '',
              ) ??
              DateTime
                  .fromMillisecondsSinceEpoch(
                0,
              );

      return timeA.compareTo(timeB);
    });

    return sortedData
        .map(
          (message) => Message.fromMap(
            message,
          ),
        )
        .toList();
  }

  Future<Map<String, Student>>
      getMessageSenders(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) {
      return {};
    }

    final List<dynamic> profileData =
        await _supabase
            .from('profiles')
            .select(
              'id, first_name, middle_initial, '
              'last_name, display_name, '
              'full_name, course, year_level',
            )
            .inFilter(
              'id',
              userIds,
            );

    final Map<String, Student>
        senders = {};

    for (final profile in profileData) {
      final Student student =
          Student.fromMap(
        Map<String, dynamic>.from(
          profile,
        ),
      );

      senders[student.id] =
          student;
    }

    return senders;
  }

  Future<void> sendMessage({
    required int groupId,
    required String message,
  }) async {
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    await _supabase
        .from('messages')
        .insert({
          'group_id': groupId,
          'sender_id': user.id,
          'message': message,
        });
  }
}