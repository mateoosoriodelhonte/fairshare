import 'package:meta/meta.dart';

import '../../core/money/currency.dart';

/// A set of people sharing expenses: a flat, a trip, a couple, a club.
@immutable
class Group {
  const Group({
    required this.id,
    required this.name,
    required this.baseCurrency,
    required this.emoji,
    required this.createdAt,
    required this.updatedAt,
    this.isDemo = false,
  });

  final String id;
  final String name;

  /// Every balance in the group is expressed in this currency. Expenses in
  /// other currencies carry an explicit user-entered conversion rate.
  final Currency baseCurrency;

  /// A single emoji used as the group's icon. Purely decorative.
  final String emoji;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// True for the bundled synthetic demo group.
  final bool isDemo;

  Group copyWith({String? name, Currency? baseCurrency, String? emoji, DateTime? updatedAt, bool? isDemo}) => Group(
    id: id,
    name: name ?? this.name,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    emoji: emoji ?? this.emoji,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDemo: isDemo ?? this.isDemo,
  );

  @override
  bool operator ==(Object other) =>
      other is Group &&
      other.id == id &&
      other.name == name &&
      other.baseCurrency == baseCurrency &&
      other.emoji == emoji &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.isDemo == isDemo;

  @override
  int get hashCode => Object.hash(id, name, baseCurrency, emoji, createdAt, updatedAt, isDemo);

  @override
  String toString() => 'Group($name, ${baseCurrency.code})';
}
