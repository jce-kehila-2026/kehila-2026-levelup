/// Logic Tier — Helper
/// Path: lib/logic/helpers/logout_helper.dart
///
/// Centralized logout that cancels all active Firestore stream subscriptions
/// BEFORE signing out, preventing `permission-denied` errors from lingering
/// listeners that fire after the auth state becomes null.
library;

import 'package:firebase_auth/firebase_auth.dart';
import '../../di/service_locator.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/instructor_dashboard_controller.dart';
import '../controllers/student_dashboard_controller.dart';
import '../controllers/student_assignment_controller.dart';
import '../controllers/student_notification_controller.dart';
import '../controllers/student_profile_controller.dart';
import '../controllers/auth_controller.dart';

/// Cancel all active Firestore streams on singleton controllers, reset auth
/// state, then sign out from Firebase. This prevents the race condition where
/// Firestore listeners try to read data after the user is no longer
/// authenticated.
Future<void> performLogout() async {
  // 1. Cancel all Firestore stream subscriptions on singleton controllers.
  //    Use try-catch for each so that an uninitialized (never-accessed) lazy
  //    singleton doesn't break the entire logout flow.
  try { getIt<AdminDashboardController>().cancelSubscriptions(); } catch (_) {}
  try { getIt<InstructorDashboardController>().cancelSubscriptions(); } catch (_) {}
  try { getIt<StudentDashboardController>().cancelSubscriptions(); } catch (_) {}
  try { getIt<StudentAssignmentController>().cancelSubscriptions(); } catch (_) {}
  try { getIt<StudentNotificationController>().cancelSubscriptions(); } catch (_) {}
  try { getIt<StudentProfileController>().cancelSubscriptions(); } catch (_) {}

  // 2. Reset auth controller state
  try { getIt<AuthController>().reset(); } catch (_) {}

  // 3. Now sign out — no listeners will fire permission-denied reads
  await FirebaseAuth.instance.signOut();
}
