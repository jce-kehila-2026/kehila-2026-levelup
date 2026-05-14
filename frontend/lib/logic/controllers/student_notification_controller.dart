/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_notification_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class StudentNotificationController extends ChangeNotifier {
  final NotificationRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AppNotification> _notifications = [];

  StudentNotificationController(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _notifications = await _repository.getNotifications();
    _isLoading = false;
    notifyListeners();
  }

  // ── Getters ────────────────────────────
  List<AppNotification> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  void markAsRead(AppNotification item) {
    item.isRead = true;
    notifyListeners();
  }
}
