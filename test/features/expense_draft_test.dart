import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:fairshare/features/expenses/expense_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  final g = testGroup();
  final ms = members(['a', 'b', 'c']);
  final now = DateTime(2026, 5, 4, 10);

  ExpenseDraft fresh() => ExpenseDraft.create(group: g, members: ms, today: now);

  group('ExpenseDraft validation', () {
    test('empty draft reports the required fields', () {
      final r = fresh().build(id: 'x', now: now);
      expect(r.isValid, isFalse);
      expect(r.errors.keys, containsAll([DraftField.description, DraftField.amount]));
      expect(r.errors[DraftField.rate], isNull);
    });

    test('valid equal split builds an expense with conserved shares', () {
      final d = fresh()
        ..description = ' Dinner '
        ..amountText = '100';
      final r = d.build(id: 'x', now: now);
      expect(r.isValid, isTrue);
      final e = r.expense!;
      expect(e.description, 'Dinner');
      expect(e.amount, const Money(10000, Currencies.usd));
      expect(e.shares.map((s) => s.amountMinor), [3334, 3333, 3333]);
      expect(e.isConsistent, isTrue);
      expect(e.paidByMemberId, 'a');
      expect(e.date, DateTime(2026, 5, 4));
      expect(e.conversionRate, isNull);
    });

    test('rejects zero, negative, over-precise and garbage amounts', () {
      for (final bad in ['0', '-5', '1.234', 'abc', '1,2,3']) {
        final d = fresh()
          ..description = 'x'
          ..amountText = bad;
        expect(
          d.build(id: 'x', now: now).errors[DraftField.amount],
          isNotNull,
          reason: bad,
        );
      }
    });

    test('foreign currency requires a rate and converts the preview', () {
      final d = fresh()
        ..description = 'Tapas'
        ..amountText = '10'
        ..currency = Currencies.eur;
      expect(d.needsRate, isTrue);
      expect(d.build(id: 'x', now: now).errors[DraftField.rate], contains('rate'));
      d.rateText = '1.085';
      expect(d.convertedTotal, const Money(1085, Currencies.usd));
      final r = d.build(id: 'x', now: now);
      expect(r.isValid, isTrue);
      expect(r.expense!.conversionRate, ConversionRate.parse('1.085'));
      d.rateText = '0';
      expect(d.build(id: 'x', now: now).errors[DraftField.rate], isNotNull);
    });

    test('switching back to the base currency drops the rate', () {
      final d = fresh()
        ..description = 'x'
        ..amountText = '10'
        ..currency = Currencies.eur
        ..rateText = '1.1';
      d.currency = Currencies.usd;
      expect(d.build(id: 'x', now: now).expense!.conversionRate, isNull);
    });

    test('no participants is an error', () {
      final d = fresh()
        ..description = 'x'
        ..amountText = '10'
        ..setAllIncluded(false);
      expect(d.build(id: 'x', now: now).errors[DraftField.participants], isNotNull);
    });

    test('percentages must parse and sum to 100', () {
      final d = fresh()
        ..description = 'x'
        ..amountText = '90'
        ..changeSplitType(SplitType.percentage);
      d.participants[0].text = '50';
      d.participants[1].text = '25';
      d.participants[2].text = '';
      expect(d.preview().error, contains('C'));
      d.participants[2].text = '20';
      expect(d.preview().error, contains('95%'));
      d.participants[2].text = '25';
      final r = d.build(id: 'x', now: now);
      expect(r.isValid, isTrue);
      expect(r.expense!.shares.map((s) => s.amountMinor), [4500, 2250, 2250]);
      expect(r.expense!.shares.map((s) => s.splitValue), [5000, 2500, 2500]);
    });

    test('shares split and distributeEvenly', () {
      final d = fresh()
        ..description = 'x'
        ..amountText = '30'
        ..changeSplitType(SplitType.shares)
        ..distributeEvenly();
      expect(d.participants.map((p) => p.text), ['1', '1', '1']);
      d.participants[0].text = '2';
      d.participants[2].included = false;
      final r = d.build(id: 'x', now: now);
      expect(r.expense!.shares.map((s) => s.amountMinor), [2000, 1000]);
      d.participants[1].text = 'two';
      expect(d.preview().error, contains('whole number'));
    });

    test('exact split reports shortfall and excess in money terms', () {
      final d = fresh()
        ..description = 'x'
        ..amountText = '10'
        ..changeSplitType(SplitType.exact);
      d.participants[0].text = '4';
      d.participants[1].text = '4';
      d.participants[2].text = '1.50';
      expect(d.preview().error, r'Amounts are $0.50 short of the total.');
      d.participants[2].text = '2.75';
      expect(d.preview().error, r'Amounts exceed the total by $0.75.');
      d.participants[2].text = '2';
      expect(d.build(id: 'x', now: now).isValid, isTrue);
    });

    test('distributeEvenly for percentages and exact amounts conserves totals', () {
      final d = fresh()
        ..description = 'x'
        ..amountText = '10'
        ..changeSplitType(SplitType.percentage)
        ..distributeEvenly();
      expect(d.participants.map((p) => p.text), ['33.34', '33.33', '33.33']);
      expect(d.preview().isValid, isTrue);
      d
        ..changeSplitType(SplitType.exact)
        ..distributeEvenly();
      expect(d.participants.map((p) => p.text), ['3.34', '3.33', '3.33']);
      expect(d.preview().isValid, isTrue);
    });

    test('percent parsing and formatting', () {
      expect(ExpenseDraft.parseBasisPoints('33.33'), 3333);
      expect(ExpenseDraft.parseBasisPoints('50 %'), 5000);
      expect(ExpenseDraft.parseBasisPoints('100'), 10000);
      expect(ExpenseDraft.parseBasisPoints('100.01'), isNull);
      expect(ExpenseDraft.parseBasisPoints('12,5'), 1250);
      expect(ExpenseDraft.parseBasisPoints('abc'), isNull);
      expect(ExpenseDraft.parseBasisPoints('1.234'), isNull);
      expect(ExpenseDraft.formatPercent(3333), '33.33');
      expect(ExpenseDraft.formatPercent(5000), '50');
      expect(ExpenseDraft.formatPercent(1250), '12.5');
    });
  });

  group('ExpenseDraft.edit', () {
    test('round-trips an existing percentage expense', () {
      final original = expense(
        amountMinor: 9000,
        paidBy: 'b',
        participants: ['a', 'b'],
        splitType: SplitType.percentage,
        shares: const [
          ExpenseShare(memberId: 'a', amountMinor: 6000, splitValue: 6667),
          ExpenseShare(memberId: 'b', amountMinor: 3000, splitValue: 3333),
        ],
        currency: Currencies.eur,
        rate: ConversionRate.parse('1.1'),
      ).copyWith(notes: 'hello', category: ExpenseCategory.travel);
      final d = ExpenseDraft.edit(group: g, members: ms, expense: original);
      expect(d.isEditing, isTrue);
      expect(d.amountText, '90.00');
      expect(d.currency, Currencies.eur);
      expect(d.rateText, '1.1');
      expect(d.participants.map((p) => p.included), [true, true, false]);
      expect(d.participants.map((p) => p.text), ['66.67', '33.33', '']);
      final rebuilt = d.build(id: original.id, now: now).expense!;
      expect(rebuilt.amount, original.amount);
      expect(rebuilt.shares, original.shares);
      expect(rebuilt.notes, 'hello');
      expect(rebuilt.category, ExpenseCategory.travel);
      expect(rebuilt.createdAt, original.createdAt);
      expect(rebuilt.updatedAt, now);
      expect(rebuilt.paidByMemberId, 'b');
    });

    test('round-trips exact and shares inputs', () {
      final exact = expense(
        amountMinor: 1000,
        paidBy: 'a',
        participants: ['a', 'c'],
        splitType: SplitType.exact,
        shares: const [
          ExpenseShare(memberId: 'a', amountMinor: 250, splitValue: 250),
          ExpenseShare(memberId: 'c', amountMinor: 750, splitValue: 750),
        ],
      );
      final d = ExpenseDraft.edit(group: g, members: ms, expense: exact);
      expect(d.participants.map((p) => p.text), ['2.50', '', '7.50']);
      expect(d.build(id: exact.id, now: now).expense!.shares, exact.shares);

      final shares = expense(
        amountMinor: 1000,
        paidBy: 'a',
        participants: ['a', 'b'],
        splitType: SplitType.shares,
        shares: const [
          ExpenseShare(memberId: 'a', amountMinor: 750, splitValue: 3),
          ExpenseShare(memberId: 'b', amountMinor: 250, splitValue: 1),
        ],
      );
      final d2 = ExpenseDraft.edit(group: g, members: ms, expense: shares);
      expect(d2.participants.map((p) => p.text), ['3', '1', '']);
      expect(d2.build(id: shares.id, now: now).expense!.shares, shares.shares);
    });
  });
}
