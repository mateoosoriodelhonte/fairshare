import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../../domain/insights.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'donut_chart.dart';
import 'monthly_bar_chart.dart';

/// Category ring + monthly bars for a [SpendingInsights]. Lays out side by
/// side when wide, stacked when narrow.
class InsightsPanel extends StatelessWidget {
  const InsightsPanel({required this.insights, this.showStats = true, super.key});

  final SpendingInsights insights;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    final i = insights;
    final palette = context.palette;
    final segments = [
      for (final c in i.byCategory)
        DonutSegment(label: c.category.label, value: c.amount.minorUnits, color: palette.category(c.category)),
    ];
    final bars = MonthlyBarChart.fromMonths([
      for (final m in i.byMonth) (month: m.month, value: m.amount.minorUnits),
    ], i.currency);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final categoryCard = FsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spending by category', style: context.text.titleSmall),
              const SizedBox(height: FsSpace.lg),
              DonutChart(
                segments: segments,
                centerTitle: i.totalSpent.format(),
                centerSubtitle: i.expenseCount == 1 ? '1 expense' : '${i.expenseCount} expenses',
              ),
            ],
          ),
        );
        final monthlyCard = FsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Last 6 months', style: context.text.titleSmall)),
                  Flexible(
                    child: Text(
                      'This month ${i.thisMonth.format()}',
                      style: context.text.bodySmall?.tabular,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FsSpace.lg),
              MonthlyBarChart(points: bars, currency: i.currency),
            ],
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showStats) ...[_StatRow(insights: i), const SizedBox(height: FsSpace.md)],
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: categoryCard),
                  const SizedBox(width: FsSpace.md),
                  Expanded(flex: 4, child: monthlyCard),
                ],
              )
            else ...[
              categoryCard,
              const SizedBox(height: FsSpace.md),
              monthlyCard,
            ],
          ],
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.insights});

  final SpendingInsights insights;

  @override
  Widget build(BuildContext context) {
    final i = insights;
    final tiles = [
      _StatTile(label: 'Total spent', money: i.totalSpent),
      _StatTile(label: 'This month', money: i.thisMonth),
      _StatTile(
        label: 'Outstanding',
        money: i.outstanding,
        caption: i.outstanding.isZero
            ? 'All settled'
            : 'Across ${i.groupCount == 1 ? '1 group' : '${i.groupCount} groups'}',
        colored: true,
      ),
      _StatTile(
        label: 'Top category',
        text: i.topCategory?.category.label ?? '–',
        caption: i.topCategory == null ? 'No expenses yet' : i.topCategory!.amount.format(),
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 720 ? 4 : 2;
        final width = (c.maxWidth - FsSpace.md * (columns - 1)) / columns;
        return Wrap(
          spacing: FsSpace.md,
          runSpacing: FsSpace.md,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, this.money, this.text, this.caption, this.colored = false});

  final String label;
  final Money? money;
  final String? text;
  final String? caption;
  final bool colored;

  @override
  Widget build(BuildContext context) {
    return FsCard(
      padding: const EdgeInsets.fromLTRB(FsSpace.lg, FsSpace.md, FsSpace.lg, FsSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: context.text.labelSmall?.copyWith(letterSpacing: 0.6)),
          const SizedBox(height: FsSpace.xs),
          if (money != null)
            AnimatedMoneyText(
              money!,
              style: context.text.headlineSmall?.copyWith(
                color: colored && money!.isPositive ? context.palette.warning : null,
              ),
            )
          else
            Text(text ?? '', style: context.text.headlineSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(caption!, style: context.text.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}
