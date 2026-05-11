import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../theme/app_theme.dart';
import 'package:frontend/l10n/app_localizations.dart';

class CustomImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  bool get expanded => false;

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final imageUrl = embedContext.node.value.data as String;
    
    final bool isAsset = imageUrl.startsWith('assets/');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isAsset
              ? Image.asset(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Premium content renderer that intelligently detects content type
/// (Quill Delta JSON, PDF link, plain text, image URL) and renders
/// each with professional typography, spacing, and visual treatment.
class VibePremiumRenderer extends StatefulWidget {
  final String content;

  const VibePremiumRenderer({
    super.key,
    required this.content,
  });

  @override
  State<VibePremiumRenderer> createState() => _VibePremiumRendererState();
}

class _VibePremiumRendererState extends State<VibePremiumRenderer> {
  quill.QuillController? _quillController;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(VibePremiumRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      _initController();
    }
  }

  /// Parses the content string as a Quill Delta JSON document and initialises
  /// a read-only [QuillController]. Supports two delta formats:
  ///   - Wrapped:   `{"ops": [...]}` (standard Quill export)
  ///   - Unwrapped: `[{"insert": ...}, ...]` (bare ops array, our repo format)
  ///
  /// If parsing fails or the content is not Delta JSON, the controller is set
  /// to null and the appropriate fallback renderer is used in [build].
  void _initController() {
    if (_isQuillDelta(widget.content)) {
      try {
        final decoded = jsonDecode(widget.content);
        // Normalise: unwrap the ops array if it is wrapped in an object
        final ops = (decoded is Map && decoded.containsKey('ops')) ? decoded['ops'] : decoded;
        final doc = quill.Document.fromJson(ops);
        _quillController = quill.QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true, // view-only; students and instructors cannot edit here
        );
      } catch (_) {
        _quillController = null;
      }
    } else {
      _quillController = null;
    }
  }

  @override
  void dispose() {
    _quillController?.dispose();
    super.dispose();
  }

  // ── Content-Type Detection ────────────────────────
  //
  // Priority order used in build():
  //   1. Quill Delta JSON  → rich text with RTL/Arabic support
  //   2. PDF link          → tappable card that opens the secure viewer
  //   3. Image URL         → inline image card
  //   4. Fallback          → plain text with SelectableText

  /// Returns true when [s] is valid Quill Delta JSON (wrapped or bare-ops).
  bool _isQuillDelta(String s) {
    if (s.isEmpty) return false;
    final trimmed = s.trim();
    // Quick structural check before the more expensive JSON parse
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return false;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic> && decoded.containsKey('ops')) return true;
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        return (decoded.first as Map).containsKey('insert');
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _isPdfLink(String s) {
    final lower = s.trim().toLowerCase();
    return lower.endsWith('.pdf') ||
        lower.contains('/pdf') ||
        (lower.startsWith('http') && lower.contains('pdf'));
  }

  bool _isImageUrl(String s) {
    final lower = s.trim().toLowerCase();
    return (lower.startsWith('http://') || lower.startsWith('https://')) &&
        (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp') || lower.endsWith('.gif'));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) {
      return _buildEmptyState(context);
    }

    if (_isQuillDelta(widget.content) && _quillController != null) {
      return _buildDeltaContent();
    }

    if (_isPdfLink(widget.content)) {
      return _buildPdfCard(context);
    }

    if (_isImageUrl(widget.content)) {
      return _buildImageCard();
    }

    return _buildPlainText();
  }

  // ── Builders ──────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: AppColors.mutedForeground.withValues(alpha: 0.6)),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context)!.noContentProvided,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.mutedForeground.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.primary.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.pdfDocumentLabel,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.content.trim().split('/').last,
                  style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context)!.viewLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        widget.content.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, _, _) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image_outlined, size: 20, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.imageNotLoaded, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeltaContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: quill.QuillEditor.basic(
        controller: _quillController!,
        config: quill.QuillEditorConfig(
          embedBuilders: [CustomImageEmbedBuilder()],
        ),
      ),
    );
  }

  Widget _buildPlainText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.content.trim(),
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.text,
          height: 1.65,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
