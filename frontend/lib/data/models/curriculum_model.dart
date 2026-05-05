/// Data Tier — Model
/// Path: lib/data/models/curriculum_model.dart
library;

enum CurriculumItemType { material, assignment }

class CurriculumItem {
  final String id;
  final CurriculumItemType type;
  String title;
  String? content;
  List<String> searchTags;
  bool visible;
  bool isActive;
  String deadlineText;
  final String? imageUrl;
  final String? deltaJson; // Rich text content as Delta JSON string

  CurriculumItem({
    this.id = '',
    required this.type,
    required this.title,
    this.content,
    this.searchTags = const [],
    this.visible = true,
    this.isActive = true,
    this.deadlineText = 'No deadline',
    this.imageUrl,
    this.deltaJson,
  });

  factory CurriculumItem.fromMap(Map<String, dynamic> map) {
    return CurriculumItem(
      id: map['id'] ?? '',
      type: map['type'] == 'assignment' ? CurriculumItemType.assignment : CurriculumItemType.material,
      title: map['title'] ?? '',
      content: map['content'],
      searchTags: List<String>.from(map['searchTags'] ?? []),
      visible: map['visible'] ?? true,
      isActive: map['isActive'] ?? true,
      deadlineText: map['deadlineText'] ?? 'No deadline',
      imageUrl: map['imageUrl'],
      deltaJson: map['deltaJson'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'content': content,
      'searchTags': searchTags,
      'visible': visible,
      'isActive': isActive,
      'deadlineText': deadlineText,
      'imageUrl': imageUrl,
      'deltaJson': deltaJson,
    };
  }
}

class WeekModel {
  final String id;
  String name;
  final List<CurriculumItem> items;

  WeekModel({
    required this.id,
    required this.name,
    List<CurriculumItem>? items,
  }) : items = items ?? [];

  factory WeekModel.fromMap(Map<String, dynamic> map, String documentId) {
    return WeekModel(
      id: documentId,
      name: map['name'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => CurriculumItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class LevelModel {
  final String id;
  String name;
  final List<WeekModel> weeks;

  LevelModel({
    required this.id,
    required this.name,
    List<WeekModel>? weeks,
  }) : weeks = weeks ?? [];

  factory LevelModel.fromMap(Map<String, dynamic> map, String documentId) {
    return LevelModel(
      id: documentId,
      name: map['name'] ?? '',
      weeks: (map['weeks'] as List<dynamic>?)
              ?.map((week) => WeekModel.fromMap(week as Map<String, dynamic>, week['id'] ?? ''))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weeks': weeks.map((week) => week.toMap()).toList(),
    };
  }
}

/// Wraps a CurriculumItem with its parent Level and Week names for search results.
class CurriculumSearchResult {
  final CurriculumItem item;
  final String levelName;
  final String weekName;

  const CurriculumSearchResult({
    required this.item,
    required this.levelName,
    required this.weekName,
  });

  String get contextLabel => '$levelName • $weekName';
}
