/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_dashboard_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/curriculum_model.dart';

class StudentDashboardController extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _search = '';
  String _studentName = '';
  String _levelLabel = '';
  String _groupLabel = '—';
  String _instructorName = '—';
  List<CurriculumItem> _allLessons = [];

  StreamSubscription<DocumentSnapshot>? _userDocSub;
  StreamSubscription<DocumentSnapshot>? _curriculumSub;
  StreamSubscription<DocumentSnapshot>? _groupSub;

  String? _subscribedLevelId;
  String? _subscribedGroupId;

  StudentDashboardController() {
    _load();
  }

  // ── Initial load ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    await _fetchAll();
    _isLoading = false;
    notifyListeners();
    _startStreams();
  }

  Future<void> _fetchAll() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final db = FirebaseFirestore.instance;
      String? levelId;

      // 1. User document — display name and levelId
      final userDoc = await db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _studentName = data['name'] as String? ?? '';
        levelId = data['levelId'] as String?;
      }

      // 2. Group — label, instructor name, and levelId fallback.
      //    Try groupId shortcut first; fall back to a full collection scan.
      String? groupId;
      if (userDoc.exists) {
        groupId = userDoc.data()?['groupId'] as String?;
      }
      Map<String, dynamic>? groupData;

      if (groupId != null && groupId.isNotEmpty) {
        final doc = await db.collection('groups').doc(groupId).get();
        if (doc.exists) groupData = doc.data();
      }

      if (groupData == null) {
        final snap = await db.collection('groups').get();
        for (final doc in snap.docs) {
          final data = doc.data();
          final students = data['students'] as List<dynamic>? ?? [];
          if (students.any((s) => (s as Map)['id'] == uid)) {
            groupData = data;
            groupId = doc.id;
            break;
          }
        }
      }

      if (groupData != null) {
        _groupLabel = groupData['name'] as String? ?? '—';
        final instructorIds =
            List<String>.from(groupData['instructorIds'] as List? ?? []);
        if (instructorIds.isNotEmpty) {
          final instDoc =
              await db.collection('users').doc(instructorIds.first).get();
          _instructorName = instDoc.data()?['name'] as String? ?? '—';
        }
        if (levelId == null || levelId.isEmpty) {
          levelId = groupData['globalLevel'] as String?;
        }
      }

      if (groupId != null && groupId.isNotEmpty) {
        _subscribeToGroup(groupId);
      }

      // 3. Level name and visible lesson library
      if (levelId != null && levelId.isNotEmpty) {
        final levelDoc =
            await db.collection('curriculum').doc(levelId).get();
        if (levelDoc.exists) {
          final data = levelDoc.data()!;
          _levelLabel = data['name'] as String? ?? levelId;
          _allLessons = _parseLessons(data);
        } else {
          _levelLabel = levelId;
        }
        _subscribeToCurriculum(levelId);
      }
    } catch (e) {
      debugPrint('StudentDashboardController._fetchAll error: $e');
    }
  }

  // ── Real-time streams ──────────────────────────────────────────────────────

  void _startStreams() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _userDocSub?.cancel();
    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .skip(1) // skip the first event which duplicates the initial load
        .listen((snap) async {
      if (!snap.exists || snap.data() == null) return;
      await _fetchAll();
      notifyListeners();
    });
  }

  void _subscribeToGroup(String groupId) {
    if (_subscribedGroupId == groupId) return;
    _subscribedGroupId = groupId;
    _groupSub?.cancel();
    _groupSub = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .skip(1)
        .listen((snap) async {
      await _fetchAll();
      notifyListeners();
    });
  }

  void _subscribeToCurriculum(String levelId) {
    if (_subscribedLevelId == levelId) return;
    _subscribedLevelId = levelId;
    _curriculumSub?.cancel();
    _curriculumSub = FirebaseFirestore.instance
        .collection('curriculum')
        .doc(levelId)
        .snapshots()
        .skip(1) // skip duplicate of the initial get() above
        .listen((snap) {
      if (!snap.exists || snap.data() == null) return;
      final data = snap.data()!;
      _levelLabel = data['name'] as String? ?? levelId;
      _allLessons = _parseLessons(data);
      notifyListeners();
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<CurriculumItem> _parseLessons(Map<String, dynamic> levelData) {
    final rawWeeks = levelData['weeks'] as List<dynamic>? ?? [];
    final items = <CurriculumItem>[];
    for (final rawWeek in rawWeeks) {
      final weekMap = rawWeek as Map<String, dynamic>;
      final rawItems = weekMap['items'] as List<dynamic>? ?? [];
      for (final rawItem in rawItems) {
        final item = CurriculumItem.fromMap(rawItem as Map<String, dynamic>);
        if (item.visible && item.type == CurriculumItemType.material) {
          items.add(item);
        }
      }
    }
    return items;
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _userDocSub?.cancel();
    _curriculumSub?.cancel();
    _groupSub?.cancel();
    super.dispose();
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  String get search => _search;
  String get studentName => _studentName;
  String get levelLabel => _levelLabel;
  String get groupLabel => _groupLabel;
  String get instructorName => _instructorName;
  int get lessonCount => _allLessons.length;
  int get tasksDue => 0;
  int get newNotifications => 0;

  List<CurriculumItem> get lessons {
    if (_search.isEmpty) return _allLessons;
    final term = _search.toLowerCase();
    return _allLessons.where((l) {
      final matchTitle = l.title.toLowerCase().contains(term);
      final matchTag = l.searchTags.any((t) => t.toLowerCase().contains(term));
      return matchTitle || matchTag;
    }).toList();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }
}
