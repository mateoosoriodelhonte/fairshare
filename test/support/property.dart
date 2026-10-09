import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

/// Minimal seeded property-testing helper.
///
/// Runs [body] [iterations] times with a deterministic [Random]. On failure
/// the seed and iteration are reported so the case can be reproduced.
void forAll(
  String description,
  void Function(Random rng, int iteration) body, {
  int iterations = 300,
  int seed = 20261009,
}) {
  test(description, () {
    for (var i = 0; i < iterations; i++) {
      final rng = Random(seed + i);
      try {
        body(rng, i);
      } catch (e) {
        // ignore: only_throw_errors
        throw TestFailure('Property failed at iteration $i (seed ${seed + i}): $e');
      }
    }
  });
}

extension RandomExt on Random {
  /// Inclusive range.
  int intBetween(int min, int max) {
    final span = max - min + 1;
    if (span <= 0xFFFFFFFF) return min + nextInt(span);
    final hi = nextInt(1 << 21);
    final lo = nextInt(1 << 32);
    return min + ((hi << 32) | lo) % span;
  }

  T pick<T>(List<T> items) => items[nextInt(items.length)];
}
