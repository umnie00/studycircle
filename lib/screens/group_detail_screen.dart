import 'package:flutter/material.dart';

import '../models/student.dart';
import '../models/study_group.dart';
import '../services/group_service.dart';
import 'chat_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final StudyGroup group;

  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailScreen> createState() {
    return _GroupDetailScreenState();
  }
}

class _GroupDetailScreenState
    extends State<GroupDetailScreen> {
  static const Color maroon =
      Color(0xFF800000);

  static const Color lightMaroon =
      Color(0xFFF6EAEA);

  static const Color backgroundColor =
      Color(0xFFF9F9F9);

  final GroupService groupService =
      GroupService();

  late Future<int> memberCountFuture;
  late Future<bool> membershipFuture;
  late Future<List<Student>> membersFuture;
  late Future<Student?> creatorFuture;

  bool isJoining = false;
  bool isLeaving = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    memberCountFuture =
        groupService.getMemberCount(
      widget.group.id,
    );

    membershipFuture =
        groupService.isMember(
      widget.group.id,
    );

    membersFuture =
        groupService.getGroupMembers(
      widget.group.id,
    );

    creatorFuture =
        groupService.getStudentById(
      widget.group.creatorId,
    );
  }

  bool get isCreator {
    return widget.group.creatorId ==
        groupService.currentUserId;
  }

  Future<void> joinGroup() async {
    setState(() {
      isJoining = true;
    });

    try {
      await groupService.joinGroup(
        widget.group.id,
      );

      if (!mounted) return;

      setState(() {
        membershipFuture =
            Future.value(true);

        memberCountFuture =
            groupService.getMemberCount(
          widget.group.id,
        );

        membersFuture =
            groupService.getGroupMembers(
          widget.group.id,
        );
      });

      showMessage(
        'You joined "${widget.group.title}"!',
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          isJoining = false;
        });
      }
    }
  }

  Future<void> leaveGroup() async {
    if (isCreator) {
      showMessage(
        'Group creators must delete the group.',
      );
      return;
    }

    final bool? confirmed =
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
                BorderRadius.circular(
              24,
            ),
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
                Container(
                  width: 58,
                  height: 58,
                  decoration:
                      const BoxDecoration(
                    color: lightMaroon,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_outlined,
                    color: maroon,
                    size: 28,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(
                  'Leave Group?',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'Are you sure you want to '
                  'leave "${widget.group.title}"?',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        Colors.grey.shade700,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

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
                      side: BorderSide(
                        color:
                            Colors.grey.shade300,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Cancel',
                      style:
                          TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

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
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Leave Group',
                      style:
                          TextStyle(
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

    if (confirmed != true) {
      return;
    }

    setState(() {
      isLeaving = true;
    });

    try {
      await groupService.leaveGroup(
        widget.group.id,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLeaving = false;
      });

      showMessage(
        error.toString(),
      );
    }
  }

  Future<void> deleteGroup() async {
    if (!isCreator) {
      return;
    }

    final bool? confirmed =
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
                BorderRadius.circular(
              24,
            ),
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
                Container(
                  width: 58,
                  height: 58,
                  decoration:
                      BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 28,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(
                  'Delete Group?',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  'Are you sure you want to '
                  'delete "${widget.group.title}"?\n\n'
                  'This will remove the group, '
                  'its members, and its chat messages.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        Colors.grey.shade700,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

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
                      side: BorderSide(
                        color:
                            Colors.grey.shade300,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Cancel',
                      style:
                          TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

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
                          Colors.red.shade700,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child:
                        const Text(
                      'Delete Group',
                      style:
                          TextStyle(
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

    if (confirmed != true) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      await groupService.deleteGroup(
        widget.group.id,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      showMessage(
        error.toString(),
      );
    }
  }

  void openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChatScreen(
            group: widget.group,
          );
        },
      ),
    );
  }

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  String getCreatorName(
    Student? creator,
  ) {
    if (creator == null) {
      return 'Unknown';
    }

    if (creator.displayName
        .trim()
        .isNotEmpty) {
      return creator.displayName
          .trim();
    }

    if (creator.fullName
        .trim()
        .isNotEmpty) {
      return creator.fullName
          .trim();
    }

    return 'Unknown';
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        title: const Text(
          'Study Group',
          style:
              TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          if (isCreator)
            IconButton(
              onPressed:
                  isDeleting
                      ? null
                      : deleteGroup,
              tooltip:
                  'Delete Group',
              icon:
                  isDeleting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.delete_outline,
                        ),
            ),
        ],
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration:
                  BoxDecoration(
                color:
                    lightMaroon,
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
              child:
                  Text(
                widget.group.subject
                    .toUpperCase(),
                style:
                    const TextStyle(
                  color: maroon,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.bold,
                  letterSpacing:
                      0.5,
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              widget.group.title,
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              widget.group.description
                      .isEmpty
                  ? 'No description provided.'
                  : widget.group
                      .description,
              style:
                  TextStyle(
                color:
                    Colors.grey.shade700,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildSectionCard(
              child:
                  Column(
                children: [
                  _buildInfoRow(
                    icon: Icons
                        .location_on_outlined,
                    title:
                        'Study Spot',
                    value:
                        widget.group
                            .location,
                  ),

                  const Divider(
                    height: 26,
                  ),

                  _buildInfoRow(
                    icon: Icons
                        .calendar_month_outlined,
                    title:
                        'Schedule',
                    value:
                        widget.group
                            .schedule,
                  ),

                  const Divider(
                    height: 26,
                  ),

                  FutureBuilder<int>(
                    future:
                        memberCountFuture,
                    builder:
                        (context,
                            snapshot) {
                      final String count =
                          snapshot.hasData
                              ? '${snapshot.data}'
                              : '...';

                      final String
                          studentText =
                          snapshot.hasData &&
                                  snapshot.data ==
                                      1
                              ? 'student'
                              : 'students';

                      return
                          _buildInfoRow(
                        icon: Icons
                            .groups_outlined,
                        title:
                            'Members',
                        value:
                            '$count $studentText',
                      );
                    },
                  ),

                  const Divider(
                    height: 26,
                  ),

                  FutureBuilder<Student?>(
                    future:
                        creatorFuture,
                    builder:
                        (context,
                            snapshot) {
                      String creatorText =
                          'Loading...';

                      if (snapshot.hasData) {
                        creatorText =
                            'Created by ${getCreatorName(snapshot.data)}';
                      }

                      if (snapshot.hasError) {
                        creatorText =
                            'Created by Unknown';
                      }

                      return
                          _buildInfoRow(
                        icon: Icons
                            .person_outline,
                        title:
                            'Group Status',
                        value:
                            creatorText,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildSectionCard(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Text(
                    'Members',
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  FutureBuilder<
                      List<Student>>(
                    future:
                        membersFuture,
                    builder:
                        (context,
                            snapshot) {
                      if (snapshot
                              .connectionState ==
                          ConnectionState
                              .waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                maroon,
                          ),
                        );
                      }

                      if (snapshot
                          .hasError) {
                        return Text(
                          'Could not load members.',
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        );
                      }

                      final List<Student>
                          members =
                          snapshot.data ??
                              [];

                      if (members
                          .isEmpty) {
                        return Text(
                          'No members yet.',
                          style:
                              TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        );
                      }

                      return Column(
                        children:
                            members
                                .map(
                          (student) {
                            final String
                                firstLetter =
                                student
                                        .fullName
                                        .trim()
                                        .isNotEmpty
                                    ? student
                                        .fullName
                                        .trim()[0]
                                        .toUpperCase()
                                    : '?';

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    12,
                              ),
                              child:
                                  Row(
                                children: [
                                  CircleAvatar(
                                    radius:
                                        21,
                                    backgroundColor:
                                        lightMaroon,
                                    child:
                                        Text(
                                      firstLetter,
                                      style:
                                          const TextStyle(
                                        color:
                                            maroon,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width:
                                        12,
                                  ),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student
                                              .fullName,
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                            fontSize:
                                                15,
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              2,
                                        ),

                                        Text(
                                          '${student.course} • ${student.yearLevel}',
                                          style:
                                              TextStyle(
                                            color:
                                                Colors.grey.shade600,
                                            fontSize:
                                                12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                                .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            _buildSectionCard(
              padding:
                  const EdgeInsets.all(
                14,
              ),
              child:
                  FutureBuilder<bool>(
                future:
                    membershipFuture,
                builder:
                    (context,
                        snapshot) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            maroon,
                      ),
                    );
                  }

                  final bool isMember =
                      snapshot.data ??
                          false;

                  // Non-member
                  if (!isMember) {
                    return SizedBox(
                      width:
                          double.infinity,
                      height: 52,
                      child:
                          ElevatedButton
                              .icon(
                        onPressed:
                            isJoining
                                ? null
                                : joinGroup,
                        icon: isJoining
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .group_add,
                              ),
                        label:
                            Text(
                          isJoining
                              ? 'Joining...'
                              : 'Join Group',
                        ),
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              maroon,
                          foregroundColor:
                              Colors.white,
                          elevation:
                              0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // Creator
                  if (isCreator) {
                    return Column(
                      children: [
                        Container(
                          width:
                              double.infinity,
                          padding:
                              const EdgeInsets
                                  .all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                lightMaroon,
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child:
                              const Row(
                            children: [
                              Icon(
                                Icons
                                    .check_circle,
                                color:
                                    maroon,
                              ),

                              SizedBox(
                                width: 10,
                              ),

                              Expanded(
                                child:
                                    Text(
                                  'You created this group.',
                                  style:
                                      TextStyle(
                                    color:
                                        maroon,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton
                                  .icon(
                            onPressed:
                                openChat,
                            icon:
                                const Icon(
                              Icons
                                  .chat_outlined,
                            ),
                            label:
                                const Text(
                              'Open Group Chat',
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  maroon,
                              foregroundColor:
                                  Colors.white,
                              elevation:
                                  0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Normal joined member
                  return Column(
                    children: [
                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .all(
                          14,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              lightMaroon,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                        child:
                            const Row(
                          children: [
                            Icon(
                              Icons
                                  .check_circle,
                              color:
                                  maroon,
                            ),

                            SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  Text(
                                'You are a member of this group.',
                                style:
                                    TextStyle(
                                  color:
                                      maroon,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 52,
                        child:
                            ElevatedButton
                                .icon(
                          onPressed:
                              openChat,
                          icon:
                              const Icon(
                            Icons
                                .chat_outlined,
                          ),
                          label:
                              const Text(
                            'Open Group Chat',
                          ),
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                maroon,
                            foregroundColor:
                                Colors.white,
                            elevation:
                                0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      SizedBox(
                        width:
                            double.infinity,
                        height: 52,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed:
                              isLeaving
                                  ? null
                                  : leaveGroup,
                          icon: isLeaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    color:
                                        maroon,
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .logout_outlined,
                                ),
                          label:
                              Text(
                            isLeaving
                                ? 'Leaving...'
                                : 'Leave Group',
                          ),
                          style:
                              OutlinedButton
                                  .styleFrom(
                            foregroundColor:
                                maroon,
                            side:
                                const BorderSide(
                              color:
                                  maroon,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(18),
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          padding,
      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child:
          child,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              const BoxDecoration(
            color:
                lightMaroon,
            shape:
                BoxShape.circle,
          ),
          child:
              Icon(
            icon,
            color: maroon,
            size: 21,
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child:
              Column(
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
                  fontSize: 15,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}