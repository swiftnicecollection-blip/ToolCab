import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Utility for building responsive layouts across devices.
///
/// Provides breakpoint helpers and adaptive sizing based on
/// the current screen dimensions.
abstract final class ResponsiveUtils {
  /// Whether the current device is a small phone (< 360dp width).
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < 360;
  }

  /// Whether the current device is a phone (< 600dp width).
  static bool isPhone(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppSpacing.tabletBreakpoint;
  }

  /// Whether the current device is a tablet (>= 600dp width).
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
  }

  /// Whether the current device is a large tablet / desktop (>= 960dp width).
  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppSpacing.desktopBreakpoint;
  }

  /// Returns the current device type.
  static DeviceType deviceType(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width < 360) {
      return DeviceType.smallPhone;
    } else if (width < AppSpacing.tabletBreakpoint) {
      return DeviceType.phone;
    } else if (width < AppSpacing.desktopBreakpoint) {
      return DeviceType.tablet;
    }
    return DeviceType.desktop;
  }

  /// Returns the number of grid columns for a given context.
  ///
  /// - Small phones: 2 columns
  /// - Phones: 2 columns
  /// - Tablets: 3 columns
  /// - Desktop: 4 columns
  static int gridColumns(BuildContext context) {
    final DeviceType type = deviceType(context);
    switch (type) {
      case DeviceType.smallPhone:
      case DeviceType.phone:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 4;
    }
  }

  /// Returns the horizontal screen padding for the current device.
  static double screenPadding(BuildContext context) {
    return isTablet(context) ? 32.0 : 20.0;
  }

  /// Returns the maximum content width for the current device.
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return AppSpacing.maxContentWidth;
    }
    return MediaQuery.sizeOf(context).width;
  }

  /// Returns a responsive value based on the current device type.
  static T responsive<T>({
    required BuildContext context,
    required T phone,
    T? smallPhone,
    T? tablet,
    T? desktop,
  }) {
    final DeviceType type = deviceType(context);
    switch (type) {
      case DeviceType.smallPhone:
        return smallPhone ?? phone;
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }
}

/// Device type classification based on screen width.
enum DeviceType {
  /// Small phones (< 360dp).
  smallPhone,

  /// Standard phones (360-599dp).
  phone,

  /// Tablets (600-959dp).
  tablet,

  /// Large tablets / desktop (>= 960dp).
  desktop,
}
