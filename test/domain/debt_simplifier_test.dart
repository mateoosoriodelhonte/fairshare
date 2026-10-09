import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/property.dart';

void main() {
  const usd = Currencies.usd;

  group('DebtSimplifier.simplify', () {
    test('no transfers when everyone is settled', () {
      expect(DebtSimplifier.simplify({'a': 0, 'b': 0}, usd), isEmpty);
      expect(DebtSimplifier.simplify({}, usd), isEmpty);
    });

    test('two people: single transfer', () {
      final t = DebtSimplifier.simplify({'a': 500, 'b': -500}, usd);
      expect(t, [const Transfer(fromMemberId: 'b', toMemberId: 'a', amount: Money(500, usd))]);
    });

    test('chain a->b->c collapses to one transfer', () {
      // a is owed 10 by b, b is owed 10 by c => balances a:+10, b:0, c:-10.
      final t = DebtSimplifier.simplify({'a': 1000, 'b': 0, 'c': -1000}, usd);
      expect(t, [const Transfer(fromMemberId: 'c', toMemberId: 'a', amount: Money(1000, usd))]);
    });

    test('exact matches are paired first', () {
      // Greedy-only would do: d1(-70)->c1(+100) 70, d2(-30)->c1 30, d3(-50)->c2(+50) 50 => 3 transfers.
      // Exact matching finds d3<->c2 first, then greedy for the rest: still 3, but
      // with {c1:+50, c2:+30, d1:-50, d2:-30} exact matching yields 2 transfers.
      final t = DebtSimplifier.simplify({'c1': 50, 'c2': 30, 'd1': -50, 'd2': -30}, usd);
      expect(t.length, 2);
      expect(
        t,
        containsAll([
          const Transfer(fromMemberId: 'd1', toMemberId: 'c1', amount: Money(50, usd)),
          const Transfer(fromMemberId: 'd2', toMemberId: 'c2', amount: Money(30, usd)),
        ]),
      );
    });

    test('rejects unbalanced input', () {
      expect(() => DebtSimplifier.simplify({'a': 1, 'b': 0}, usd), throwsArgumentError);
    });

    test('at most k-1 transfers for k non-zero members', () {
      final t = DebtSimplifier.simplify({'a': 300, 'b': 200, 'c': -100, 'd': -400, 'e': 0}, usd);
      expect(t.length, lessThanOrEqualTo(3));
      final applied = DebtSimplifier.apply({'a': 300, 'b': 200, 'c': -100, 'd': -400, 'e': 0}, t);
      expect(applied.values.every((v) => v == 0), isTrue);
    });

    test('is deterministic', () {
      final balances = {'z': 10, 'y': 10, 'x': -5, 'w': -15};
      expect(DebtSimplifier.simplify(balances, usd), DebtSimplifier.simplify(Map.of(balances), usd));
    });

    forAll('settles everyone exactly with ≤ k−1 positive debtor→creditor transfers', (rng, _) {
      final n = rng.intBetween(1, 15);
      final balances = <String, int>{};
      var running = 0;
      for (var i = 0; i < n - 1; i++) {
        final v = rng.intBetween(-100000, 100000);
        balances['m$i'] = v;
        running += v;
      }
      balances['m${n - 1}'] = -running; // force conservation
      final transfers = DebtSimplifier.simplify(balances, usd);
      final nonZero = balances.values.where((v) => v != 0).length;
      expect(transfers.length, lessThanOrEqualTo(nonZero == 0 ? 0 : nonZero - 1));
      for (final t in transfers) {
        expect(t.amount.isPositive, isTrue);
        expect(t.fromMemberId, isNot(t.toMemberId));
        expect(balances[t.fromMemberId]!, lessThan(0), reason: 'transfers come from debtors');
        expect(balances[t.toMemberId]!, greaterThan(0), reason: 'transfers go to creditors');
      }
      final applied = DebtSimplifier.apply(balances, transfers);
      expect(
        applied.values.every((v) => v == 0),
        isTrue,
        reason: 'all balances must be zero after applying $transfers to $balances',
      );
      // Nobody pays more than they owed in total.
      final paidBy = <String, int>{};
      for (final t in transfers) {
        paidBy[t.fromMemberId] = (paidBy[t.fromMemberId] ?? 0) + t.amount.minorUnits;
      }
      paidBy.forEach((id, paid) => expect(paid, -balances[id]!));
    });
  });
}
