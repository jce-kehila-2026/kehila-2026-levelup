import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:secure_application/secure_application.dart';
import 'package:screen_protector/screen_protector.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:frontend/l10n/app_localizations.dart';

class SecurePdfViewerScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;

  const SecurePdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  State<SecurePdfViewerScreen> createState() => _SecurePdfViewerScreenState();
}

class _SecurePdfViewerScreenState extends State<SecurePdfViewerScreen> {
  @override
  void initState() {
    super.initState();
    _secureScreen();
  }

  Future<void> _secureScreen() async {
    if (!kIsWeb) {
      await ScreenProtector.preventScreenshotOn();
    }
  }

  @override
  void dispose() {
    _unsecureScreen();
    super.dispose();
  }

  Future<void> _unsecureScreen() async {
    if (!kIsWeb) {
      await ScreenProtector.preventScreenshotOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecureApplication(
      nativeRemoveDelay: 100,
      onNeedUnlock: (secure) => null,
      child: SecureGate(
        blurr: 20,
        opacity: 0.8,
        lockedBuilder: (context, secureNotifier) => Center(child: Text(AppLocalizations.of(context)!.secureModeEnabled)),
        child: Builder(builder: (context) {
          SecureApplicationProvider.of(context)?.secure();
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
            ),
            body: PdfPreview(
              build: (format) => widget.pdfBytes,
              allowSharing: false,
              allowPrinting: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              padding: EdgeInsets.zero,
              maxPageWidth: double.infinity,
              initialPageFormat: PdfPageFormat.a4,
            ),
          );
        }),
      ),
    );
  }
}
