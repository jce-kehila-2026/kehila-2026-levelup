/// Data Tier — Repository
/// Path: lib/data/repositories/notification_repository.dart
library;

import '../models/notification_model.dart';

class NotificationRepository {
  final List<AppNotification> _notifications = [
    AppNotification(id: '1', title: 'New Assignment Assigned', body: 'Mr. Smith assigned "Find the Fork". Due in 2 days.', type: 'assignment', relatedId: 'a3', isRead: false, time: '2h ago'),
    // Arabic notification — coexists with English one above to test bilingual notification list rendering
    AppNotification(id: '2', title: 'تم تصحيح الواجب', body: 'تم تصحيح إجابتك على "اختبار مبادئ الافتتاح". الحكم: صحيح!', type: 'grade', relatedId: 'a4', isRead: false, time: '5h ago'),
    // Arabic notification — tests RTL body text in a read notification card
    AppNotification(id: '3', title: 'تم إتاحة محتوى جديد', body: 'منهج المستوى الثاني أصبح متاحاً الآن في قسم الدروس.', type: 'material', isRead: true, time: '1d ago'),
  ];

  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_notifications);
  }

  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
  }
}
