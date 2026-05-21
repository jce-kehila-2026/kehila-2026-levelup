/// Logic Tier — Controller
/// Path: lib/logic/controllers/group_detail_controller.dart
library;

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/group_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';

class GroupDetailController extends ChangeNotifier {
  final String groupId;
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;
  
  late GroupModel group;
  List<UserModel> _allInstructors = [];
  List<UserModel> _allStudents = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// Canonical level map used throughout the app.
  static const Map<String, String> levelMap = {
    'l1': 'Level 1',
    'l2': 'Level 2',
    'l3': 'Level 3',
  };

  GroupDetailController(this.groupId, this._groupRepository, this._userRepository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    
    group = await _groupRepository.getGroupById(groupId) ??
      GroupModel(id: groupId, serialNumber: 0, name: 'Unknown Group', instructorIds: [], students: [], createdAt: DateTime.now());
    
    _allInstructors = await _userRepository.getInstructors();
    _allStudents = await _userRepository.getStudents();
    
    _isLoading = false;
    notifyListeners();
  }

  // ── State ──────────────────────────────
  String _search = '';
  String _availableInstructorsSearch = '';
  String _availableStudentsSearch = '';
  String? _selectedLevelFilter; // null means "All Levels"

  /// Transient selection state for bulk-add dialog (selected student IDs).
  final Set<String> _bulkSelectedStudentIds = {};

  // ── Getters ────────────────────────────
  String get search => _search;
  String get availableInstructorsSearch => _availableInstructorsSearch;
  String get availableStudentsSearch => _availableStudentsSearch;
  String? get selectedLevelFilter => _selectedLevelFilter;

  Set<String> get bulkSelectedStudentIds => Set.unmodifiable(_bulkSelectedStudentIds);
  int get bulkSelectionCount => _bulkSelectedStudentIds.length;
  
  List<UserModel> get groupInstructors {
    return _allInstructors.where((i) => group.instructorIds.contains(i.id)).toList();
  }

  List<UserModel> get availableInstructors {
    final available = _allInstructors.where((i) => !group.instructorIds.contains(i.id)).toList();
    if (_availableInstructorsSearch.isEmpty) return available;
    final term = _availableInstructorsSearch.toLowerCase();
    return available.where((i) => i.name.toLowerCase().contains(term) || (i.email ?? '').toLowerCase().contains(term)).toList();
  }

  /// Returns students grouped by their academic level within this group.
  /// The returned Map is ordered by level key (l1, l2, l3).
  Map<String, List<UserModel>> get studentsByLevel {
    final Map<String, List<UserModel>> result = {};
    
    for (final entry in group.studentLevels.entries) {
      final studentId = entry.key;
      final levelId = entry.value;
      final user = _allStudents.where((s) => s.id == studentId).firstOrNull;
      if (user == null) continue;

      // Apply search filter (name, username, studentNumber)
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchesName = user.name.toLowerCase().contains(q);
        final matchesUsername = (user.username ?? '').toLowerCase().contains(q);
        final matchesStudentNum = (user.studentNumber ?? '').toLowerCase().contains(q);
        if (!matchesName && !matchesUsername && !matchesStudentNum) continue;
      }

      // Apply level filter
      if (_selectedLevelFilter != null && _selectedLevelFilter != levelId) {
        continue;
      }

      result.putIfAbsent(levelId, () => []);
      result[levelId]!.add(user);
    }

    // Sort by level key so l1 appears before l2, etc.
    final sorted = Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  /// Flat list of all students in the group (for count display, etc.)
  List<UserModel> get allGroupStudents {
    return _allStudents.where((s) => group.studentLevels.containsKey(s.id)).toList();
  }

  List<UserModel> get availableStudents {
    final available = _allStudents.where((s) => !group.studentLevels.containsKey(s.id)).toList();
    if (_availableStudentsSearch.isEmpty) return available;
    final term = _availableStudentsSearch.toLowerCase();
    return available.where((s) => s.name.toLowerCase().contains(term) || (s.email ?? '').toLowerCase().contains(term)).toList();
  }

  // ── Actions ────────────────────────────
  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setLevelFilter(String? levelId) {
    _selectedLevelFilter = levelId;
    notifyListeners();
  }

  void setAvailableInstructorsSearch(String value) {
    _availableInstructorsSearch = value;
    notifyListeners();
  }

  void setAvailableStudentsSearch(String value) {
    _availableStudentsSearch = value;
    notifyListeners();
  }

  void toggleBulkStudent(String studentId) {
    if (_bulkSelectedStudentIds.contains(studentId)) {
      _bulkSelectedStudentIds.remove(studentId);
    } else {
      _bulkSelectedStudentIds.add(studentId);
    }
    notifyListeners();
  }

  void clearBulkSelection() {
    _bulkSelectedStudentIds.clear();
    notifyListeners();
  }

  Future<bool> deleteGroup() async {
    _isLoading = true;
    notifyListeners();
    await _groupRepository.deleteGroup(groupId);
    return true;
  }

  Future<void> addInstructor(String instructorId) async {
    _isLoading = true;
    notifyListeners();
    await _groupRepository.addInstructorToGroup(groupId, instructorId);
    _availableInstructorsSearch = '';
    await _init();
  }

  Future<void> removeInstructor(String instructorId) async {
    _isLoading = true;
    notifyListeners();
    await _groupRepository.removeInstructorFromGroup(groupId, instructorId);
    await _init();
  }

  Future<void> addStudent(String studentId, String levelId) async {
    _isLoading = true;
    notifyListeners();
    await _groupRepository.addStudentToGroup(groupId, studentId, levelId);
    _availableStudentsSearch = '';
    await _init();
  }

  /// Adds all currently selected students to the group at the given global level,
  /// with one _init() call at the end.
  Future<void> bulkAddStudents(String levelId) async {
    if (_bulkSelectedStudentIds.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    for (final studentId in _bulkSelectedStudentIds) {
      await _groupRepository.addStudentToGroup(groupId, studentId, levelId);
    }
    _bulkSelectedStudentIds.clear();
    _availableStudentsSearch = '';
    await _init();
  }

  /// Creates multiple new students and adds them to the group in a single
  /// operation, calling _init() only once at the end.
  Future<List<UserModel>> bulkCreateStudents(
      List<({String name, String levelId})> entries) async {
    final created = <UserModel>[];
    for (final e in entries) {
      final idx = _allStudents.length + created.length + 1001;
      final studentNumber = '#$idx';
      final username = _generateUsername(e.name);
      final pinCode = (1000 + Random().nextInt(9000)).toString();
      final student = UserModel(
        id: studentNumber,
        userNumber: idx,
        name: e.name,
        email: '${username.replaceAll('.', '')}@levelup.edu',
        role: UserRole.student,
        studentNumber: studentNumber,
        username: username,
        pinCode: pinCode,
        lastActive: null,
      );
      _allStudents.add(student);
      await _groupRepository.addStudentToGroup(groupId, studentNumber, e.levelId);
      created.add(student);
    }
    await _init();
    return created;
  }

  Future<void> removeStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();
    await _groupRepository.removeStudentFromGroup(groupId, studentId);
    await _init();
  }

  /// Permanently deletes a student from the group AND the user repository.
  Future<void> deleteStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();
    await _groupRepository.removeStudentFromGroup(groupId, studentId);
    await _userRepository.deleteStudent(studentId);
    await _init();
  }

  /// Creates a new student, adds them to this group at the given level,
  /// and returns the created UserModel with their credentials.
  Future<UserModel> createStudent(String fullName, String levelId) async {
    final random = Random();
    final nextNumber = _allStudents.length + 1001;
    final studentNumber = '#$nextNumber';
    final username = _generateUsername(fullName);
    final pinCode = (1000 + random.nextInt(9000)).toString();

    final student = UserModel(
      id: studentNumber,
      userNumber: nextNumber,
      name: fullName,
      email: '${username.replaceAll('.', '')}@levelup.edu',
      role: UserRole.student,
      studentNumber: studentNumber,
      username: username,
      pinCode: pinCode,
      lastActive: null,
    );

    _allStudents.add(student);
    await _groupRepository.addStudentToGroup(groupId, studentNumber, levelId);
    await _init();
    return student;
  }

  /// Generates a clean, lowercase, URL-safe English username.
  /// Uses a transliteration map for common Arabic/Hebrew characters,
  /// and always appends a unique 4-digit suffix for guaranteed uniqueness.
  String _generateUsername(String fullName) {
    // Common Arabic → English transliteration map
    const Map<String, String> transliterationMap = {
      'أ': 'a', 'ا': 'a', 'إ': 'e', 'آ': 'a',
      'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j',
      'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'th',
      'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh',
      'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z',
      'ع': 'a', 'غ': 'gh', 'ف': 'f', 'ق': 'q',
      'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w', 'ي': 'y', 'ى': 'a',
      'ة': 'h', 'ئ': 'e', 'ء': 'a', 'ؤ': 'o',
      // Hebrew common letters
      'א': 'a', 'ב': 'b', 'ג': 'g', 'ד': 'd',
      'ה': 'h', 'ו': 'v', 'ז': 'z', 'ח': 'h',
      'ט': 't', 'י': 'y', 'כ': 'k', 'ל': 'l',
      'מ': 'm', 'נ': 'n', 'ס': 's', 'ע': 'a',
      'פ': 'p', 'צ': 'ts', 'ק': 'q', 'ר': 'r',
      'ש': 'sh', 'ת': 't',
      // Common accented Latin → ASCII
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
      'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u',
      'ô': 'o', 'ö': 'o', 'ò': 'o', 'ó': 'o',
      'î': 'i', 'ï': 'i', 'ì': 'i', 'í': 'i',
      'ç': 'c', 'ñ': 'n',
    };

    String transliterate(String input) {
      final buffer = StringBuffer();
      for (int i = 0; i < input.length; i++) {
        final char = input[i];
        final lower = char.toLowerCase();
        if (transliterationMap.containsKey(lower)) {
          buffer.write(transliterationMap[lower]);
        } else if (RegExp(r'[a-z0-9._ ]').hasMatch(lower)) {
          buffer.write(lower);
        }
        // Skip any other unrecognized characters
      }
      return buffer.toString();
    }

    final parts = fullName.trim().split(RegExp(r'\s+'));
    String base;
    if (parts.length >= 2) {
      base = '${transliterate(parts[0])}.${transliterate(parts[1])}';
    } else {
      base = transliterate(parts[0]);
    }

    // Strip any remaining non-ASCII-safe characters after transliteration
    final sanitized = base.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');

    // Always append a unique 4-digit suffix for guaranteed uniqueness
    final suffix = (1000 + Random().nextInt(9000)).toString();
    if (sanitized.isEmpty) {
      return 'student_$suffix';
    }
    return '${sanitized}_$suffix';
  }

  /// Resets the PIN for a student and returns the new PIN.
  String resetStudentPin(String studentId) {
    final random = Random();
    final newPin = (1000 + random.nextInt(9000)).toString();
    final index = _allStudents.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final old = _allStudents[index];
      _allStudents[index] = UserModel(
        id: old.id,
        userNumber: old.userNumber,
        name: old.name,
        email: old.email,
        role: old.role,
        studentNumber: old.studentNumber,
        username: old.username,
        pinCode: newPin,
        lastActive: old.lastActive,
        phoneNumber: old.phoneNumber,
        address: old.address,
        assignedLevels: old.assignedLevels,
      );
      notifyListeners();
    }
    return newPin;
  }
}
