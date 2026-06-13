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
    try {
      _notifications = await _repository.getNotifications();
    } catch (e) {
      debugPrint('StudentNotificationController._init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refetches notifications from Firestore.
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = await _repository.getNotifications();
    } catch (e) {
      debugPrint('StudentNotificationController.refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Getters ────────────────────────────
  List<AppNotification> get notifications => _notifications;

  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Marks a notification as read and persists it to Firestore.
  Future<void> markAsRead(AppNotification item) async {
    if (item.isRead) return;
    item.isRead = true;
    notifyListeners();
    try {
      await _repository.markAsRead(item.id);
    } catch (e) {
      debugPrint('StudentNotificationController.markAsRead error: $e');
    }
  }
}
