import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Centralized animation system for the ToolCab design system.
///
/// Provides consistent durations, curves, and animation patterns
/// used throughout the application for a premium, polished feel.
abstract final class AppAnimations {
  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  /// Fast — micro-interactions, button presses, icon toggles (80ms).
  static const Duration fast = Duration(milliseconds: 80);

  /// Quick — small element transitions, hover states (120ms).
  static const Duration quick = Duration(milliseconds: 120);

  /// Standard — card taps, navigation transitions, minor changes (200ms).
  static const Duration standard = Duration(milliseconds: 200);

  /// Slow — larger transitions, page fade-ins, bottom sheets (300ms).
  static const Duration slow = Duration(milliseconds: 300);

  /// Slower — onboarding / splash animations, prominent transitions (400ms).
  static const Duration slower = Duration(milliseconds: 400);

  /// Slowest — full-screen transitions, complex entrances (600ms).
  static const Duration slowest = Duration(milliseconds: 600);

  // ---------------------------------------------------------------------------
  // Curves
  // ---------------------------------------------------------------------------

  /// Standard ease-out curve for most UI transitions.
  static const Curve easeOut = Curves.easeOut;

  /// Standard ease-in curve for dismissals / exits.
  static const Curve easeIn = Curves.easeIn;

  /// Standard ease-in-out for symmetric transitions.
  static const Curve easeInOut = Curves.easeInOut;

  /// Cubic ease-out — smooth deceleration for premium feel.
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// Cubic ease-in — smooth acceleration for exits.
  static const Curve easeInCubic = Curves.easeInCubic;

  /// Cubic ease-in-out — smooth entrance & exit symmetry.
  static const Curve easeInOutCubic = Curves.easeInOutCubic;

  /// Elastic-out — playful scaling for success states and hero elements.
  static const Curve elasticOut = Curves.elasticOut;

  /// Back-out — subtle overshoot for attention-grabbing elements.
  static const Curve backOut = Curves.easeOutBack;

  /// Linear — for continuous progress indicators.
  static const Curve linear = Curves.linear;
}

/// Convenience animation helpers for common micro-interactions.
abstract final class AppMicroAnimations {
  /// Interactive press scale for tappable cards and buttons.
  static Widget pressScale({
    required BuildContext context,
    required bool pressed,
    required Widget child,
  }) {
    return AnimatedScale(
      scale: pressed ? 0.97 : 1.0,
      duration: AppAnimations.fast,
      curve: AppAnimations.easeOut,
      child: child,
    );
  }

  /// Opacity transition for loading / content swaps.
  static Widget fadeSwitch({
    required Widget child,
    Key? key,
    Duration duration = AppAnimations.standard,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: duration,
      switchInCurve: AppAnimations.easeOutCubic,
      switchOutCurve: AppAnimations.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animated countup / value display.
  static Widget valueChange({
    required Widget child,
    Key? key,
  }) {
    return AnimatedSwitcher(
      key: key,
      duration: AppAnimations.quick,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Animation durations for use in GetX transitions.
abstract final class AppRouteTransitions {
  /// Page transition duration for route changes.
  static const Duration pageTransition = AppAnimations.slow;

  /// Default fade-in transition.
  static const Transition defaultTransition = Transition.fadeIn;

  /// Slide-right for tool/detail navigation.
  static const Transition detailTransition = Transition.rightToLeft;

  /// Subtle zoom transition for modal/accent screens.
  static const Transition modalTransition = Transition.zoom;
}
