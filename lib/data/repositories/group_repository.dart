import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../../core/money/currency.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';
import '../mappers.dart';
import 'errors.dart';

/// Groups and their members.
class GroupRepository {
  GroupRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Number of distinct avatar colours; mirrors the palette in the UI layer.
  static const int avatarPaletteSize = 10;

  Stream<List<Group>> watchGroups() =>
      (_db.select(_db.groups)..orderBy([(g) => OrderingTerm.desc(g.updatedAt), (g) => OrderingTerm.asc(g.name)]))
          .watch()
          .map((rows) => rows.map(Mappers.toGroup).toList());

  Future<List<Group>> getGroups() => (_db.select(
    _db.groups,
  )..orderBy([(g) => OrderingTerm.desc(g.updatedAt)])).get().then((rows) => rows.map(Mappers.toGroup).toList());

  Stream<Group?> watchGroup(String id) => (_db.select(
    _db.groups,
  )..where((g) => g.id.equals(id))).watchSingleOrNull().map((r) => r == null ? null : Mappers.toGroup(r));

  Future<Group?> getGroup(String id) => (_db.select(
    _db.groups,
  )..where((g) => g.id.equals(id))).getSingleOrNull().then((r) => r == null ? null : Mappers.toGroup(r));

  Future<Group> createGroup({
    required String name,
    required Currency baseCurrency,
    String emoji = '👥',
    bool isDemo = false,
    String? id,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const DomainRuleException('Give the group a name.');
    }
    final now = _clock();
    final group = Group(
      id: id ?? Ids.next(),
      name: trimmed,
      baseCurrency: baseCurrency,
      emoji: emoji,
      isDemo: isDemo,
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.groups).insert(Mappers.fromGroup(group));
    return group;
  }

  Future<void> updateGroup(Group group) async {
    if (group.name.trim().isEmpty) {
      throw const DomainRuleException('Give the group a name.');
    }
    final updated = group.copyWith(name: group.name.trim(), updatedAt: _clock());
    final rows = await (_db.update(_db.groups)..where((g) => g.id.equals(group.id))).write(Mappers.fromGroup(updated));
    if (rows == 0) throw NotFoundException('Group', group.id);
  }

  /// Marks the group as recently active so it sorts first on the dashboard.
  Future<void> touch(String groupId) =>
      (_db.update(_db.groups)..where((g) => g.id.equals(groupId))).write(GroupsCompanion(updatedAt: Value(_clock())));

  /// Deletes the group and, via cascading foreign keys, all of its members,
  /// expenses, settlements and templates.
  Future<void> deleteGroup(String id) => (_db.delete(_db.groups)..where((g) => g.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Members
  // ---------------------------------------------------------------------------

  Stream<List<Member>> watchMembers(String groupId) =>
      (_db.select(_db.members)
            ..where((m) => m.groupId.equals(groupId))
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .watch()
          .map((rows) => rows.map(Mappers.toMember).toList());

  Future<List<Member>> getMembers(String groupId) =>
      (_db.select(_db.members)
            ..where((m) => m.groupId.equals(groupId))
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .get()
          .then((rows) => rows.map(Mappers.toMember).toList());

  Future<Member> addMember(String groupId, String name, {int? colorIndex, String? id}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const DomainRuleException('Give the member a name.');
    }
    final existing = await getMembers(groupId);
    if (existing.any((m) => m.name.toLowerCase() == trimmed.toLowerCase())) {
      throw DomainRuleException('"$trimmed" is already in this group.');
    }
    final member = Member(
      id: id ?? Ids.next(),
      groupId: groupId,
      name: trimmed,
      colorIndex: colorIndex ?? existing.length % avatarPaletteSize,
      createdAt: _clock(),
    );
    await _db.into(_db.members).insert(Mappers.fromMember(member));
    await touch(groupId);
    return member;
  }

  Future<void> updateMember(Member member) async {
    final trimmed = member.name.trim();
    if (trimmed.isEmpty) {
      throw const DomainRuleException('Give the member a name.');
    }
    final siblings = await getMembers(member.groupId);
    if (siblings.any((m) => m.id != member.id && m.name.toLowerCase() == trimmed.toLowerCase())) {
      throw DomainRuleException('"$trimmed" is already in this group.');
    }
    final rows = await (_db.update(
      _db.members,
    )..where((m) => m.id.equals(member.id))).write(Mappers.fromMember(member.copyWith(name: trimmed)));
    if (rows == 0) throw NotFoundException('Member', member.id);
  }

  /// True when any expense, share, settlement or template references the member.
  Future<bool> isMemberReferenced(String memberId) async {
    final paid =
        await (_db.select(_db.expenses)
              ..where((e) => e.paidByMemberId.equals(memberId))
              ..limit(1))
            .get();
    if (paid.isNotEmpty) return true;
    final shares =
        await (_db.select(_db.expenseShares)
              ..where((s) => s.memberId.equals(memberId))
              ..limit(1))
            .get();
    if (shares.isNotEmpty) return true;
    final settled =
        await (_db.select(_db.settlements)
              ..where((s) => s.fromMemberId.equals(memberId) | s.toMemberId.equals(memberId))
              ..limit(1))
            .get();
    if (settled.isNotEmpty) return true;
    final templates =
        await (_db.select(_db.recurringTemplates)
              ..where((t) => t.paidByMemberId.equals(memberId))
              ..limit(1))
            .get();
    if (templates.isNotEmpty) return true;
    final templateShares =
        await (_db.select(_db.recurringTemplateShares)
              ..where((s) => s.memberId.equals(memberId))
              ..limit(1))
            .get();
    return templateShares.isNotEmpty;
  }

  /// Removes a member. Refused when the member appears in any ledger entry,
  /// because deleting them would silently change other people's balances.
  Future<void> deleteMember(String memberId) async {
    if (await isMemberReferenced(memberId)) {
      throw const DomainRuleException(
        'This person has expenses or settlements in the group. Remove those first, or keep them as a member.',
      );
    }
    await (_db.delete(_db.members)..where((m) => m.id.equals(memberId))).go();
  }
}
