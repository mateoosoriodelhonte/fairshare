import 'package:meta/meta.dart';

import '../../core/money/conversion_rate.dart';
import '../../core/money/currency.dart';
import '../../core/money/money.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../models/settlement.dart';
import '../models/split_type.dart';
import 'allocation.dart';
import 'transfer.dart';

/// Thrown when an expense or settlement in a foreign currency has no rate to
/// the group's base currency. Data written through the app always carries a
/// rate; this guards imported or hand-edited data.
class MissingConversionRateException implements Exception {
  const MissingConversionRateException(this.entityId, this.from, this.to);

  final String entityId;
  final Currency from;
  final Currency to;

  @override
  String toString() => 'Missing conversion rate for $entityId: $from -> $to';
}

/// Exact accounting position of one member, in the group's base currency.
///
/// `balance = paid + settledOut - owed - settledIn`
///
/// A positive balance means the group owes this member; negative means this
/// member owes the group.
@immutable
class MemberBalance {
  const MemberBalance({
    required this.memberId,
    required this.paid,
    required this.owed,
    required this.settledOut,
    required this.settledIn,
  });

  final String memberId;

  /// Total of expenses this member paid for.
  final Money paid;

  /// Total of expense shares attributed to this member.
  final Money owed;

  /// Total this member handed to others in recorded settlements.
  final Money settledOut;

  /// Total this member received in recorded settlements.
  final Money settledIn;

  Money get balance => paid + settledOut - owed - settledIn;

  /// What this member spent for their own consumption: their own shares.
  Money get consumed => owed;
}

/// Balance sheet for a whole group, in the group's base currency.
@immutable
class BalanceSheet {
  BalanceSheet({required this.currency, required Map<String, MemberBalance> byMember})
    : byMember = Map.unmodifiable(byMember);

  final Currency currency;
  final Map<String, MemberBalance> byMember;

  Money balanceOf(String memberId) => byMember[memberId]?.balance ?? Money.zero(currency);

  /// Sum of all balances. Always zero for a consistent ledger (every unit
  /// paid is a unit owed, and every settlement moves value between two
  /// members). Exposed for tests and diagnostics.
  Money get total => Money.sum(byMember.values.map((b) => b.balance), currency);

  bool get isBalanced => total.isZero;

  Money get totalSpent => Money.sum(byMember.values.map((b) => b.paid), currency);

  bool get isSettled => byMember.values.every((b) => b.balance.isZero);

  List<MemberBalance> get creditors =>
      byMember.values.where((b) => b.balance.isPositive).toList()..sort((a, b) => b.balance.compareTo(a.balance));

  List<MemberBalance> get debtors =>
      byMember.values.where((b) => b.balance.isNegative).toList()..sort((a, b) => a.balance.compareTo(b.balance));
}

/// An expense re-expressed in the group's base currency with per-member
/// shares that sum exactly to the converted total.
@immutable
class ConvertedExpense {
  const ConvertedExpense({required this.expense, required this.total, required this.shares});

  final Expense expense;
  final Money total;
  final Map<String, Money> shares;
}

/// Pure functions that turn a group's expenses and settlements into exact
/// balances. No rounding happens here except inside foreign-currency
/// conversion, which is performed once per expense on its total and then
/// allocated with the largest-remainder method so conservation holds.
class BalanceCalculator {
  const BalanceCalculator._();

  /// Converts an expense to [base]. Same-currency expenses pass through with
  /// their stored shares; foreign ones are converted once on the total and
  /// the converted total is allocated proportionally to the original shares.
  static ConvertedExpense convertExpense(Expense expense, Currency base) {
    if (expense.amount.currency == base) {
      return ConvertedExpense(
        expense: expense,
        total: expense.amount,
        shares: {for (final s in expense.shares) s.memberId: Money(s.amountMinor, base)},
      );
    }
    final rate = expense.conversionRate;
    if (rate == null) {
      throw MissingConversionRateException(expense.id, expense.amount.currency, base);
    }
    final total = rate.convert(expense.amount, base);
    final weights = _conversionWeights(expense);
    final List<int> parts;
    if (weights.every((w) => w == 0) || total.isZero) {
      parts = List<int>.filled(weights.length, 0);
    } else {
      parts = allocateByWeights(total.minorUnits, weights);
    }
    return ConvertedExpense(
      expense: expense,
      total: total,
      shares: {for (var i = 0; i < expense.shares.length; i++) expense.shares[i].memberId: Money(parts[i], base)},
    );
  }

  /// Weights used to allocate a converted total. The original split rule is
  /// re-applied in the base currency: an equal split stays equal (rather
  /// than inheriting foreign-currency rounding), percentages and share counts
  /// are reused verbatim, and exact amounts are scaled proportionally.
  static List<int> _conversionWeights(Expense expense) {
    final shares = expense.shares;
    switch (expense.splitType) {
      case SplitType.equal:
        return List<int>.filled(shares.length, 1);
      case SplitType.percentage:
      case SplitType.shares:
        final values = shares.map((s) => s.splitValue).toList();
        if (values.every((v) => v != null) && values.any((v) => v! > 0)) {
          return values.cast<int>();
        }
        return shares.map((s) => s.amountMinor).toList();
      case SplitType.exact:
        return shares.map((s) => s.amountMinor).toList();
    }
  }

  static Money convertSettlement(Settlement settlement, Currency base) {
    if (settlement.amount.currency == base) return settlement.amount;
    final rate = settlement.conversionRate;
    if (rate == null) {
      throw MissingConversionRateException(settlement.id, settlement.amount.currency, base);
    }
    return rate.convert(settlement.amount, base);
  }

  /// Computes the exact balance sheet. Members with no activity appear with
  /// zero balances so the UI can list everyone.
  static BalanceSheet compute({
    required Group group,
    required List<Member> members,
    required List<Expense> expenses,
    required List<Settlement> settlements,
  }) {
    final base = group.baseCurrency;
    final paid = <String, int>{};
    final owed = <String, int>{};
    final settledOut = <String, int>{};
    final settledIn = <String, int>{};
    for (final m in members) {
      paid[m.id] = 0;
      owed[m.id] = 0;
      settledOut[m.id] = 0;
      settledIn[m.id] = 0;
    }

    for (final e in expenses) {
      final converted = convertExpense(e, base);
      paid[e.paidByMemberId] = (paid[e.paidByMemberId] ?? 0) + converted.total.minorUnits;
      converted.shares.forEach((memberId, share) {
        owed[memberId] = (owed[memberId] ?? 0) + share.minorUnits;
      });
    }
    for (final s in settlements) {
      final amount = convertSettlement(s, base).minorUnits;
      settledOut[s.fromMemberId] = (settledOut[s.fromMemberId] ?? 0) + amount;
      settledIn[s.toMemberId] = (settledIn[s.toMemberId] ?? 0) + amount;
    }

    final ids = <String>{...paid.keys, ...owed.keys, ...settledOut.keys, ...settledIn.keys};
    return BalanceSheet(
      currency: base,
      byMember: {
        for (final id in ids)
          id: MemberBalance(
            memberId: id,
            paid: Money(paid[id] ?? 0, base),
            owed: Money(owed[id] ?? 0, base),
            settledOut: Money(settledOut[id] ?? 0, base),
            settledIn: Money(settledIn[id] ?? 0, base),
          ),
      },
    );
  }

  /// Exact pairwise debts: for every expense, each participant other than the
  /// payer owes the payer their share; settlements reduce the debt in the
  /// direction they were paid. Opposite debts between the same two people are
  /// netted so each pair appears at most once.
  ///
  /// This is the "who actually owes whom" view. It is *not* optimised; see
  /// [DebtSimplifier] for a reduced transfer set.
  static List<Transfer> pairwiseDebts({
    required Group group,
    required List<Expense> expenses,
    required List<Settlement> settlements,
  }) {
    final base = group.baseCurrency;
    // Keyed by (debtor, creditor) with debtor < creditor lexicographically to
    // keep a single entry per pair; sign encodes direction.
    final net = <String, int>{};
    void add(String from, String to, int amount) {
      if (from == to || amount == 0) return;
      final ordered = from.compareTo(to) < 0;
      final key = ordered ? '$from|$to' : '$to|$from';
      net[key] = (net[key] ?? 0) + (ordered ? amount : -amount);
    }

    for (final e in expenses) {
      final converted = convertExpense(e, base);
      converted.shares.forEach((memberId, share) {
        if (memberId != e.paidByMemberId) add(memberId, e.paidByMemberId, share.minorUnits);
      });
    }
    for (final s in settlements) {
      final amount = convertSettlement(s, base).minorUnits;
      // Paying someone reduces what you owe them (or creates a debt from them).
      add(s.toMemberId, s.fromMemberId, amount);
    }

    final result = <Transfer>[];
    net.forEach((key, value) {
      if (value == 0) return;
      final parts = key.split('|');
      if (value > 0) {
        result.add(Transfer(fromMemberId: parts[0], toMemberId: parts[1], amount: Money(value, base)));
      } else {
        result.add(Transfer(fromMemberId: parts[1], toMemberId: parts[0], amount: Money(-value, base)));
      }
    });
    result.sort((a, b) {
      final cmp = b.amount.compareTo(a.amount);
      return cmp != 0 ? cmp : a.fromMemberId.compareTo(b.fromMemberId);
    });
    return result;
  }

  /// Verifies conservation: converting and allocating must never create or
  /// destroy value. Used by tests and the import validator.
  static bool conservesValue(Expense e, Currency base) {
    final c = convertExpense(e, base);
    final sum = c.shares.values.fold<int>(0, (acc, m) => acc + m.minorUnits);
    return sum == c.total.minorUnits;
  }

  /// Convenience for UIs that need a rate-aware conversion of an arbitrary
  /// amount, e.g. previewing an expense before it is saved.
  static Money toBase(Money amount, Currency base, ConversionRate? rate) {
    if (amount.currency == base) return amount;
    if (rate == null) {
      throw MissingConversionRateException('preview', amount.currency, base);
    }
    return rate.convert(amount, base);
  }
}
