import 'package:flutter/material.dart';

import '../models/student.dart';
import '../models/study_group.dart';
import '../services/group_service.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  final Student student;
  final bool createdGroups;

  const GroupListScreen({
    super.key,
    required this.student,
    required this.createdGroups,
  });

  @override
  State<GroupListScreen> createState() {
    return _GroupListScreenState();
  }
}

class _GroupListScreenState
    extends State<GroupListScreen> {
  static const Color maroon =
      Color(0xFF800000);

  static const Color lightMaroon =
      Color(0xFFF6EAEA);

  static const Color backgroundColor =
      Color(0xFFF9F9F9);

  final GroupService groupService =
      GroupService();

  late Future<List<StudyGroup>> groupsFuture;

  @override
  void initState() {
    super.initState();

    loadGroups();
  }

  void loadGroups() {
    if (widget.createdGroups) {
      groupsFuture =
          groupService.getCreatedGroups();
    } else {
      groupsFuture =
          groupService.getJoinedGroups();
    }
  }

  Future<void> refreshGroups() async {
    setState(() {
      loadGroups();
    });

    await groupsFuture;
  }

  Future<void> openGroup(
    StudyGroup group,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return GroupDetailScreen(
            group: group,
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
    final String pageTitle =
        widget.createdGroups
            ? 'Created Groups'
            : 'Joined Groups';

    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        title: Text(
          pageTitle,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body:
          RefreshIndicator(
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

            final List<StudyGroup>
                groups =
                snapshot.data ?? [];

            if (groups.isEmpty) {
              return ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  90,
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
                        Icon(
                      widget.createdGroups
                          ? Icons
                              .workspace_premium_outlined
                          : Icons
                              .groups_outlined,
                      color: maroon,
                      size: 42,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Center(
                    child: Text(
                      widget.createdGroups
                          ? 'No created groups'
                          : 'No joined groups',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        fontSize: 21,
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
                      widget.createdGroups
                          ? 'Groups you create will appear here.'
                          : 'Groups you join will appear here.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color: Colors
                            .grey
                            .shade600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                16,
                20,
                16,
                30,
              ),
              itemCount:
                  groups.length,
              itemBuilder:
                  (context, index) {
                final StudyGroup
                    group =
                    groups[index];

                return _buildGroupCard(
                  group,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    StudyGroup group,
  ) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        onTap: () {
          openGroup(group);
        },
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            18,
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
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      lightMaroon,
                  borderRadius:
                      BorderRadius
                          .circular(
                    8,
                  ),
                ),
                child:
                    Text(
                  group.subject
                      .toUpperCase(),
                  style:
                      const TextStyle(
                    color: maroon,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                group.title,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              if (group.description
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 7,
                ),

                Text(
                  group.description,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade700,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(
                height: 16,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Icon(
                    Icons
                        .location_on_outlined,
                    color: maroon,
                    size: 20,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        Text(
                      group.location,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 8,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  const Icon(
                    Icons
                        .schedule_outlined,
                    color: maroon,
                    size: 20,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        Text(
                      group.schedule,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton(
                  onPressed: () {
                    openGroup(
                      group,
                    );
                  },
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
                    minimumSize:
                        const Size(
                      double.infinity,
                      46,
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
                    'Open Group',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}