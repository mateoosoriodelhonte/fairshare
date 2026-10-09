import '../models/expense_share.dart';
import '../models/split_type.dart';
import 'allocation.dart';

/// Raw user input for one participant in the expense editor.
class SplitInput {
  const SplitInput(this.memberId, [this.value]);

  final String memberId;

  /// Meaning depends on the split type: basis points, share count, or exact
  /// minor units. Ignored for equal splits.
  final int? value;
}

/// A human readable validation failure from [ExpenseSplitter].
class SplitValidationException implements Exception {
  const SplitValidationException(this.message);

  final String message;

  @override
  String toString() => 'SplitValidationException: $message';
}

/// Turns the user's split choice into concrete per-member amounts.
///
/// This is the single place where a split's rounding policy is decided; the
/// resulting [ExpenseShare]s are persisted so balances never need to redo it.
class ExpenseSplitter {
  const ExpenseSplitter._();

  static List<ExpenseShare> computeShares({
    required SplitType type,
    required int totalMinor,
    required List<SplitInput> inputs,
  }) {
    if (totalMinor <= 0) {
      throw const SplitValidationException('Amount must be greater than zero.');
    }
    if (inputs.isEmpty) {
      throw const SplitValidationException('Choose at least one person to split with.');
    }
    final ids = inputs.map((i) => i.memberId).toSet();
    if (ids.length != inputs.length) {
      throw const SplitValidationException('A person can only appear once in a split.');
    }

    switch (type) {
      case SplitType.equal:
        final parts = allocateEqually(totalMinor, inputs.length);
        return [
          for (var i = 0; i < inputs.length; i++) ExpenseShare(memberId: inputs[i].memberId, amountMinor: parts[i]),
        ];

      case SplitType.percentage:
        final bps = <int>[];
        for (final input in inputs) {
          final v = input.value;
          if (v == null || v < 0) {
            throw const SplitValidationException('Every percentage must be zero or more.');
          }
          bps.add(v);
        }
        final sum = bps.fold<int>(0, (a, b) => a + b);
        if (sum != basisPointsPer100Percent) {
          final pct = (sum / 100).toStringAsFixed(sum % 100 == 0 ? 0 : 2);
          throw SplitValidationException('Percentages must add up to 100% (currently $pct%).');
        }
        final parts = allocateByBasisPoints(totalMinor, bps);
        return [
          for (var i = 0; i < inputs.length; i++)
            ExpenseShare(memberId: inputs[i].memberId, amountMinor: parts[i], splitValue: bps[i]),
        ];

      case SplitType.shares:
        final weights = <int>[];
        for (final input in inputs) {
          final v = input.value;
          if (v == null || v < 0) {
            throw const SplitValidationException('Every share count must be zero or more.');
          }
          weights.add(v);
        }
        if (weights.every((w) => w == 0)) {
          throw const SplitValidationException('At least one person needs a share.');
        }
        final parts = allocateByWeights(totalMinor, weights);
        return [
          for (var i = 0; i < inputs.length; i++)
            ExpenseShare(memberId: inputs[i].memberId, amountMinor: parts[i], splitValue: weights[i]),
        ];

      case SplitType.exact:
        final amounts = <int>[];
        for (final input in inputs) {
          final v = input.value;
          if (v == null || v < 0) {
            throw const SplitValidationException('Every amount must be zero or more.');
          }
          amounts.add(v);
        }
        final sum = amounts.fold<int>(0, (a, b) => a + b);
        if (sum != totalMinor) {
          throw SplitValidationException(
            sum < totalMinor
                ? 'Amounts fall short of the total by ${totalMinor - sum} minor units.'
                : 'Amounts exceed the total by ${sum - totalMinor} minor units.',
          );
        }
        final parts = allocateExactly(totalMinor, amounts);
        return [
          for (var i = 0; i < inputs.length; i++)
            ExpenseShare(memberId: inputs[i].memberId, amountMinor: parts[i], splitValue: amounts[i]),
        ];
    }
  }
}
