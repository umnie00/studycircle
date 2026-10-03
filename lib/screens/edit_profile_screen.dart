import 'package:flutter/material.dart';

import '../models/student.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Student student;

  const EditProfileScreen({
    super.key,
    required this.student,
  });

  @override
  State<EditProfileScreen> createState() {
    return _EditProfileScreenState();
  }
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  static const Color maroon = Color(0xFF800000);

  final ProfileService profileService =
      ProfileService();

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController middleInitialController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController displayNameController =
      TextEditingController();

  final TextEditingController courseController =
      TextEditingController();

  String selectedYear = '1st Year';

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadStudentData();
  }

  void _loadStudentData() {
    String firstName = widget.student.firstName;
    String middleInitial = widget.student.middleInitial;
    String lastName = widget.student.lastName;

    // Support old profiles that only have full_name.
    if (firstName.isEmpty &&
        lastName.isEmpty &&
        widget.student.fullName.isNotEmpty) {
      final List<String> parts =
          widget.student.fullName
              .replaceAll('.', '')
              .trim()
              .split(RegExp(r'\s+'));

      if (parts.isNotEmpty) {
        firstName = parts.first;
      }

      if (parts.length >= 3) {
        middleInitial = parts[1];
        lastName = parts.sublist(2).join(' ');
      } else if (parts.length == 2) {
        lastName = parts[1];
      }
    }

    firstNameController.text = firstName;
    middleInitialController.text =
        middleInitial;
    lastNameController.text = lastName;

    displayNameController.text =
        widget.student.displayName;

    courseController.text =
        widget.student.course;

    selectedYear =
        widget.student.yearLevel.isNotEmpty
            ? widget.student.yearLevel
            : '1st Year';
  }

  Future<void> saveChanges() async {
    final String firstName =
        firstNameController.text.trim();

    final String middleInitial =
        middleInitialController.text.trim();

    final String lastName =
        lastNameController.text.trim();

    final String displayName =
        displayNameController.text.trim();

    final String course =
        courseController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        displayName.isEmpty ||
        course.isEmpty) {
      showMessage(
        'Please fill in all required fields.',
      );
      return;
    }

    if (middleInitial.isNotEmpty &&
        middleInitial.length != 1) {
      showMessage(
        'Middle Initial must be only one letter.',
      );
      return;
    }

    if (!_isLettersOnly(firstName)) {
      showMessage(
        'First Name should contain letters only.',
      );
      return;
    }

    if (!_isLettersOnly(lastName)) {
      showMessage(
        'Family Name should contain letters only.',
      );
      return;
    }

    if (middleInitial.isNotEmpty &&
        !_isLettersOnly(middleInitial)) {
      showMessage(
        'Middle Initial should contain letters only.',
      );
      return;
    }

    final String fullName =
        middleInitial.isNotEmpty
            ? '$firstName $middleInitial. $lastName'
            : '$firstName $lastName';

    final Student updatedStudent = Student(
      id: widget.student.id,
      firstName: firstName,
      middleInitial: middleInitial,
      lastName: lastName,
      displayName: displayName,
      fullName: fullName,
      course: course,
      yearLevel: selectedYear,
    );

    setState(() {
      isLoading = true;
    });

    try {
      await profileService.saveProfile(
        updatedStudent,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        updatedStudent,
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        'Could not update profile. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isLettersOnly(String value) {
    final RegExp namePattern =
        RegExp(r'^[a-zA-Z]+$');

    return namePattern.hasMatch(value);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleInitialController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();
    courseController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Your Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Update your StudyCircle information.',
              ),

              const SizedBox(height: 30),

              TextField(
                controller:
                    firstNameController,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    const InputDecoration(
                  labelText: 'First Name *',
                  prefixIcon:
                      Icon(Icons.person),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    middleInitialController,
                textCapitalization:
                    TextCapitalization.characters,
                maxLength: 1,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Middle Initial',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                  border:
                      OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    lastNameController,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Family Name *',
                  prefixIcon:
                      Icon(Icons.person),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    displayNameController,
                textCapitalization:
                    TextCapitalization.words,
                decoration:
                    const InputDecoration(
                  labelText:
                      'StudyCircle Name *',
                  hintText: 'Ninin',
                  prefixIcon: Icon(
                    Icons.alternate_email,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'This is your public name on StudyCircle.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller:
                    courseController,
                textCapitalization:
                    TextCapitalization.characters,
                decoration:
                    const InputDecoration(
                  labelText: 'Course *',
                  hintText: 'BSIT',
                  prefixIcon:
                      Icon(Icons.school),
                  border:
                      OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Year Level *',
                  prefixIcon: Icon(
                    Icons.calendar_today,
                  ),
                  border:
                      OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '1st Year',
                    child:
                        Text('1st Year'),
                  ),
                  DropdownMenuItem(
                    value: '2nd Year',
                    child:
                        Text('2nd Year'),
                  ),
                  DropdownMenuItem(
                    value: '3rd Year',
                    child:
                        Text('3rd Year'),
                  ),
                  DropdownMenuItem(
                    value: '4th Year',
                    child:
                        Text('4th Year'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : saveChanges,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        maroon,
                    foregroundColor:
                        Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style:
                              TextStyle(
                            fontSize: 16,
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