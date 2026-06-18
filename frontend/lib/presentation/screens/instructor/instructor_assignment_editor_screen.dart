// ignore_for_file: experimental_member_use
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:frontend/l10n/app_localizations.dart';
import '../../../utils/editor_paste_listener.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/group_model.dart';
import '../../../theme/app_theme.dart';
import '../../../logic/controllers/instructor_assignment_controller.dart';
import '../../../logic/controllers/instructor_group_controller.dart';
import '../../../logic/controllers/auth_controller.dart';
import '../../../di/service_locator.dart';

class _ImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => quill.BlockEmbed.imageType;

  @override
  bool get expanded => true;

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final src = embedContext.node.value.data as String;
    final img = src.startsWith('data:')
        ? Image.memory(
            base64Decode(src.split(',').last),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          )
        : Image.network(
            src,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
          );
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(borderRadius: BorderRadius.circular(8), child: img),
      ),
    );
  }
}

class InstructorAssignmentEditorScreen extends StatefulWidget {
  /// Null → Create mode. type=='central' → Template mode. type=='custom' → Edit mode.
  final AssignmentModel? initialAssignment;

  const InstructorAssignmentEditorScreen({super.key, this.initialAssignment});

  @override
  State<InstructorAssignmentEditorScreen> createState() =>
      _InstructorAssignmentEditorScreenState();
}

class _InstructorAssignmentEditorScreenState extends State<InstructorAssignmentEditorScreen> {
  final InstructorAssignmentController _controller = getIt<InstructorAssignmentController>();
  final InstructorGroupController _groupController = getIt<InstructorGroupController>();
  final AuthController _authController = getIt<AuthController>();

  List<String> _assignedLevelIds = [];

  late TextEditingController _titleCtrl;
  late quill.QuillController _quillCtrl;
  StreamSubscription<quill.DocChange>? _docChangeSub;
  bool _processingImage = false;
  dynamic _pasteListener;

  DateTime? _selectedDeadline;
  AssignmentType _selectedType = AssignmentType.text;
  List<TextEditingController> _choiceCtrls = [TextEditingController(), TextEditingController()];

  GroupModel? _selectedGroup;
  String? _selectedLevel;
  String? _preselectedGroupId;

  static final _imageUrlRegex = RegExp(
    r'^https?://\S+\.(?:jpg|jpeg|png|gif|webp|svg)(\?[^\s]*)?\s*$',
    caseSensitive: false,
  );

  bool get _isEditMode =>
      widget.initialAssignment != null && widget.initialAssignment!.type == 'custom';

  @override
  void initState() {
    super.initState();
    _authController.getCurrentAssignedLevels().then((ids) {
      if (mounted) setState(() => _assignedLevelIds = ids);
    });

    final a = widget.initialAssignment;

    _titleCtrl = TextEditingController(text: a?.title ?? '');

    final clipCfg = quill.QuillControllerConfig(
      clipboardConfig: quill.QuillClipboardConfig(
        onImagePaste: (bytes) async =>
            'data:image/png;base64,${base64Encode(bytes)}',
      ),
    );

    // Try to load existing Quill delta; fall back to plain text or empty
    if (a != null && (a.textContent?.isNotEmpty ?? false)) {
      try {
        _quillCtrl = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(a.textContent!) as List),
          selection: const TextSelection.collapsed(offset: 0),
          config: clipCfg,
        );
      } catch (_) {
        // Plain-text content — insert it as a plain paragraph
        final doc = quill.Document();
        doc.insert(0, a.textContent!);
        _quillCtrl = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          config: clipCfg,
        );
      }
    } else {
      _quillCtrl = quill.QuillController.basic(config: clipCfg);
    }

    // Edit mode: pre-fill all editable fields
    if (_isEditMode && a != null) {
      _selectedDeadline = a.deadline;
      _selectedType = a.assignmentType;
      if (a.choices != null && a.choices!.isNotEmpty) {
        _choiceCtrls = a.choices!.map((c) => TextEditingController(text: c)).toList();
      }
      _preselectedGroupId = a.groupId;
      _selectedLevel = a.levelId;
    }

    _docChangeSub = _quillCtrl.document.changes.listen(_onDocumentChange);

    _pasteListener = addImagePasteListener(_quillCtrl);
  }

  @override
  void dispose() {
    removeImagePasteListener(_pasteListener);
    _docChangeSub?.cancel();
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    for (final c in _choiceCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _onDocumentChange(quill.DocChange change) {
    if (_processingImage || change.source != quill.ChangeSource.local) return;
    int offset = 0;
    for (final op in change.change.operations) {
      if (op.isRetain) {
        offset += op.length!;
      } else if (op.isInsert && op.data is String) {
        final raw = op.data as String;
        final url = raw.trim();
        if (_imageUrlRegex.hasMatch(url)) {
          _processingImage = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _quillCtrl.document.delete(offset, raw.length);
            _quillCtrl.document.insert(offset, '\n');
            _quillCtrl.document.insert(offset + 1, quill.BlockEmbed.image(url));
            _quillCtrl.document.insert(offset + 2, '\n');
            _processingImage = false;
          });
          return;
        }
        offset += raw.length;
      }
    }
  }

  Widget _buildInsertImageButton() {
    final l10n = AppLocalizations.of(context)!;
    return IconButton(
      tooltip: l10n.insertImageUrlTooltip,
      icon: const Icon(Icons.image_outlined, size: 20, color: AppColors.primary),
      onPressed: () async {
        final urlCtrl = TextEditingController();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding: EdgeInsets.fromLTRB(24, 24, 24, kIsWeb ? 24 : MediaQuery.of(ctx).viewInsets.bottom + 24),
            title: Text(l10n.insertImageTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: TextField(
                  controller: urlCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: const Icon(Icons.link, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancelButton)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.insertButton),
              ),
            ],
          ),
        );
        if (confirmed == true && urlCtrl.text.trim().isNotEmpty) {
          final url = urlCtrl.text.trim();
          final index = _quillCtrl.selection.baseOffset;
          final safeIndex = index < 0 ? 0 : index;
          _quillCtrl.document.insert(safeIndex, '\n');
          _quillCtrl.document.insert(safeIndex + 1, quill.BlockEmbed.image(url));
          _quillCtrl.document.insert(safeIndex + 2, '\n');
        }
      },
    );
  }

  Future<void> _pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline != null && _selectedDeadline!.isAfter(DateTime.now())
          ? _selectedDeadline!
          : DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDeadline != null
            ? TimeOfDay(hour: _selectedDeadline!.hour, minute: _selectedDeadline!.minute)
            : const TimeOfDay(hour: 23, minute: 59),
        initialEntryMode: TimePickerEntryMode.inputOnly,
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (title.isEmpty) {
      _showError(l10n.titleRequired);
      return;
    }
    if (_selectedDeadline == null) {
      _showError(l10n.selectDeadline);
      return;
    }
    
    // Resolve group to save: either selected or pre-selected
    GroupModel? groupToSave = _selectedGroup;
    if (groupToSave == null && _preselectedGroupId != null) {
      try {
        groupToSave = _groupController.myGroups.firstWhere((g) => g.id == _preselectedGroupId);
      } catch (_) {}
    }
    
    if (groupToSave == null) {
      _showError(l10n.chooseGroupHint);
      return;
    }
    if (_selectedLevel == null) {
      _showError(l10n.selectLevelHint);
      return;
    }

    List<String> choices = [];
    if (_selectedType == AssignmentType.multipleChoice) {
      choices = _choiceCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
      if (choices.length < 2) {
        _showError(l10n.atLeast2Options);
        return;
      }
    }

    final deltaJson = jsonEncode(_quillCtrl.document.toDelta().toJson());
    final a = widget.initialAssignment;

    if (_isEditMode && a != null) {
      _controller.updateContent(
        a.id, title, deltaJson, _selectedType, choices,
        groupId: groupToSave.id,
        groupName: groupToSave.name,
        levelId: _selectedLevel,
      );
      if (_selectedDeadline != a.deadline) {
        _controller.updateDeadline(a.id, _selectedDeadline!);
      }
    } else {
      _controller.addAssignment(
        title,
        deadline: _selectedDeadline,
        textContent: deltaJson,
        assignmentType: _selectedType,
        choices: choices,
        groupId: groupToSave.id,
        groupName: groupToSave.name,
        levelId: _selectedLevel,
      );
    }

    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Lazily resolve pre-selected group once the controller has groups loaded
    GroupModel? resolvedGroup = _selectedGroup;
    if (resolvedGroup == null && _preselectedGroupId != null) {
      try {
        resolvedGroup = _groupController.myGroups.firstWhere((g) => g.id == _preselectedGroupId);
      } catch (_) {}
    }

    final groups = _groupController.myGroups;
    final levels = (resolvedGroup?.activeLevels.toList() ?? <String>[])
        .where((l) => _assignedLevelIds.contains(l))
        .toList();
    if (_selectedLevel != null && !levels.contains(_selectedLevel)) {
      levels.add(_selectedLevel!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.assignment_outlined, color: AppColors.text, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _isEditMode ? l10n.editContent : l10n.createAssignment,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            )),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Title
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.assignmentTitleLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.input, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),

              // Quill Toolbar
              Container(
                height: 52,
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Expanded(
                      child: quill.QuillSimpleToolbar(
                        controller: _quillCtrl,
                        config: const quill.QuillSimpleToolbarConfig(
                          multiRowsDisplay: false,
                          showBoldButton: true, showItalicButton: true, showUnderLineButton: true,
                          showHeaderStyle: true, showListBullets: true, showListNumbers: true,
                          showDividers: false, showFontFamily: false, showFontSize: false,
                          showBackgroundColorButton: false, showColorButton: false, showClearFormat: false,
                          showAlignmentButtons: true, showIndent: false, showLink: false,
                          showDirection: true,
                          showSearchButton: false, showSubscript: false, showSuperscript: false,
                          showCodeBlock: false, showInlineCode: false, showQuote: false,
                          showStrikeThrough: false, showSmallButton: false,
                        ),
                      ),
                    ),
                    _buildInsertImageButton(),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Quill Editor
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.input, width: 1.5)),
                  child: quill.QuillEditor.basic(
                    controller: _quillCtrl,
                    config: quill.QuillEditorConfig(
                      embedBuilders: [_ImageEmbedBuilder()],
                      placeholder: l10n.hintAssignmentInstructions,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Assignment Type Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _selectedType = AssignmentType.text),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == AssignmentType.text ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(l10n.textAnswerType, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _selectedType == AssignmentType.text ? AppColors.white : AppColors.mutedForeground)),
                    ),
                  )),
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _selectedType = AssignmentType.multipleChoice),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedType == AssignmentType.multipleChoice ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(l10n.multipleChoiceType, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _selectedType == AssignmentType.multipleChoice ? AppColors.white : AppColors.mutedForeground)),
                    ),
                  )),
                ]),
              ),

              // MCQ Choices (only when Multiple Choice selected)
              if (_selectedType == AssignmentType.multipleChoice) ...[
                const SizedBox(height: 8),
                ...List.generate(_choiceCtrls.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _choiceCtrls[i],
                        decoration: InputDecoration(
                          hintText: l10n.hintOptionN((i + 1).toString()),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.input, width: 1.2)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.2)),
                        ),
                      ),
                    ),
                    if (_choiceCtrls.length > 2)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                        onPressed: () => setState(() => _choiceCtrls.removeAt(i)),
                      ),
                  ]),
                )),
                if (_choiceCtrls.length < 4)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _choiceCtrls.add(TextEditingController())),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.addOptionButton),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
                    ),
                  ),
              ],
              const SizedBox(height: 8),

              // Group Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<GroupModel>(
                    value: resolvedGroup,
                    hint: Text(l10n.chooseGroupHint, style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.mutedForeground),
                    items: groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)))).toList(),
                    onChanged: (val) => setState(() {
                      _selectedGroup = val;
                      _selectedLevel = null;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Level Dropdown
              Opacity(
                opacity: resolvedGroup == null ? 0.4 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLevel,
                      hint: Text(l10n.selectLevelHint, style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.mutedForeground),
                      items: levels.map((l) => DropdownMenuItem(
                        value: l,
                        child: Text(l10n.levelLabel(l.replaceAll('l', '')), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      )).toList(),
                      onChanged: resolvedGroup == null ? null : (val) => setState(() => _selectedLevel = val),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Deadline Picker
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedDeadline != null ? AppColors.primary : AppColors.input, width: 1.5),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today, size: 16, color: _selectedDeadline != null ? AppColors.primary : AppColors.mutedForeground),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDeadline != null
                          ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}  ${_selectedDeadline!.hour}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}'
                          : l10n.selectDeadline,
                      style: TextStyle(fontSize: 14, color: _selectedDeadline != null ? AppColors.text : AppColors.mutedForeground),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.cancel, style: const TextStyle(color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _isEditMode ? l10n.saveChanges : l10n.createButton,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
