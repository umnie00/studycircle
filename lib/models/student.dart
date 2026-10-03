class Student {
  final String id;

  // Formal name
  final String firstName;
  final String middleInitial;
  final String lastName;

  // StudyCircle public name
  final String displayName;

  // Kept for compatibility with the existing system
  final String fullName;

  final String course;
  final String yearLevel;

  Student({
    required this.id,
    required this.firstName,
    required this.middleInitial,
    required this.lastName,
    required this.displayName,
    required this.fullName,
    required this.course,
    required this.yearLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'middle_initial': middleInitial,
      'last_name': lastName,
      'display_name': displayName,
      'full_name': fullName,
      'course': course,
      'year_level': yearLevel,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    final String firstName =
        (map['first_name'] ?? '').toString();

    final String middleInitial =
        (map['middle_initial'] ?? '').toString();

    final String lastName =
        (map['last_name'] ?? '').toString();

    final String existingFullName =
        (map['full_name'] ?? '').toString();

    final String fullName = existingFullName.isNotEmpty
        ? existingFullName
        : [
            firstName,
            middleInitial,
            lastName,
          ].where((name) => name.isNotEmpty).join(' ');

    return Student(
      id: map['id'].toString(),
      firstName: firstName,
      middleInitial: middleInitial,
      lastName: lastName,
      displayName: (map['display_name'] ?? '').toString(),
      fullName: fullName,
      course: (map['course'] ?? '').toString(),
      yearLevel: (map['year_level'] ?? '').toString(),
    );
  }
}
