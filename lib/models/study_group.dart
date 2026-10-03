class StudyGroup {
  final int id;
  final String creatorId;
  final String subject;
  final String title;
  final String description;
  final String location;
  final String schedule;
  final DateTime createdAt;

  StudyGroup({
    required this.id,
    required this.creatorId,
    required this.subject,
    required this.title,
    required this.description,
    required this.location,
    required this.schedule,
    required this.createdAt,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id'] as int,
      creatorId: map['creator_id'] as String,
      subject: map['subject'] as String,
      title: map['title'] as String,
      description: map['description'] ?? '',
      location: map['location'] as String,
      schedule: map['schedule'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creator_id': creatorId,
      'subject': subject,
      'title': title,
      'description': description,
      'location': location,
      'schedule': schedule,
      'created_at': createdAt.toIso8601String(),
    };
  }
}