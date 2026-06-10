/// Logic Tier — Controller
/// Path: lib/logic/controllers/instructor_dashboard_controller.dart
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/group_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';

class InstructorDashboardController extends ChangeNotifier {
  final AssignmentRepository _assignmentRepo;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AssignmentModel> _activeAssignments = [];
  int _myGroupsCount = 0;
  int _studentsCount = 0;
  String _instructorName = '';

  List<GroupModel> _myGroups = [];
  List<UserModel> _allStudents = [];

  StreamSubscription<DocumentSnapshot>? _userSub;
  StreamSubscription<QuerySnapshot>? _groupsSub;
  StreamSubscription<QuerySnapshot>? _usersSub;
  StreamSubscription<QuerySnapshot>? _assignmentsSub;

  InstructorDashboardController(this._assignmentRepo, this._groupRepository, this._userRepository) {
    _init();
  }

  // ── Initial load ───────────────────────────────────────────────────────────

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _fetchData();
    } catch (e) {
      debugPrint('InstructorDashboardController._init error: $e');
    }
    _isLoading = false;
    notifyListeners();
    _startStreams();
  }

  Future<void> _fetchData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final results = await Future.wait([
      _assignmentRepo.getInstructorAssignments(),
      _groupRepository.getGroups(),
      _userRepository.getStudents(),
    ]);
    _activeAssignments = results[0] as List<AssignmentModel>;
    if (uid != null) {
      // Fetch user document for instructor name
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _instructorName = (userDoc.data()?['name'] as String?) ?? '';
      }

      final allGroups = results[1] as List<GroupModel>;
      _myGroups = allGroups.where((g) => g.instructorIds.contains(uid)).toList();
      _myGroupsCount = _myGroups.length;
      _allStudents = results[2] as List<UserModel>;
      _recalcStudentsCount();
    }
  }

  void _recalcStudentsCount() {
    final activeStudentIds = _allStudents.map((s) => s.id).toSet();
    final myGroupStudentIds = <String>{};
    for (final g in _myGroups) {
      myGroupStudentIds.addAll(g.studentIds);
    }
    _studentsCount = myGroupStudentIds.where((id) => activeStudentIds.contains(id)).length;
  }

  // ── Real-time streams ──────────────────────────────────────────────────────

  void _startStreams() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 1. Live Instructor Profile
    _userSub?.cancel();
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (snap.exists) {
        _instructorName = (snap.data()?['name'] as String?) ?? '';
        notifyListeners();
      }
    });

    // 2. Live group counts: filter docs where instructorIds contains this UID
    _groupsSub?.cancel();
    _groupsSub = FirebaseFirestore.instance
        .collection('groups')
        .snapshots()
        .listen((snap) {
      _myGroups = snap.docs
          .map((d) => GroupModel.fromMap(d.data(), d.id))
          .where((g) => g.instructorIds.contains(uid) && !g.isArchived)
          .toList();
      _myGroupsCount = _myGroups.length;
      _recalcStudentsCount();
      notifyListeners();
    });

    // 3. Live student changes: update _allStudents list in real-time
    _usersSub?.cancel();
    _usersSub = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .listen((snap) {
      _allStudents = snap.docs
          .map((d) => UserModel.fromMap(d.data(), d.id))
          .where((s) => s.isArchived == false)
          .toList();
      _recalcStudentsCount();
      notifyListeners();
    });

    // 4. Live assignment list: re-fetch from repository on any change
    _assignmentsSub?.cancel();
    _assignmentsSub = FirebaseFirestore.instance
        .collection('assignments')
        .snapshots()
        .skip(1) // skip duplicate of the initial load
        .listen((_) async {
      try {
        _activeAssignments = await _assignmentRepo.getInstructorAssignments();
        notifyListeners();
      } catch (e) {
        debugPrint('InstructorDashboardController assignments stream error: $e');
      }
    });
  }

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _fetchData();
    } catch (e) {
      debugPrint('InstructorDashboardController.refresh error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _userSub?.cancel();
    _groupsSub?.cancel();
    _usersSub?.cancel();
    _assignmentsSub?.cancel();
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  String get instructorName => _instructorName;

  Map<String, String> get stats => {
        'myGroups': _myGroupsCount.toString(),
        'students': _studentsCount.toString(),
        'assignments': _activeAssignments.length.toString(),
        'pendingReview': '0',
      };

  List<AssignmentModel> get activeAssignments => _activeAssignments;
}
