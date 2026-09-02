import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Premium loading indicator with optional label.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.label, this.size = 32, this.color});

  /// Optional label below the spinner.
  final String? label;

  /// Spinner size.
  final double size;

  /// Spinner color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: color ?? AppColors.primary,
            ),
          ),
          if (label != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              label!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen loading overlay.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key, this.label});

  /// Optional label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
      child: LoadingIndicator(label: label),
    );
  }
}
