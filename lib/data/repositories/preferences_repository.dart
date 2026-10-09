import 'package:drift/drift.dart';

import '../../core/money/currency.dart';
import '../../domain/models/models.dart';
import '../db/app_database.dart';

/// Key/value preferences with typed accessors.
class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  static const _themeMode = 'themeMode';
  static const _defaultCurrency = 'defaultCurrency';
  static const _settlementMode = 'settlementMode';
  static const _demoSeeded = 'demoSeeded';
  static const _autoGenerateRecurring = 'autoGenerateRecurring';

  Stream<AppPreferences> watch() => _db.select(_db.settingEntries).watch().map(_fromRows);

  Future<AppPreferences> get() async => _fromRows(await _db.select(_db.settingEntries).get());

  AppPreferences _fromRows(List<SettingEntryRow> rows) {
    final map = {for (final r in rows) r.key: r.value};
    return AppPreferences(
      themeMode: AppThemeMode.fromKey(map[_themeMode]),
      defaultCurrency: Currencies.byCode(map[_defaultCurrency] ?? '') ?? Currencies.usd,
      settlementMode: SettlementMode.fromKey(map[_settlementMode]),
      demoSeeded: map[_demoSeeded] == 'true',
      autoGenerateRecurring: map[_autoGenerateRecurring] != 'false',
    );
  }

  Future<void> _set(String key, String value) => _db
      .into(_db.settingEntries)
      .insertOnConflictUpdate(SettingEntriesCompanion(key: Value(key), value: Value(value)));

  Future<void> setThemeMode(AppThemeMode mode) => _set(_themeMode, mode.key);
  Future<void> setDefaultCurrency(Currency currency) => _set(_defaultCurrency, currency.code);
  Future<void> setSettlementMode(SettlementMode mode) => _set(_settlementMode, mode.key);
  Future<void> setDemoSeeded(bool value) => _set(_demoSeeded, value.toString());
  Future<void> setAutoGenerateRecurring(bool value) => _set(_autoGenerateRecurring, value.toString());
}
