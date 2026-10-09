import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/router.dart';
import '../../core/money/money.dart';
import '../../domain/accounting/accounting.dart';
import '../../domain/group_snapshot.dart';
import '../../domain/models/models.dart';
import '../../ui/category_icons.dart';
import '../../ui/shell/app_shell.dart';
import '../../ui/theme/theme.dart';
import '../../ui/widgets/widgets.dart';

/// Expenses grouped by month, newest first.
class ExpenseList extends StatelessWidget {
  const ExpenseList({required this.snapshot, this.limit, super.key});

  final GroupSnapshot snapshot;

  /// When set, only the most recent [limit] expenses are shown.
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final expenses = limit == null ? snapshot.expenses : snapshot.expenses.take(limit!).toList();
    final sections = <DateTime, List<Expense>>{};
    for (final e in expenses) {
      sections.putIfAbsent(DateTime(e.date.year, e.date.month), () => []).add(e);
    }
    final monthFormat = DateFormat.yMMMM();
    var index = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in sections.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(FsSpace.xs, FsSpace.lg, FsSpace.xs, FsSpace.sm),
            child: Row(
              children: [
                Expanded(child: Text(monthFormat.format(entry.key), style: context.text.labelMedium)),
                MoneyText(
                  _monthTotal(entry.value),
                  style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FsListCard(
            children: [
              for (final e in entry.value)
                StaggeredEntrance(
                  index: index++,
                  child: ExpenseTile(expense: e, snapshot: snapshot),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Money _monthTotal(List<Expense> expenses) {
    final base = snapshot.group.baseCurrency;
    var total = 0;
    for (final e in expenses) {
      total += BalanceCalculator.convertExpense(e, base).total.minorUnits;
    }
    return Money(total, base);
  }
}

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({required this.expense, required this.snapshot, super.key});

  final Expense expense;
  final GroupSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final base = snapshot.group.baseCurrency;
    final foreign = expense.amount.currency != base;
    final converted = foreign ? BalanceCalculator.convertExpense(expense, base).total : null;
    final payer = snapshot.memberName(expense.paidByMemberId);
    final n = expense.participantCount;
    final color = palette.category(expense.category);
    final day = DateFormat.MMMd().format(expense.date);

    return ListTile(
      onTap: () => context.navigateTo(Routes.expense(expense.groupId, expense.id)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(FsRadius.md),
        ),
        child: Icon(categoryIcon(expense.category), color: color, size: 20),
      ),
      title: Text(expense.description, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '$day · Paid by $payer · ${n == 1 ? '1 person' : '$n people'}'
        '${expense.recurringTemplateId != null ? ' · Recurring' : ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // ListTile caps trailing height at 56; scale down rather than overflow at large text sizes.
      trailing: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MoneyText(expense.amount, style: context.text.titleMedium),
            if (converted != null) Text('≈ ${converted.format()}', style: context.text.bodySmall?.tabular),
          ],
        ),
      ),
    );
  }
}
