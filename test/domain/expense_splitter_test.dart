import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  int total(List<ExpenseShare> shares) => shares.fold(0, (a, s) => a + s.amountMinor);

  group('ExpenseSplitter', () {
    test('equal split with remainder', () {
      final shares = ExpenseSplitter.computeShares(
        type: SplitType.equal,
        totalMinor: 1000,
        inputs: const [SplitInput('a'), SplitInput('b'), SplitInput('c')],
      );
      expect(shares.map((s) => s.amountMinor), [334, 333, 333]);
      expect(shares.map((s) => s.memberId), ['a', 'b', 'c']);
      expect(total(shares), 1000);
    });

    test('percentage split stores basis points as splitValue', () {
      final shares = ExpenseSplitter.computeShares(
        type: SplitType.percentage,
        totalMinor: 5000,
        inputs: const [SplitInput('a', 7000), SplitInput('b', 3000)],
      );
      expect(shares.map((s) => s.amountMinor), [3500, 1500]);
      expect(shares.map((s) => s.splitValue), [7000, 3000]);
    });

    test('percentage must sum to 100%', () {
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.percentage,
          totalMinor: 5000,
          inputs: const [SplitInput('a', 7000), SplitInput('b', 2000)],
        ),
        throwsA(isA<SplitValidationException>().having((e) => e.message, 'message', contains('90%'))),
      );
    });

    test('shares split', () {
      final shares = ExpenseSplitter.computeShares(
        type: SplitType.shares,
        totalMinor: 900,
        inputs: const [SplitInput('a', 2), SplitInput('b', 1), SplitInput('c', 0)],
      );
      expect(shares.map((s) => s.amountMinor), [600, 300, 0]);
      expect(total(shares), 900);
    });

    test('shares require at least one positive share', () {
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.shares,
          totalMinor: 900,
          inputs: const [SplitInput('a', 0), SplitInput('b', 0)],
        ),
        throwsA(isA<SplitValidationException>()),
      );
    });

    test('exact split must match total', () {
      final ok = ExpenseSplitter.computeShares(
        type: SplitType.exact,
        totalMinor: 900,
        inputs: const [SplitInput('a', 500), SplitInput('b', 400)],
      );
      expect(ok.map((s) => s.amountMinor), [500, 400]);
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.exact,
          totalMinor: 900,
          inputs: const [SplitInput('a', 500), SplitInput('b', 300)],
        ),
        throwsA(isA<SplitValidationException>().having((e) => e.message, 'message', contains('short'))),
      );
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.exact,
          totalMinor: 900,
          inputs: const [SplitInput('a', 500), SplitInput('b', 500)],
        ),
        throwsA(isA<SplitValidationException>().having((e) => e.message, 'message', contains('exceed'))),
      );
    });

    test('rejects zero, negative totals, no participants, duplicates, negatives', () {
      expect(
        () => ExpenseSplitter.computeShares(type: SplitType.equal, totalMinor: 0, inputs: const [SplitInput('a')]),
        throwsA(isA<SplitValidationException>()),
      );
      expect(
        () => ExpenseSplitter.computeShares(type: SplitType.equal, totalMinor: -100, inputs: const [SplitInput('a')]),
        throwsA(isA<SplitValidationException>()),
      );
      expect(
        () => ExpenseSplitter.computeShares(type: SplitType.equal, totalMinor: 100, inputs: const []),
        throwsA(isA<SplitValidationException>()),
      );
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.equal,
          totalMinor: 100,
          inputs: const [SplitInput('a'), SplitInput('a')],
        ),
        throwsA(isA<SplitValidationException>()),
      );
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.exact,
          totalMinor: 100,
          inputs: const [SplitInput('a', 150), SplitInput('b', -50)],
        ),
        throwsA(isA<SplitValidationException>()),
      );
      expect(
        () => ExpenseSplitter.computeShares(
          type: SplitType.percentage,
          totalMinor: 100,
          inputs: const [SplitInput('a'), SplitInput('b', 10000)],
        ),
        throwsA(isA<SplitValidationException>()),
      );
    });
  });
}
