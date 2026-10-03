import 'package:flutter/material.dart';

import '../models/study_locations.dart';
import '../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() {
    return _CreateGroupScreenState();
  }
}

class _CreateGroupScreenState
    extends State<CreateGroupScreen> {
  static const Color maroon = Color(0xFF800000);
  static const Color lightMaroon =
      Color(0xFFF6EAEA);

  final GroupService groupService =
      GroupService();

  final TextEditingController subjectController =
      TextEditingController();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  String? selectedLocation;

  DateTime? selectedDate;

  TimeOfDay? selectedTime;

  bool isLoading = false;

  Future<void> selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate:
          selectedDate ?? now,
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate:
          DateTime(2100, 12, 31),
      helpText:
          'SELECT STUDY DATE',
      cancelText: 'CANCEL',
      confirmText: 'SELECT',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });

    // Clear time if the new date makes
    // the current schedule invalid.
    if (selectedTime != null &&
        isSelectedDateTimePast()) {
      setState(() {
        selectedTime = null;
      });
    }
  }

  Future<void> selectTime() async {
    if (selectedDate == null) {
      showMessage(
        'Please select a study date first.',
      );
      return;
    }

    final TimeOfDay? pickedTime =
        await showTimePicker(
      context: context,
      initialTime:
          selectedTime ??
              TimeOfDay.now(),
      helpText:
          'SELECT STUDY TIME',
      cancelText: 'CANCEL',
      confirmText: 'SELECT',
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      selectedTime = pickedTime;
    });

    if (isSelectedDateTimePast()) {
      setState(() {
        selectedTime = null;
      });

      showMessage(
        'Please choose a future time.',
      );
    }
  }

  bool isSelectedDateTimePast() {
    if (selectedDate == null ||
        selectedTime == null) {
      return false;
    }

    final DateTime scheduledDateTime =
        DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    return scheduledDateTime
        .isBefore(DateTime.now());
  }

  String getFormattedDate() {
    if (selectedDate == null) {
      return 'Select a study date';
    }

    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[selectedDate!.month - 1]} '
        '${selectedDate!.day}, '
        '${selectedDate!.year}';
  }

  String getFormattedTime() {
    if (selectedTime == null) {
      return 'Select a study time';
    }

    final int hour =
        selectedTime!.hourOfPeriod == 0
            ? 12
            : selectedTime!.hourOfPeriod;

    final String minute =
        selectedTime!.minute
            .toString()
            .padLeft(2, '0');

    final String period =
        selectedTime!.period ==
                DayPeriod.am
            ? 'AM'
            : 'PM';

    return '$hour:$minute $period';
  }

  String getScheduleText() {
    if (selectedDate == null ||
        selectedTime == null) {
      return '';
    }

    return '${getFormattedDate()} • '
        '${getFormattedTime()}';
  }

  Future<void> createGroup() async {
    final String subject =
        subjectController.text.trim();

    final String title =
        titleController.text.trim();

    final String description =
        descriptionController.text.trim();

    // Required field validation
    if (subject.isEmpty) {
      showMessage(
        'Please enter a subject.',
      );
      return;
    }

    if (title.isEmpty) {
      showMessage(
        'Please enter a group title.',
      );
      return;
    }

    if (description.isEmpty) {
      showMessage(
        'Please enter a group description.',
      );
      return;
    }

    if (selectedLocation == null) {
      showMessage(
        'Please select a study spot.',
      );
      return;
    }

    if (selectedDate == null) {
      showMessage(
        'Please select a study date.',
      );
      return;
    }

    if (selectedTime == null) {
      showMessage(
        'Please select a study time.',
      );
      return;
    }

    if (isSelectedDateTimePast()) {
      showMessage(
        'Please choose a future schedule.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await groupService.createGroup(
        subject: subject,
        title: title,
        description: description,
        location: selectedLocation!,
        schedule: getScheduleText(),
      );

      if (!mounted) {
        return;
      }

      showMessage(
        'Study group created!',
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(
        'Could not create study group.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  Widget buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  void dispose() {
    subjectController.dispose();
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9F9F9),

      appBar: AppBar(
        title: const Text(
          'Create Study Group',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a Study Group',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Invite other UM students to study together.',
                style: TextStyle(
                  color:
                      Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              // SUBJECT
              buildSectionTitle(
                'Subject *',
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    subjectController,
                textCapitalization:
                    TextCapitalization.sentences,
                maxLength: 40,
                decoration:
                    const InputDecoration(
                  hintText:
                      'e.g. Programming',
                  prefixIcon:
                      Icon(
                    Icons
                        .menu_book_outlined,
                    color: maroon,
                  ),
                  border:
                      OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 18),

              // TITLE
              buildSectionTitle(
                'Group Title *',
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    titleController,
                textCapitalization:
                    TextCapitalization.sentences,
                maxLength: 60,
                decoration:
                    const InputDecoration(
                  hintText:
                      'e.g. Flutter Study Group',
                  prefixIcon:
                      Icon(
                    Icons.groups_outlined,
                    color: maroon,
                  ),
                  border:
                      OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 18),

              // DESCRIPTION
              buildSectionTitle(
                'Description *',
              ),

              const SizedBox(height: 8),

              TextField(
                controller:
                    descriptionController,
                textCapitalization:
                    TextCapitalization.sentences,
                maxLines: 4,
                maxLength: 250,
                decoration:
                    const InputDecoration(
                  hintText:
                      'What will your group study?',
                  prefixIcon:
                      Padding(
                    padding:
                        EdgeInsets.only(
                      bottom: 55,
                    ),
                    child:
                        Icon(
                      Icons
                          .description_outlined,
                      color: maroon,
                    ),
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // STUDY SPOT
              buildSectionTitle(
                'Study Spot *',
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<
                  String>(
                initialValue:
                    selectedLocation,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Select a study spot',
                  prefixIcon:
                      Icon(
                    Icons
                        .location_on_outlined,
                    color: maroon,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                items: StudyLocations
                    .locations
                    .map(
                  (
                    location,
                  ) {
                    return DropdownMenuItem<
                        String>(
                      value: location,
                      child:
                          Text(location),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation =
                        value;
                  });
                },
              ),

              const SizedBox(height: 18),

              // SCHEDULE
              buildSectionTitle(
                'Schedule *',
              ),

              const SizedBox(height: 8),

              // DATE
              InkWell(
                onTap: selectDate,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child:
                    InputDecorator(
                  decoration:
                      const InputDecoration(
                    prefixIcon:
                        Icon(
                      Icons
                          .calendar_month_outlined,
                      color: maroon,
                    ),
                    hintText:
                        'Select a study date',
                    border:
                        OutlineInputBorder(),
                  ),
                  child: Text(
                    getFormattedDate(),
                    style: TextStyle(
                      color:
                          selectedDate ==
                                  null
                              ? Colors
                                  .grey
                                  .shade600
                              : Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // TIME
              InkWell(
                onTap: selectTime,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                child:
                    InputDecorator(
                  decoration:
                      const InputDecoration(
                    prefixIcon:
                        Icon(
                      Icons
                          .access_time_outlined,
                      color: maroon,
                    ),
                    hintText:
                        'Select a study time',
                    border:
                        OutlineInputBorder(),
                  ),
                  child: Text(
                    getFormattedTime(),
                    style: TextStyle(
                      color:
                          selectedTime ==
                                  null
                              ? Colors
                                  .grey
                                  .shade600
                              : Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // SCHEDULE PREVIEW
              if (selectedDate != null &&
                  selectedTime != null)
                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                      BoxDecoration(
                    color: lightMaroon,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .event_available,
                        color: maroon,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          getScheduleText(),
                          style:
                              const TextStyle(
                            color:
                                maroon,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              // CREATE BUTTON
              SizedBox(
                width:
                    double.infinity,
                height: 52,
                child:
                    ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : createGroup,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        maroon,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                            strokeWidth:
                                2.5,
                          ),
                        )
                      : const Text(
                          'Create Study Group',
                          style:
                              TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
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