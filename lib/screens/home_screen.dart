import 'package:flutter/material.dart';

import '../models/student.dart';
import '../models/study_group.dart';
import '../services/group_service.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'my_groups_screen.dart';
import 'profile_view_screen.dart';

class HomeScreen extends StatefulWidget {
  final Student student;

  const HomeScreen({
    super.key,
    required this.student,
  });

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color maroon =
      Color(0xFF800000);

  static const Color lightMaroon =
      Color(0xFFF6EAEA);

  static const Color backgroundColor =
      Color(0xFFF9F9F9);

  final GroupService groupService =
      GroupService();

  final TextEditingController searchController =
      TextEditingController();

  late Future<List<StudyGroup>> groupsFuture;

  String selectedSubject = 'All';
  String searchText = '';

  int currentIndex = 0;

  Set<int> myGroupIds = {};

  @override
  void initState() {
    super.initState();

    groupsFuture =
        groupService.getGroups();

    searchController.addListener(() {
      setState(() {
        searchText =
            searchController.text
                .trim()
                .toLowerCase();
      });
    });

    loadMyGroups();
  }

  Future<void> loadMyGroups() async {
    try {
      final List<StudyGroup> groups =
          await groupService.getMyGroups();

      if (!mounted) return;

      setState(() {
        myGroupIds =
            groups.map(
              (group) => group.id,
            ).toSet();
      });
    } catch (error) {
      // Keep app running.
    }
  }

  Future<void> refreshGroups() async {
    setState(() {
      groupsFuture =
          groupService.getGroups();
    });

    await groupsFuture;
    await loadMyGroups();
  }

  Future<void> openCreateGroup() async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const CreateGroupScreen();
        },
      ),
    );

    if (result == true) {
      await refreshGroups();
    }
  }

  Future<void> joinGroup(
    StudyGroup group,
  ) async {
    final bool isCreator =
        group.creatorId ==
            groupService.currentUserId;

    if (myGroupIds.contains(group.id) ||
        isCreator) {
      return;
    }

    try {
      await groupService.joinGroup(
        group.id,
      );

      if (!mounted) return;

      setState(() {
        myGroupIds.add(
          group.id,
        );
      });

      showMessage(
        'You joined "${group.title}"!',
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        error.toString(),
      );

      await loadMyGroups();
    }
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

  List<StudyGroup> filterGroups(
    List<StudyGroup> groups,
  ) {
    return groups.where((group) {
      final bool matchesSubject =
          selectedSubject == 'All' ||
              group.subject
                      .toLowerCase() ==
                  selectedSubject
                      .toLowerCase();

      final String searchValue =
          '${group.subject} '
          '${group.title} '
          '${group.description} '
          '${group.location} '
          '${group.schedule}'
              .toLowerCase();

      final bool matchesSearch =
          searchText.isEmpty ||
              searchValue.contains(
                searchText,
              );

      return matchesSubject &&
          matchesSearch;
    }).toList();
  }

  List<String> getSubjects(
    List<StudyGroup> groups,
  ) {
    final List<String> subjects =
        groups
            .map(
              (group) =>
                  group.subject.trim(),
            )
            .where(
              (subject) =>
                  subject.isNotEmpty,
            )
            .toSet()
            .toList();

    subjects.sort();

    return [
      'All',
      ...subjects,
    ];
  }

  String getGreetingName() {
    if (widget.student.displayName
        .trim()
        .isNotEmpty) {
      return widget.student.displayName
          .trim();
    }

    if (widget.student.firstName
        .trim()
        .isNotEmpty) {
      return widget.student.firstName
          .trim();
    }

    final String fullName =
        widget.student.fullName.trim();

    if (fullName.isEmpty) {
      return 'Student';
    }

    return fullName
        .split(' ')
        .first;
  }

  String getInitial() {
    final String name =
        getGreetingName();

    if (name.isEmpty) {
      return 'S';
    }

    return name[0].toUpperCase();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.white,
        elevation: 0,
        titleSpacing: 20,

        title: Text(
          currentIndex == 0
              ? 'StudyCircle'
              : currentIndex == 1
                  ? 'My Groups'
                  : 'My Profile',
          style:
              const TextStyle(
            color: maroon,
            fontSize: 21,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions:
            currentIndex == 0
                ? [
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        right: 16,
                      ),
                      child:
                          CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            lightMaroon,
                        child:
                            Text(
                          getInitial(),
                          style:
                              const TextStyle(
                            color:
                                maroon,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),
                  ]
                : null,
      ),

      floatingActionButton:
          currentIndex == 0
              ? FloatingActionButton.extended(
                  onPressed:
                      openCreateGroup,
                  backgroundColor:
                      maroon,
                  foregroundColor:
                      Colors.white,
                  elevation: 4,
                  icon:
                      const Icon(
                    Icons.add,
                  ),
                  label:
                      const Text(
                    'Create Group',
                  ),
                )
              : null,

      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildHomeContent(),

          MyGroupsScreen(
            student:
                widget.student,
          ),

          ProfileViewScreen(
            student:
                widget.student,
          ),
        ],
      ),

      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            currentIndex,
        backgroundColor:
            Colors.white,
        indicatorColor:
            lightMaroon,

        onDestinationSelected:
            (index) {
          setState(() {
            currentIndex =
                index;
          });
        },

        destinations:
            const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: Colors.grey,
            ),
            selectedIcon:
                Icon(
              Icons.home,
              color: maroon,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.groups_outlined,
              color: Colors.grey,
            ),
            selectedIcon:
                Icon(
              Icons.groups,
              color: maroon,
            ),
            label: 'My Groups',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: Colors.grey,
            ),
            selectedIcon:
                Icon(
              Icons.person,
              color: maroon,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      color: maroon,

      onRefresh:
          refreshGroups,

      child:
          FutureBuilder<List<StudyGroup>>(
        future:
            groupsFuture,

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
                  Icons
                      .error_outline,
                  size: 60,
                  color: maroon,
                ),
                SizedBox(
                  height: 12,
                ),
                Center(
                  child:
                      Text(
                    'Could not load study groups.',
                  ),
                ),
              ],
            );
          }

          final List<StudyGroup>
              groups =
              snapshot.data ?? [];

          final List<String>
              subjects =
              getSubjects(
            groups,
          );

          final List<StudyGroup>
              filteredGroups =
              filterGroups(
            groups,
          );

          return ListView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              110,
            ),

            children: [
              _buildWelcomeHeader(
                totalGroups:
                    groups.length,
                myGroups:
                    myGroupIds.length,
              ),

              const SizedBox(
                height: 22,
              ),

              _buildSearchSection(),

              const SizedBox(
                height: 16,
              ),

              _buildSubjectFilters(
                subjects,
              ),

              const SizedBox(
                height: 26,
              ),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .center,
                children: [
                  const Expanded(
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Available Study Groups',
                          style:
                              TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Find students to study with.',
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

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
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),
                    child:
                        Text(
                      '${filteredGroups.length}',
                      style:
                          const TextStyle(
                        color:
                            maroon,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              if (groups.isEmpty)
                _buildEmptyState(
                  message:
                      'No study groups yet.',
                  subMessage:
                      'Be the first to create one!',
                ),

              if (groups.isNotEmpty &&
                  filteredGroups.isEmpty)
                _buildEmptyState(
                  message:
                      'No matching groups.',
                  subMessage:
                      'Try another search or subject.',
                ),

              ...filteredGroups.map(
                (group) {
                  return _buildGroupCard(
                    group,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader({
    required int totalGroups,
    required int myGroups,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(
        color: maroon,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Hi, ${getGreetingName()}! 👋',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    const Text(
                      'Find your study circle and learn together.',
                      style:
                          TextStyle(
                        color:
                            Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 54,
                height: 54,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white24,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child:
                    const Icon(
                  Icons.groups_rounded,
                  color:
                      Colors.white,
                  size: 29,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _buildStatCard(
                  icon:
                      Icons.groups_outlined,
                  value:
                      '$totalGroups',
                  label:
                      'Available Groups',
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    _buildStatCard(
                  icon:
                      Icons.bookmark_outline,
                  value:
                      '$myGroups',
                  label:
                      'My Groups',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white12,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                const BoxDecoration(
              color:
                  Colors.white24,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              color:
                  Colors.white,
              size: 19,
            ),
          ),

          const SizedBox(
            width: 9,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  value,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border:
            Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          const Text(
            'Find a Study Group',
            style:
                TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            'Search by subject, title, or study spot.',
            style:
                TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 12,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          TextField(
            controller:
                searchController,

            decoration:
                InputDecoration(
              hintText:
                  'Search study groups...',
              prefixIcon:
                  const Icon(
                Icons.search,
                color:
                    maroon,
              ),
              suffixIcon:
                  searchText.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            searchController
                                .clear();
                          },
                          icon:
                              const Icon(
                            Icons
                                .clear,
                          ),
                        )
                      : null,
              filled:
                  true,
              fillColor:
                  backgroundColor,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets
                      .symmetric(
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilters(
    List<String> subjects,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        const Text(
          'Browse by Subject',
          style:
              TextStyle(
            fontSize: 15,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        SizedBox(
          height: 42,
          child:
              ListView.separated(
            scrollDirection:
                Axis.horizontal,
            itemCount:
                subjects.length,

            separatorBuilder:
                (context, index) {
              return const SizedBox(
                width: 8,
              );
            },

            itemBuilder:
                (context, index) {
              final String subject =
                  subjects[index];

              final bool isSelected =
                  selectedSubject ==
                      subject;

              return ChoiceChip(
                label:
                    Text(
                  subject,
                ),

                selected:
                    isSelected,

                selectedColor:
                    maroon,

                backgroundColor:
                    Colors.white,

                side:
                    BorderSide(
                  color: isSelected
                      ? maroon
                      : Colors.grey
                          .shade300,
                ),

                labelStyle:
                    TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.black87,
                  fontWeight:
                      FontWeight.w500,
                ),

                onSelected:
                    (selected) {
                  setState(() {
                    selectedSubject =
                        subject;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(
    StudyGroup group,
  ) {
    final bool isCreator =
        group.creatorId ==
            groupService.currentUserId;

    final bool isMember =
        myGroupIds.contains(
              group.id,
            ) ||
            isCreator;

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child:
          Card(
        margin:
            EdgeInsets.zero,
        elevation: 1,
        color:
            Colors.white,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
          side:
              BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),

        child:
            InkWell(
          borderRadius:
              BorderRadius.circular(
            20,
          ),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) {
                  return GroupDetailScreen(
                    group: group,
                  );
                },
              ),
            );
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
                  CrossAxisAlignment
                      .start,

              children: [
                Row(
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
                          color:
                              maroon,
                          fontSize:
                              11,
                          fontWeight:
                              FontWeight
                                  .bold,
                          letterSpacing:
                              0.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    if (isCreator)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              lightMaroon,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child:
                            const Text(
                          'Created by you',
                          style:
                              TextStyle(
                            color:
                                maroon,
                            fontSize:
                                10,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      )
                    else if (isMember)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.green
                                  .shade50,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                        child:
                            Text(
                          'Joined',
                          style:
                              TextStyle(
                            color:
                                Colors.green
                                    .shade700,
                            fontSize:
                                10,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 13,
                ),

                Text(
                  group.title,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
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
                      color:
                          Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(
                  height: 17,
                ),

                _buildInfoRow(
                  icon:
                      Icons.location_on_outlined,
                  text:
                      group.location,
                ),

                const SizedBox(
                  height: 9,
                ),

                _buildInfoRow(
                  icon:
                      Icons.schedule_outlined,
                  text:
                      group.schedule,
                ),

                const SizedBox(
                  height: 17,
                ),

                SizedBox(
                  width:
                      double.infinity,

                  child:
                      ElevatedButton.icon(
                    onPressed:
                        isMember
                            ? null
                            : () {
                                joinGroup(
                                  group,
                                );
                              },

                    icon:
                        Icon(
                      isMember
                          ? Icons.check
                          : Icons.group_add,
                    ),

                    label:
                        Text(
                      isCreator
                          ? 'Your Group'
                          : isMember
                              ? 'Joined'
                              : 'Join Group',
                    ),

                    style:
                        ElevatedButton
                            .styleFrom(
                      minimumSize:
                          const Size(
                        double.infinity,
                        46,
                      ),

                      backgroundColor:
                          maroon,

                      foregroundColor:
                          Colors.white,

                      disabledBackgroundColor:
                          isCreator
                              ? lightMaroon
                              : const Color(
                                  0xFFF0DCDC,
                                ),

                      disabledForegroundColor:
                          maroon,

                      elevation:
                          0,

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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,

      children: [
        Container(
          width: 32,
          height: 32,
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
            color:
                maroon,
            size: 17,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
              Padding(
            padding:
                const EdgeInsets.only(
              top: 6,
            ),
            child:
                Text(
              text,
              style:
                  const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required String message,
    required String subMessage,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 70,
      ),

      child:
          Column(
        children: [
          Container(
            width: 84,
            height: 84,

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
              color:
                  maroon,
              size: 44,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            subMessage,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}