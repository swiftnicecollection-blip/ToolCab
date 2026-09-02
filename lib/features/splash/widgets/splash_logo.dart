import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// Splash logo with glow effect.
///
/// The [fadeProgress] and [scaleProgress] values are driven by the
/// parent splash view's animation timeline so the logo can be
/// choreographed as part of a staggered sequence.
class SplashLogo extends StatelessWidget {
  const SplashLogo({
    super.key,
    this.size = 96,
    this.fadeProgress = 1.0,
    this.scaleProgress = 1.0,
  });

  /// Logo size.
  final double size;

  /// Fade-in progress (0.0 → 1.0).
  final double fadeProgress;

  /// Scale-up progress (0.0 → 1.0).
  final double scaleProgress;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: fadeProgress.clamp(0.0, 1.0),
      child: Transform.scale(
        scale: 0.6 + (scaleProgress.clamp(0.0, 1.0) * 0.4),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: AppShadows.primary(AppColors.primary),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }
}
