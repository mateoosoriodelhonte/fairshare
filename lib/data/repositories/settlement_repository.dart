import 'package:drift/drift.dart';

import '../../domain/models/models.dart';
import '../db/app_database.dart';
import '../mappers.dart';
import 'errors.dart';

/// Manual settlement records. FairShare never moves money; these are notes
/// that money changed hands elsewhere.
class SettlementRepository {
  SettlementRepository(this._db);

  final AppDatabase _db;

  Stream<List<Settlement>> watchSettlements(String groupId) =>
      (_db.select(_db.settlements)
            ..where((s) => s.groupId.equals(groupId))
            ..orderBy([(s) => OrderingTerm.desc(s.date), (s) => OrderingTerm.desc(s.createdAt)]))
          .watch()
          .map((rows) => rows.map(Mappers.toSettlement).toList());

  Future<List<Settlement>> getSettlements(String groupId) =>
      (_db.select(_db.settlements)
            ..where((s) => s.groupId.equals(groupId))
            ..orderBy([(s) => OrderingTerm.desc(s.date)]))
          .get()
          .then((rows) => rows.map(Mappers.toSettlement).toList());

  Future<void> upsertSettlement(Settlement settlement) async {
    if (!settlement.amount.isPositive) {
      throw const DomainRuleException('Settlement amount must be greater than zero.');
    }
    if (settlement.fromMemberId == settlement.toMemberId) {
      throw const DomainRuleException('Choose two different people.');
    }
    await _db.transaction(() async {
      await _db.into(_db.settlements).insertOnConflictUpdate(Mappers.fromSettlement(settlement));
      await (_db.update(
        _db.groups,
      )..where((g) => g.id.equals(settlement.groupId))).write(GroupsCompanion(updatedAt: Value(settlement.createdAt)));
    });
  }

  Future<void> deleteSettlement(String id) => (_db.delete(_db.settlements)..where((s) => s.id.equals(id))).go();
}
