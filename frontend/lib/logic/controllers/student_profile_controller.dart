/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_profile_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/student_profile_model.dart';
import '../../data/repositories/student_profile_repository.dart';

class StudentProfileController extends ChangeNotifier {
  final StudentProfileRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late StudentProfile _profile;

  StudentProfileController(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _profile = await _repository.getProfile();
    _isLoading = false;
    notifyListeners();
  }

  // ── Getters ────────────────────────────
  StudentProfile get profile => _profile;
}
