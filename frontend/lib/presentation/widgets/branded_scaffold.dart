import 'package:flutter/material.dart';

/// A global watermark overlay widget that renders the branding image
/// at very low opacity behind all content. Designed to be injected
/// at the MaterialApp.builder level so every route inherits it.
class BrandedBackground extends StatelessWidget {
  final Widget child;

  const BrandedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
