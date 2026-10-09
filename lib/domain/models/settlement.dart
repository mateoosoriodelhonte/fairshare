import 'package:meta/meta.dart';

import '../../core/money/conversion_rate.dart';
import '../../core/money/money.dart';

/// A record that [fromMemberId] handed [amount] to [toMemberId] outside the
/// app (cash, bank transfer, whatever). FairShare never moves money itself.
@immutable
class Settlement {
  const Settlement({
    required this.id,
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.conversionRate,
    this.note,
  });

  final String id;
  final String groupId;
  final String fromMemberId;
  final String toMemberId;
  final Money amount;

  /// Rate to the group's base currency when [amount] is in another currency.
  final ConversionRate? conversionRate;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  Settlement copyWith({
    String? fromMemberId,
    String? toMemberId,
    Money? amount,
    ConversionRate? conversionRate,
    bool clearConversionRate = false,
    DateTime? date,
    String? note,
    bool clearNote = false,
  }) => Settlement(
    id: id,
    groupId: groupId,
    fromMemberId: fromMemberId ?? this.fromMemberId,
    toMemberId: toMemberId ?? this.toMemberId,
    amount: amount ?? this.amount,
    conversionRate: clearConversionRate ? null : (conversionRate ?? this.conversionRate),
    date: date ?? this.date,
    note: clearNote ? null : (note ?? this.note),
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Settlement &&
      other.id == id &&
      other.groupId == groupId &&
      other.fromMemberId == fromMemberId &&
      other.toMemberId == toMemberId &&
      other.amount == amount &&
      other.conversionRate == conversionRate &&
      other.date == date &&
      other.note == note &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, groupId, fromMemberId, toMemberId, amount, conversionRate, date, note, createdAt);

  @override
  String toString() => 'Settlement($fromMemberId -> $toMemberId: $amount)';
}
