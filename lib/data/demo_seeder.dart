import '../core/ids.dart';
import '../core/money/money_exports.dart';
import '../domain/accounting/accounting.dart';
import '../domain/models/models.dart';
import 'repositories/repositories.dart';

/// Creates the bundled demo group: a fictional flat share with synthetic
/// people and amounts. Nothing here is real financial data.
///
/// The group exercises every feature: all four split types, a
/// foreign-currency expense with an explicit rate, a partial settlement,
/// and two recurring templates.
class DemoSeeder {
  DemoSeeder({
    required this.groups,
    required this.expenses,
    required this.settlements,
    required this.recurring,
    required this.preferences,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final GroupRepository groups;
  final ExpenseRepository expenses;
  final SettlementRepository settlements;
  final RecurringRepository recurring;
  final PreferencesRepository preferences;
  final DateTime Function() _clock;

  static const String groupName = 'Casa Verde';

  /// Seeds the demo group and returns its id.
  Future<String> seed() async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    DateTime daysAgo(int d) => today.subtract(Duration(days: d));

    final group = await groups.createGroup(name: groupName, baseCurrency: Currencies.eur, emoji: '🏠', isDemo: true);
    final ana = await groups.addMember(group.id, 'Ana');
    final ben = await groups.addMember(group.id, 'Ben');
    final chloe = await groups.addMember(group.id, 'Chloe');
    final dev = await groups.addMember(group.id, 'Dev');
    final everyone = [ana, ben, chloe, dev];

    Future<void> add({
      required String description,
      required int amountMinor,
      required Member paidBy,
      required ExpenseCategory category,
      required int daysBack,
      List<Member>? participants,
      SplitType splitType = SplitType.equal,
      List<int>? values,
      Currency currency = Currencies.eur,
      ConversionRate? rate,
      String? notes,
    }) async {
      final people = participants ?? everyone;
      final shares = ExpenseSplitter.computeShares(
        type: splitType,
        totalMinor: amountMinor,
        inputs: [for (var i = 0; i < people.length; i++) SplitInput(people[i].id, values?[i])],
      );
      await expenses.upsertExpense(
        Expense(
          id: Ids.next(),
          groupId: group.id,
          description: description,
          amount: Money(amountMinor, currency),
          paidByMemberId: paidBy.id,
          category: category,
          date: daysAgo(daysBack),
          splitType: splitType,
          shares: shares,
          conversionRate: rate,
          notes: notes,
          createdAt: now.subtract(Duration(days: daysBack)),
          updatedAt: now.subtract(Duration(days: daysBack)),
        ),
      );
    }

    await add(
      description: 'Weekly groceries',
      amountMinor: 8640,
      paidBy: ana,
      category: ExpenseCategory.groceries,
      daysBack: 41,
    );
    await add(
      description: 'Electricity bill',
      amountMinor: 11230,
      paidBy: ben,
      category: ExpenseCategory.utilities,
      daysBack: 38,
    );
    await add(
      description: 'Housewarming dinner',
      amountMinor: 14250,
      paidBy: chloe,
      category: ExpenseCategory.food,
      daysBack: 35,
    );
    await add(
      description: 'Living room lamp',
      amountMinor: 7999,
      paidBy: dev,
      category: ExpenseCategory.shopping,
      daysBack: 31,
      participants: [ana, ben, dev],
      splitType: SplitType.shares,
      values: [2, 1, 1],
      notes: 'Ana wanted the bigger one, so she takes two shares.',
    );
    await add(
      description: 'Weekly groceries',
      amountMinor: 9115,
      paidBy: ben,
      category: ExpenseCategory.groceries,
      daysBack: 27,
    );
    await add(
      description: 'Streaming subscriptions',
      amountMinor: 2497,
      paidBy: chloe,
      category: ExpenseCategory.entertainment,
      daysBack: 24,
      splitType: SplitType.percentage,
      values: [4000, 2000, 2000, 2000],
      notes: 'Chloe uses two profiles.',
    );
    await add(
      description: 'Train tickets to Porto',
      amountMinor: 12600,
      paidBy: ana,
      category: ExpenseCategory.travel,
      daysBack: 20,
      participants: [ana, chloe],
      currency: Currencies.gbp,
      rate: ConversionRate.parse('1.17'),
      notes: 'Booked on a UK site; rate from the card statement.',
    );
    await add(
      description: 'Cleaning supplies',
      amountMinor: 2385,
      paidBy: dev,
      category: ExpenseCategory.housing,
      daysBack: 17,
    );
    await add(
      description: 'Pizza night',
      amountMinor: 5200,
      paidBy: ben,
      category: ExpenseCategory.food,
      daysBack: 13,
      splitType: SplitType.exact,
      values: [1300, 1700, 1300, 900],
      notes: 'Dev only had two slices.',
    );
    await add(
      description: 'Weekly groceries',
      amountMinor: 7742,
      paidBy: chloe,
      category: ExpenseCategory.groceries,
      daysBack: 10,
    );
    await add(
      description: 'Internet',
      amountMinor: 3999,
      paidBy: dev,
      category: ExpenseCategory.utilities,
      daysBack: 8,
    );
    await add(
      description: 'Concert tickets',
      amountMinor: 9000,
      paidBy: ana,
      category: ExpenseCategory.entertainment,
      daysBack: 5,
      participants: [ana, ben, dev],
    );
    await add(
      description: 'Birthday cake for Chloe',
      amountMinor: 2850,
      paidBy: ben,
      category: ExpenseCategory.gifts,
      daysBack: 3,
      participants: [ana, ben, dev],
    );
    await add(
      description: 'Weekly groceries',
      amountMinor: 8320,
      paidBy: ana,
      category: ExpenseCategory.groceries,
      daysBack: 1,
    );

    await settlements.upsertSettlement(
      Settlement(
        id: Ids.next(),
        groupId: group.id,
        fromMemberId: dev.id,
        toMemberId: ana.id,
        amount: const Money(3000, Currencies.eur),
        date: daysAgo(6),
        note: 'Cash, partial',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    );

    final nextMonth = DateTime(today.year, today.month + 1, 1);
    await recurring.upsertTemplate(
      RecurringTemplate(
        id: Ids.next(),
        groupId: group.id,
        description: 'Rent',
        amount: const Money(160000, Currencies.eur),
        paidByMemberId: ana.id,
        category: ExpenseCategory.housing,
        splitType: SplitType.equal,
        shares: ExpenseSplitter.computeShares(
          type: SplitType.equal,
          totalMinor: 160000,
          inputs: [for (final m in everyone) SplitInput(m.id)],
        ),
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
        nextDueDate: nextMonth,
        isActive: true,
        createdAt: now,
      ),
    );
    await recurring.upsertTemplate(
      RecurringTemplate(
        id: Ids.next(),
        groupId: group.id,
        description: 'Internet',
        amount: const Money(3999, Currencies.eur),
        paidByMemberId: dev.id,
        category: ExpenseCategory.utilities,
        splitType: SplitType.equal,
        shares: ExpenseSplitter.computeShares(
          type: SplitType.equal,
          totalMinor: 3999,
          inputs: [for (final m in everyone) SplitInput(m.id)],
        ),
        frequency: RecurrenceFrequency.monthly,
        interval: 1,
        nextDueDate: DateTime(today.year, today.month + 1, 8),
        isActive: true,
        createdAt: now,
      ),
    );

    await preferences.setDemoSeeded(true);
    return group.id;
  }
}
