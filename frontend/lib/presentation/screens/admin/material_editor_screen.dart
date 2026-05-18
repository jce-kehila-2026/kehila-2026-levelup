// ignore_for_file: experimental_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:frontend/l10n/app_localizations.dart';
import 'package:web/web.dart' as webapi;
import '../../../theme/app_theme.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../logic/controllers/curriculum_controller.dart';
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

class MaterialEditorScreen extends StatefulWidget {
  final int levelIndex;
  final int weekIndex;
  final int? itemIndex;
  final CurriculumItem? item;

  const MaterialEditorScreen({
    super.key,
    required this.levelIndex,
    required this.weekIndex,
    this.itemIndex,
    this.item,
  });

  @override
  State<MaterialEditorScreen> createState() => _MaterialEditorScreenState();
}

class _MaterialEditorScreenState extends State<MaterialEditorScreen> {
  final CurriculumController _controller = getIt<CurriculumController>();
  late TextEditingController _titleCtrl;
  late quill.QuillController _quillCtrl;
  StreamSubscription<quill.DocChange>? _docChangeSub;
  bool _processingImage = false;
  JSFunction? _pasteListener;

  static final _imageUrlRegex = RegExp(
    r'^https?://\S+\.(?:jpg|jpeg|png|gif|webp|svg)(\?[^\s]*)?\s*$',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item?.title ?? '');
    
    final clipCfg = quill.QuillControllerConfig(
      clipboardConfig: quill.QuillClipboardConfig(
        onImagePaste: (bytes) async =>
            'data:image/png;base64,${base64Encode(bytes)}',
      ),
    );

    final raw = widget.item?.content ?? widget.item?.deltaJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        _quillCtrl = quill.QuillController(
          document: quill.Document.fromJson(jsonDecode(raw) as List),
          selection: const TextSelection.collapsed(offset: 0),
          config: clipCfg,
        );
      } catch (_) {
        _quillCtrl = quill.QuillController.basic(config: clipCfg);
      }
    } else {
      _quillCtrl = quill.QuillController.basic(config: clipCfg);
    }
    _docChangeSub = _quillCtrl.document.changes.listen(_onDocumentChange);

    if (kIsWeb) {
      _pasteListener = _handleWebPaste.toJS;
      webapi.window.addEventListener('paste', _pasteListener);
    }
  }

  void _handleWebPaste(webapi.ClipboardEvent event) {
    final files = event.clipboardData?.files;
    if (files == null || files.length == 0) return;
    for (int i = 0; i < files.length; i++) {
      final file = files.item(i);
      if (file == null || !file.type.startsWith('image/')) continue;
      event.preventDefault();
      final reader = webapi.FileReader();
      void onLoad(webapi.Event _) {
        final jsResult = reader.result;
        if (jsResult == null) return;
        final dataUri = (jsResult as JSString).toDart;
        final index = _quillCtrl.selection.baseOffset;
        final safeIndex = index < 0 ? 0 : index;
        _quillCtrl.document.insert(safeIndex, '\n');
        _quillCtrl.document.insert(safeIndex + 1, quill.BlockEmbed.image(dataUri));
        _quillCtrl.document.insert(safeIndex + 2, '\n');
      }
      reader.onload = onLoad.toJS;
      reader.readAsDataURL(file);
      return;
    }
  }

  @override
  void dispose() {
    if (kIsWeb && _pasteListener != null) {
      webapi.window.removeEventListener('paste', _pasteListener);
    }
    _docChangeSub?.cancel();
    _titleCtrl.dispose();
    _quillCtrl.dispose();
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
    return IconButton(
      tooltip: 'Insert Image URL',
      icon: const Icon(Icons.image_outlined, size: 20, color: AppColors.primary),
      onPressed: () async {
        final urlCtrl = TextEditingController();
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Insert Image', style: TextStyle(fontWeight: FontWeight.bold)),
            content: TextField(
              controller: urlCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'https://example.com/image.jpg',
                prefixIcon: const Icon(Icons.link, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Insert'),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.item != null;

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
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(isEdit ? Icons.edit_outlined : Icons.library_books, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.addMaterialTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text))),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l10n.materialTitleLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.input, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
              const SizedBox(height: 12),
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
                          showAlignmentButtons: false, showIndent: false, showLink: false,
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.input, width: 1.5)),
                  child: quill.QuillEditor.basic(
                    controller: _quillCtrl,
                    config: quill.QuillEditorConfig(
                      embedBuilders: [_ImageEmbedBuilder()],
                      placeholder: isEdit ? 'Edit material content…' : 'Write material content here…',
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                      onPressed: () {
                        final title = _titleCtrl.text.trim();
                        if (title.isEmpty) return;
                        final deltaJson = jsonEncode(_quillCtrl.document.toDelta().toJson());
                        if (isEdit) {
                          _controller.updateItem(widget.levelIndex, widget.weekIndex, widget.itemIndex!, title, deltaJson);
                        } else {
                          _controller.addMaterial(widget.levelIndex, widget.weekIndex, title, content: deltaJson);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEdit ? 'Save' : l10n.add, style: const TextStyle(fontWeight: FontWeight.bold)),
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