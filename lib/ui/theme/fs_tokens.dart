import 'package:flutter/animation.dart';

/// Spacing scale (logical pixels). Use these instead of magic numbers so
/// rhythm stays consistent across screens.
class FsSpace {
  FsSpace._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class FsRadius {
  FsRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double pill = 999;
}

/// Motion tokens. Durations are short and curves decelerate, so the UI feels
/// responsive rather than animated for its own sake.
class FsMotion {
  FsMotion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 420);
  static const Duration chart = Duration(milliseconds: 700);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve spring = Curves.easeOutBack;
}

/// Responsive breakpoints.
class FsLayout {
  FsLayout._();

  /// Below this width the app uses stack navigation without a sidebar.
  static const double compactMax = 760;

  /// Between compact and expanded the sidebar collapses to icons.
  static const double expandedMin = 1080;

  /// Reading-width cap for content columns on wide screens.
  static const double contentMaxWidth = 880;

  static const double sidebarWidth = 272;
  static const double railWidth = 80;
}
