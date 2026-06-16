/// Presentation Tier — Screen
/// Path: lib/presentation/screens/details/lesson_detail_screen.dart
library;

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/vibe_premium_renderer.dart';
import '../../../logic/controllers/lesson_detail_controller.dart';
import '../../../di/service_locator.dart';

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
            title: Text(
              lesson.title,
              style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Meta row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock_outline, size: 11, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'View only',
                                style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          lesson.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.3),
                        ),
                        const Divider(color: AppColors.border, height: 28),
                        // White doc card
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(32),
                              child: VibePremiumRenderer(
                                content: lesson.deltaJson ?? lesson.content ?? '',
                                attachments: lesson.attachments,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
