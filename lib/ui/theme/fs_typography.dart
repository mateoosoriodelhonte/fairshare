import 'package:flutter/material.dart';

/// Type scale built on Inter. Headlines are tight and heavy; body copy is
/// relaxed. Money always uses tabular figures so columns line up.
class FsType {
  FsType._();

  static const String fontFamily = 'Inter';

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme({required Color primary, required Color secondary}) {
    TextStyle s(double size, FontWeight weight, {double? height, double spacing = 0, Color? color}) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: color ?? primary,
    );
    return TextTheme(
      displayLarge: s(44, FontWeight.w700, height: 1.1, spacing: -1.2),
      displayMedium: s(36, FontWeight.w700, height: 1.1, spacing: -0.9),
      displaySmall: s(30, FontWeight.w700, height: 1.15, spacing: -0.6),
      headlineLarge: s(28, FontWeight.w700, height: 1.2, spacing: -0.5),
      headlineMedium: s(24, FontWeight.w600, height: 1.2, spacing: -0.4),
      headlineSmall: s(20, FontWeight.w600, height: 1.25, spacing: -0.2),
      titleLarge: s(18, FontWeight.w600, height: 1.3, spacing: -0.2),
      titleMedium: s(16, FontWeight.w600, height: 1.35, spacing: -0.1),
      titleSmall: s(14, FontWeight.w600, height: 1.4),
      bodyLarge: s(16, FontWeight.w400, height: 1.5),
      bodyMedium: s(14.5, FontWeight.w400, height: 1.5),
      bodySmall: s(13, FontWeight.w400, height: 1.45, color: secondary),
      labelLarge: s(14.5, FontWeight.w600, height: 1.3),
      labelMedium: s(13, FontWeight.w500, height: 1.3, spacing: 0.1),
      labelSmall: s(11.5, FontWeight.w600, height: 1.3, spacing: 0.4, color: secondary),
    );
  }
}

extension FsTextStyleX on TextStyle {
  /// Tabular figures for aligned numbers.
  TextStyle get tabular => copyWith(fontFeatures: FsType.tabular);

  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
}
