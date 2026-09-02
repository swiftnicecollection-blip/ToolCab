import 'package:flutter/widgets.dart';

/// Spacing and dimension system for the ToolCab design system.
///
/// Provides a consistent, scalable spacing scale used throughout
/// the application for padding, margins, gaps, and component sizes.
abstract final class AppSpacing {
  /// Extra small — 2.0
  static const double xxs = 2;

  /// Extra small — 4.0
  static const double xs = 4;

  /// Small — 8.0
  static const double sm = 8;

  /// Medium — 12.0
  static const double md = 12;

  /// Large — 16.0
  static const double lg = 16;

  /// Extra large — 24.0
  static const double xl = 24;

  /// Double extra large — 32.0
  static const double xxl = 32;

  /// Triple extra large — 48.0
  static const double xxxl = 48;

  /// Quadruple extra large — 64.0
  static const double xxxxl = 64;

  // ---------------------------------------------------------------------------
  // Component Dimensions
  // ---------------------------------------------------------------------------

  /// Standard button height.
  static const double buttonHeight = 52;

  /// Small button height.
  static const double buttonHeightSmall = 40;

  /// Standard text field height.
  static const double textFieldHeight = 56;

  /// Standard icon container size.
  static const double iconContainer = 48;

  /// Small icon container size.
  static const double iconContainerSmall = 40;

  /// Large icon container size.
  static const double iconContainerLarge = 64;

  /// Standard avatar size.
  static const double avatar = 48;

  /// Large avatar size.
  static const double avatarLarge = 72;

  /// Standard card corner radius.
  static const double radiusSm = 8;

  /// Medium card corner radius.
  static const double radiusMd = 12;

  /// Large card corner radius.
  static const double radiusLg = 16;

  /// Extra large card corner radius.
  static const double radiusXl = 24;

  /// Pill / fully rounded radius.
  static const double radiusPill = 100;

  /// Standard card elevation.
  static const double elevationSm = 1;

  /// Medium card elevation.
  static const double elevationMd = 4;

  /// Large card elevation.
  static const double elevationLg = 8;

  /// Maximum content width for tablets / large screens.
  static const double maxContentWidth = 960;

  /// Maximum width for forms (login, signup).
  static const double maxFormWidth = 480;

  /// Breakpoint for tablet layouts.
  static const double tabletBreakpoint = 600;

  /// Breakpoint for large tablet / desktop layouts.
  static const double desktopBreakpoint = 960;
}

/// Responsive spacing helper that scales spacing based on screen width.
abstract final class ResponsiveSpacing {
  /// Returns a scaled spacing value based on device width.
  ///
  /// On small phones (< 360dp) returns the base value.
  /// On large phones/tablets scales proportionally up to 1.5x.
  static double scale(BuildContext context, double base) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < 360) {
      return base;
    } else if (width < 600) {
      return base * 1.1;
    } else if (width < 960) {
      return base * 1.3;
    }
    return base * 1.5;
  }
}

/// Edge insets helpers for consistent padding across the app.
abstract final class AppInsets {
  /// Screen horizontal padding — 20dp on phones, scales up on tablets.
  static EdgeInsets screen(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    final double horizontal = width >= 600 ? 32.0 : 20.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  /// Card padding — 16dp.
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.lg);

  /// Small card padding — 12dp.
  static const EdgeInsets cardSmall = EdgeInsets.all(AppSpacing.md);

  /// Button padding — horizontal 24, vertical 14.
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: 14,
  );

  /// Text field content padding.
  static const EdgeInsets textField = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: 14,
  );
}
