import 'package:fairshare/core/money/money_exports.dart';
import 'package:fairshare/data/db/app_database.dart';
import 'package:fairshare/data/repositories/repositories.dart';
import 'package:fairshare/domain/accounting/accounting.dart';
import 'package:fairshare/domain/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late GroupRepository groups;
  late ExpenseRepository expenses;
  late SettlementRepository settlements;
  late RecurringRepository recurring;
  late PreferencesRepository prefs;
  var now = DateTime(2026, 3, 1, 12);

  setUp(() {
    db = AppDatabase.inMemory();
    DateTime clock() => now;
    groups = GroupRepository(db, clock: clock);
    expenses = ExpenseRepository(db);
    settlements = SettlementRepository(db);
    recurring = RecurringRepository(db, clock: clock);
    prefs = PreferencesRepository(db);
  });

  tearDown(() => db.close());

  Future<(Group, Member, Member)> seedGroup() async {
    final g = await groups.createGroup(name: 'Flat', baseCurrency: Currencies.eur, emoji: '🏠');
    final a = await groups.addMember(g.id, 'Ana');
    final b = await groups.addMember(g.id, 'Ben');
    return (g, a, b);
  }

  Expense makeExpense(
    Group g,
    Member payer,
    List<Member> participants,
    int amount, {
    Currency? currency,
    ConversionRate? rate,
    String? id,
    DateTime? date,
  }) {
    final shares = ExpenseSplitter.computeShares(
      type: SplitType.equal,
      totalMinor: amount,
      inputs: [for (final p in participants) SplitInput(p.id)],
    );
    return Expense(
      id: id ?? 'exp-${DateTime.now().microsecondsSinceEpoch}-$amount',
      groupId: g.id,
      description: 'Groceries',
      amount: Money(amount, currency ?? g.baseCurrency),
      paidByMemberId: payer.id,
      category: ExpenseCategory.groceries,
      date: date ?? DateTime(2026, 3, 1),
      splitType: SplitType.equal,
      shares: shares,
      conversionRate: rate,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('groups and members', () {
    test('create, read, update, delete group', () async {
      final g = await groups.createGroup(name: '  Trip  ', baseCurrency: Currencies.usd, emoji: '✈️');
      expect(g.name, 'Trip');
      expect((await groups.getGroup(g.id))!, g);
      expect(await groups.watchGroups().first, [g]);

      now = now.add(const Duration(minutes: 1));
      await groups.updateGroup(g.copyWith(name: 'Lisbon trip'));
      final updated = (await groups.getGroup(g.id))!;
      expect(updated.name, 'Lisbon trip');
      expect(updated.updatedAt, now);

      await groups.deleteGroup(g.id);
      expect(await groups.getGroup(g.id), isNull);
    });

    test('rejects empty names', () async {
      expect(() => groups.createGroup(name: '  ', baseCurrency: Currencies.usd), throwsA(isA<DomainRuleException>()));
    });

    test('members: add, duplicate names refused, colours cycle', () async {
      final (g, a, b) = await seedGroup();
      expect(a.colorIndex, 0);
      expect(b.colorIndex, 1);
      expect(() => groups.addMember(g.id, ' ana '), throwsA(isA<DomainRuleException>()));
      expect(() => groups.addMember(g.id, ''), throwsA(isA<DomainRuleException>()));
      expect((await groups.getMembers(g.id)).map((m) => m.name), ['Ana', 'Ben']);

      await groups.updateMember(b.copyWith(name: 'Benjamin'));
      expect((await groups.getMembers(g.id)).last.name, 'Benjamin');
      expect(() => groups.updateMember(b.copyWith(name: 'Ana')), throwsA(isA<DomainRuleException>()));
    });

    test('member with history cannot be deleted; unused member can', () async {
      final (g, a, b) = await seedGroup();
      final c = await groups.addMember(g.id, 'Cleo');
      await expenses.upsertExpense(makeExpense(g, a, [a, b], 1000));
      expect(await groups.isMemberReferenced(a.id), isTrue);
      expect(await groups.isMemberReferenced(b.id), isTrue);
      expect(await groups.isMemberReferenced(c.id), isFalse);
      expect(() => groups.deleteMember(a.id), throwsA(isA<DomainRuleException>()));
      expect(() => groups.deleteMember(b.id), throwsA(isA<DomainRuleException>()));
      await groups.deleteMember(c.id);
      expect((await groups.getMembers(g.id)).length, 2);
    });

    test('foreign keys are enforced at the database level too', () async {
      final (g, a, b) = await seedGroup();
      await expenses.upsertExpense(makeExpense(g, a, [a, b], 1000));
      // Bypass the repository guard: SQLite itself must refuse.
      expect(() => (db.delete(db.members)..where((m) => m.id.equals(a.id))).go(), throwsA(isA<Exception>()));
    });

    test('deleting a group cascades to members, expenses, shares, settlements, templates', () async {
      final (g, a, b) = await seedGroup();
      await expenses.upsertExpense(makeExpense(g, a, [a, b], 1000));
      await settlements.upsertSettlement(
        Settlement(
          id: 's1',
          groupId: g.id,
          fromMemberId: b.id,
          toMemberId: a.id,
          amount: const Money(500, Currencies.eur),
          date: DateTime(2026, 3, 2),
          createdAt: now,
        ),
      );
      await recurring.upsertTemplate(
        RecurringTemplate(
          id: 'r1',
          groupId: g.id,
          description: 'Rent',
          amount: const Money(100000, Currencies.eur),
          paidByMemberId: a.id,
          category: ExpenseCategory.housing,
          splitType: SplitType.equal,
          shares: [
            ExpenseShare(memberId: a.id, amountMinor: 50000),
            ExpenseShare(memberId: b.id, amountMinor: 50000),
          ],
          frequency: RecurrenceFrequency.monthly,
          interval: 1,
          nextDueDate: DateTime(2026, 4, 1),
          isActive: true,
          createdAt: now,
        ),
      );
      await groups.deleteGroup(g.id);
      expect(await db.select(db.members).get(), isEmpty);
      expect(await db.select(db.expenses).get(), isEmpty);
      expect(await db.select(db.expenseShares).get(), isEmpty);
      expect(await db.select(db.settlements).get(), isEmpty);
      expect(await db.select(db.recurringTemplates).get(), isEmpty);
      expect(await db.select(db.recurringTemplateShares).get(), isEmpty);
    });
  });

  group('expenses', () {
    test('round-trips every field including foreign currency and notes', () async {
      final (g, a, b) = await seedGroup();
      final e = makeExpense(
        g,
        a,
        [a, b],
        1234,
        currency: Currencies.usd,
        rate: ConversionRate.parse('0.92'),
        id: 'e1',
      ).copyWith(notes: 'Split after the trip', category: ExpenseCategory.travel);
      await expenses.upsertExpense(e);
      final loaded = await expenses.getExpense('e1');
      expect(loaded, e);
      expect(loaded!.conversionRate, ConversionRate.parse('0.92'));
      expect(loaded.shares.map((s) => s.memberId), [a.id, b.id]);
    });

    test('upsert replaces shares atomically and bumps group updatedAt', () async {
      final (g, a, b) = await seedGroup();
      final c = await groups.addMember(g.id, 'Cleo');
      final e = makeExpense(g, a, [a, b, c], 900, id: 'e1');
      await expenses.upsertExpense(e);
      expect((await expenses.getExpense('e1'))!.shares.length, 3);

      now = now.add(const Duration(hours: 1));
      final edited = e.copyWith(
        shares: ExpenseSplitter.computeShares(
          type: SplitType.exact,
          totalMinor: 900,
          inputs: [SplitInput(a.id, 400), SplitInput(c.id, 500)],
        ),
        splitType: SplitType.exact,
        updatedAt: now,
      );
      await expenses.upsertExpense(edited);
      final loaded = (await expenses.getExpense('e1'))!;
      expect(loaded.shares.map((s) => s.memberId), [a.id, c.id]);
      expect(loaded.shares.map((s) => s.splitValue), [400, 500]);
      expect(await db.select(db.expenseShares).get(), hasLength(2));
      expect((await groups.getGroup(g.id))!.updatedAt, now);
    });

    test('refuses inconsistent expenses', () async {
      final (g, a, b) = await seedGroup();
      final bad = makeExpense(g, a, [a, b], 1000).copyWith(amount: const Money(999, Currencies.eur));
      expect(() => expenses.upsertExpense(bad), throwsA(isA<DomainRuleException>()));
      final noShares = makeExpense(g, a, [a, b], 1000).copyWith(shares: []);
      expect(() => expenses.upsertExpense(noShares), throwsA(isA<DomainRuleException>()));
    });

    test('watchExpenses is ordered newest first and reacts to writes', () async {
      final (g, a, b) = await seedGroup();
      final stream = expenses.watchExpenses(g.id);
      expect(await stream.first, isEmpty);
      await expenses.upsertExpense(makeExpense(g, a, [a, b], 100, id: 'old', date: DateTime(2026, 1, 1)));
      await expenses.upsertExpense(makeExpense(g, a, [a, b], 200, id: 'new', date: DateTime(2026, 2, 1)));
      final list = await expenses.getExpenses(g.id);
      expect(list.map((e) => e.id), ['new', 'old']);
      expect(await expenses.countForGroup(g.id), 2);
      await expenses.deleteExpense('old');
      expect((await expenses.getExpenses(g.id)).map((e) => e.id), ['new']);
      expect(await db.select(db.expenseShares).get(), hasLength(2));
    });

    test('balances computed from persisted data match the calculator', () async {
      final (g, a, b) = await seedGroup();
      await expenses.upsertExpense(makeExpense(g, a, [a, b], 1000, id: 'e1'));
      await settlements.upsertSettlement(
        Settlement(
          id: 's1',
          groupId: g.id,
          fromMemberId: b.id,
          toMemberId: a.id,
          amount: const Money(200, Currencies.eur),
          date: DateTime(2026, 3, 2),
          createdAt: now,
        ),
      );
      final sheet = BalanceCalculator.compute(
        group: (await groups.getGroup(g.id))!,
        members: await groups.getMembers(g.id),
        expenses: await expenses.getExpenses(g.id),
        settlements: await settlements.getSettlements(g.id),
      );
      expect(sheet.balanceOf(a.id), const Money(300, Currencies.eur));
      expect(sheet.balanceOf(b.id), const Money(-300, Currencies.eur));
      expect(sheet.isBalanced, isTrue);
    });
  });

  group('settlements', () {
    test('validates amount and distinct members', () async {
      final (g, a, b) = await seedGroup();
      Settlement make(int amount, String from, String to) => Settlement(
        id: 's',
        groupId: g.id,
        fromMemberId: from,
        toMemberId: to,
        amount: Money(amount, Currencies.eur),
        date: DateTime(2026, 3, 2),
        createdAt: now,
      );
      expect(() => settlements.upsertSettlement(make(0, a.id, b.id)), throwsA(isA<DomainRuleException>()));
      expect(() => settlements.upsertSettlement(make(-5, a.id, b.id)), throwsA(isA<DomainRuleException>()));
      expect(() => settlements.upsertSettlement(make(5, a.id, a.id)), throwsA(isA<DomainRuleException>()));
      await settlements.upsertSettlement(make(5, a.id, b.id));
      expect(await settlements.getSettlements(g.id), hasLength(1));
      await settlements.deleteSettlement('s');
      expect(await settlements.getSettlements(g.id), isEmpty);
    });
  });

  group('recurring templates', () {
    RecurringTemplate rent(Group g, Member a, Member b, DateTime next, {bool active = true}) => RecurringTemplate(
      id: 'rent',
      groupId: g.id,
      description: 'Rent',
      amount: const Money(100000, Currencies.eur),
      paidByMemberId: a.id,
      category: ExpenseCategory.housing,
      splitType: SplitType.equal,
      shares: [
        ExpenseShare(memberId: a.id, amountMinor: 50000),
        ExpenseShare(memberId: b.id, amountMinor: 50000),
      ],
      frequency: RecurrenceFrequency.monthly,
      interval: 1,
      nextDueDate: next,
      isActive: active,
      createdAt: now,
    );

    test('round-trips', () async {
      final (g, a, b) = await seedGroup();
      final t = rent(g, a, b, DateTime(2026, 4, 1));
      await recurring.upsertTemplate(t);
      expect(await recurring.getTemplate('rent'), t);
      expect(await recurring.watchTemplates(g.id).first, [t]);
    });

    test('generateDue: Jan 31 monthly template, run on Mar 15 -> Jan 31 and Feb 28, next Mar 28', () async {
      final (g, a, b) = await seedGroup();
      await recurring.upsertTemplate(rent(g, a, b, DateTime(2026, 1, 31)));
      now = DateTime(2026, 3, 15, 9);
      final created = await recurring.generateDue();
      expect(created, 2);
      final list = await expenses.getExpenses(g.id);
      expect(list.map((e) => e.date), [DateTime(2026, 2, 28), DateTime(2026, 1, 31)]);
      expect(list.every((e) => e.recurringTemplateId == 'rent'), isTrue);
      expect(list.every((e) => e.isConsistent), isTrue);
      final t = (await recurring.getTemplate('rent'))!;
      expect(t.nextDueDate, DateTime(2026, 3, 28));
      expect(t.lastGeneratedAt, now);
      expect(await recurring.generateDue(), 0);
    });

    test('inactive templates and future templates generate nothing', () async {
      final (g, a, b) = await seedGroup();
      await recurring.upsertTemplate(rent(g, a, b, DateTime(2026, 1, 1), active: false));
      now = DateTime(2026, 6, 1);
      expect(await recurring.generateDue(), 0);
      await recurring.upsertTemplate(rent(g, a, b, DateTime(2027, 1, 1)));
      expect(await recurring.generateDue(), 0);
    });

    test('deleting a template keeps generated expenses but unlinks them', () async {
      final (g, a, b) = await seedGroup();
      await recurring.upsertTemplate(rent(g, a, b, DateTime(2026, 2, 1)));
      now = DateTime(2026, 2, 2);
      expect(await recurring.generateDue(), 1);
      await recurring.deleteTemplate('rent');
      final list = await expenses.getExpenses(g.id);
      expect(list, hasLength(1));
      expect(list.single.recurringTemplateId, isNull);
    });
  });

  group('preferences', () {
    test('defaults and round-trip', () async {
      expect(await prefs.get(), const AppPreferences());
      await prefs.setThemeMode(AppThemeMode.dark);
      await prefs.setDefaultCurrency(Currencies.gbp);
      await prefs.setSettlementMode(SettlementMode.direct);
      await prefs.setDemoSeeded(true);
      await prefs.setAutoGenerateRecurring(false);
      final p = await prefs.get();
      expect(p.themeMode, AppThemeMode.dark);
      expect(p.defaultCurrency, Currencies.gbp);
      expect(p.settlementMode, SettlementMode.direct);
      expect(p.demoSeeded, isTrue);
      expect(p.autoGenerateRecurring, isFalse);
      expect(await prefs.watch().first, p);
    });
  });
}
