import 'package:meta/meta.dart';

/// One participant's slice of an expense.
///
/// [amountMinor] is the computed amount in the *expense's* currency. It is
/// always materialised when the expense is saved, so balances never depend on
/// re-running a split algorithm. [splitValue] is the raw input the user
/// typed for the chosen split type (basis points, share count or exact minor
/// units) and exists only so the editor can be re-opened faithfully.
@immutable
class ExpenseShare {
  const ExpenseShare({required this.memberId, required this.amountMinor, this.splitValue});

  final String memberId;
  final int amountMinor;
  final int? splitValue;

  ExpenseShare copyWith({int? amountMinor, int? splitValue}) => ExpenseShare(
    memberId: memberId,
    amountMinor: amountMinor ?? this.amountMinor,
    splitValue: splitValue ?? this.splitValue,
  );

  @override
  bool operator ==(Object other) =>
      other is ExpenseShare &&
      other.memberId == memberId &&
      other.amountMinor == amountMinor &&
      other.splitValue == splitValue;

  @override
  int get hashCode => Object.hash(memberId, amountMinor, splitValue);

  @override
  String toString() => 'ExpenseShare($memberId: $amountMinor)';
}
