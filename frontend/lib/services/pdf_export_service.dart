import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import '../presentation/screens/secure_pdf_viewer_screen.dart';

class PdfExportService {
  /// Converts a Quill Delta JSON string to a PDF document and pushes the
  /// secure viewer screen onto the navigation stack.
  ///
  /// Font loading strategy: The Cairo font is loaded first because it covers
  /// the full Arabic Unicode block (U+0600–U+06FF). If the font asset is
  /// missing (e.g., during development without full assets), the PDF is still
  /// generated using the system fallback font — Arabic text may not render
  /// correctly in that case but the export will not crash.
  ///
  /// RTL direction: [TextDirection.rtl] is applied globally so that Arabic
  /// paragraphs flow right-to-left and punctuation is mirrored correctly.
  /// English text within the same document is still handled correctly by the
  /// Unicode Bidirectional Algorithm.
  static Future<void> exportAndShowPdf(BuildContext context, String title, String deltaJsonStr) async {
    try {
      // Attempt to load the Cairo Arabic font; null = use system fallback
      pw.Font? arabicFont;
      pw.Font? arabicBoldFont;
      try {
        final regularData = await rootBundle.load('assets/fonts/static/Cairo-Regular.ttf');
        arabicFont = pw.Font.ttf(regularData);

        final boldData = await rootBundle.load('assets/fonts/static/Cairo-Bold.ttf');
        arabicBoldFont = pw.Font.ttf(boldData);
      } catch (e) {
        debugPrint('Failed to load Arabic font: $e');
      }

      // Normalise the delta: the repo stores bare ops arrays, but some paths
      // may produce the wrapped {"ops":[...]} format — handle both.
      List<dynamic> ops;
      try {
        final decoded = jsonDecode(deltaJsonStr);
        ops = (decoded is Map && decoded.containsKey('ops'))
            ? List<dynamic>.from(decoded['ops'] as List)
            : List<dynamic>.from(decoded as List);
      } catch (_) {
        // Legacy plain text — wrap as a valid single-insert Delta
        ops = <dynamic>[<String, dynamic>{'insert': '$deltaJsonStr\n'}];
      }
      final (processedOps, hadImageFailures) = await _resolveNetworkImages(ops);
      final doc = quill.Document.fromJson(processedOps);

      final pdfConverter = PDFConverter(
        backMatterDelta: null,
        frontMatterDelta: null,
        document: doc.toDelta(),
        fallbacks: [?arabicFont, ?arabicBoldFont], // fallback fonts for unsupported glyphs
        textDirection: TextDirection.rtl, // RTL for Arabic; Bidi algorithm handles inline English
        themeData: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicBoldFont,
        ),
        pageFormat: const PDFPageFormat(
          width: 595, // A4 width in PDF points
          height: 842, // A4 height in PDF points
          marginTop: 60,
          marginBottom: 60,
          marginLeft: 40,
          marginRight: 40,
        ),
      );

      final pdfDoc = await pdfConverter.createDocument();
      if (pdfDoc == null) {
        throw Exception("Failed to generate PDF document.");
      }
      
      final Uint8List pdfBytes = await pdfDoc.save();

      if (hadImageFailures && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Warning: Some external images could not be included in the PDF due to browser security restrictions. '
              'Please Copy-Paste images directly into the editor instead of using URLs.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SecurePdfViewerScreen(
              pdfBytes: pdfBytes,
              title: title,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  static Future<(List<dynamic>, bool)> _resolveNetworkImages(List<dynamic> ops) async {
    final result = <dynamic>[];
    bool hadFailures = false;
    for (final op in ops) {
      if (op is Map && op['insert'] is Map) {
        final insert = op['insert'] as Map;
        if (insert.containsKey('image')) {
          final src = insert['image'] as String;
          // Already a data URI — pass through untouched
          if (src.startsWith('data:')) {
            result.add(op);
            continue;
          }
          if (src.startsWith('http://') || src.startsWith('https://')) {
            try {
              final response = await http.get(Uri.parse(src));
              final contentType = response.headers['content-type'] ?? '';
              if (response.statusCode == 200 && contentType.startsWith('image/')) {
                final mimeType = contentType.split(';').first.trim();
                // base64Encode produces a single-line string (no newlines) — safe for data URIs
                final dataUri = 'data:$mimeType;base64,${base64Encode(response.bodyBytes)}';
                result.add({...(op as Map<String, dynamic>), 'insert': {'image': dataUri}});
                continue;
              } else {
                hadFailures = true;
                debugPrint('PDF: skipping image $src — status=${response.statusCode} type=$contentType');
              }
            } catch (e) {
              hadFailures = true;
              debugPrint('PDF: failed to fetch image $src: $e');
            }
          }
        }
      }
      result.add(op);
    }
    return (result, hadFailures);
  }
}
