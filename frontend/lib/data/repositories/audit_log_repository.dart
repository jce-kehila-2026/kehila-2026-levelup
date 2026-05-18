/// Data Tier — Repository
/// Path: lib/data/repositories/audit_log_repository.dart
library;

import '../models/audit_log_model.dart';

class AuditLogRepository {
  Future<List<AuditLog>> getAllLogs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AuditLog(id: '1', action: 'Created new level', details: 'Level 3 — Advanced', performerName: 'Admin User', performerRole: 'admin', performedBy: 'admin_uid', time: DateTime.now().subtract(const Duration(minutes: 5)), preciseTimestamp: DateTime.now().subtract(const Duration(minutes: 5)), serialNumber: '1'),
      AuditLog(id: '2', action: 'Added instructor', details: 'sarah.j@levelup.edu', performerName: 'Admin User', performerRole: 'admin', performedBy: 'admin_uid', time: DateTime.now().subtract(const Duration(hours: 1)), preciseTimestamp: DateTime.now().subtract(const Duration(hours: 1)), serialNumber: '1'),
      // Arabic log entry — Arabic instructor name and Arabic action coexist with English entries
      AuditLog(id: '3', action: 'إنشاء واجب', details: 'تمرين إعداد الرقعة — الأسبوع الأول', performerName: 'د. أحمد الشريف', performerRole: 'instructor', performedBy: '#2', time: DateTime.now().subtract(const Duration(hours: 3)), preciseTimestamp: DateTime.now().subtract(const Duration(hours: 3)), serialNumber: '2'),
      AuditLog(id: '4', action: 'Graded submission', details: 'Alex Rivera — 92%', performerName: 'Sarah Jenkins', performerRole: 'instructor', performedBy: '#3', time: DateTime.now().subtract(const Duration(hours: 5)), preciseTimestamp: DateTime.now().subtract(const Duration(hours: 5)), serialNumber: '3'),
      // Arabic log entry — student name and action in Arabic to test mixed student roster rendering
      AuditLog(id: '5', action: 'تسليم واجب', details: 'الأسبوع الأول: تمرين إعداد الرقعة', performerName: 'عمر حسان', performerRole: 'student', performedBy: '#1003', time: DateTime.now().subtract(const Duration(days: 1)), preciseTimestamp: DateTime.now().subtract(const Duration(days: 1)), serialNumber: '1003'),
      AuditLog(id: '6', action: 'Joined group', details: 'المجموعة المسائية', performerName: 'Maya Patel', performerRole: 'student', performedBy: '#1002', time: DateTime.now().subtract(const Duration(days: 1, hours: 2)), preciseTimestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)), serialNumber: '1002'),
      AuditLog(id: '7', action: 'Updated curriculum', details: 'Level 1 — Week 3 content', performerName: 'Dr. Ahmed', performerRole: 'instructor', performedBy: '#2', time: DateTime.now().subtract(const Duration(days: 2)), preciseTimestamp: DateTime.now().subtract(const Duration(days: 2)), serialNumber: '2'),
      AuditLog(id: '8', action: 'Deleted group', details: 'Test Group (cleanup)', performerName: 'Admin User', performerRole: 'admin', performedBy: 'admin_uid', time: DateTime.now().subtract(const Duration(days: 2, hours: 6)), preciseTimestamp: DateTime.now().subtract(const Duration(days: 2, hours: 6)), serialNumber: '1'),
    ];
  }

  /// Returns the most recent N logs.
  Future<List<AuditLog>> getRecentLogs({int count = 5}) async {
    final all = await getAllLogs();
    return all.take(count).toList();
  }

  /// Returns rich, instructor-specific activity logs with target person info.
  Future<List<AuditLog>> getInstructorLogs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      // Grading actions
      AuditLog(
        id: 'il1',
        action: 'Graded assignment',
        details: 'Marked "Week 1: Fundamentals Quiz" as Correct for Alex Rivera #1001',
        performerName: 'Dr. Ahmed',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(minutes: 12)),
        preciseTimestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        serialNumber: '2',
        targetPersonName: 'Alex Rivera',
        targetStudentNumber: '#1001',
      ),
      AuditLog(
        id: 'il2',
        action: 'Revised grade',
        details: 'Changed "Board Setup Exercise" to Needs Revision for Maya Patel #1002',
        performerName: 'Dr. Ahmed',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(minutes: 45)),
        preciseTimestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        serialNumber: '2',
        targetPersonName: 'Maya Patel',
        targetStudentNumber: '#1002',
      ),

      // Student management
      AuditLog(
        id: 'il3',
        action: 'Added new student',
        details: 'Created credentials for James Walker #1005 in Morning Group A',
        performerName: 'Dr. Ahmed',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        serialNumber: '2',
        targetPersonName: 'James Walker',
        targetStudentNumber: '#1005',
      ),
      // Arabic log — Arabic student name in target fields tests RTL rendering in activity timeline
      AuditLog(
        id: 'il4',
        action: 'إعادة تعيين الرمز السري',
        details: 'تم إعادة تعيين رمز الدخول للطالب عمر حسان #1003',
        performerName: 'د. أحمد الشريف',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
        serialNumber: '2',
        targetPersonName: 'عمر حسان',
        targetStudentNumber: '#1003',
      ),

      // Assignment creation
      AuditLog(
        id: 'il5',
        action: 'Created assignment',
        details: 'New custom assignment: "Opening Principles Essay" with 7-day deadline',
        performerName: 'Dr. Ahmed',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(hours: 3)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 3)),
        serialNumber: '2',
      ),
      // Arabic log — Arabic group name references the bilingual group record
      AuditLog(
        id: 'il6',
        action: 'تعيين من المنهج',
        details: 'تم تعيين "ابحث عن الشوكة" من مجموعة المسؤول إلى المجموعة المسائية',
        performerName: 'Sarah Jenkins',
        performerRole: 'instructor',
        performedBy: '#3',
        time: DateTime.now().subtract(const Duration(hours: 5)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 5)),
        serialNumber: '3',
      ),

      // Curriculum actions
      AuditLog(
        id: 'il7',
        action: 'Assigned Level 1 content',
        details: 'Linked "Knight Movement Basics" to Level 1 students in Morning Group A',
        performerName: 'Dr. Ahmed',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(hours: 8)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 8)),
        serialNumber: '2',
      ),

      // Student submissions
      AuditLog(
        id: 'il8',
        action: 'Student submitted work',
        details: 'Lina Chen #1004 submitted "Notation Practice"',
        performerName: 'Lina Chen',
        performerRole: 'student',
        performedBy: '#1004',
        time: DateTime.now().subtract(const Duration(hours: 10)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 10)),
        serialNumber: '1004',
        targetPersonName: 'Lina Chen',
        targetStudentNumber: '#1004',
      ),
      // Fully Arabic log — both performer and details in Arabic for complete RTL log row test
      AuditLog(
        id: 'il9',
        action: 'تسليم عمل من الطالب',
        details: 'عمر حسان #1003 سلّم واجب "ابحث عن الشوكة"',
        performerName: 'عمر حسان',
        performerRole: 'student',
        performedBy: '#1003',
        time: DateTime.now().subtract(const Duration(hours: 12)),
        preciseTimestamp: DateTime.now().subtract(const Duration(hours: 12)),
        serialNumber: '1003',
        targetPersonName: 'عمر حسان',
        targetStudentNumber: '#1003',
      ),

      // Group management
      // Arabic target name — tests RTL student name rendering in the target column of the log table
      AuditLog(
        id: 'il10',
        action: 'Removed student from group',
        details: 'Removed فاطمة الزهراء #1006 from Advanced Cohort',
        performerName: 'Sarah Jenkins',
        performerRole: 'instructor',
        performedBy: '#3',
        time: DateTime.now().subtract(const Duration(days: 1)),
        preciseTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        serialNumber: '3',
        targetPersonName: 'فاطمة الزهراء',
        targetStudentNumber: '#1006',
      ),
      AuditLog(
        id: 'il11',
        action: 'Graded assignment',
        details: 'Marked "Notation Practice" as Correct for Fatima Al-Zahra #1006',
        performerName: 'Sarah Jenkins',
        performerRole: 'instructor',
        performedBy: '#3',
        time: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        preciseTimestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        serialNumber: '3',
        targetPersonName: 'Fatima Al-Zahra',
        targetStudentNumber: '#1006',
      ),
      AuditLog(
        id: 'il12',
        action: 'Updated group schedule',
        details: 'Changed Morning Group A schedule from Mon/Wed to Tue/Thu',
        performerName: 'Dr. Ahmed',
        performerRole: 'instructor',
        performedBy: '#2',
        time: DateTime.now().subtract(const Duration(days: 2)),
        preciseTimestamp: DateTime.now().subtract(const Duration(days: 2)),
        serialNumber: '2',
      ),
    ];
  }
}
