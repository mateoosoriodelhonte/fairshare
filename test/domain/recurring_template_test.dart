import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  RecurringTemplate template(RecurrenceFrequency f, int interval, DateTime next) => RecurringTemplate(
    id: 'r1',
    groupId: 'g1',
    description: 'Rent',
    amount: const Money(100000, Currencies.usd),
    paidByMemberId: 'a',
    category: ExpenseCategory.housing,
    splitType: SplitType.equal,
    shares: const [
      ExpenseShare(memberId: 'a', amountMinor: 50000),
      ExpenseShare(memberId: 'b', amountMinor: 50000),
    ],
    frequency: f,
    interval: interval,
    nextDueDate: next,
    isActive: true,
    createdAt: DateTime(2026),
  );

  group('RecurringTemplate.nextAfter', () {
    test('daily and weekly', () {
      expect(
        template(RecurrenceFrequency.daily, 3, DateTime(2026, 1, 30)).nextAfter(DateTime(2026, 1, 30)),
        DateTime(2026, 2, 2),
      );
      expect(
        template(RecurrenceFrequency.weekly, 2, DateTime(2026, 1, 1)).nextAfter(DateTime(2026, 1, 1)),
        DateTime(2026, 1, 15),
      );
    });

    test('monthly clamps to month end', () {
      final t = template(RecurrenceFrequency.monthly, 1, DateTime(2026, 1, 31));
      expect(t.nextAfter(DateTime(2026, 1, 31)), DateTime(2026, 2, 28));
      expect(t.nextAfter(DateTime(2026, 3, 31)), DateTime(2026, 4, 30));
      expect(t.nextAfter(DateTime(2026, 12, 15)), DateTime(2027, 1, 15));
    });

    test('yearly handles leap day', () {
      final t = template(RecurrenceFrequency.yearly, 1, DateTime(2028, 2, 29));
      expect(t.nextAfter(DateTime(2028, 2, 29)), DateTime(2029, 2, 28));
    });

    test('dueDatesUntil lists all occurrences and is capped', () {
      final t = template(RecurrenceFrequency.monthly, 1, DateTime(2026, 1, 15));
      expect(t.dueDatesUntil(DateTime(2026, 4, 1)), [
        DateTime(2026, 1, 15),
        DateTime(2026, 2, 15),
        DateTime(2026, 3, 15),
      ]);
      expect(t.dueDatesUntil(DateTime(2025, 12, 1)), isEmpty);
      final daily = template(RecurrenceFrequency.daily, 1, DateTime(2020));
      expect(daily.dueDatesUntil(DateTime(2026)).length, 120);
    });
  });
}
