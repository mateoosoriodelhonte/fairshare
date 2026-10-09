import 'package:flutter/material.dart';

import '../../domain/models/expense_category.dart';

/// Semantic colours that Material's [ColorScheme] does not cover: balance
/// signs, avatars, categories, and chart series. Registered as a
/// [ThemeExtension] so widgets read it through `context.palette`.
@immutable
class FsPalette extends ThemeExtension<FsPalette> {
  const FsPalette({
    required this.positive,
    required this.onPositive,
    required this.positiveContainer,
    required this.negative,
    required this.onNegative,
    required this.negativeContainer,
    required this.warning,
    required this.warningContainer,
    required this.hairline,
    required this.avatarBackgrounds,
    required this.avatarForegrounds,
    required this.chartSeries,
    required this.categoryColors,
    required this.chartTrack,
  });

  /// "You are owed" / credit.
  final Color positive;
  final Color onPositive;
  final Color positiveContainer;

  /// "You owe" / debit.
  final Color negative;
  final Color onNegative;
  final Color negativeContainer;

  final Color warning;
  final Color warningContainer;

  /// One-pixel separators and card borders.
  final Color hairline;

  final List<Color> avatarBackgrounds;
  final List<Color> avatarForegrounds;

  /// Ordered series colours for charts.
  final List<Color> chartSeries;
  final Map<ExpenseCategory, Color> categoryColors;

  /// Background of bars/rings before data fills them.
  final Color chartTrack;

  Color avatarBackground(int index) => avatarBackgrounds[index % avatarBackgrounds.length];
  Color avatarForeground(int index) => avatarForegrounds[index % avatarForegrounds.length];
  Color category(ExpenseCategory c) => categoryColors[c] ?? chartSeries.last;
  Color series(int index) => chartSeries[index % chartSeries.length];

  /// Colour for a signed amount: positive, negative, or neutral text.
  Color forSign(int minorUnits, {required Color neutral}) =>
      minorUnits > 0 ? positive : (minorUnits < 0 ? negative : neutral);

  static const FsPalette light = FsPalette(
    positive: Color(0xFF1B8A5A),
    onPositive: Color(0xFFFFFFFF),
    positiveContainer: Color(0xFFDDF4E8),
    negative: Color(0xFFD1453B),
    onNegative: Color(0xFFFFFFFF),
    negativeContainer: Color(0xFFFBE4E1),
    warning: Color(0xFFB7791F),
    warningContainer: Color(0xFFFBEFD6),
    hairline: Color(0xFFE6E4DE),
    chartTrack: Color(0xFFEDEBE6),
    avatarBackgrounds: [
      Color(0xFFD9ECF7),
      Color(0xFFFBE2D5),
      Color(0xFFE2F1DD),
      Color(0xFFF2E1F5),
      Color(0xFFFCEFC7),
      Color(0xFFDDEFF0),
      Color(0xFFFADDE6),
      Color(0xFFE4E6F7),
      Color(0xFFE7EFD8),
      Color(0xFFF3E4D7),
    ],
    avatarForegrounds: [
      Color(0xFF1C5D85),
      Color(0xFF9A4A1E),
      Color(0xFF2F6B2A),
      Color(0xFF6E3A86),
      Color(0xFF7D5A05),
      Color(0xFF1F6B70),
      Color(0xFF9A2F55),
      Color(0xFF3A4194),
      Color(0xFF4D6618),
      Color(0xFF7A4A2A),
    ],
    chartSeries: [
      Color(0xFF0F766E),
      Color(0xFFE07A3F),
      Color(0xFF3B6FD6),
      Color(0xFFB8578E),
      Color(0xFF8A9A1C),
      Color(0xFFD9A400),
      Color(0xFF5B5F66),
    ],
    categoryColors: {
      ExpenseCategory.food: Color(0xFFE07A3F),
      ExpenseCategory.groceries: Color(0xFF5E9E3A),
      ExpenseCategory.drinks: Color(0xFFB8578E),
      ExpenseCategory.transport: Color(0xFF3B6FD6),
      ExpenseCategory.housing: Color(0xFF0F766E),
      ExpenseCategory.utilities: Color(0xFF6B7C93),
      ExpenseCategory.entertainment: Color(0xFF8E5BD6),
      ExpenseCategory.travel: Color(0xFF1F9BB5),
      ExpenseCategory.shopping: Color(0xFFD9A400),
      ExpenseCategory.health: Color(0xFFD1453B),
      ExpenseCategory.gifts: Color(0xFFE2558E),
      ExpenseCategory.other: Color(0xFF8A8C90),
    },
  );

  static const FsPalette dark = FsPalette(
    positive: Color(0xFF4CCB8A),
    onPositive: Color(0xFF00301B),
    positiveContainer: Color(0xFF123524),
    negative: Color(0xFFF07B72),
    onNegative: Color(0xFF3D0B08),
    negativeContainer: Color(0xFF3C1A17),
    warning: Color(0xFFE2B254),
    warningContainer: Color(0xFF3B2E10),
    hairline: Color(0xFF2A2E33),
    chartTrack: Color(0xFF24282D),
    avatarBackgrounds: [
      Color(0xFF1C3A4D),
      Color(0xFF4A2A1B),
      Color(0xFF203A1F),
      Color(0xFF3B2446),
      Color(0xFF433611),
      Color(0xFF173A3D),
      Color(0xFF461C2C),
      Color(0xFF26294A),
      Color(0xFF2E3A16),
      Color(0xFF3E2C20),
    ],
    avatarForegrounds: [
      Color(0xFF9FD3F2),
      Color(0xFFF2B693),
      Color(0xFFA8E0A0),
      Color(0xFFDDB6EC),
      Color(0xFFF2D889),
      Color(0xFF97DEE0),
      Color(0xFFF4A9C4),
      Color(0xFFB9BDF2),
      Color(0xFFC9E09A),
      Color(0xFFE7C3A6),
    ],
    chartSeries: [
      Color(0xFF4FD1C5),
      Color(0xFFF2A071),
      Color(0xFF7FA6F0),
      Color(0xFFD98BBE),
      Color(0xFFB7C85A),
      Color(0xFFF0C94A),
      Color(0xFF9A9FA6),
    ],
    categoryColors: {
      ExpenseCategory.food: Color(0xFFF2A071),
      ExpenseCategory.groceries: Color(0xFF8FCB6A),
      ExpenseCategory.drinks: Color(0xFFD98BBE),
      ExpenseCategory.transport: Color(0xFF7FA6F0),
      ExpenseCategory.housing: Color(0xFF4FD1C5),
      ExpenseCategory.utilities: Color(0xFF9AA9BE),
      ExpenseCategory.entertainment: Color(0xFFB591EC),
      ExpenseCategory.travel: Color(0xFF63C4DB),
      ExpenseCategory.shopping: Color(0xFFF0C94A),
      ExpenseCategory.health: Color(0xFFF07B72),
      ExpenseCategory.gifts: Color(0xFFF08AB4),
      ExpenseCategory.other: Color(0xFF9A9FA6),
    },
  );

  @override
  FsPalette copyWith({
    Color? positive,
    Color? onPositive,
    Color? positiveContainer,
    Color? negative,
    Color? onNegative,
    Color? negativeContainer,
    Color? warning,
    Color? warningContainer,
    Color? hairline,
    List<Color>? avatarBackgrounds,
    List<Color>? avatarForegrounds,
    List<Color>? chartSeries,
    Map<ExpenseCategory, Color>? categoryColors,
    Color? chartTrack,
  }) => FsPalette(
    positive: positive ?? this.positive,
    onPositive: onPositive ?? this.onPositive,
    positiveContainer: positiveContainer ?? this.positiveContainer,
    negative: negative ?? this.negative,
    onNegative: onNegative ?? this.onNegative,
    negativeContainer: negativeContainer ?? this.negativeContainer,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    hairline: hairline ?? this.hairline,
    avatarBackgrounds: avatarBackgrounds ?? this.avatarBackgrounds,
    avatarForegrounds: avatarForegrounds ?? this.avatarForegrounds,
    chartSeries: chartSeries ?? this.chartSeries,
    categoryColors: categoryColors ?? this.categoryColors,
    chartTrack: chartTrack ?? this.chartTrack,
  );

  @override
  FsPalette lerp(ThemeExtension<FsPalette>? other, double t) {
    if (other is! FsPalette) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return FsPalette(
      positive: c(positive, other.positive),
      onPositive: c(onPositive, other.onPositive),
      positiveContainer: c(positiveContainer, other.positiveContainer),
      negative: c(negative, other.negative),
      onNegative: c(onNegative, other.onNegative),
      negativeContainer: c(negativeContainer, other.negativeContainer),
      warning: c(warning, other.warning),
      warningContainer: c(warningContainer, other.warningContainer),
      hairline: c(hairline, other.hairline),
      avatarBackgrounds: [
        for (var i = 0; i < avatarBackgrounds.length; i++)
          c(avatarBackgrounds[i], other.avatarBackgrounds[i % other.avatarBackgrounds.length]),
      ],
      avatarForegrounds: [
        for (var i = 0; i < avatarForegrounds.length; i++)
          c(avatarForegrounds[i], other.avatarForegrounds[i % other.avatarForegrounds.length]),
      ],
      chartSeries: [
        for (var i = 0; i < chartSeries.length; i++) c(chartSeries[i], other.chartSeries[i % other.chartSeries.length]),
      ],
      categoryColors: {
        for (final e in categoryColors.entries) e.key: c(e.value, other.categoryColors[e.key] ?? e.value),
      },
      chartTrack: c(chartTrack, other.chartTrack),
    );
  }
}

extension FsPaletteContext on BuildContext {
  FsPalette get palette => Theme.of(this).extension<FsPalette>() ?? FsPalette.light;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
