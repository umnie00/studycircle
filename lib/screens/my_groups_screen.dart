import 'package:flutter/material.dart';

import '../models/student.dart';
import '../models/study_group.dart';
import '../services/group_service.dart';
import 'group_list_screen.dart';

class MyGroupsScreen extends StatefulWidget {
  final Student student;

  const MyGroupsScreen({
    super.key,
    required this.student,
  });

  @override
  State<MyGroupsScreen> createState() {
    return _MyGroupsScreenState();
  }
}

class _MyGroupsScreenState
    extends State<MyGroupsScreen> {
  static const Color maroon =
      Color(0xFF800000);

  static const Color lightMaroon =
      Color(0xFFF6EAEA);



  final GroupService groupService =
      GroupService();

  late Future<List<StudyGroup>> groupsFuture;

  @override
  void initState() {
    super.initState();

    groupsFuture =
        groupService.getMyGroups();
  }

  Future<void> refreshGroups() async {
    setState(() {
      groupsFuture =
          groupService.getMyGroups();
    });

    await groupsFuture;
  }

  Future<void> openGroupList({
    required bool createdGroups,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return GroupListScreen(
            student: widget.student,
            createdGroups: createdGroups,
          );
        },
      ),
    );

    if (mounted) {
      await refreshGroups();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return RefreshIndicator(
      color: maroon,
      onRefresh: refreshGroups,
      child:
          FutureBuilder<List<StudyGroup>>(
        future: groupsFuture,
        builder:
            (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: maroon,
              ),
            );
          }

          if (snapshot.hasError) {
            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: 180,
                ),
                Icon(
                  Icons.error_outline,
                  color: maroon,
                  size: 60,
                ),
                SizedBox(
                  height: 12,
                ),
                Center(
                  child: Text(
                    'Could not load your groups.',
                  ),
                ),
              ],
            );
          }

          final List<StudyGroup> groups =
              snapshot.data ?? [];

          final String? currentUserId =
              groupService.currentUserId;

          final int createdCount =
              currentUserId == null
                  ? 0
                  : groups
                      .where(
                        (group) =>
                            group.creatorId ==
                            currentUserId,
                      )
                      .length;

          final int joinedCount =
              groups.length - createdCount;

          if (groups.isEmpty) {
            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                100,
                20,
                30,
              ),
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 130,
                  ),
                  decoration:
                      const BoxDecoration(
                    color:
                        lightMaroon,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      const Icon(
                    Icons.groups_outlined,
                    color: maroon,
                    size: 42,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                const Center(
                  child: Text(
                    'No groups yet',
                    style:
                        TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Center(
                  child: Text(
                    'Create or join a study group from the Home tab.',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      color:
                          Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.fromLTRB(
              18,
              24,
              18,
              30,
            ),
            children: [
              const Text(
                'My Groups',
                style:
                    TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Choose a section to view your study groups.',
                style:
                    TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(
                height: 22,
              ),

              _buildGroupCategoryCard(
                icon:
                    Icons.workspace_premium_outlined,
                title:
                    'Created Groups',
                description:
                    'Groups you created',
                count:
                    createdCount,
                createdGroups:
                    true,
              ),

              const SizedBox(
                height: 16,
              ),

              _buildGroupCategoryCard(
                icon:
                    Icons.groups_outlined,
                title:
                    'Joined Groups',
                description:
                    'Groups you joined',
                count:
                    joinedCount,
                createdGroups:
                    false,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupCategoryCard({
    required IconData icon,
    required String title,
    required String description,
    required int count,
    required bool createdGroups,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 300,
      child: Material(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        child: InkWell(
          borderRadius:
              BorderRadius.circular(24),
          onTap: () {
            openGroupList(
              createdGroups:
                  createdGroups,
            );
          },
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(24),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              border:
                  Border.all(
                color:
                    Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration:
                      const BoxDecoration(
                    color: lightMaroon,
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: maroon,
                    size: 40,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                Text(
                  title,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  description,
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        lightMaroon,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child:
                      Text(
                    '$count ${count == 1 ? 'group' : 'groups'}',
                    style:
                        const TextStyle(
                      color: maroon,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 46,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      openGroupList(
                        createdGroups:
                            createdGroups,
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
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
                        const Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Text(
                          'View Groups',
                          style:
                              TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons
                              .arrow_forward,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}