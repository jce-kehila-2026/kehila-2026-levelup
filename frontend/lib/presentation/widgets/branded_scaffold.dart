import 'package:flutter/material.dart';

/// A global watermark overlay widget that renders the branding image
/// at very low opacity behind all content. Designed to be injected
/// at the MaterialApp.builder level so every route inherits it.
class BrandedBackground extends StatelessWidget {
  final Widget child;

  const BrandedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Content Layer ────────────────────────────
        child,
        // ── Watermark Layer ──────────────────────────
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.04,
              child: Image.asset(
                'assets/images/Shah2Range.jpeg',
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
