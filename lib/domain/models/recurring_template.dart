import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../core/money/conversion_rate.dart';
import '../../core/money/money.dart';
import 'expense_category.dart';
import 'expense_share.dart';
import 'split_type.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  String get key => name;

  String label(int interval) => switch (this) {
    RecurrenceFrequency.daily => interval == 1 ? 'Every day' : 'Every $interval days',
    RecurrenceFrequency.weekly => interval == 1 ? 'Every week' : 'Every $interval weeks',
    RecurrenceFrequency.monthly => interval == 1 ? 'Every month' : 'Every $interval months',
    RecurrenceFrequency.yearly => interval == 1 ? 'Every year' : 'Every $interval years',
  };

  static RecurrenceFrequency fromKey(String key) => RecurrenceFrequency.values.firstWhere(
    (e) => e.name == key,
    orElse: () => throw ArgumentError.value(key, 'key', 'Unknown frequency'),
  );
}

/// A blueprint for expenses that repeat (rent, streaming subscriptions,
/// cleaning service). Instances are materialised as ordinary [Expense]s so the
/// ledger stays simple and auditable.
@immutable
class RecurringTemplate {
  RecurringTemplate({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidByMemberId,
    required this.category,
    required this.splitType,
    required List<ExpenseShare> shares,
    required this.frequency,
    required this.interval,
    required this.nextDueDate,
    required this.isActive,
    required this.createdAt,
    this.conversionRate,
    this.notes,
    this.lastGeneratedAt,
  }) : assert(interval >= 1, 'interval must be at least 1'),
       shares = List.unmodifiable(shares);

  final String id;
  final String groupId;
  final String description;
  final Money amount;
  final String paidByMemberId;
  final ExpenseCategory category;
  final SplitType splitType;
  final List<ExpenseShare> shares;
  final ConversionRate? conversionRate;
  final String? notes;
  final RecurrenceFrequency frequency;

  /// Repeat every [interval] units of [frequency].
  final int interval;

  /// Date (midnight, local) of the next expense to generate.
  final DateTime nextDueDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastGeneratedAt;

  /// Returns the occurrence following [from] according to this schedule.
  DateTime nextAfter(DateTime from) {
    final d = DateTime(from.year, from.month, from.day);
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return d.add(Duration(days: interval));
      case RecurrenceFrequency.weekly:
        return d.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.monthly:
        return _addMonths(d, interval);
      case RecurrenceFrequency.yearly:
        return _addMonths(d, 12 * interval);
    }
  }

  /// Adds months while clamping the day to the target month's length, so a
  /// template due on the 31st stays at month-end rather than skipping.
  static DateTime _addMonths(DateTime d, int months) {
    final totalMonths = d.month - 1 + months;
    final year = d.year + totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day > lastDay ? lastDay : d.day);
  }

  /// All due dates up to and including [until], starting from [nextDueDate].
  /// Capped to avoid runaway generation for templates far in the past.
  List<DateTime> dueDatesUntil(DateTime until, {int max = 120}) {
    final result = <DateTime>[];
    var cursor = nextDueDate;
    final limit = DateTime(until.year, until.month, until.day);
    while (!cursor.isAfter(limit) && result.length < max) {
      result.add(cursor);
      cursor = nextAfter(cursor);
    }
    return result;
  }

  RecurringTemplate copyWith({
    String? description,
    Money? amount,
    String? paidByMemberId,
    ExpenseCategory? category,
    SplitType? splitType,
    List<ExpenseShare>? shares,
    ConversionRate? conversionRate,
    bool clearConversionRate = false,
    String? notes,
    bool clearNotes = false,
    RecurrenceFrequency? frequency,
    int? interval,
    DateTime? nextDueDate,
    bool? isActive,
    DateTime? lastGeneratedAt,
  }) => RecurringTemplate(
    id: id,
    groupId: groupId,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    paidByMemberId: paidByMemberId ?? this.paidByMemberId,
    category: category ?? this.category,
    splitType: splitType ?? this.splitType,
    shares: shares ?? this.shares,
    conversionRate: clearConversionRate ? null : (conversionRate ?? this.conversionRate),
    notes: clearNotes ? null : (notes ?? this.notes),
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt,
    lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is RecurringTemplate &&
      other.id == id &&
      other.groupId == groupId &&
      other.description == description &&
      other.amount == amount &&
      other.paidByMemberId == paidByMemberId &&
      other.category == category &&
      other.splitType == splitType &&
      const ListEquality<ExpenseShare>().equals(other.shares, shares) &&
      other.conversionRate == conversionRate &&
      other.notes == notes &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.nextDueDate == nextDueDate &&
      other.isActive == isActive &&
      other.createdAt == createdAt &&
      other.lastGeneratedAt == lastGeneratedAt;

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    description,
    amount,
    paidByMemberId,
    category,
    splitType,
    const ListEquality<ExpenseShare>().hash(shares),
    conversionRate,
    notes,
    frequency,
    interval,
    nextDueDate,
    isActive,
    createdAt,
    lastGeneratedAt,
  );
}
