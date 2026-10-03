import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileViewScreen extends StatefulWidget {
  final Student student;

  const ProfileViewScreen({
    super.key,
    required this.student,
  });

  @override
  State<ProfileViewScreen> createState() {
    return _ProfileViewScreenState();
  }
}

class _ProfileViewScreenState
    extends State<ProfileViewScreen> {
  static const Color maroon =
      Color(0xFF800000);

  static const Color lightMaroon =
      Color(0xFFF6EAEA);

  final AuthService authService =
      AuthService();

  late Student currentStudent;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    currentStudent = widget.student;
  }

  String getInitial(String name) {
    final String trimmed =
        name.trim();

    if (trimmed.isEmpty) {
      return 'S';
    }

    return trimmed[0].toUpperCase();
  }

  Future<void> openEditProfile() async {
    final Student? updatedStudent =
        await Navigator.push<Student>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditProfileScreen(
            student: currentStudent,
          );
        },
      ),
    );

    if (updatedStudent != null) {
      setState(() {
        currentStudent =
            updatedStudent;
      });
    }
  }

  Future<void> logout() async {
    final bool? confirm =
        await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor:
              Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              22,
              22,
              22,
              20,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                // Logout icon
                Container(
                  width: 58,
                  height: 58,
                  decoration:
                      const BoxDecoration(
                    color: lightMaroon,
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_outlined,
                    color: maroon,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'Log Out?',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Message
                Text(
                  'Are you sure you want to '
                  'log out of StudyCircle?',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 22),

                // Cancel button
                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                    style:
                        OutlinedButton
                            .styleFrom(
                      foregroundColor:
                          Colors.black87,
                      backgroundColor:
                          Colors.white,
                      side:
                          BorderSide(
                        color: Colors
                            .grey
                            .shade300,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Log out button
                SizedBox(
                  width:
                      double.infinity,
                  height: 50,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          maroon,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? error =
        await authService.logout();

    if (!mounted) {
      return;
    }

    if (error != null) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content: Text(error),
        ),
      );

      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
        currentStudent.displayName
                .trim()
                .isNotEmpty
            ? currentStudent.displayName
            : currentStudent.fullName;

    final String initial =
        getInitial(displayName);

    return SingleChildScrollView(
      padding:
          const EdgeInsets.fromLTRB(
        24,
        30,
        24,
        30,
      ),
      child: Column(
        children: [
          // Profile avatar
          CircleAvatar(
            radius: 46,
            backgroundColor:
                lightMaroon,
            child: Text(
              initial,
              style:
                  const TextStyle(
                color: maroon,
                fontSize: 36,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // StudyCircle Name
          Text(
            displayName,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
              color: maroon,
            ),
          ),

          const SizedBox(height: 6),

          // Formal Name
          Text(
            currentStudent.fullName,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'UM Student',
            style: TextStyle(
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 30),

          // StudyCircle Name
          _buildInfoCard(
            icon:
                Icons.alternate_email,
            title:
                'StudyCircle Name',
            value:
                currentStudent
                        .displayName
                        .isNotEmpty
                    ? currentStudent
                        .displayName
                    : 'Not provided',
          ),

          const SizedBox(height: 12),

          // First Name
          _buildInfoCard(
            icon:
                Icons.person_outline,
            title:
                'First Name',
            value:
                currentStudent
                        .firstName
                        .isNotEmpty
                    ? currentStudent
                        .firstName
                    : 'Not provided',
          ),

          const SizedBox(height: 12),

          // Middle Initial
          _buildInfoCard(
            icon:
                Icons.person_outline,
            title:
                'Middle Initial',
            value:
                currentStudent
                        .middleInitial
                        .isEmpty
                    ? 'Not provided'
                    : '${currentStudent.middleInitial}.',
          ),

          const SizedBox(height: 12),

          // Family Name
          _buildInfoCard(
            icon:
                Icons.person_outline,
            title:
                'Family Name',
            value:
                currentStudent
                        .lastName
                        .isNotEmpty
                    ? currentStudent
                        .lastName
                    : 'Not provided',
          ),

          const SizedBox(height: 12),

          // Course
          _buildInfoCard(
            icon:
                Icons.school_outlined,
            title:
                'Course',
            value:
                currentStudent.course,
          ),

          const SizedBox(height: 12),

          // Year Level
          _buildInfoCard(
            icon:
                Icons.calendar_today_outlined,
            title:
                'Year Level',
            value:
                currentStudent.yearLevel,
          ),

          const SizedBox(height: 30),

          // Edit Profile
          SizedBox(
            width:
                double.infinity,
            height: 50,
            child:
                ElevatedButton.icon(
              onPressed:
                  openEditProfile,
              icon:
                  const Icon(
                Icons.edit,
              ),
              label:
                  const Text(
                'Edit Profile',
              ),
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    maroon,
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Log Out
          SizedBox(
            width:
                double.infinity,
            height: 50,
            child:
                OutlinedButton.icon(
              onPressed:
                  isLoading
                      ? null
                      : logout,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: maroon,
                      ),
                    )
                  : const Icon(
                      Icons.logout,
                    ),
              label:
                  Text(
                isLoading
                    ? 'Logging out...'
                    : 'Log Out',
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    maroon,
                side:
                    const BorderSide(
                  color: maroon,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                const BoxDecoration(
              color: lightMaroon,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: maroon,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}