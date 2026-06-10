/// Logic Tier — Controller
/// Path: lib/logic/controllers/instructor_dashboard_controller.dart
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
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

  StreamSubscription<QuerySnapshot>? _groupsSub;
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
      final allGroups = results[1] as List;
      final myGroups = allGroups
          .where((g) => (g.instructorIds as List).contains(uid))
          .toList();
      final myGroupIds = myGroups.map((g) => g.id as String).toSet();
      _myGroupsCount = myGroups.length;
      final allStudents = results[2] as List<UserModel>;
      _studentsCount = allStudents
          .where((s) => s.groupId != null && myGroupIds.contains(s.groupId))
          .length;
    }
  }

  // ── Real-time streams ──────────────────────────────────────────────────────

  void _startStreams() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Live group counts: filter docs where instructorIds contains this UID
    _groupsSub?.cancel();
    _groupsSub = FirebaseFirestore.instance
        .collection('groups')
        .snapshots()
        .listen((snap) async {
      final myGroupDocs = snap.docs.where((d) {
        final ids = List<String>.from(d.data()['instructorIds'] as List? ?? []);
        return ids.contains(uid);
      }).toList();
      _myGroupsCount = myGroupDocs.length;
      final myGroupIds = myGroupDocs.map((d) => d.id).toSet();
      try {
        final allStudents = await _userRepository.getStudents();
        _studentsCount = allStudents
            .where((s) => s.groupId != null && myGroupIds.contains(s.groupId))
            .length;
      } catch (e) {
        debugPrint('InstructorDashboardController groups stream error: $e');
      }
      notifyListeners();
    });

    // Live assignment list: re-fetch from repository on any change
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
    _groupsSub?.cancel();
    _assignmentsSub?.cancel();
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  Map<String, String> get stats => {
        'myGroups': _myGroupsCount.toString(),
        'students': _studentsCount.toString(),
        'assignments': _activeAssignments.length.toString(),
        'pendingReview': '0',
      };

  List<AssignmentModel> get activeAssignments => _activeAssignments;
}
