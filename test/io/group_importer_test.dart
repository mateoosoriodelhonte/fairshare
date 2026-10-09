import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/data/db/app_database.dart';
import 'package:fairshare/data/repositories/repositories.dart';
import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:fairshare/domain/group_snapshot.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:fairshare/io/group_importer.dart';
import 'package:fairshare/io/group_json_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  late AppDatabase db;
  late GroupRepository groups;
  late ExpenseRepository expenses;
  late SettlementRepository settlements;
  late RecurringRepository recurring;

  setUp(() {
    db = AppDatabase.inMemory();
    groups = GroupRepository(db);
    expenses = ExpenseRepository(db);
    settlements = SettlementRepository(db);
    recurring = RecurringRepository(db);
  });

  tearDown(() => db.close());

  /// A source group built purely from fixtures (ids like "a", "b", "r1").
  GroupSnapshot source() {
    final g = testGroup(currency: Currencies.eur);
    final ms = members(['a', 'b', 'c']);
    final template = RecurringTemplate(
      id: 'r1',
      groupId: g.id,
      description: 'Rent',
      amount: const Money(90000, Currencies.eur),
      paidByMemberId: 'a',
      category: ExpenseCategory.housing,
      splitType: SplitType.equal,
      shares: const [
        ExpenseShare(memberId: 'a', amountMinor: 30000),
        ExpenseShare(memberId: 'b', amountMinor: 30000),
        ExpenseShare(memberId: 'c', amountMinor: 30000),
      ],
      frequency: RecurrenceFrequency.monthly,
      interval: 1,
      nextDueDate: DateTime(2027, 1, 1),
      isActive: true,
      createdAt: t0,
    );
    return GroupSnapshot(
      group: g,
      members: ms,
      expenses: [
        expense(
          amountMinor: 90000,
          paidBy: 'a',
          participants: ['a', 'b', 'c'],
          currency: Currencies.eur,
        ).copyWith(recurringTemplateId: 'r1'),
        expense(
          amountMinor: 1000,
          paidBy: 'b',
          participants: ['a', 'b'],
          currency: Currencies.gbp,
          rate: ConversionRate.parse('1.17'),
          splitType: SplitType.shares,
          shares: const [
            ExpenseShare(memberId: 'a', amountMinor: 750, splitValue: 3),
            ExpenseShare(memberId: 'b', amountMinor: 250, splitValue: 1),
          ],
        ),
        expense(amountMinor: 3333, paidBy: 'c', participants: ['a', 'b', 'c'], currency: Currencies.eur),
      ],
      settlements: [settlement(from: 'b', to: 'a', amountMinor: 500, currency: Currencies.eur)],
      templates: [template],
    );
  }

  Future<GroupSnapshot> snapshotOf(String id) async => GroupSnapshot(
    group: (await groups.getGroup(id))!,
    members: await groups.getMembers(id),
    expenses: await expenses.getExpenses(id),
    settlements: await settlements.getSettlements(id),
    templates: await recurring.getTemplates(id),
  );

  test('import creates an equivalent group with fresh ids and remapped references', () async {
    final src = source();
    final text = GroupJsonCodec.encodeToString(src, exportedAt: DateTime.utc(2026));
    final importer = GroupImporter(groups: groups, expenses: expenses, settlements: settlements, recurring: recurring);
    final imported = await importer.import(GroupJsonCodec.decodeString(text));

    expect(imported.id, isNot(src.group.id));
    expect(imported.name, src.group.name, reason: 'no clash, so the name is kept');
    final copy = await snapshotOf(imported.id);
    expect(copy.members.map((m) => m.name), ['A', 'B', 'C']);
    expect(copy.members.map((m) => m.id), isNot(contains('a')));
    expect(copy.expenses.length, 3);
    expect(copy.settlements.length, 1);
    expect(copy.templates.length, 1);
    expect(copy.expenses.every((e) => e.isConsistent), isTrue);

    for (final m in src.members) {
      final twin = copy.members.firstWhere((c) => c.name == m.name);
      expect(copy.balances.balanceOf(twin.id), src.balances.balanceOf(m.id), reason: m.name);
    }
    expect(copy.balances.isBalanced, isTrue);

    final rent = copy.expenses.firstWhere((e) => e.amount.minorUnits == 90000);
    expect(rent.recurringTemplateId, copy.templates.single.id, reason: 'template link remapped');
    final gbp = copy.expenses.firstWhere((e) => e.amount.currency == Currencies.gbp);
    expect(gbp.conversionRate, ConversionRate.parse('1.17'));
    expect(gbp.shares.map((s) => s.splitValue), [3, 1]);

    final again = GroupJsonCodec.decodeString(GroupJsonCodec.encodeToString(copy));
    expect(
      BalanceCalculator.compute(
        group: again.group,
        members: again.members,
        expenses: again.expenses,
        settlements: again.settlements,
      ).isBalanced,
      isTrue,
    );
  });

  test('a name clash gets an "(imported)" suffix', () async {
    await groups.createGroup(name: 'Test', baseCurrency: Currencies.eur);
    final importer = GroupImporter(groups: groups, expenses: expenses, settlements: settlements, recurring: recurring);
    final imported = await importer.import(GroupJsonCodec.decode(GroupJsonCodec.encode(source())));
    expect(imported.name, 'Test (imported)');
    expect((await groups.getGroups()).length, 2);
  });
}
