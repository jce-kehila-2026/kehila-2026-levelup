/// Presentation Tier — Screen
/// Path: lib/presentation/screens/details/lesson_detail_screen.dart
///
/// ✅ Zero mock data — uses LessonDetailController
/// ✅ Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/badge.dart';
import '../../widgets/vibe_premium_renderer.dart';
import '../../../services/pdf_export_service.dart'; // PdfExportService
import '../../../logic/controllers/lesson_detail_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

class LessonDetailScreen extends StatefulWidget {
  final String id;
  const LessonDetailScreen({super.key, required this.id});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late final LessonDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<LessonDetailController>(param1: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final lesson = _controller.lesson;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.text),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppLocalizations.of(context)!.lessonLabel, style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                tooltip: AppLocalizations.of(context)!.viewAsPdfTooltip,
                onPressed: () => PdfExportService.exportAndShowPdf(context, lesson.title, lesson.deltaJson ?? lesson.content ?? ''),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Content Area
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(AppLocalizations.of(context)!.level1Label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                            const SizedBox(width: 6),
                            const Icon(Icons.chevron_right, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(AppLocalizations.of(context)!.week1Foundations, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mutedForeground)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(lesson.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.3)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: lesson.searchTags.map((tag) => BadgeWidget(label: tag, variant: BadgeVariant.muted)).toList(),
                        ),
                        const SizedBox(height: 24),
                        VibePremiumRenderer(
                          content: lesson.deltaJson ?? lesson.content ?? '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
