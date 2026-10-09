import '../core/ids.dart';
import '../data/repositories/repositories.dart';
import '../domain/models/models.dart';
import 'group_json_codec.dart';

/// Persists an [ImportedGroup] as a *new* group with fresh ids so an import
/// can never overwrite or collide with existing data.
class GroupImporter {
  GroupImporter({
    required this.groups,
    required this.expenses,
    required this.settlements,
    required this.recurring,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final GroupRepository groups;
  final ExpenseRepository expenses;
  final SettlementRepository settlements;
  final RecurringRepository recurring;
  final DateTime Function() _clock;

  Future<Group> import(ImportedGroup data) async {
    final existing = await groups.getGroups();
    var name = data.group.name;
    if (existing.any((g) => g.name.toLowerCase() == name.toLowerCase())) {
      name = '$name (imported)';
    }
    final group = await groups.createGroup(
      name: name,
      baseCurrency: data.group.baseCurrency,
      emoji: data.group.emoji,
      isDemo: data.group.isDemo,
    );

    final memberIds = <String, String>{};
    for (final m in data.members) {
      final created = await groups.addMember(group.id, m.name, colorIndex: m.colorIndex);
      memberIds[m.id] = created.id;
    }
    String mapMember(String id) => memberIds[id]!;

    final templateIds = <String, String>{};
    for (final t in data.templates) {
      final id = Ids.next();
      templateIds[t.id] = id;
      await recurring.upsertTemplate(
        RecurringTemplate(
          id: id,
          groupId: group.id,
          description: t.description,
          amount: t.amount,
          paidByMemberId: mapMember(t.paidByMemberId),
          category: t.category,
          splitType: t.splitType,
          shares: [
            for (final s in t.shares)
              ExpenseShare(memberId: mapMember(s.memberId), amountMinor: s.amountMinor, splitValue: s.splitValue),
          ],
          conversionRate: t.conversionRate,
          notes: t.notes,
          frequency: t.frequency,
          interval: t.interval,
          nextDueDate: t.nextDueDate,
          isActive: t.isActive,
          createdAt: t.createdAt,
          lastGeneratedAt: t.lastGeneratedAt,
        ),
      );
    }

    for (final e in data.expenses) {
      await expenses.upsertExpense(
        Expense(
          id: Ids.next(),
          groupId: group.id,
          description: e.description,
          amount: e.amount,
          paidByMemberId: mapMember(e.paidByMemberId),
          category: e.category,
          date: e.date,
          splitType: e.splitType,
          shares: [
            for (final s in e.shares)
              ExpenseShare(memberId: mapMember(s.memberId), amountMinor: s.amountMinor, splitValue: s.splitValue),
          ],
          conversionRate: e.conversionRate,
          notes: e.notes,
          recurringTemplateId: e.recurringTemplateId == null ? null : templateIds[e.recurringTemplateId],
          createdAt: e.createdAt,
          updatedAt: e.updatedAt,
        ),
      );
    }

    for (final s in data.settlements) {
      await settlements.upsertSettlement(
        Settlement(
          id: Ids.next(),
          groupId: group.id,
          fromMemberId: mapMember(s.fromMemberId),
          toMemberId: mapMember(s.toMemberId),
          amount: s.amount,
          conversionRate: s.conversionRate,
          date: s.date,
          note: s.note,
          createdAt: s.createdAt,
        ),
      );
    }

    await groups.touch(group.id);
    return (await groups.getGroup(group.id)) ?? group.copyWith(updatedAt: _clock());
  }
}
