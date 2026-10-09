import 'dart:math' as math;

import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import 'transfer.dart';

/// Reduces a set of balances to a small list of transfers that settles
/// everyone exactly.
///
/// Guarantees (all covered by tests):
/// * Applying the returned transfers brings every balance to exactly zero.
/// * Every transfer is strictly positive and goes from a member with a
///   negative balance to a member with a positive balance.
/// * The number of transfers is at most `k - 1`, where `k` is the number of
///   members with a non-zero balance.
///
/// Non-guarantee, stated plainly: this is **not** proven to produce the
/// minimum possible number of transfers. Finding that minimum is equivalent
/// to a subset-sum partitioning problem and is NP-hard in general. The
/// algorithm does an exact-match pass (which pairs off any debtor whose debt
/// exactly equals a creditor's credit) and then a greedy largest-first
/// matching, which in practice gives a short, intuitive list.
class DebtSimplifier {
  const DebtSimplifier._();

  static List<Transfer> simplify(Map<String, int> balances, Currency currency) {
    final total = balances.values.fold<int>(0, (a, b) => a + b);
    if (total != 0) {
      throw ArgumentError.value(balances, 'balances', 'must sum to zero (got $total)');
    }

    // Stable, deterministic ordering: by magnitude desc, then id asc.
    int byMagnitudeThenId(MapEntry<String, int> a, MapEntry<String, int> b) {
      final cmp = b.value.abs().compareTo(a.value.abs());
      return cmp != 0 ? cmp : a.key.compareTo(b.key);
    }

    final creditors = balances.entries.where((e) => e.value > 0).map((e) => _Party(e.key, e.value)).toList()
      ..sort((a, b) => byMagnitudeThenId(MapEntry(a.id, a.amount), MapEntry(b.id, b.amount)));
    final debtors = balances.entries.where((e) => e.value < 0).map((e) => _Party(e.key, -e.value)).toList()
      ..sort((a, b) => byMagnitudeThenId(MapEntry(a.id, a.amount), MapEntry(b.id, b.amount)));

    final transfers = <Transfer>[];

    // Pass 1: exact matches. Each one settles two people with one transfer,
    // which the greedy pass alone might not find.
    final creditByAmount = <int, List<_Party>>{};
    for (final c in creditors) {
      creditByAmount.putIfAbsent(c.amount, () => []).add(c);
    }
    for (final d in debtors) {
      final bucket = creditByAmount[d.amount];
      if (bucket != null && bucket.isNotEmpty) {
        final c = bucket.removeAt(0);
        transfers.add(Transfer(fromMemberId: d.id, toMemberId: c.id, amount: Money(d.amount, currency)));
        d.amount = 0;
        c.amount = 0;
      }
    }

    // Pass 2: greedy largest-first matching on whatever remains.
    final remainingCreditors = creditors.where((c) => c.amount > 0).toList();
    final remainingDebtors = debtors.where((d) => d.amount > 0).toList();
    var i = 0;
    var j = 0;
    while (i < remainingCreditors.length && j < remainingDebtors.length) {
      final c = remainingCreditors[i];
      final d = remainingDebtors[j];
      final x = math.min(c.amount, d.amount);
      transfers.add(Transfer(fromMemberId: d.id, toMemberId: c.id, amount: Money(x, currency)));
      c.amount -= x;
      d.amount -= x;
      if (c.amount == 0) i++;
      if (d.amount == 0) j++;
    }
    assert(i == remainingCreditors.length && j == remainingDebtors.length, 'greedy matching must exhaust both sides');
    return transfers;
  }

  /// Applies [transfers] to [balances] and returns the resulting balances.
  /// Paying reduces the payer's debt (raises their balance) and lowers the
  /// receiver's credit.
  static Map<String, int> apply(Map<String, int> balances, List<Transfer> transfers) {
    final result = Map<String, int>.of(balances);
    for (final t in transfers) {
      result[t.fromMemberId] = (result[t.fromMemberId] ?? 0) + t.amount.minorUnits;
      result[t.toMemberId] = (result[t.toMemberId] ?? 0) - t.amount.minorUnits;
    }
    return result;
  }
}

class _Party {
  _Party(this.id, this.amount);

  final String id;
  int amount;
}
