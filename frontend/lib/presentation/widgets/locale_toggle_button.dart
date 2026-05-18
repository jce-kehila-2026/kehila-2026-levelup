import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/controllers/locale_provider.dart';
import '../../theme/app_theme.dart';

class LocaleToggleButton extends StatelessWidget {
  const LocaleToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocaleProvider>();
    final label = provider.isArabic ? 'EN' : 'AR';

    return GestureDetector(
      onTap: provider.toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.4,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
