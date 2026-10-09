import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/repositories/repositories.dart';
import '../domain/accounting/accounting.dart';
import '../domain/group_snapshot.dart';
import '../domain/models/models.dart';

/// The database. Overridden in tests and widget previews with an in-memory
/// instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final groupRepositoryProvider = Provider<GroupRepository>((ref) => GroupRepository(ref.watch(databaseProvider)));
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository(ref.watch(databaseProvider)));
final settlementRepositoryProvider = Provider<SettlementRepository>(
  (ref) => SettlementRepository(ref.watch(databaseProvider)),
);
final recurringRepositoryProvider = Provider<RecurringRepository>(
  (ref) => RecurringRepository(ref.watch(databaseProvider)),
);
final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(ref.watch(databaseProvider)),
);

final preferencesProvider = StreamProvider<AppPreferences>((ref) => ref.watch(preferencesRepositoryProvider).watch());

final groupsProvider = StreamProvider<List<Group>>((ref) => ref.watch(groupRepositoryProvider).watchGroups());

final groupProvider = StreamProvider.family<Group?, String>(
  (ref, id) => ref.watch(groupRepositoryProvider).watchGroup(id),
);

final membersProvider = StreamProvider.family<List<Member>, String>(
  (ref, groupId) => ref.watch(groupRepositoryProvider).watchMembers(groupId),
);

final expensesProvider = StreamProvider.family<List<Expense>, String>(
  (ref, groupId) => ref.watch(expenseRepositoryProvider).watchExpenses(groupId),
);

final settlementsProvider = StreamProvider.family<List<Settlement>, String>(
  (ref, groupId) => ref.watch(settlementRepositoryProvider).watchSettlements(groupId),
);

final templatesProvider = StreamProvider.family<List<RecurringTemplate>, String>(
  (ref, groupId) => ref.watch(recurringRepositoryProvider).watchTemplates(groupId),
);

/// Joined view of a group. Emits loading until every stream has a value;
/// a missing group yields `null` data.
final groupSnapshotProvider = Provider.family<AsyncValue<GroupSnapshot?>, String>((ref, groupId) {
  final group = ref.watch(groupProvider(groupId));
  final members = ref.watch(membersProvider(groupId));
  final expenses = ref.watch(expensesProvider(groupId));
  final settlements = ref.watch(settlementsProvider(groupId));
  final templates = ref.watch(templatesProvider(groupId));

  for (final v in [group, members, expenses, settlements, templates]) {
    if (v.hasError) return AsyncValue.error(v.error!, v.stackTrace ?? StackTrace.empty);
  }
  if (!group.hasValue || !members.hasValue || !expenses.hasValue || !settlements.hasValue || !templates.hasValue) {
    return const AsyncValue.loading();
  }
  final g = group.value;
  if (g == null) return const AsyncValue.data(null);
  return AsyncValue.data(
    GroupSnapshot(
      group: g,
      members: members.value!,
      expenses: expenses.value!,
      settlements: settlements.value!,
      templates: templates.value!,
    ),
  );
});

/// Settlement suggestions according to the user's preferred mode.
final settlementSuggestionsProvider = Provider.family<AsyncValue<List<Transfer>>, String>((ref, groupId) {
  final snapshot = ref.watch(groupSnapshotProvider(groupId));
  final mode = ref.watch(preferencesProvider).value?.settlementMode ?? SettlementMode.simplified;
  return snapshot.whenData((s) => s == null ? const <Transfer>[] : s.suggestions(mode));
});

/// Snapshots for every group, for the dashboard. Groups whose data has not
/// loaded yet are omitted rather than blocking the whole list.
final allSnapshotsProvider = Provider<AsyncValue<List<GroupSnapshot>>>((ref) {
  final groups = ref.watch(groupsProvider);
  return groups.whenData((list) {
    final result = <GroupSnapshot>[];
    for (final g in list) {
      final snap = ref.watch(groupSnapshotProvider(g.id)).value;
      if (snap != null) result.add(snap);
    }
    return result;
  });
});
