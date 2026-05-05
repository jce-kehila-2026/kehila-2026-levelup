/// Data Tier — Model
/// Path: lib/data/models/notification_model.dart
library;

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'assignment', 'grade', 'lesson'
  final String? relatedId; // ID of the related assignment/lesson
  bool isRead;
  final String time;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.isRead = false,
    required this.time,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String documentId) {
    return AppNotification(
      id: documentId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'info',
      relatedId: map['relatedId'],
      isRead: map['isRead'] ?? false,
      time: map['time'] ?? 'Just now',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': isRead,
      'time': time,
    };
  }
}
