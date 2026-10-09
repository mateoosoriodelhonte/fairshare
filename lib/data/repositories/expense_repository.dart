import 'package:drift/drift.dart';

import '../../domain/models/models.dart';
import '../db/app_database.dart';
import '../mappers.dart';
import 'errors.dart';

/// Expenses and their materialised shares.
class ExpenseRepository {
  ExpenseRepository(this._db);

  final AppDatabase _db;

  /// Expenses for a group, newest first (by date, then creation time).
  Stream<List<Expense>> watchExpenses(String groupId) {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(_db.expenseShares, _db.expenseShares.expenseId.equalsExp(_db.expenses.id)),
    ])..where(_db.expenses.groupId.equals(groupId));
    return query.watch().map(_assemble);
  }

  Future<List<Expense>> getExpenses(String groupId) async {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(_db.expenseShares, _db.expenseShares.expenseId.equalsExp(_db.expenses.id)),
    ])..where(_db.expenses.groupId.equals(groupId));
    return _assemble(await query.get());
  }

  Future<Expense?> getExpense(String id) async {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(_db.expenseShares, _db.expenseShares.expenseId.equalsExp(_db.expenses.id)),
    ])..where(_db.expenses.id.equals(id));
    final list = _assemble(await query.get());
    return list.isEmpty ? null : list.single;
  }

  Stream<Expense?> watchExpense(String id) {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(_db.expenseShares, _db.expenseShares.expenseId.equalsExp(_db.expenses.id)),
    ])..where(_db.expenses.id.equals(id));
    return query.watch().map((rows) {
      final list = _assemble(rows);
      return list.isEmpty ? null : list.single;
    });
  }

  List<Expense> _assemble(List<TypedResult> rows) {
    final byId = <String, ExpenseRow>{};
    final shares = <String, List<ExpenseShareRow>>{};
    for (final row in rows) {
      final e = row.readTable(_db.expenses);
      byId[e.id] = e;
      final s = row.readTableOrNull(_db.expenseShares);
      if (s != null) shares.putIfAbsent(e.id, () => []).add(s);
    }
    final result = [for (final e in byId.values) Mappers.toExpense(e, shares[e.id] ?? const [])];
    result.sort((a, b) {
      final cmp = b.date.compareTo(a.date);
      return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
    });
    return result;
  }

  /// Inserts or replaces an expense together with its shares, atomically.
  Future<void> upsertExpense(Expense expense) async {
    if (!expense.isConsistent) {
      throw const DomainRuleException('Shares must add up to the expense amount.');
    }
    if (expense.shares.isEmpty) {
      throw const DomainRuleException('An expense needs at least one participant.');
    }
    await _db.transaction(() async {
      await _db.into(_db.expenses).insertOnConflictUpdate(Mappers.fromExpense(expense));
      await (_db.delete(_db.expenseShares)..where((s) => s.expenseId.equals(expense.id))).go();
      await _db.batch((b) => b.insertAll(_db.expenseShares, Mappers.fromExpenseShares(expense)));
      await (_db.update(
        _db.groups,
      )..where((g) => g.id.equals(expense.groupId))).write(GroupsCompanion(updatedAt: Value(expense.updatedAt)));
    });
  }

  Future<void> deleteExpense(String id) => (_db.delete(_db.expenses)..where((e) => e.id.equals(id))).go();

  Future<int> countForGroup(String groupId) async {
    final count = _db.expenses.id.count();
    final query = _db.selectOnly(_db.expenses)
      ..addColumns([count])
      ..where(_db.expenses.groupId.equals(groupId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
