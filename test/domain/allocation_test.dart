import 'package:fairshare/domain/accounting/allocation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/property.dart';

int sum(List<int> xs) => xs.fold(0, (a, b) => a + b);

void main() {
  group('allocateEqually', () {
    test('splits evenly when divisible', () {
      expect(allocateEqually(900, 3), [300, 300, 300]);
    });

    test('hands the remainder to the first participants, one unit each', () {
      expect(allocateEqually(1000, 3), [334, 333, 333]);
      expect(allocateEqually(1001, 3), [334, 334, 333]);
      expect(allocateEqually(1, 3), [1, 0, 0]);
      expect(allocateEqually(2, 3), [1, 1, 0]);
    });

    test('handles zero and negative totals', () {
      expect(allocateEqually(0, 4), [0, 0, 0, 0]);
      expect(allocateEqually(-1000, 3), [-334, -333, -333]);
    });

    test('rejects zero participants', () {
      expect(() => allocateEqually(100, 0), throwsArgumentError);
    });

    forAll('conserves the total, parts differ by at most 1, deterministic', (rng, _) {
      final total = rng.intBetween(-1000000, 1000000);
      final n = rng.intBetween(1, 25);
      final parts = allocateEqually(total, n);
      expect(parts.length, n);
      expect(sum(parts), total);
      final mx = parts.reduce((a, b) => a > b ? a : b);
      final mn = parts.reduce((a, b) => a < b ? a : b);
      expect(mx - mn, lessThanOrEqualTo(1));
      expect(allocateEqually(total, n), parts);
    });
  });

  group('allocateByWeights', () {
    test('proportional when exact', () {
      expect(allocateByWeights(1000, [1, 1, 2]), [250, 250, 500]);
      expect(allocateByWeights(300, [1, 2]), [100, 200]);
    });

    test('largest remainder wins the leftover units', () {
      // 100 / (1,1,1) -> 33.33 each, leftover 1 -> first index by tie-break.
      expect(allocateByWeights(100, [1, 1, 1]), [34, 33, 33]);
      // 10 split 3:2:2 -> 4.29, 2.86, 2.86 -> floors 4,2,2 leftover 2 -> the
      // two .86 remainders win.
      expect(allocateByWeights(10, [3, 2, 2]), [4, 3, 3]);
    });

    test('zero weights receive nothing, even with leftovers', () {
      expect(allocateByWeights(101, [1, 0, 1]), [51, 0, 50]);
      expect(allocateByWeights(1, [0, 0, 1]), [0, 0, 1]);
    });

    test('negative totals mirror positive ones', () {
      expect(allocateByWeights(-100, [1, 1, 1]), [-34, -33, -33]);
    });

    test('rejects invalid weights', () {
      expect(() => allocateByWeights(100, []), throwsArgumentError);
      expect(() => allocateByWeights(100, [0, 0]), throwsArgumentError);
      expect(() => allocateByWeights(100, [1, -1]), throwsArgumentError);
    });

    test('does not overflow on large totals and weights', () {
      final parts = allocateByWeights(9000000000000000000, [1000000000, 1]);
      expect(sum(parts), 9000000000000000000);
    });

    forAll('conserves the total and stays within one unit of the exact share', (rng, _) {
      final total = rng.intBetween(-5000000, 5000000);
      final n = rng.intBetween(1, 12);
      final weights = List.generate(n, (_) => rng.intBetween(0, 50));
      if (weights.every((w) => w == 0)) weights[0] = 1;
      final parts = allocateByWeights(total, weights);
      expect(sum(parts), total);
      final w = sum(weights);
      for (var i = 0; i < n; i++) {
        final exact = total * weights[i] / w;
        expect(
          (parts[i] - exact).abs(),
          lessThan(1.0000001),
          reason: 'part $i of $parts for total $total weights $weights',
        );
        if (weights[i] == 0) expect(parts[i], 0);
      }
      expect(allocateByWeights(total, weights), parts, reason: 'deterministic');
    });
  });

  group('allocateByBasisPoints', () {
    test('splits 50/30/20', () {
      expect(allocateByBasisPoints(10000, [5000, 3000, 2000]), [5000, 3000, 2000]);
    });

    test('handles thirds', () {
      expect(allocateByBasisPoints(100, [3334, 3333, 3333]), [34, 33, 33]);
    });

    test('rejects percentages not summing to 100', () {
      expect(() => allocateByBasisPoints(100, [5000, 4000]), throwsArgumentError);
      expect(() => allocateByBasisPoints(100, [5000, 5001]), throwsArgumentError);
    });
  });

  group('allocateExactly', () {
    test('accepts exact sums', () {
      expect(allocateExactly(100, [60, 40]), [60, 40]);
      expect(allocateExactly(100, [100, 0]), [100, 0]);
    });

    test('rejects mismatched sums and sign mismatches', () {
      expect(() => allocateExactly(100, [60, 41]), throwsArgumentError);
      expect(() => allocateExactly(100, [160, -60]), throwsArgumentError);
      expect(() => allocateExactly(100, []), throwsArgumentError);
    });
  });
}
