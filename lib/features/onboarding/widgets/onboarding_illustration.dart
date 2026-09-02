import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';

/// Animated illustration for onboarding pages.
///
/// Displays a large icon in a gradient container with
/// floating decorative elements and a soft glow effect.
class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.icon,
    required this.color,
    this.size = 160,
  });

  /// Illustration icon.
  final IconData icon;

  /// Accent color.
  final Color color;

  /// Illustration size.
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        final double clamped = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clamped,
          child: Opacity(
            opacity: clamped,
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Glow effect
          Container(
            width: size * 1.4,
            height: size * 1.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: <Color>[
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          // Main icon container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  color.withValues(alpha: 0.20),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(icon, size: size * 0.4, color: color),
          ),
          // Decorative floating dot
          Positioned(
            top: size * 0.1,
            right: size * 0.15,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.30),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Decorative floating dot
          Positioned(
            bottom: size * 0.15,
            left: size * 0.1,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
