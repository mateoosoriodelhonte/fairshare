import 'package:drift/drift.dart';

import '../core/money/money_exports.dart';
import '../domain/models/models.dart';
import 'db/app_database.dart';

/// Conversions between Drift rows and domain models. Kept in one file so the
/// storage representation (minor units + ISO code, enum keys) is obvious.
class Mappers {
  Mappers._();

  static Group toGroup(GroupRow r) => Group(
    id: r.id,
    name: r.name,
    baseCurrency: Currencies.require(r.baseCurrency),
    emoji: r.emoji,
    isDemo: r.isDemo,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  static GroupsCompanion fromGroup(Group g) => GroupsCompanion(
    id: Value(g.id),
    name: Value(g.name),
    baseCurrency: Value(g.baseCurrency.code),
    emoji: Value(g.emoji),
    isDemo: Value(g.isDemo),
    createdAt: Value(g.createdAt),
    updatedAt: Value(g.updatedAt),
  );

  static Member toMember(MemberRow r) =>
      Member(id: r.id, groupId: r.groupId, name: r.name, colorIndex: r.colorIndex, createdAt: r.createdAt);

  static MembersCompanion fromMember(Member m) => MembersCompanion(
    id: Value(m.id),
    groupId: Value(m.groupId),
    name: Value(m.name),
    colorIndex: Value(m.colorIndex),
    createdAt: Value(m.createdAt),
  );

  static Expense toExpense(ExpenseRow r, List<ExpenseShareRow> shares) {
    final sorted = [...shares]..sort((a, b) => a.position.compareTo(b.position));
    return Expense(
      id: r.id,
      groupId: r.groupId,
      description: r.description,
      amount: Money(r.amountMinor, Currencies.require(r.currency)),
      paidByMemberId: r.paidByMemberId,
      category: ExpenseCategory.fromKey(r.category),
      date: r.date,
      splitType: SplitType.fromKey(r.splitType),
      shares: [
        for (final s in sorted)
          ExpenseShare(memberId: s.memberId, amountMinor: s.amountMinor, splitValue: s.splitValue),
      ],
      conversionRate: r.conversionRateScaled == null ? null : ConversionRate.fromScaled(r.conversionRateScaled!),
      notes: r.notes,
      recurringTemplateId: r.recurringTemplateId,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  static ExpensesCompanion fromExpense(Expense e) => ExpensesCompanion(
    id: Value(e.id),
    groupId: Value(e.groupId),
    description: Value(e.description),
    amountMinor: Value(e.amount.minorUnits),
    currency: Value(e.amount.currency.code),
    paidByMemberId: Value(e.paidByMemberId),
    category: Value(e.category.key),
    date: Value(e.date),
    splitType: Value(e.splitType.key),
    conversionRateScaled: Value(e.conversionRate?.scaled),
    notes: Value(e.notes),
    recurringTemplateId: Value(e.recurringTemplateId),
    createdAt: Value(e.createdAt),
    updatedAt: Value(e.updatedAt),
  );

  static List<ExpenseSharesCompanion> fromExpenseShares(Expense e) => [
    for (var i = 0; i < e.shares.length; i++)
      ExpenseSharesCompanion(
        expenseId: Value(e.id),
        memberId: Value(e.shares[i].memberId),
        amountMinor: Value(e.shares[i].amountMinor),
        splitValue: Value(e.shares[i].splitValue),
        position: Value(i),
      ),
  ];

  static Settlement toSettlement(SettlementRow r) => Settlement(
    id: r.id,
    groupId: r.groupId,
    fromMemberId: r.fromMemberId,
    toMemberId: r.toMemberId,
    amount: Money(r.amountMinor, Currencies.require(r.currency)),
    conversionRate: r.conversionRateScaled == null ? null : ConversionRate.fromScaled(r.conversionRateScaled!),
    date: r.date,
    note: r.note,
    createdAt: r.createdAt,
  );

  static SettlementsCompanion fromSettlement(Settlement s) => SettlementsCompanion(
    id: Value(s.id),
    groupId: Value(s.groupId),
    fromMemberId: Value(s.fromMemberId),
    toMemberId: Value(s.toMemberId),
    amountMinor: Value(s.amount.minorUnits),
    currency: Value(s.amount.currency.code),
    conversionRateScaled: Value(s.conversionRate?.scaled),
    date: Value(s.date),
    note: Value(s.note),
    createdAt: Value(s.createdAt),
  );

  static RecurringTemplate toTemplate(RecurringTemplateRow r, List<RecurringTemplateShareRow> shares) {
    final sorted = [...shares]..sort((a, b) => a.position.compareTo(b.position));
    return RecurringTemplate(
      id: r.id,
      groupId: r.groupId,
      description: r.description,
      amount: Money(r.amountMinor, Currencies.require(r.currency)),
      paidByMemberId: r.paidByMemberId,
      category: ExpenseCategory.fromKey(r.category),
      splitType: SplitType.fromKey(r.splitType),
      shares: [
        for (final s in sorted)
          ExpenseShare(memberId: s.memberId, amountMinor: s.amountMinor, splitValue: s.splitValue),
      ],
      conversionRate: r.conversionRateScaled == null ? null : ConversionRate.fromScaled(r.conversionRateScaled!),
      notes: r.notes,
      frequency: RecurrenceFrequency.fromKey(r.frequency),
      interval: r.interval,
      nextDueDate: r.nextDueDate,
      isActive: r.isActive,
      createdAt: r.createdAt,
      lastGeneratedAt: r.lastGeneratedAt,
    );
  }

  static RecurringTemplatesCompanion fromTemplate(RecurringTemplate t) => RecurringTemplatesCompanion(
    id: Value(t.id),
    groupId: Value(t.groupId),
    description: Value(t.description),
    amountMinor: Value(t.amount.minorUnits),
    currency: Value(t.amount.currency.code),
    paidByMemberId: Value(t.paidByMemberId),
    category: Value(t.category.key),
    splitType: Value(t.splitType.key),
    conversionRateScaled: Value(t.conversionRate?.scaled),
    notes: Value(t.notes),
    frequency: Value(t.frequency.key),
    interval: Value(t.interval),
    nextDueDate: Value(t.nextDueDate),
    isActive: Value(t.isActive),
    createdAt: Value(t.createdAt),
    lastGeneratedAt: Value(t.lastGeneratedAt),
  );

  static List<RecurringTemplateSharesCompanion> fromTemplateShares(RecurringTemplate t) => [
    for (var i = 0; i < t.shares.length; i++)
      RecurringTemplateSharesCompanion(
        templateId: Value(t.id),
        memberId: Value(t.shares[i].memberId),
        amountMinor: Value(t.shares[i].amountMinor),
        splitValue: Value(t.shares[i].splitValue),
        position: Value(i),
      ),
  ];
}
