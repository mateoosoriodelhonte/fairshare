import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// The single SQLite database behind FairShare.
///
/// Lives in the platform's application support directory and is never
/// uploaded or synced by the app. Use [AppDatabase.inMemory] in tests.
@DriftDatabase(
  tables: [
    Groups,
    Members,
    RecurringTemplates,
    RecurringTemplateShares,
    Expenses,
    ExpenseShares,
    Settlements,
    SettingEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Volatile database for tests and previews.
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  /// Opens (or creates) the persistent on-device database.
  factory AppDatabase.open({String name = 'fairshare'}) => AppDatabase(driftDatabase(name: name));

  @override
  int get schemaVersion => 1;

  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
