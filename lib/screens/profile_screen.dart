import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student.dart';
import '../services/profile_service.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService profileService = ProfileService();

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

  Future<void> saveProfile() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      showMessage('You are not logged in.');
      return;
    }

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
      showMessage('Please fill in all required fields.');
      return;
    }

    if (middleInitial.isNotEmpty &&
        middleInitial.length != 1) {
      showMessage('Middle Initial must be only one letter.');
      return;
    }

    if (!_isLettersOnly(firstName)) {
      showMessage('First Name should contain letters only.');
      return;
    }

    if (!_isLettersOnly(lastName)) {
      showMessage('Family Name should contain letters only.');
      return;
    }

    if (middleInitial.isNotEmpty &&
        !_isLettersOnly(middleInitial)) {
      showMessage('Middle Initial should contain letters only.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String fullName;

    if (middleInitial.isNotEmpty) {
      fullName =
          '$firstName $middleInitial. $lastName';
    } else {
      fullName =
          '$firstName $lastName';
    }

    final Student student = Student(
      id: user.id,
      firstName: firstName,
      middleInitial: middleInitial,
      lastName: lastName,
      displayName: displayName,
      fullName: fullName,
      course: course,
      yearLevel: selectedYear,
    );

    try {
      await profileService.saveProfile(student);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen(student: student);
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;

      showMessage(
        'Could not save profile. Please check your connection and database.',
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
        RegExp(r"^[a-zA-Z]+$");

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
        title: const Text('Create Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Set up your StudyCircle profile.',
              ),

              const SizedBox(height: 30),

              TextField(
                controller: firstNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: middleInitialController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 1,
                decoration: const InputDecoration(
                  labelText: 'Middle Initial',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: lastNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Family Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: displayNameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'StudyCircle Name *',
                  prefixIcon: Icon(Icons.alternate_email),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'This is the name other students will see on StudyCircle.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: courseController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Course *',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Year Level *',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: '1st Year',
                    child: Text('1st Year'),
                  ),
                  DropdownMenuItem(
                    value: '2nd Year',
                    child: Text('2nd Year'),
                  ),
                  DropdownMenuItem(
                    value: '3rd Year',
                    child: Text('3rd Year'),
                  ),
                  DropdownMenuItem(
                    value: '4th Year',
                    child: Text('4th Year'),
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
                  onPressed: isLoading ? null : saveProfile,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'Save Profile',
                          style: TextStyle(
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