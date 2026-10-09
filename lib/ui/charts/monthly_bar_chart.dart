import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import '../theme/theme.dart';

class BarPoint {
  const BarPoint({required this.label, required this.value, required this.semanticLabel});

  final String label;
  final int value;
  final String semanticLabel;
}

/// Vertical bars with animated growth, a dotted average line, and value
/// labels on the tallest bars.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({required this.points, required this.currency, this.height = 150, super.key});

  final List<BarPoint> points;
  final Currency currency;
  final double height;

  static List<BarPoint> fromMonths(List<({DateTime month, int value})> months, Currency currency) {
    final fmt = DateFormat.MMM();
    final full = DateFormat.yMMMM();
    return [
      for (final m in months)
        BarPoint(
          label: fmt.format(m.month),
          value: m.value,
          semanticLabel: '${full.format(m.month)}: ${Money(m.value, currency).format()}',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final max = points.fold<int>(0, (m, p) => p.value > m ? p.value : m);
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final nonZero = points.where((p) => p.value > 0).toList();
    final avg = nonZero.isEmpty ? 0 : nonZero.fold<int>(0, (a, p) => a + p.value) ~/ nonZero.length;

    return Semantics(
      label: 'Monthly spending. ${points.map((p) => p.semanticLabel).join('. ')}',
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: reduce ? Duration.zero : FsMotion.chart,
        curve: FsMotion.emphasized,
        builder: (context, t, _) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: Stack(
                children: [
                  if (avg > 0 && max > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: (avg / max) * height * t,
                      child: CustomPaint(
                        painter: _DashedLinePainter(color: palette.hairline),
                        size: const Size(double.infinity, 1),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final p in points)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (p.value > 0 && p.value == max)
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          _compact(Money(p.value, currency)),
                                          style: context.text.labelSmall?.tabular.copyWith(
                                            color: context.colors.onSurface,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                Container(
                                  height: max == 0 ? 3 : (3 + (height - 34) * (p.value / max) * t),
                                  decoration: BoxDecoration(
                                    color: p.value == 0
                                        ? palette.chartTrack
                                        : (p.value == max
                                              ? context.colors.primary
                                              : context.colors.primary.withValues(alpha: 0.55)),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (final p in points)
                  Expanded(
                    child: Text(p.label, textAlign: TextAlign.center, style: context.text.labelSmall),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Whole units once the amount is large enough that cents are noise in a
/// narrow bar column (e.g. `€751` instead of `€751.37`).
String _compact(Money m) {
  if (m.currency.decimalDigits == 0 || m.minorUnits.abs() < 100 * m.currency.minorUnitsPerMajor) return m.format();
  return Money(m.minorUnits - m.minorUnits % m.currency.minorUnitsPerMajor, m.currency).format().split('.').first;
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash * 2;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
