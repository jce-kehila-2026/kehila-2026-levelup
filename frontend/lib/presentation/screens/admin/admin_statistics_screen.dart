import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../di/service_locator.dart';
import '../../../logic/controllers/admin_statistics_controller.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _purpleDark  = Color(0xFF6B21A8);
const _purpleMid   = Color(0xFF8B5CF6);
const _purpleLight = Color(0xFFA78BFA);
const _purplePale  = Color(0xFFDDD6FE);
const _yellowDark  = Color(0xFFEAB308);
const _yellowMid   = Color(0xFFF59E0B);
const _yellowLight = Color(0xFFFCD34D);

const _purples = [_purpleDark, _purpleMid, _purpleLight, _purplePale];
const _yellows = [_yellowDark, _yellowMid, _yellowLight];

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminStatisticsScreen extends StatelessWidget {
  const AdminStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = getIt<AdminStatisticsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) {
          if (ctrl.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                  const SizedBox(height: 12),
                  Text(ctrl.error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: ctrl.refresh, child: const Text('Retry')),
                ],
              ),
            );
          }
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── STUDENTS ──────────────────────────────────────────
                  _sectionLabel('STUDENTS'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatChip(label: 'Total', value: '${ctrl.totalStudents}'),
                      _StatChip(label: 'Without group', value: '${ctrl.unassignedStudents}'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(builder: (ctx, c) {
                    final isWide = c.maxWidth >= 600;
                    final half = isWide ? (c.maxWidth - 14) / 2 : c.maxWidth;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: half,
                          child: _donutCard(
                            title: 'Gender',
                            subtitle: 'Distribution by gender',
                            data: ctrl.studentsByGender,
                            unit: 'students',
                          ),
                        ),
                        SizedBox(
                          width: half,
                          child: ctrl.studentsByLevel.isNotEmpty
                              ? _barCard(
                                  title: 'By Level',
                                  subtitle: 'Students per level',
                                  data: ctrl.studentsByLevel,
                                  colors: _purples,
                                  labelMapper: (k) => ctrl.levelNames[k] ?? k,
                                )
                              : _emptyCard('No level data'),
                        ),
                        SizedBox(
                          width: half,
                          child: ctrl.studentsByAge.isNotEmpty
                              ? _barCard(
                                  title: 'Age',
                                  subtitle: 'Individual ages',
                                  data: ctrl.studentsByAge,
                                  colors: _yellows,
                                )
                              : _emptyCard('No age data'),
                        ),
                        SizedBox(
                          width: half,
                          child: ctrl.studentsByLocation.isNotEmpty
                              ? _barCard(
                                  title: 'Location',
                                  subtitle: 'Top locations',
                                  data: ctrl.studentsByLocation,
                                  colors: _purples,
                                )
                              : _emptyCard('No location data'),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 32),

                  // ── INSTRUCTORS ───────────────────────────────────────
                  _sectionLabel('INSTRUCTORS'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _StatChip(label: 'Total', value: '${ctrl.totalInstructors}'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(builder: (ctx, c) {
                    final isWide = c.maxWidth >= 600;
                    final half = isWide ? (c.maxWidth - 14) / 2 : c.maxWidth;
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: half,
                          child: _donutCard(
                            title: 'Gender',
                            subtitle: 'Distribution by gender',
                            data: ctrl.instructorsByGender,
                            unit: 'instructors',
                          ),
                        ),
                        SizedBox(
                          width: half,
                          child: ctrl.instructorsByLocation.isNotEmpty
                              ? _barCard(
                                  title: 'Location',
                                  subtitle: 'Top locations',
                                  data: ctrl.instructorsByLocation,
                                  colors: _purples,
                                )
                              : _emptyCard('No location data'),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(width: 3, height: 20, color: _purpleDark),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedForeground,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ── Card wrapper ──────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _cardHeader(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Empty card ────────────────────────────────────────────────────────────

  Widget _emptyCard(String message) {
    return _card(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
          ),
        ),
      ),
    );
  }

  // ── Donut chart card ──────────────────────────────────────────────────────

  Widget _donutCard({
    required String title,
    String? subtitle,
    required Map<String, int> data,
    required String unit,
  }) {
    final total = data.values.fold(0, (a, b) => a + b);
    final entries = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    Color colorFor(String key) {
      final k = key.toLowerCase();
      if (k == 'male') return _purpleMid;
      if (k == 'female') return _yellowMid;
      final idx = entries.indexWhere((e) => e.key == key);
      return [_purpleMid, _yellowMid, _purpleLight][idx.clamp(0, 2)];
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, subtitle: subtitle),
          if (total == 0)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No data', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ),
            )
          else ...[
            SizedBox(
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _DonutPainter(
                      data: Map.fromEntries(entries),
                      colors: entries.map((e) => colorFor(e.key)).toList(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const Text(
                        'total',
                        style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...entries.map((e) {
              final color = colorFor(e.key);
              final pct = total > 0 ? (e.value / total * 100).round() : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _capitalize(e.key),
                        style: const TextStyle(fontSize: 12, color: AppColors.text),
                      ),
                    ),
                    Text(
                      '${e.value} $unit · $pct%',
                      style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── Bar chart card ────────────────────────────────────────────────────────

  Widget _barCard({
    required String title,
    String? subtitle,
    required Map<String, int> data,
    required List<Color> colors,
    String Function(String)? labelMapper,
  }) {
    final total = data.values.fold(0, (a, b) => a + b);
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b);
    final entries = data.entries.toList();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(title, subtitle: subtitle),
          ...entries.asMap().entries.map((indexed) {
            final key = indexed.value.key;
            final val = indexed.value.value;
            final label = labelMapper != null ? labelMapper(key) : key;
            final isMuted = key == 'Not set' || key == 'Other';
            final color = isMuted
                ? const Color(0xFFCBD5E1)
                : colors[indexed.key % colors.length];
            return _barRow(
              label: label,
              value: val,
              maxValue: maxVal,
              total: total,
              color: color,
              isMuted: isMuted,
            );
          }),
        ],
      ),
    );
  }

  Widget _barRow({
    required String label,
    required int value,
    required int maxValue,
    required int total,
    required Color color,
    bool isMuted = false,
  }) {
    final fraction = maxValue > 0 ? value / maxValue : 0.0;
    final pct = total > 0 ? (value / total * 100).round() : 0;
    final labelStyle = TextStyle(
      fontSize: 12,
      color: isMuted ? AppColors.mutedForeground : AppColors.text,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: labelStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, c) {
                final barWidth = fraction * c.maxWidth;
                return Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: barWidth,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: Text(
              '$value · $pct%',
              style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Stat chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Donut painter ─────────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final Map<String, int> data;
  final List<Color> colors;

  const _DonutPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = data.values.fold(0, (a, b) => a + b);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.32;
    final entries = data.entries.toList();
    double startAngle = -math.pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweep = 2 * math.pi * entries[i].value / total;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.data != data || old.colors != colors;
}
