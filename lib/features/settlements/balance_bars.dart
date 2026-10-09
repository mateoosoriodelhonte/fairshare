import 'package:flutter/material.dart';

import '../../core/money/money.dart';
import '../../domain/group_snapshot.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';

/// Diverging bar chart of member balances: credit grows to the right,
/// debt to the left, from a shared centre line.
class BalanceBars extends StatelessWidget {
  const BalanceBars({required this.snapshot, super.key});

  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final members = snapshot.members;
    final maxAbs = members.fold<int>(0, (m, member) {
      final v = snapshot.balances.balanceOf(member.id).minorUnits.abs();
      return v > m ? v : m;
    });
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Column(
      children: [
        for (final m in members) ...[
          Builder(
            builder: (context) {
              final balance = snapshot.balances.balanceOf(m.id);
              final fraction = maxAbs == 0 ? 0.0 : balance.minorUnits.abs() / maxAbs;
              final label = balance.isZero
                  ? '${m.name} is settled up'
                  : balance.isPositive
                  ? '${m.name} is owed ${balance.format()}'
                  : '${m.name} owes ${balance.abs().format()}';
              return Semantics(
                label: label,
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: FsSpace.xs),
                  child: Row(
                    children: [
                      MemberAvatar(member: m, size: 28),
                      const SizedBox(width: FsSpace.sm),
                      SizedBox(
                        width: 88,
                        child: Text(
                          m.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 22,
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final half = c.maxWidth / 2;
                              return Stack(
                                children: [
                                  Positioned(
                                    left: half - 0.5,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(width: 1, color: palette.hairline),
                                  ),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: fraction),
                                    duration: reduce ? Duration.zero : FsMotion.chart,
                                    curve: FsMotion.emphasized,
                                    builder: (context, f, _) {
                                      final w = (half - 2) * f;
                                      return Positioned(
                                        left: balance.isNegative ? half - w : half,
                                        top: 3,
                                        bottom: 3,
                                        width: w,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: balance.isNegative ? palette.negative : palette.positive,
                                            borderRadius: BorderRadius.horizontal(
                                              left: Radius.circular(balance.isNegative ? 6 : 0),
                                              right: Radius.circular(balance.isNegative ? 0 : 6),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: FsSpace.md),
                      SizedBox(
                        width: 96,
                        child: MoneyText(
                          balance,
                          signed: true,
                          colored: true,
                          textAlign: TextAlign.end,
                          style: context.text.bodyMedium?.semibold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        if (members.isNotEmpty) ...[
          const SizedBox(height: FsSpace.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total spent ${snapshot.balances.totalSpent.format()} · balances always sum to ${Money.zero(snapshot.group.baseCurrency).format()}',
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
