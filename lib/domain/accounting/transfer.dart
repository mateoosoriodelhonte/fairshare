import 'package:meta/meta.dart';

import '../../core/money/money.dart';

/// A proposed or recorded movement of value from one member to another.
@immutable
class Transfer {
  const Transfer({required this.fromMemberId, required this.toMemberId, required this.amount});

  final String fromMemberId;
  final String toMemberId;
  final Money amount;

  @override
  bool operator ==(Object other) =>
      other is Transfer &&
      other.fromMemberId == fromMemberId &&
      other.toMemberId == toMemberId &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(fromMemberId, toMemberId, amount);

  @override
  String toString() => 'Transfer($fromMemberId -> $toMemberId: $amount)';
}
