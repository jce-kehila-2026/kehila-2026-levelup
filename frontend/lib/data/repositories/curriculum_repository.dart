/// Data Tier — Repository
/// Path: lib/data/repositories/curriculum_repository.dart
library;

import '../models/curriculum_model.dart';

class CurriculumRepository {
  final List<LevelModel> _levels = [
    LevelModel(
      id: 'l1',
      name: 'Level 1 — Novice',
      weeks: [
        WeekModel(
          id: 'l1_w1',
          name: 'Week 1: Fundamentals',
          items: [
            // Bilingual material — Arabic intro paragraph followed by English body
            CurriculumItem(
              id: 'mat_1',
              type: CurriculumItemType.material,
              title: 'The Board Layout & Navigation',
              searchTags: ['intro', 'board', 'coordinates'],
              visible: true,
              imageUrl: 'assets/images/Shah2Range.jpeg',
              deltaJson: r'[{"insert":"مقدمة (Introduction)\n","attributes":{"header":1}},{"insert":"أهلاً بك في عالم الشطرنج! تتكون الرقعة من 64 مربعاً. يتحرك البيدق خطوة واحدة للأمام.\n\n"},{"insert":"The board has 64 squares. "},{"attributes":{"bold":true},"insert":"Each player starts with 16 pieces."},{"insert":"\n\n"},{"attributes":{"header":2},"insert":"The Board Layout\n"},{"insert":"The board is set up so that each player has a light square in the bottom right corner.\n"}]',
            ),
            // Bilingual assignment — Arabic question label with English body questions
            CurriculumItem(
              id: 'ca_1',
              type: CurriculumItemType.assignment,
              title: 'Piece Movement Quiz',
              isActive: true,
              deadlineText: 'Due in 2 days',
              deltaJson: r'[{"insert":"Please complete the piece movement quiz / أجب عن الأسئلة التالية:\n\n"},{"insert":"1. How does the Knight move? (كيف يتحرك الحصان؟)\n2. Can the King castle if it has already moved?\n3. What is En Passant?\n"}]',
            ),
            CurriculumItem(
              id: 'mat_2',
              type: CurriculumItemType.material,
              title: 'Special Moves: Castling & En Passant',
              searchTags: ['moves', 'advanced'],
              visible: false,
              deltaJson: r'[{"insert":"Special Moves\n","attributes":{"header":1}},{"insert":"\nCastling is a special move that involves the King and the Rook. It is the only time two pieces can move in a single turn.\n"}]',
            ),
          ],
        ),
        WeekModel(
          id: 'l1_w2',
          name: 'Week 2: Basic Tactics & Openings',
          items: [
            // Bilingual material — English primary content with Arabic section appended
            CurriculumItem(
              id: 'mat_3',
              type: CurriculumItemType.material,
              title: 'The Sicilian Defense',
              searchTags: ['openings', 'sicilian', 'advanced'],
              visible: true,
              deltaJson: r'''[{"insert":"The Sicilian Defense\n","attributes":{"header":1}},{"insert":"The Sicilian Defense is a chess opening that begins with the following moves:\n1. e4 c5\nThis is the most popular and best-scoring response to White's first move 1.e4.\n\n"},{"insert":{"image":"assets/images/Shah2Range.jpeg"}},{"insert":"\n\nBy playing c5, Black fights for the center and attacks d4. It is an aggressive, dynamic opening.\n\n"},{"insert":"الدفاع الصقلي\n","attributes":{"header":2}},{"insert":"يعدّ الدفاع الصقلي من أكثر الردود شعبيةً على الحركة الأولى للأبيض 1.e4. يلعب الأسود c5 للسيطرة على مركز الرقعة ومهاجمة المربع d4.\n"}]''',
            ),
            // Bilingual material — Arabic header followed by English explanation body
            CurriculumItem(
              id: 'mat_4',
              type: CurriculumItemType.material,
              title: 'Forks & Pins',
              searchTags: ['tactics', 'advantage'],
              visible: true,
              deltaJson: r'[{"insert":"الشوكات والتثبيتات — مقدمة\n","attributes":{"header":1}},{"insert":"تعرّف على قوة الشوكة والتثبيت للحصول على ميزة مادية على خصمك.\n\n"},{"insert":"Introduction to Tactics\n","attributes":{"header":2}},{"insert":"Discover the power of forks and pins to gain a material advantage over your opponent.\n"}]',
            ),
            // Bilingual assignment — Arabic instructions alongside English for concurrent RTL/LTR rendering
            CurriculumItem(
              id: 'ca_2',
              type: CurriculumItemType.assignment,
              title: 'Find the Fork',
              isActive: true,
              deadlineText: 'Due in 5 days',
              deltaJson: r'[{"insert":"Analyze the provided positions and identify the best fork opportunity for White.\n\nحلّل المواضع المعطاة وحدّد أفضل فرصة لعمل شوكة بقطعة الأبيض. اشرح تفكيرك خطوة بخطوة.\n"}]',
            ),
          ],
        ),
      ],
    ),
    LevelModel(
      id: 'l2',
      name: 'Level 2 — Intermediate',
      weeks: [
        WeekModel(
          id: 'l2_w1',
          name: 'Week 1: Opening Principles',
          items: [
            CurriculumItem(
              id: 'mat_5',
              type: CurriculumItemType.material,
              title: 'Controlling the Center',
              searchTags: ['openings', 'strategy'],
              visible: true,
              deltaJson: r'[{"insert":"Opening Principles\n","attributes":{"header":1}},{"insert":"\nLearn why controlling the center of the board is critical for a strong opening.\n"}]',
            ),
          ],
        ),
        // Arabic week name — tests RTL week title rendering in the collapsible week header
        WeekModel(
          id: 'l2_w2',
          name: 'الأسبوع الثاني: التكتيكات المتقدمة',
          items: [
            // Arabic material title — coexists with English items to test mixed list rendering
            CurriculumItem(
              id: 'mat_6',
              type: CurriculumItemType.material,
              title: 'قوة الدبابيس والتثبيتات',
              searchTags: ['tactics', 'intermediate'],
              visible: true,
              deltaJson: r'[{"insert":"قوة الدبابيس والتثبيتات\n","attributes":{"header":1}},{"insert":"تعلّم كيفية توظيف الدبابيس والتثبيتات لإجبار خصمك على قطع دفاعية أو فقدان مواد ثمينة.\n\n"},{"insert":"Pins and skewers force your opponent into losing material or weakening their king.\n"}]',
            ),
            CurriculumItem(
              id: 'ca_3',
              type: CurriculumItemType.assignment,
              title: 'واجب: تحديد التثبيتات',
              isActive: true,
              deadlineText: 'Due in 4 days',
              deltaJson: r'[{"insert":"في المواضع التالية، حدّد أي القطع محاصرة بتثبيت وكيف يمكن استغلال ذلك.\nIn the following positions, identify which pieces are pinned and how to exploit it.\n"}]',
            ),
          ],
        ),
      ],
    ),
    // Level 3 stub with Arabic name — tests Arabic level card in the admin curriculum screen
    LevelModel(
      id: 'l3',
      name: 'المستوى الثالث — متقدم',
      weeks: [
        WeekModel(
          id: 'l3_w1',
          name: 'الأسبوع الأول: استراتيجيات نهايات اللعبة',
          items: [
            CurriculumItem(
              id: 'mat_7',
              type: CurriculumItemType.material,
              title: 'نهايات الرخ',
              searchTags: ['endgame', 'rook', 'advanced'],
              visible: true,
              deltaJson: r'[{"insert":"نهايات الرخ\n","attributes":{"header":1}},{"insert":"تُعدّ نهايات الرخ من أكثر النهايات شيوعاً في الشطرنج. يجب على اللاعب إتقان تقنية لوسينا وموضع فيليدور.\n\n"},{"insert":"Rook Endgames\n","attributes":{"header":2}},{"insert":"Rook endgames are the most common type of endgame. Master the Lucena position and the Philidor position.\n"}]',
            ),
            CurriculumItem(
              id: 'ca_4',
              type: CurriculumItemType.assignment,
              title: 'Endgame Drill: King and Rook',
              isActive: false,
              deadlineText: 'Coming soon',
              deltaJson: r'[{"insert":"Practice the Lucena and Philidor positions until you can execute them confidently from both sides.\n"}]',
            ),
          ],
        ),
      ],
    ),
  ];

  /// Returns all levels in the curriculum.
  Future<List<LevelModel>> getLevels() async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch the entire curriculum hierarchy (Levels > Weeks > Items).
    // Expected Output: List of LevelModel containing embedded Weeks and CurriculumItems.
    await Future.delayed(const Duration(milliseconds: 500));
    return _levels;
  }

  Future<CurriculumItem?> getLessonById(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch a specific CurriculumItem by its ID.
    // Expected Output: Single CurriculumItem or null.
    await Future.delayed(const Duration(milliseconds: 300));
    for (final level in _levels) {
      for (final week in level.weeks) {
        for (final item in week.items) {
          if ((id.isNotEmpty && item.id == id) || item.title == id) return item;
        }
      }
    }
    // Fallback: first item (supports legacy callers with empty/unresolved IDs)
    if (_levels.isNotEmpty && _levels.first.weeks.isNotEmpty && _levels.first.weeks.first.items.isNotEmpty) {
      return _levels.first.weeks.first.items.first;
    }
    return null;
  }

  /// Adds a new level.
  Future<void> addLevel(String name) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Create a new Level document.
    // Expected Output: Add to the 'curriculum' collection.
    await Future.delayed(const Duration(milliseconds: 500));
    _levels.add(LevelModel(
      id: 'l${_levels.length + 1}',
      name: name,
    ));
  }

  /// Updates the name of an existing level.
  Future<void> editLevel(String levelId, String newName) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update the 'name' field of the Level document.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _levels.indexWhere((l) => l.id == levelId);
    if (index != -1) _levels[index].name = newName;
  }

  /// Deletes a level and all its nested weeks and items.
  Future<void> deleteLevel(String levelId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Delete the Level document and all nested Week/Item sub-documents.
    await Future.delayed(const Duration(milliseconds: 300));
    _levels.removeWhere((l) => l.id == levelId);
  }

  /// Adds a new week to a level.
  Future<void> addWeek(int levelIndex, String name) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Add a new Week array element to the specific Level document.
    // Expected Output: Update Level document.
    await Future.delayed(const Duration(milliseconds: 500));
    final level = _levels[levelIndex];
    level.weeks.add(WeekModel(
      id: '${level.id}_w${level.weeks.length + 1}',
      name: name,
    ));
  }

  /// Adds a material item to a week.
  Future<void> addMaterial(int levelIndex, int weekIndex, String title, {String? content}) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Add a new CurriculumItem of type 'material' to the specific Week's items array.
    // Expected Output: Update Level document.
    await Future.delayed(const Duration(milliseconds: 500));
    _levels[levelIndex].weeks[weekIndex].items.add(
      CurriculumItem(
        id: 'mat_${DateTime.now().millisecondsSinceEpoch}',
        type: CurriculumItemType.material,
        title: title,
        content: content,
        searchTags: [],
        visible: true,
      ),
    );
  }

  /// Adds an assignment item to a week. Caller may supply a pre-generated [id];
  /// if omitted one is generated from the current timestamp.
  Future<void> addAssignment(int levelIndex, int weekIndex, String title, {String? content, String? id}) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Add a new CurriculumItem of type 'assignment' to the specific Week's items array.
    // Expected Output: Update Level document.
    await Future.delayed(const Duration(milliseconds: 500));
    _levels[levelIndex].weeks[weekIndex].items.add(
      CurriculumItem(
        id: id ?? 'ca_${DateTime.now().millisecondsSinceEpoch}',
        type: CurriculumItemType.assignment,
        title: title,
        content: content,
        isActive: true,
        deadlineText: 'Next week',
      ),
    );
  }

  /// Toggles visibility of a material item.
  Future<void> toggleVisibility(int levelIndex, int weekIndex, int itemIndex) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update the 'visible' field of a specific CurriculumItem inside a Week.
    await Future.delayed(const Duration(milliseconds: 200));
    final item = _levels[levelIndex].weeks[weekIndex].items[itemIndex];
    item.visible = !item.visible;
  }

  /// Updates the title and content of an existing curriculum item.
  Future<void> updateItem(int levelIndex, int weekIndex, int itemIndex, String title, String content) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update the 'title' and 'content' ('deltaJson') of a specific CurriculumItem.
    await Future.delayed(const Duration(milliseconds: 300));
    final item = _levels[levelIndex].weeks[weekIndex].items[itemIndex];
    item.title = title;
    item.content = content;
  }

  /// Deletes an item from a week.
  Future<void> deleteItem(int levelIndex, int weekIndex, int itemIndex) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Remove a CurriculumItem from the items array in a specific Week.
    await Future.delayed(const Duration(milliseconds: 300));
    _levels[levelIndex].weeks[weekIndex].items.removeAt(itemIndex);
  }
}
