import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:fairshare/domain/models/models.dart';

final DateTime t0 = DateTime(2026, 1, 1);

Group testGroup({String id = 'g1', Currency currency = Currencies.usd}) =>
    Group(id: id, name: 'Test', baseCurrency: currency, emoji: '🧪', createdAt: t0, updatedAt: t0);

Member member(String id, {String groupId = 'g1', int colorIndex = 0}) =>
    Member(id: id, groupId: groupId, name: id.toUpperCase(), colorIndex: colorIndex, createdAt: t0);

List<Member> members(List<String> ids, {String groupId = 'g1'}) => [
  for (var i = 0; i < ids.length; i++) member(ids[i], groupId: groupId, colorIndex: i),
];

int _counter = 0;

Expense expense({
  required int amountMinor,
  required String paidBy,
  required List<String> participants,
  Currency currency = Currencies.usd,
  SplitType splitType = SplitType.equal,
  List<ExpenseShare>? shares,
  ConversionRate? rate,
  String groupId = 'g1',
  DateTime? date,
}) {
  final id = 'e${_counter++}';
  final computed =
      shares ??
      ExpenseSplitter.computeShares(
        type: splitType,
        totalMinor: amountMinor,
        inputs: [for (final p in participants) SplitInput(p)],
      );
  return Expense(
    id: id,
    groupId: groupId,
    description: 'Expense $id',
    amount: Money(amountMinor, currency),
    paidByMemberId: paidBy,
    category: ExpenseCategory.other,
    date: date ?? t0,
    splitType: splitType,
    shares: computed,
    conversionRate: rate,
    createdAt: t0,
    updatedAt: t0,
  );
}

Settlement settlement({
  required String from,
  required String to,
  required int amountMinor,
  Currency currency = Currencies.usd,
  ConversionRate? rate,
  String groupId = 'g1',
}) {
  final id = 's${_counter++}';
  return Settlement(
    id: id,
    groupId: groupId,
    fromMemberId: from,
    toMemberId: to,
    amount: Money(amountMinor, currency),
    conversionRate: rate,
    date: t0,
    createdAt: t0,
  );
}
