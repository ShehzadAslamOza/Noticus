class NotificationEntity {
  final String id;
  final String userId;
  final String packageName;
  final String title;
  final String content;
  final DateTime timestamp;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.packageName,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'packageName': packageName,
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
