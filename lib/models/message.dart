class Message {
  final int id;
  final int groupId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      groupId: map['group_id'] as int,
      senderId: map['sender_id'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(
        map['created_at'] as String,
      ),
    );
  }
}