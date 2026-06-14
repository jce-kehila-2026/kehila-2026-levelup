/// Logic Tier — Controller
/// Path: lib/logic/controllers/admin_dashboard_controller.dart
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/repositories/audit_log_repository.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';

class AdminDashboardController extends ChangeNotifier {
  final AuditLogRepository _logRepository;
  final UserRepository _userRepository;
  final GroupRepository _groupRepository;
  final CurriculumRepository _curriculumRepository;

  AdminDashboardController(
    this._logRepository,
    this._userRepository,
    this._groupRepository,
    this._curriculumRepository,
  ) {
    _init();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AuditLog> _recentLogs = [];
  int _studentCount = 0;
  int _instructorCount = 0;
  int _groupCount = 0;
  int _levelCount = 0;
  int _lessonCount = 0;

  StreamSubscription<QuerySnapshot>? _usersSub;
  StreamSubscription<QuerySnapshot>? _groupsSub;
  StreamSubscription<QuerySnapshot>? _levelsSub;

  // ── Initial load ───────────────────────────────────────────────────────────

  String? _error;
  String? get error => _error;

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _logRepository.getRecentLogs(count: 5),
        _userRepository.getStudents(),
        _userRepository.getInstructors(),
        _groupRepository.getGroups(),
        _curriculumRepository.getLevels(),
      ]);
      _recentLogs = results[0] as List<AuditLog>;
      _studentCount = (results[1] as List).length;
      _instructorCount = (results[2] as List).length;
      _groupCount = (results[3] as List).length;
      final levels = results[4] as List<LevelModel>;
      _levelCount = levels.length;
      _lessonCount = levels.fold(
          0, (acc, l) => acc + l.weeks.fold(0, (ws, w) => ws + w.items.length));
    } catch (e, stack) {
      _error = e.toString();
      debugPrint('AdminDashboardController._init error: $e');
      debugPrint('Stacktrace: $stack');
    }
    _isLoading = false;
    notifyListeners();
    _startStreams();
  }

  // ── Real-time streams ──────────────────────────────────────────────────────

  void _startStreams() {
    // Live student/instructor counts from the users collection (excluding archived users)
    _usersSub?.cancel();
    _usersSub = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .skip(1) // skip duplicate of the initial load
        .listen((snap) {
      int students = 0;
      int instructors = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final role = data['role'] as String?;
        final isArchived = data['isArchived'] as bool? ?? false;
        if (isArchived) continue;
        if (role == 'student') { students++; }
        else if (role == 'instructor') { instructors++; }
      }
      _studentCount = students;
      _instructorCount = instructors;
      notifyListeners();
    });

    // Live group count from the groups collection (excluding archived groups)
    _groupsSub?.cancel();
    _groupsSub = FirebaseFirestore.instance
        .collection('groups')
        .snapshots()
        .skip(1) // skip duplicate of the initial load
        .listen((snap) {
      int activeGroups = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final isArchived = data['isArchived'] as bool? ?? false;
        if (!isArchived) {
          activeGroups++;
        }
      }
      _groupCount = activeGroups;
      notifyListeners();
    });

    // Live curriculum count and lessons count from the curriculum collection
    _levelsSub?.cancel();
    _levelsSub = FirebaseFirestore.instance
        .collection('curriculum')
        .snapshots()
        .skip(1)
        .listen((snap) {
      final levels = snap.docs.map((d) => LevelModel.fromMap(d.data(), d.id)).toList();
      _levelCount = levels.length;
      _lessonCount = levels.fold(
          0, (acc, l) => acc + l.weeks.fold(0, (ws, w) => ws + w.items.length));
      notifyListeners();
    });
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _usersSub?.cancel();
    _groupsSub?.cancel();
    _levelsSub?.cancel();
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  Map<String, String> get stats => {
        'students': _studentCount.toString(),
        'instructors': _instructorCount.toString(),
        'levels': _levelCount.toString(),
        'groups': _groupCount.toString(),
        'lessons': _lessonCount.toString(),
        'activeTasks': '0',
      };

  List<AuditLog> get recentLogs => _recentLogs;
}
