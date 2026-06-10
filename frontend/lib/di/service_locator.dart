// Dependency Injection — Service Locator
/// Path: lib/di/service_locator.dart
library;

import 'package:get_it/get_it.dart';

// Repositories
import '../data/repositories/auth_repository.dart';
import '../data/repositories/curriculum_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/group_repository.dart';
import '../data/repositories/assignment_repository.dart';
import '../data/repositories/audit_log_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/student_profile_repository.dart';
import '../data/repositories/submission_repository.dart';

// Controllers — Auth
import '../logic/controllers/auth_controller.dart';

// Controllers — Admin
import '../logic/controllers/admin_dashboard_controller.dart';
import '../logic/controllers/curriculum_controller.dart';
import '../logic/controllers/user_controller.dart';
import '../logic/controllers/group_controller.dart';
import '../logic/controllers/audit_log_controller.dart';

// Controllers — Instructor
import '../logic/controllers/instructor_dashboard_controller.dart';
import '../logic/controllers/instructor_assignment_controller.dart';
import '../logic/controllers/instructor_group_controller.dart';
import '../logic/controllers/instructor_log_controller.dart';

// Controllers — Student
import '../logic/controllers/student_dashboard_controller.dart';
import '../logic/controllers/student_assignment_controller.dart';
import '../logic/controllers/student_notification_controller.dart';
import '../logic/controllers/student_profile_controller.dart';

// Controllers — Details
import '../logic/controllers/assignment_detail_controller.dart';
import '../logic/controllers/group_detail_controller.dart';
import '../logic/controllers/lesson_detail_controller.dart';
import '../logic/controllers/student_detail_controller.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // ──────────────────────────────────────
  // Data Tier — Repositories (lazy singletons)
  // ──────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository());
  getIt.registerLazySingleton<CurriculumRepository>(() => CurriculumRepository());
  getIt.registerLazySingleton<UserRepository>(() => UserRepository());
  getIt.registerLazySingleton<GroupRepository>(() => GroupRepository());
  getIt.registerLazySingleton<AssignmentRepository>(() => AssignmentRepository());
  getIt.registerLazySingleton<AuditLogRepository>(() => AuditLogRepository());
  getIt.registerLazySingleton<NotificationRepository>(() => NotificationRepository());
  getIt.registerLazySingleton<StudentProfileRepository>(() => StudentProfileRepository());
  getIt.registerLazySingleton<SubmissionRepository>(() => SubmissionRepository());

  // ──────────────────────────────────────
  // Logic Tier — Controllers: Auth
  // ──────────────────────────────────────
  getIt.registerLazySingleton<AuthController>(
    () => AuthController(getIt<AuthRepository>()),
  );

  // ──────────────────────────────────────
  // Logic Tier — Controllers: Admin
  // ──────────────────────────────────────
  getIt.registerLazySingleton<AdminDashboardController>(
    () => AdminDashboardController(getIt<AuditLogRepository>()),
  );
  getIt.registerLazySingleton<CurriculumController>(
    () => CurriculumController(getIt<CurriculumRepository>(), getIt<AssignmentRepository>(), getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<UserController>(
    () => UserController(getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<GroupController>(
    () => GroupController(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<AuditLogController>(
    () => AuditLogController(getIt<AuditLogRepository>()),
  );

  // ──────────────────────────────────────
  // Logic Tier — Controllers: Instructor
  // ──────────────────────────────────────
  getIt.registerFactory<InstructorDashboardController>(
    () => InstructorDashboardController(getIt<AssignmentRepository>()),
  );
  getIt.registerFactory<InstructorAssignmentController>(
    () => InstructorAssignmentController(getIt<AssignmentRepository>()),
  );
  getIt.registerFactory<InstructorGroupController>(
    () => InstructorGroupController(getIt<GroupRepository>(), getIt<UserRepository>()),
  );
  getIt.registerFactory<InstructorLogController>(
    () => InstructorLogController(getIt<AuditLogRepository>()),
  );

  // ──────────────────────────────────────
  // Logic Tier — Controllers: Student
  // ──────────────────────────────────────
  getIt.registerFactory<StudentDashboardController>(
    () => StudentDashboardController(),
  );
  getIt.registerFactory<StudentAssignmentController>(
    () => StudentAssignmentController(),
  );
  getIt.registerFactory<StudentNotificationController>(
    () => StudentNotificationController(getIt<NotificationRepository>()),
  );
  getIt.registerFactory<StudentProfileController>(
    () => StudentProfileController(getIt<StudentProfileRepository>()),
  );

  // ──────────────────────────────────────
  // Logic Tier — Controllers: Details (Factories)
  // ──────────────────────────────────────
  getIt.registerFactoryParam<AssignmentDetailController, String, void>(
    (id, _) => AssignmentDetailController(id, getIt<AssignmentRepository>(), getIt<AuthController>(), getIt<SubmissionRepository>(), getIt<UserRepository>()),
  );
  getIt.registerFactoryParam<GroupDetailController, String, void>(
    (id, _) => GroupDetailController(id, getIt<GroupRepository>(), getIt<UserRepository>()),
  );
  getIt.registerFactoryParam<LessonDetailController, String, void>(
    (id, _) => LessonDetailController(id, getIt<CurriculumRepository>()),
  );
  getIt.registerFactoryParam<StudentDetailController, String, void>(
    (id, _) => StudentDetailController(id, getIt<StudentProfileRepository>()),
  );
}

