/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_detail_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/student_profile_model.dart';
import '../../data/repositories/student_profile_repository.dart';

class StudentDetailController extends ChangeNotifier {
  final String studentId;
  final StudentProfileRepository _repository;
  
  late StudentProfile profile;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StudentDetailController(this.studentId, this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    profile = await _repository.getProfileById(studentId) ?? 
      StudentProfile(id: studentId, name: 'Unknown Student', username: '', studentId: '', level: '', group: '', instructorName: '');
    _isLoading = false;
    notifyListeners();
  }

  // Add any student specific state/actions here
}
