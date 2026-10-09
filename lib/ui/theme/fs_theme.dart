import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'fs_palette.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

/// Builds the light and dark [ThemeData] for FairShare.
///
/// Design intent: calm neutral surfaces, one teal accent, no drop shadows
/// (hairlines and tone separate layers), generous radii, Inter everywhere.
class FsTheme {
  FsTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    palette: FsPalette.light,
    scheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0F766E),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD5F0EC),
      onPrimaryContainer: Color(0xFF0B3B37),
      secondary: Color(0xFF5B5F66),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFEDEBE6),
      onSecondaryContainer: Color(0xFF2C2E31),
      tertiary: Color(0xFFB7791F),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFBEFD6),
      onTertiaryContainer: Color(0xFF4A2F05),
      error: Color(0xFFD1453B),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFBE4E1),
      onErrorContainer: Color(0xFF5A1612),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1B1B1A),
      onSurfaceVariant: Color(0xFF6B6A66),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF7F6F3),
      surfaceContainer: Color(0xFFF1F0EC),
      surfaceContainerHigh: Color(0xFFEAE9E4),
      surfaceContainerHighest: Color(0xFFE3E1DB),
      surfaceDim: Color(0xFFDCDAD4),
      surfaceBright: Color(0xFFFFFFFF),
      outline: Color(0xFFC4C2BB),
      outlineVariant: Color(0xFFE6E4DE),
      inverseSurface: Color(0xFF2E2F31),
      onInverseSurface: Color(0xFFF2F1EE),
      inversePrimary: Color(0xFF7FD9CF),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFF0F766E),
    ),
    scaffoldBackground: const Color(0xFFF7F6F3),
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    palette: FsPalette.dark,
    scheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF5BD6CA),
      onPrimary: Color(0xFF00332F),
      primaryContainer: Color(0xFF144441),
      onPrimaryContainer: Color(0xFFBDF0EA),
      secondary: Color(0xFFB0B4BB),
      onSecondary: Color(0xFF1E2124),
      secondaryContainer: Color(0xFF2B2F34),
      onSecondaryContainer: Color(0xFFE2E4E8),
      tertiary: Color(0xFFE2B254),
      onTertiary: Color(0xFF3B2A05),
      tertiaryContainer: Color(0xFF3B2E10),
      onTertiaryContainer: Color(0xFFF8E3B4),
      error: Color(0xFFF07B72),
      onError: Color(0xFF3D0B08),
      errorContainer: Color(0xFF3C1A17),
      onErrorContainer: Color(0xFFFAD4D0),
      surface: Color(0xFF17191C),
      onSurface: Color(0xFFF1F1EE),
      onSurfaceVariant: Color(0xFFA3A49F),
      surfaceContainerLowest: Color(0xFF0E1012),
      surfaceContainerLow: Color(0xFF131518),
      surfaceContainer: Color(0xFF1C1F23),
      surfaceContainerHigh: Color(0xFF23272C),
      surfaceContainerHighest: Color(0xFF2C3035),
      surfaceDim: Color(0xFF0E1012),
      surfaceBright: Color(0xFF34383E),
      outline: Color(0xFF4A4F56),
      outlineVariant: Color(0xFF2A2E33),
      inverseSurface: Color(0xFFF1F1EE),
      onInverseSurface: Color(0xFF1B1B1A),
      inversePrimary: Color(0xFF0F766E),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFF5BD6CA),
    ),
    scaffoldBackground: const Color(0xFF0E1012),
  );

  static ThemeData _build({
    required Brightness brightness,
    required FsPalette palette,
    required ColorScheme scheme,
    required Color scaffoldBackground,
  }) {
    final text = FsType.textTheme(primary: scheme.onSurface, secondary: scheme.onSurfaceVariant);
    final isDark = brightness == Brightness.dark;
    final cardColor = isDark ? scheme.surfaceContainer : scheme.surfaceContainerLowest;
    final roundedLg = RoundedRectangleBorder(borderRadius: BorderRadius.circular(FsRadius.lg));
    final roundedMd = RoundedRectangleBorder(borderRadius: BorderRadius.circular(FsRadius.md));

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: FsType.fontFamily,
      textTheme: text,
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: [palette],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.macOS: FsPageTransitionsBuilder(),
          TargetPlatform.windows: FsPageTransitionsBuilder(),
          TargetPlatform.linux: FsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        toolbarHeight: 56,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FsRadius.lg),
          side: BorderSide(color: palette.hairline),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.hairline, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: roundedMd,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: text.labelLarge,
          minimumSize: const Size(44, 44),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: roundedMd,
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: text.labelLarge,
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(44, 44),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: roundedMd,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          textStyle: text.labelLarge,
          minimumSize: const Size(44, 40),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: scheme.onSurfaceVariant, minimumSize: const Size(40, 40)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: roundedLg,
        extendedTextStyle: text.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant.withValues(alpha: 0.7)),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: text.labelMedium?.copyWith(color: scheme.primary),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall?.copyWith(color: scheme.error),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(FsRadius.md), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FsRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FsRadius.md),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FsRadius.md),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(FsRadius.md),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: roundedMd,
        contentPadding: const EdgeInsets.symmetric(horizontal: FsSpace.lg, vertical: 2),
        titleTextStyle: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall,
        iconColor: scheme.onSurfaceVariant,
        minVerticalPadding: 10,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FsRadius.xl)),
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(FsRadius.xl))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: roundedMd,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        insetPadding: const EdgeInsets.all(FsSpace.lg),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelType: NavigationRailLabelType.all,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? scheme.surfaceContainer : scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: roundedMd,
          side: BorderSide(color: scheme.outlineVariant),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          textStyle: text.labelMedium,
          visualDensity: VisualDensity.compact,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FsRadius.pill)),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: Colors.transparent,
        selectedColor: scheme.primaryContainer,
        labelStyle: text.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: false,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.onPrimary : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? scheme.primary : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: scheme.inverseSurface, borderRadius: BorderRadius.circular(FsRadius.sm)),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
        waitDuration: const Duration(milliseconds: 500),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: roundedMd,
        color: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStatePropertyAll(roundedMd),
          backgroundColor: WidgetStatePropertyAll(isDark ? scheme.surfaceContainerHigh : scheme.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: isDark ? scheme.surfaceContainerHigh : scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FsRadius.xl)),
        headerHeadlineStyle: text.headlineMedium,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary, linearTrackColor: palette.chartTrack),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.onSurfaceVariant.withValues(alpha: 0.35)),
        radius: const Radius.circular(FsRadius.pill),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}

/// A quiet fade-through: the incoming page fades in while rising 12px; the
/// outgoing page fades slightly. Used on desktop where horizontal slides feel
/// out of place.
class FsPageTransitionsBuilder extends PageTransitionsBuilder {
  const FsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) return child;
    final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    final rise = Tween<Offset>(
      begin: const Offset(0, 0.015),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: FsMotion.emphasized));
    final dim = Tween<double>(
      begin: 1,
      end: 0.92,
    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut));
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: rise,
        child: FadeTransition(opacity: dim, child: child),
      ),
    );
  }
}
