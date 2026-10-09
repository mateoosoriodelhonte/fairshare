/// Integer allocation primitives.
///
/// Every function here takes an integer total (in minor units) and returns a
/// list of integers that sums *exactly* to that total. Remainders that cannot
/// be divided evenly are distributed deterministically, one minor unit at a
/// time, so repeated runs on the same input yield the same output.
///
/// Intermediate products use [BigInt] so very large totals or weights cannot
/// overflow 64-bit integers.
library;

/// Splits [total] into [count] parts that differ by at most one minor unit.
///
/// The first `total mod count` parts receive the extra unit. For a negative
/// total the absolute value is split and the signs flipped, so the "extra"
/// unit is always applied to the earliest participants in both directions.
List<int> allocateEqually(int total, int count) {
  if (count <= 0) {
    throw ArgumentError.value(count, 'count', 'must be positive');
  }
  final sign = total < 0 ? -1 : 1;
  final abs = total.abs();
  final base = abs ~/ count;
  final remainder = abs % count;
  return List<int>.generate(count, (i) => sign * (base + (i < remainder ? 1 : 0)), growable: false);
}

/// Splits [total] proportionally to [weights] using the largest-remainder
/// (Hamilton) method.
///
/// Each part is first assigned `floor(total * w / sumWeights)`; the leftover
/// units are then handed, one each, to the parts with the largest fractional
/// remainders (ties broken by lower index). The result sums exactly to
/// [total] and each part is within one unit of its exact proportional value.
///
/// Weights must be non-negative and sum to a positive number.
List<int> allocateByWeights(int total, List<int> weights) {
  if (weights.isEmpty) {
    throw ArgumentError.value(weights, 'weights', 'must not be empty');
  }
  var weightSum = BigInt.zero;
  for (final w in weights) {
    if (w < 0) {
      throw ArgumentError.value(w, 'weights', 'must be non-negative');
    }
    weightSum += BigInt.from(w);
  }
  if (weightSum == BigInt.zero) {
    throw ArgumentError.value(weights, 'weights', 'must sum to a positive number');
  }

  final sign = total < 0 ? -1 : 1;
  final absTotal = BigInt.from(total.abs());
  final floors = List<int>.filled(weights.length, 0);
  final remainders = List<BigInt>.filled(weights.length, BigInt.zero);
  var allocated = BigInt.zero;
  for (var i = 0; i < weights.length; i++) {
    final product = absTotal * BigInt.from(weights[i]);
    final q = product ~/ weightSum;
    floors[i] = q.toInt();
    remainders[i] = product - q * weightSum;
    allocated += q;
  }
  var leftover = (absTotal - allocated).toInt();

  // Indices sorted by descending remainder, then ascending index for ties.
  final order = List<int>.generate(weights.length, (i) => i)
    ..sort((a, b) {
      final cmp = remainders[b].compareTo(remainders[a]);
      return cmp != 0 ? cmp : a.compareTo(b);
    });
  for (final i in order) {
    if (leftover == 0) break;
    // Only parts with positive weight may receive remainder units; a zero
    // weight always has a zero remainder so it is never reached first, but we
    // guard explicitly to make the invariant obvious.
    if (weights[i] == 0) continue;
    floors[i] += 1;
    leftover -= 1;
  }
  assert(leftover == 0);
  return List<int>.generate(weights.length, (i) => sign * floors[i], growable: false);
}

/// Total basis points in 100%.
const int basisPointsPer100Percent = 10000;

/// Splits [total] by percentages expressed in basis points (1% = 100 bp).
/// The basis points must sum to exactly [basisPointsPer100Percent].
List<int> allocateByBasisPoints(int total, List<int> basisPoints) {
  final sum = basisPoints.fold<int>(0, (acc, bp) => acc + bp);
  if (sum != basisPointsPer100Percent) {
    throw ArgumentError.value(basisPoints, 'basisPoints', 'must sum to $basisPointsPer100Percent (100%), got $sum');
  }
  return allocateByWeights(total, basisPoints);
}

/// Validates an explicit allocation: all parts non-negative (for a positive
/// total) and summing exactly to [total]. Returns a copy of [amounts].
List<int> allocateExactly(int total, List<int> amounts) {
  if (amounts.isEmpty) {
    throw ArgumentError.value(amounts, 'amounts', 'must not be empty');
  }
  final sum = amounts.fold<int>(0, (acc, a) => acc + a);
  if (sum != total) {
    throw ArgumentError.value(amounts, 'amounts', 'must sum to $total, got $sum');
  }
  for (final a in amounts) {
    if (total >= 0 && a < 0 || total < 0 && a > 0) {
      throw ArgumentError.value(a, 'amounts', 'must have the same sign as the total');
    }
  }
  return List<int>.of(amounts, growable: false);
}
