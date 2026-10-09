import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/data/db/app_database.dart';
import 'package:fairshare/data/demo_seeder.dart';
import 'package:fairshare/data/repositories/repositories.dart';
import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.inMemory());
  tearDown(() => db.close());

  test('demo group is complete, consistent, and balanced', () async {
    final now = DateTime(2026, 10, 9, 12);
    final groups = GroupRepository(db, clock: () => now);
    final expenses = ExpenseRepository(db);
    final settlements = SettlementRepository(db);
    final recurring = RecurringRepository(db, clock: () => now);
    final prefs = PreferencesRepository(db);
    final seeder = DemoSeeder(
      groups: groups,
      expenses: expenses,
      settlements: settlements,
      recurring: recurring,
      preferences: prefs,
      clock: () => now,
    );

    final id = await seeder.seed();
    final group = (await groups.getGroup(id))!;
    expect(group.isDemo, isTrue);
    expect(group.name, DemoSeeder.groupName);
    expect(group.baseCurrency, Currencies.eur);

    final members = await groups.getMembers(id);
    expect(members.map((m) => m.name), ['Ana', 'Ben', 'Chloe', 'Dev']);

    final list = await expenses.getExpenses(id);
    expect(list.length, greaterThanOrEqualTo(12));
    expect(list.every((e) => e.isConsistent), isTrue);
    expect(list.map((e) => e.splitType).toSet(), SplitType.values.toSet(), reason: 'every split type is demonstrated');
    final foreign = list.where((e) => e.amount.currency != Currencies.eur).toList();
    expect(foreign, isNotEmpty);
    expect(foreign.every((e) => e.conversionRate != null), isTrue);
    expect(list.every((e) => !e.date.isAfter(now)), isTrue);

    final paid = await settlements.getSettlements(id);
    expect(paid, hasLength(1));

    final templates = await recurring.getTemplates(id);
    expect(templates.map((t) => t.description), containsAll(['Rent', 'Internet']));
    expect(templates.every((t) => t.nextDueDate.isAfter(now)), isTrue, reason: 'nothing is due immediately');
    expect(await recurring.generateDue(), 0);

    final sheet = BalanceCalculator.compute(group: group, members: members, expenses: list, settlements: paid);
    expect(sheet.isBalanced, isTrue);
    expect(sheet.isSettled, isFalse, reason: 'the demo should have something to settle');
    expect((await prefs.get()).demoSeeded, isTrue);
  });

  test('seeding twice creates two independent groups', () async {
    final groups = GroupRepository(db);
    final seeder = DemoSeeder(
      groups: groups,
      expenses: ExpenseRepository(db),
      settlements: SettlementRepository(db),
      recurring: RecurringRepository(db),
      preferences: PreferencesRepository(db),
    );
    final a = await seeder.seed();
    final b = await seeder.seed();
    expect(a, isNot(b));
    expect((await groups.getGroups()).length, 2);
  });
}
