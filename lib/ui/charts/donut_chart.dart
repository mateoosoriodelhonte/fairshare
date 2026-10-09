import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

class DonutSegment {
  const DonutSegment({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;
}

/// Animated ring chart with a centred label and a legend. Values are
/// integers (minor units); proportions are computed in doubles only for
/// drawing, never for accounting.
class DonutChart extends StatelessWidget {
  const DonutChart({
    required this.segments,
    required this.centerTitle,
    required this.centerSubtitle,
    this.size = 168,
    this.maxLegendItems = 6,
    super.key,
  });

  final List<DonutSegment> segments;
  final String centerTitle;
  final String centerSubtitle;
  final double size;
  final int maxLegendItems;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (a, s) => a + s.value);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final legend = segments.take(maxLegendItems).toList();
    final rest = segments.skip(maxLegendItems).fold<int>(0, (a, s) => a + s.value);
    final semantics = total == 0
        ? 'No spending yet'
        : segments.map((s) => '${s.label} ${(s.value * 100 / total).toStringAsFixed(0)}%').join(', ');

    return Semantics(
      label: 'Spending by category: $semantics',
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 380;
          final ring = SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: reduce ? Duration.zero : FsMotion.chart,
              curve: FsMotion.emphasized,
              builder: (context, t, _) => CustomPaint(
                painter: _DonutPainter(
                  segments: segments,
                  total: total,
                  progress: t,
                  track: context.palette.chartTrack,
                  gap: 2.5,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(centerTitle, style: context.text.titleLarge?.tabular, textAlign: TextAlign.center),
                      Text(centerSubtitle, style: context.text.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          );
          final legendWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in legend) _LegendRow(segment: s, total: total),
              if (rest > 0)
                _LegendRow(
                  segment: DonutSegment(label: 'Other', value: rest, color: context.colors.outline),
                  total: total,
                ),
            ],
          );
          if (horizontal) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ring,
                const SizedBox(width: FsSpace.xl),
                Expanded(child: legendWidget),
              ],
            );
          }
          return Column(
            children: [
              ring,
              const SizedBox(height: FsSpace.lg),
              legendWidget,
            ],
          );
        },
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.segment, required this.total});

  final DonutSegment segment;
  final int total;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : segment.value * 100 / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: segment.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: FsSpace.sm),
          Expanded(
            child: Text(segment.label, style: context.text.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${pct.toStringAsFixed(pct >= 10 ? 0 : 1)}%',
            style: context.text.bodyMedium?.tabular.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.total,
    required this.progress,
    required this.track,
    required this.gap,
  });

  final List<DonutSegment> segments;
  final int total;
  final double progress;
  final Color track;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.13;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (total == 0) return;
    final gapRad = gap / (rect.width / 2);
    var start = -math.pi / 2;
    final sweepTotal = math.pi * 2 * progress;
    var consumed = 0.0;
    for (final s in segments) {
      if (s.value <= 0) continue;
      final full = math.pi * 2 * (s.value / total);
      final available = sweepTotal - consumed;
      if (available <= 0) break;
      final sweep = math.min(full, available);
      final drawn = math.max(0.0, sweep - (segments.length > 1 ? gapRad : 0));
      canvas.drawArc(rect, start + gapRad / 2, drawn, false, paint..color = s.color);
      start += full;
      consumed += full;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.segments != segments || old.total != total || old.track != track;
}
