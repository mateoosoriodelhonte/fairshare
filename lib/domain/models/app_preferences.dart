import 'package:meta/meta.dart';

import '../../core/money/currency.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  String get key => name;

  static AppThemeMode fromKey(String? key) =>
      AppThemeMode.values.firstWhere((e) => e.name == key, orElse: () => AppThemeMode.system);
}

/// How settlement suggestions are produced.
enum SettlementMode {
  /// Net everyone's balances and propose a short list of transfers.
  simplified,

  /// Show the literal pairwise debts (who paid for whom).
  direct;

  String get key => name;

  static SettlementMode fromKey(String? key) =>
      SettlementMode.values.firstWhere((e) => e.name == key, orElse: () => SettlementMode.simplified);
}

/// User-level preferences. Persisted as key/value rows.
@immutable
class AppPreferences {
  const AppPreferences({
    this.themeMode = AppThemeMode.system,
    this.defaultCurrency = Currencies.usd,
    this.settlementMode = SettlementMode.simplified,
    this.demoSeeded = false,
    this.autoGenerateRecurring = true,
  });

  final AppThemeMode themeMode;
  final Currency defaultCurrency;
  final SettlementMode settlementMode;

  /// Whether the demo group has been created at least once.
  final bool demoSeeded;

  /// Materialise due recurring expenses automatically on launch.
  final bool autoGenerateRecurring;

  AppPreferences copyWith({
    AppThemeMode? themeMode,
    Currency? defaultCurrency,
    SettlementMode? settlementMode,
    bool? demoSeeded,
    bool? autoGenerateRecurring,
  }) => AppPreferences(
    themeMode: themeMode ?? this.themeMode,
    defaultCurrency: defaultCurrency ?? this.defaultCurrency,
    settlementMode: settlementMode ?? this.settlementMode,
    demoSeeded: demoSeeded ?? this.demoSeeded,
    autoGenerateRecurring: autoGenerateRecurring ?? this.autoGenerateRecurring,
  );

  @override
  bool operator ==(Object other) =>
      other is AppPreferences &&
      other.themeMode == themeMode &&
      other.defaultCurrency == defaultCurrency &&
      other.settlementMode == settlementMode &&
      other.demoSeeded == demoSeeded &&
      other.autoGenerateRecurring == autoGenerateRecurring;

  @override
  int get hashCode => Object.hash(themeMode, defaultCurrency, settlementMode, demoSeeded, autoGenerateRecurring);
}
