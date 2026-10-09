import 'package:meta/meta.dart';

import '../core/money/money_exports.dart';
import 'accounting/accounting.dart';
import 'group_snapshot.dart';
import 'models/models.dart';

@immutable
class CategoryTotal {
  const CategoryTotal({required this.category, required this.amount});

  final ExpenseCategory category;
  final Money amount;
}

@immutable
class MonthTotal {
  const MonthTotal({required this.month, required this.amount});

  /// First day of the month.
  final DateTime month;
  final Money amount;
}

/// Aggregated spending for one or more groups that share a base currency.
/// All sums are exact integer arithmetic on converted expense totals.
@immutable
class SpendingInsights {
  SpendingInsights._({
    required this.currency,
    required this.totalSpent,
    required this.thisMonth,
    required this.outstanding,
    required this.groupCount,
    required this.expenseCount,
    required List<CategoryTotal> byCategory,
    required List<MonthTotal> byMonth,
  }) : byCategory = List.unmodifiable(byCategory),
       byMonth = List.unmodifiable(byMonth);

  final Currency currency;
  final Money totalSpent;
  final Money thisMonth;

  /// Sum of all positive balances: what is still owed across the groups.
  final Money outstanding;
  final int groupCount;
  final int expenseCount;

  /// Descending by amount; zero categories omitted.
  final List<CategoryTotal> byCategory;

  /// Oldest first, covering the last [monthsBack] months up to [now].
  final List<MonthTotal> byMonth;

  bool get isEmpty => expenseCount == 0;

  /// Largest category, or null when there are no expenses.
  CategoryTotal? get topCategory => byCategory.isEmpty ? null : byCategory.first;

  static const int monthsBack = 6;

  /// Computes insights for every snapshot whose base currency is
  /// [currency]; others are ignored so sums stay meaningful.
  static SpendingInsights compute(List<GroupSnapshot> snapshots, {required Currency currency, required DateTime now}) {
    final relevant = snapshots.where((s) => s.group.baseCurrency == currency).toList();
    var total = 0;
    var thisMonth = 0;
    var outstanding = 0;
    var count = 0;
    final byCategory = <ExpenseCategory, int>{};
    final months = <DateTime, int>{};
    final firstMonth = DateTime(now.year, now.month - (monthsBack - 1), 1);
    for (var i = 0; i < monthsBack; i++) {
      months[DateTime(firstMonth.year, firstMonth.month + i, 1)] = 0;
    }
    final currentMonth = DateTime(now.year, now.month, 1);

    for (final s in relevant) {
      outstanding += s.balances.creditors.fold<int>(0, (acc, b) => acc + b.balance.minorUnits);
      for (final e in s.expenses) {
        final converted = BalanceCalculator.convertExpense(e, currency).total.minorUnits;
        total += converted;
        count++;
        byCategory[e.category] = (byCategory[e.category] ?? 0) + converted;
        final month = DateTime(e.date.year, e.date.month, 1);
        if (months.containsKey(month)) months[month] = months[month]! + converted;
        if (month == currentMonth) thisMonth += converted;
      }
    }

    final categories =
        byCategory.entries
            .where((e) => e.value != 0)
            .map((e) => CategoryTotal(category: e.key, amount: Money(e.value, currency)))
            .toList()
          ..sort((a, b) {
            final cmp = b.amount.compareTo(a.amount);
            return cmp != 0 ? cmp : a.category.index.compareTo(b.category.index);
          });
    final monthly = months.entries.map((e) => MonthTotal(month: e.key, amount: Money(e.value, currency))).toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return SpendingInsights._(
      currency: currency,
      totalSpent: Money(total, currency),
      thisMonth: Money(thisMonth, currency),
      outstanding: Money(outstanding, currency),
      groupCount: relevant.length,
      expenseCount: count,
      byCategory: categories,
      byMonth: monthly,
    );
  }

  /// Currencies present across [snapshots], most-used (by total spent) first.
  static List<Currency> currenciesIn(List<GroupSnapshot> snapshots) {
    final totals = <Currency, int>{};
    for (final s in snapshots) {
      totals[s.group.baseCurrency] = (totals[s.group.baseCurrency] ?? 0) + s.balances.totalSpent.minorUnits;
    }
    final list = totals.keys.toList()
      ..sort((a, b) {
        final cmp = totals[b]!.compareTo(totals[a]!);
        return cmp != 0 ? cmp : a.code.compareTo(b.code);
      });
    return list;
  }
}
