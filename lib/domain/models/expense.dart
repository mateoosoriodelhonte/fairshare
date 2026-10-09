import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../core/money/conversion_rate.dart';
import '../../core/money/money.dart';
import 'expense_category.dart';
import 'expense_share.dart';
import 'split_type.dart';

/// A single purchase paid by one member on behalf of some participants.
@immutable
class Expense {
  Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidByMemberId,
    required this.category,
    required this.date,
    required this.splitType,
    required List<ExpenseShare> shares,
    required this.createdAt,
    required this.updatedAt,
    this.conversionRate,
    this.notes,
    this.recurringTemplateId,
  }) : shares = List.unmodifiable(shares);

  final String id;
  final String groupId;
  final String description;

  /// Total in the expense's own currency (which may differ from the group's).
  final Money amount;
  final String paidByMemberId;
  final ExpenseCategory category;

  /// Calendar date of the purchase (time component is ignored for display).
  final DateTime date;
  final SplitType splitType;

  /// Participants and their computed shares. Shares sum exactly to [amount].
  final List<ExpenseShare> shares;

  /// Rate from [amount.currency] to the group's base currency. Null when the
  /// expense is already in the base currency.
  final ConversionRate? conversionRate;
  final String? notes;

  /// Set when the expense was generated from a recurring template.
  final String? recurringTemplateId;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get participantCount => shares.length;

  bool participates(String memberId) => shares.any((s) => s.memberId == memberId);

  Money shareOf(String memberId) {
    final share = shares.firstWhereOrNull((s) => s.memberId == memberId);
    return Money(share?.amountMinor ?? 0, amount.currency);
  }

  /// Sum of all shares; equal to [amount] for a valid expense.
  Money get sharesTotal => Money(shares.fold<int>(0, (acc, s) => acc + s.amountMinor), amount.currency);

  bool get isConsistent => sharesTotal == amount && amount.isPositive;

  Expense copyWith({
    String? description,
    Money? amount,
    String? paidByMemberId,
    ExpenseCategory? category,
    DateTime? date,
    SplitType? splitType,
    List<ExpenseShare>? shares,
    ConversionRate? conversionRate,
    bool clearConversionRate = false,
    String? notes,
    bool clearNotes = false,
    String? recurringTemplateId,
    bool clearRecurringTemplateId = false,
    DateTime? updatedAt,
  }) => Expense(
    id: id,
    groupId: groupId,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    category: category ?? this.category,
    date: date ?? this.date,
    splitType: splitType ?? this.splitType,
    shares: shares ?? this.shares,
    conversionRate: clearConversionRate ? null : (conversionRate ?? this.conversionRate),
    notes: clearNotes ? null : (notes ?? this.notes),
    recurringTemplateId: clearRecurringTemplateId ? null : (recurringTemplateId ?? this.recurringTemplateId),
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Expense &&
      other.id == id &&
      other.groupId == groupId &&
      other.description == description &&
      other.amount == amount &&
      other.paidByMemberId == paidByMemberId &&
      other.category == category &&
      other.date == date &&
      other.splitType == splitType &&
      const ListEquality<ExpenseShare>().equals(other.shares, shares) &&
      other.conversionRate == conversionRate &&
      other.notes == notes &&
      other.recurringTemplateId == recurringTemplateId &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    description,
    amount,
    paidByMemberId,
    category,
    date,
    splitType,
    const ListEquality<ExpenseShare>().hash(shares),
    conversionRate,
    notes,
    recurringTemplateId,
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'Expense($description, $amount, paid by $paidByMemberId)';
}
