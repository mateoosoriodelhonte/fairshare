import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/group_snapshot.dart';
import 'package:fairshare/domain/insights.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 9);

  GroupSnapshot snap({
    String id = 'g1',
    Currency currency = Currencies.usd,
    List<Expense> expenses = const [],
    List<Settlement> settlements = const [],
  }) => GroupSnapshot(
    group: testGroup(id: id, currency: currency),
    members: members(['a', 'b'], groupId: id),
    expenses: expenses,
    settlements: settlements,
    templates: const [],
  );

  test('empty input yields empty insights with six zero months', () {
    final i = SpendingInsights.compute([], currency: Currencies.usd, now: now);
    expect(i.isEmpty, isTrue);
    expect(i.byMonth.length, 6);
    expect(i.byMonth.first.month, DateTime(2026, 5, 1));
    expect(i.byMonth.last.month, DateTime(2026, 10, 1));
    expect(i.byMonth.every((m) => m.amount.isZero), isTrue);
    expect(i.topCategory, isNull);
  });

  test('totals, categories, months and outstanding are exact and converted', () {
    final s = snap(
      expenses: [
        expense(
          amountMinor: 1000,
          paidBy: 'a',
          participants: ['a', 'b'],
          date: DateTime(2026, 10, 2),
        ).copyWith(category: ExpenseCategory.food),
        expense(
          amountMinor: 500,
          paidBy: 'a',
          participants: ['a', 'b'],
          date: DateTime(2026, 9, 15),
        ).copyWith(category: ExpenseCategory.food),
        // €10 at 1.1 -> $11.00, groceries, five months ago
        expense(
          amountMinor: 1000,
          paidBy: 'b',
          participants: ['a', 'b'],
          currency: Currencies.eur,
          rate: ConversionRate.parse('1.1'),
          date: DateTime(2026, 5, 20),
        ).copyWith(category: ExpenseCategory.groceries),
        // Too old to appear in the monthly series, but still in totals.
        expense(
          amountMinor: 300,
          paidBy: 'a',
          participants: ['a', 'b'],
          date: DateTime(2025, 1, 1),
        ).copyWith(category: ExpenseCategory.other),
      ],
      settlements: [settlement(from: 'b', to: 'a', amountMinor: 100)],
    );
    final i = SpendingInsights.compute([s], currency: Currencies.usd, now: now);
    expect(i.totalSpent, const Money(2900, Currencies.usd));
    expect(i.thisMonth, const Money(1000, Currencies.usd));
    expect(i.expenseCount, 4);
    expect(i.groupCount, 1);
    expect(i.byCategory.map((c) => c.category), [
      ExpenseCategory.food,
      ExpenseCategory.groceries,
      ExpenseCategory.other,
    ]);
    expect(i.byCategory.first.amount, const Money(1500, Currencies.usd));
    expect(i.topCategory!.category, ExpenseCategory.food);
    expect(i.byMonth.map((m) => m.amount.minorUnits), [1100, 0, 0, 0, 500, 1000]);
    // a paid 1800 of USD-equivalent, owed 1450 -> +350; settlement b->a 100 -> a +250.
    expect(i.outstanding, const Money(250, Currencies.usd));
  });

  test('only groups in the requested currency are included', () {
    final usd = snap(
      expenses: [
        expense(amountMinor: 100, paidBy: 'a', participants: ['a', 'b'], date: now),
      ],
    );
    final eur = snap(
      id: 'g2',
      currency: Currencies.eur,
      expenses: [
        expense(
          amountMinor: 999,
          paidBy: 'a',
          participants: ['a', 'b'],
          currency: Currencies.eur,
          groupId: 'g2',
          date: now,
        ),
      ],
    );
    final i = SpendingInsights.compute([usd, eur], currency: Currencies.usd, now: now);
    expect(i.totalSpent, const Money(100, Currencies.usd));
    expect(i.groupCount, 1);
    expect(SpendingInsights.currenciesIn([usd, eur]), [Currencies.eur, Currencies.usd]);
  });
}
