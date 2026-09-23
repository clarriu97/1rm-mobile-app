/// Spacing scale (logical pixels).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner radii. Kept tight on purpose: machined steel, not pebbles.
class AppRadii {
  AppRadii._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
}

/// Minimum size for anything tappable.
const double kMinTapTarget = 48;
