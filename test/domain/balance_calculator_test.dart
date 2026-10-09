import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';
import '../support/property.dart';

void main() {
  const usd = Currencies.usd;

  group('BalanceCalculator.compute', () {
    test('empty group has zero balances for everyone', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [],
        settlements: [],
      );
      expect(sheet.balanceOf('a'), const Money(0, usd));
      expect(sheet.balanceOf('b'), const Money(0, usd));
      expect(sheet.isBalanced, isTrue);
      expect(sheet.isSettled, isTrue);
    });

    test('single expense split equally', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b', 'c']),
        expenses: [
          expense(amountMinor: 3000, paidBy: 'a', participants: ['a', 'b', 'c']),
        ],
        settlements: [],
      );
      expect(sheet.balanceOf('a'), const Money(2000, usd));
      expect(sheet.balanceOf('b'), const Money(-1000, usd));
      expect(sheet.balanceOf('c'), const Money(-1000, usd));
      expect(sheet.total, const Money(0, usd));
      expect(sheet.byMember['a']!.paid, const Money(3000, usd));
      expect(sheet.byMember['a']!.owed, const Money(1000, usd));
    });

    test('uneven split: remainder cents still conserve', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b', 'c']),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'b', participants: ['a', 'b', 'c']),
        ],
        settlements: [],
      );
      expect(sheet.balanceOf('a'), const Money(-334, usd));
      expect(sheet.balanceOf('b'), const Money(1000 - 333, usd));
      expect(sheet.balanceOf('c'), const Money(-333, usd));
      expect(sheet.isBalanced, isTrue);
    });

    test('payer not participating', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [
          expense(amountMinor: 500, paidBy: 'a', participants: ['b']),
        ],
        settlements: [],
      );
      expect(sheet.balanceOf('a'), const Money(500, usd));
      expect(sheet.balanceOf('b'), const Money(-500, usd));
    });

    test('full settlement zeroes balances', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'a', participants: ['a', 'b']),
        ],
        settlements: [settlement(from: 'b', to: 'a', amountMinor: 500)],
      );
      expect(sheet.isSettled, isTrue);
      expect(sheet.isBalanced, isTrue);
    });

    test('partial settlement leaves the remainder', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'a', participants: ['a', 'b']),
        ],
        settlements: [settlement(from: 'b', to: 'a', amountMinor: 200)],
      );
      expect(sheet.balanceOf('a'), const Money(300, usd));
      expect(sheet.balanceOf('b'), const Money(-300, usd));
    });

    test('over-settlement flips the direction (still conserved)', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'a', participants: ['a', 'b']),
        ],
        settlements: [settlement(from: 'b', to: 'a', amountMinor: 700)],
      );
      expect(sheet.balanceOf('a'), const Money(-200, usd));
      expect(sheet.balanceOf('b'), const Money(200, usd));
      expect(sheet.isBalanced, isTrue);
    });

    test('duplicate expenses count twice (ledger is literal, not deduplicated)', () {
      final e = expense(amountMinor: 1000, paidBy: 'a', participants: ['a', 'b']);
      final once = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [e],
        settlements: [],
      );
      final twice = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [e, e],
        settlements: [],
      );
      expect(twice.balanceOf('a'), once.balanceOf('a') * 2);
      expect(twice.isBalanced, isTrue);
    });

    test('duplicate settlements count twice', () {
      final s = settlement(from: 'b', to: 'a', amountMinor: 500);
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'a', participants: ['a', 'b']),
        ],
        settlements: [s, s],
      );
      expect(sheet.balanceOf('a'), const Money(-500, usd));
      expect(sheet.isBalanced, isTrue);
    });

    test('members referenced only by expenses still appear', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a']),
        expenses: [
          expense(amountMinor: 100, paidBy: 'a', participants: ['ghost']),
        ],
        settlements: [],
      );
      expect(sheet.balanceOf('ghost'), const Money(-100, usd));
      expect(sheet.isBalanced, isTrue);
    });
  });

  group('multi-currency', () {
    test('foreign expense converted once, shares allocated to conserve', () {
      // 1 EUR = 1.085 USD. €10.00 -> $10.85. The equal split is re-applied to
      // the converted total: 362, 362, 361 (not 3 × 3.6167 rounded, and not
      // weighted by the foreign-currency cents 334:333:333).
      final e = expense(
        amountMinor: 1000,
        currency: Currencies.eur,
        paidBy: 'a',
        participants: ['a', 'b', 'c'],
        rate: ConversionRate.parse('1.085'),
      );
      final converted = BalanceCalculator.convertExpense(e, usd);
      expect(converted.total, const Money(1085, usd));
      final shares = converted.shares.values.map((m) => m.minorUnits).toList();
      expect(shares.fold<int>(0, (a, b) => a + b), 1085);
      expect(shares, [362, 362, 361]);
      expect(BalanceCalculator.conservesValue(e, usd), isTrue);
    });

    test('missing rate on a foreign expense is an error, not a silent 1:1', () {
      final e = expense(amountMinor: 1000, currency: Currencies.eur, paidBy: 'a', participants: ['a', 'b']);
      expect(() => BalanceCalculator.convertExpense(e, usd), throwsA(isA<MissingConversionRateException>()));
    });

    test('settlement in a foreign currency uses its own rate', () {
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b']),
        expenses: [
          expense(amountMinor: 2000, paidBy: 'a', participants: ['a', 'b']),
        ],
        settlements: [
          settlement(
            from: 'b',
            to: 'a',
            amountMinor: 1000,
            currency: Currencies.eur,
            rate: ConversionRate.parse('1.0'),
          ),
        ],
      );
      expect(sheet.isSettled, isTrue);
    });

    test('zero-decimal and three-decimal currencies', () {
      final g = testGroup(currency: Currencies.jpy);
      final sheet = BalanceCalculator.compute(
        group: g,
        members: members(['a', 'b', 'c']),
        expenses: [
          expense(amountMinor: 1000, currency: Currencies.jpy, paidBy: 'a', participants: ['a', 'b', 'c']),
          // KD1.000 at 1 KWD = 490 JPY -> ¥490
          expense(
            amountMinor: 1000,
            currency: Currencies.kwd,
            paidBy: 'b',
            participants: ['a', 'b'],
            rate: ConversionRate.parse('490'),
          ),
        ],
        settlements: [],
      );
      expect(sheet.isBalanced, isTrue);
      expect(sheet.byMember['b']!.paid, const Money(490, Currencies.jpy));
    });
  });

  group('pairwise debts', () {
    test('direct debts between participants and payer', () {
      final debts = BalanceCalculator.pairwiseDebts(
        group: testGroup(),
        expenses: [
          expense(amountMinor: 3000, paidBy: 'a', participants: ['a', 'b', 'c']),
        ],
        settlements: [],
      );
      expect(debts.length, 2);
      expect(debts.every((t) => t.toMemberId == 'a' && t.amount == const Money(1000, usd)), isTrue);
    });

    test('opposite debts net out', () {
      final debts = BalanceCalculator.pairwiseDebts(
        group: testGroup(),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'a', participants: ['b']),
          expense(amountMinor: 400, paidBy: 'b', participants: ['a']),
        ],
        settlements: [],
      );
      expect(debts, [const Transfer(fromMemberId: 'b', toMemberId: 'a', amount: Money(600, usd))]);
    });

    test('settlements reduce pairwise debt', () {
      final debts = BalanceCalculator.pairwiseDebts(
        group: testGroup(),
        expenses: [
          expense(amountMinor: 1000, paidBy: 'a', participants: ['b']),
        ],
        settlements: [settlement(from: 'b', to: 'a', amountMinor: 1000)],
      );
      expect(debts, isEmpty);
    });

    test('pairwise debts and balances agree', () {
      final expenses = [
        expense(amountMinor: 1234, paidBy: 'a', participants: ['a', 'b', 'c']),
        expense(amountMinor: 999, paidBy: 'c', participants: ['b', 'c']),
        expense(amountMinor: 5, paidBy: 'b', participants: ['a']),
      ];
      final sheet = BalanceCalculator.compute(
        group: testGroup(),
        members: members(['a', 'b', 'c']),
        expenses: expenses,
        settlements: [],
      );
      final debts = BalanceCalculator.pairwiseDebts(group: testGroup(), expenses: expenses, settlements: []);
      final applied = DebtSimplifier.apply({
        for (final e in sheet.byMember.entries) e.key: e.value.balance.minorUnits,
      }, debts);
      expect(applied.values.every((v) => v == 0), isTrue);
    });
  });

  forAll('conservation: balances always sum to zero (random ledgers, mixed currencies)', (rng, _) {
    final base = rng.pick([Currencies.usd, Currencies.jpy, Currencies.kwd, Currencies.eur]);
    final g = testGroup(currency: base);
    final ids = List.generate(rng.intBetween(1, 8), (i) => 'm$i');
    final ms = members(ids);
    final expenses = <Expense>[];
    for (var i = 0; i < rng.intBetween(0, 25); i++) {
      final currency = rng.nextInt(4) == 0 ? rng.pick(Currencies.all) : base;
      final participants = ids.where((_) => rng.nextBool()).toList();
      if (participants.isEmpty) participants.add(rng.pick(ids));
      final type = rng.pick(SplitType.values);
      final amount = rng.intBetween(1, 2000000);
      List<SplitInput> inputs;
      switch (type) {
        case SplitType.equal:
          inputs = [for (final p in participants) SplitInput(p)];
        case SplitType.shares:
          inputs = [for (final p in participants) SplitInput(p, rng.intBetween(0, 9))];
          if (inputs.every((s) => s.value == 0)) inputs[0] = SplitInput(inputs[0].memberId, 1);
        case SplitType.percentage:
          final weights = [for (final _ in participants) rng.intBetween(1, 100)];
          final bps = allocateByWeights(10000, weights);
          inputs = [for (var k = 0; k < participants.length; k++) SplitInput(participants[k], bps[k])];
        case SplitType.exact:
          final parts = allocateByWeights(amount, [for (final _ in participants) rng.intBetween(1, 100)]);
          inputs = [for (var k = 0; k < participants.length; k++) SplitInput(participants[k], parts[k])];
      }
      final shares = ExpenseSplitter.computeShares(type: type, totalMinor: amount, inputs: inputs);
      expenses.add(
        expense(
          amountMinor: amount,
          currency: currency,
          paidBy: rng.pick(ids),
          participants: participants,
          splitType: type,
          shares: shares,
          rate: currency == base ? null : ConversionRate.fromScaled(rng.intBetween(1, 300000000)),
        ),
      );
    }
    final settlements = <Settlement>[];
    for (var i = 0; i < rng.intBetween(0, 10); i++) {
      final currency = rng.nextInt(4) == 0 ? rng.pick(Currencies.all) : base;
      settlements.add(
        settlement(
          from: rng.pick(ids),
          to: rng.pick(ids),
          amountMinor: rng.intBetween(1, 100000),
          currency: currency,
          rate: currency == base ? null : ConversionRate.fromScaled(rng.intBetween(1, 300000000)),
        ),
      );
    }
    final sheet = BalanceCalculator.compute(group: g, members: ms, expenses: expenses, settlements: settlements);
    expect(sheet.total.minorUnits, 0, reason: 'balances must sum to zero');
    for (final e in expenses) {
      expect(BalanceCalculator.conservesValue(e, base), isTrue, reason: 'expense ${e.id} must conserve value');
    }
    // Pairwise debts, applied to balances, must also zero them out.
    final debts = BalanceCalculator.pairwiseDebts(group: g, expenses: expenses, settlements: settlements);
    final applied = DebtSimplifier.apply({
      for (final e in sheet.byMember.entries) e.key: e.value.balance.minorUnits,
    }, debts);
    expect(applied.values.every((v) => v == 0), isTrue, reason: 'pairwise debts must reconcile with balances');
  });
}
