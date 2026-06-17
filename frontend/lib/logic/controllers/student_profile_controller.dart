/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_profile_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/student_profile_model.dart';
import '../../data/repositories/student_profile_repository.dart';

class StudentProfileController extends ChangeNotifier {
  final StudentProfileRepository _repository;
  StreamSubscription<User?>? _authSub;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StudentProfile? _profile;

  StudentProfileController(this._repository) {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _init();
      } else {
        _profile = null;
        notifyListeners();
      }
    });
  }

  String? _error;
  String? get error => _error;

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.getProfile();
    } catch (e, stack) {
      _error = e.toString();
      debugPrint('StudentProfileController._init error: $e');
      debugPrint('Stacktrace: $stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Getters ────────────────────────────
  StudentProfile get profile => _profile ?? StudentProfile(
        id: '',
        name: '',
        username: '',
        studentId: '',
        level: '',
        group: '',
        instructorName: '',
        submissions: 0,
        graded: 0,
        correct: 0,
      );

  /// Cancel all active Firestore stream subscriptions without disposing the
  /// controller. Called by the logout helper before FirebaseAuth.signOut().
  void cancelSubscriptions() {
    _authSub?.cancel();
    _authSub = null;
  }

  @override
  void dispose() {
    cancelSubscriptions();
    super.dispose();
  }
}
