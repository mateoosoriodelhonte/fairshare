import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';
import '../mappers.dart';
import 'errors.dart';

/// Recurring templates and the materialisation of their due instances.
class RecurringRepository {
  RecurringRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<RecurringTemplate>> watchTemplates(String groupId) {
    final query = _db.select(_db.recurringTemplates).join([
      leftOuterJoin(
        _db.recurringTemplateShares,
        _db.recurringTemplateShares.templateId.equalsExp(_db.recurringTemplates.id),
      ),
    ])..where(_db.recurringTemplates.groupId.equals(groupId));
    return query.watch().map(_assemble);
  }

  Future<List<RecurringTemplate>> getTemplates(String groupId) async {
    final query = _db.select(_db.recurringTemplates).join([
      leftOuterJoin(
        _db.recurringTemplateShares,
        _db.recurringTemplateShares.templateId.equalsExp(_db.recurringTemplates.id),
      ),
    ])..where(_db.recurringTemplates.groupId.equals(groupId));
    return _assemble(await query.get());
  }

  Future<List<RecurringTemplate>> getAllActiveTemplates() async {
    final query = _db.select(_db.recurringTemplates).join([
      leftOuterJoin(
        _db.recurringTemplateShares,
        _db.recurringTemplateShares.templateId.equalsExp(_db.recurringTemplates.id),
      ),
    ])..where(_db.recurringTemplates.isActive.equals(true));
    return _assemble(await query.get());
  }

  Future<RecurringTemplate?> getTemplate(String id) async {
    final query = _db.select(_db.recurringTemplates).join([
      leftOuterJoin(
        _db.recurringTemplateShares,
        _db.recurringTemplateShares.templateId.equalsExp(_db.recurringTemplates.id),
      ),
    ])..where(_db.recurringTemplates.id.equals(id));
    final list = _assemble(await query.get());
    return list.isEmpty ? null : list.single;
  }

  List<RecurringTemplate> _assemble(List<TypedResult> rows) {
    final byId = <String, RecurringTemplateRow>{};
    final shares = <String, List<RecurringTemplateShareRow>>{};
    for (final row in rows) {
      final t = row.readTable(_db.recurringTemplates);
      byId[t.id] = t;
      final s = row.readTableOrNull(_db.recurringTemplateShares);
      if (s != null) shares.putIfAbsent(t.id, () => []).add(s);
    }
    final result = [for (final t in byId.values) Mappers.toTemplate(t, shares[t.id] ?? const [])];
    result.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return result;
  }

  Future<void> upsertTemplate(RecurringTemplate template) async {
    if (template.shares.isEmpty) {
      throw const DomainRuleException('A template needs at least one participant.');
    }
    final total = template.shares.fold<int>(0, (a, s) => a + s.amountMinor);
    if (total != template.amount.minorUnits || !template.amount.isPositive) {
      throw const DomainRuleException('Shares must add up to the template amount.');
    }
    await _db.transaction(() async {
      await _db.into(_db.recurringTemplates).insertOnConflictUpdate(Mappers.fromTemplate(template));
      await (_db.delete(_db.recurringTemplateShares)..where((s) => s.templateId.equals(template.id))).go();
      await _db.batch((b) => b.insertAll(_db.recurringTemplateShares, Mappers.fromTemplateShares(template)));
    });
  }

  Future<void> deleteTemplate(String id) => (_db.delete(_db.recurringTemplates)..where((t) => t.id.equals(id))).go();

  /// Creates an expense for every due occurrence of every active template, up
  /// to [until] (defaults to today), and advances each template's next due
  /// date. Returns the number of expenses created. Runs in one transaction so
  /// a crash cannot leave a template half-advanced.
  Future<int> generateDue({DateTime? until, String? groupId}) async {
    final limit = until ?? _clock();
    final templates = groupId == null
        ? await getAllActiveTemplates()
        : (await getTemplates(groupId)).where((t) => t.isActive).toList();
    var created = 0;
    await _db.transaction(() async {
      for (final t in templates) {
        final dates = t.dueDatesUntil(limit);
        if (dates.isEmpty) continue;
        final now = _clock();
        for (final date in dates) {
          final expense = Expense(
            id: Ids.next(),
            groupId: t.groupId,
            description: t.description,
            amount: t.amount,
            paidByMemberId: t.paidByMemberId,
            category: t.category,
            date: date,
            splitType: t.splitType,
            shares: t.shares,
            conversionRate: t.conversionRate,
            notes: t.notes,
            recurringTemplateId: t.id,
            createdAt: now,
            updatedAt: now,
          );
          await _db.into(_db.expenses).insert(Mappers.fromExpense(expense));
          await _db.batch((b) => b.insertAll(_db.expenseShares, Mappers.fromExpenseShares(expense)));
          created++;
        }
        var next = t.nextDueDate;
        while (!next.isAfter(DateTime(limit.year, limit.month, limit.day))) {
          next = t.nextAfter(next);
        }
        await (_db.update(_db.recurringTemplates)..where((r) => r.id.equals(t.id))).write(
          RecurringTemplatesCompanion(nextDueDate: Value(next), lastGeneratedAt: Value(now)),
        );
        await (_db.update(
          _db.groups,
        )..where((g) => g.id.equals(t.groupId))).write(GroupsCompanion(updatedAt: Value(now)));
      }
    });
    return created;
  }
}
