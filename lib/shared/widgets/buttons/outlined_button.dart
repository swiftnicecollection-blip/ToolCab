import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Outlined action button with border styling.
class OutlinedButtonWidget extends StatelessWidget {
  const OutlinedButtonWidget({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.height = AppSpacing.buttonHeight,
    this.borderColor,
    this.foregroundColor,
    this.borderRadius = AppSpacing.radiusMd,
  });

  /// Button label text.
  final String label;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button is in a loading state.
  final bool loading;

  /// Whether the button should expand to full width.
  final bool fullWidth;

  /// Button height.
  final double height;

  /// Custom border color.
  final Color? borderColor;

  /// Custom foreground (text/icon) color.
  final Color? foregroundColor;

  /// Border radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final Color fg = foregroundColor ?? AppColors.primary;
    final Color border = borderColor ?? Theme.of(context).colorScheme.outline;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          disabledForegroundColor: fg.withValues(alpha: 0.5),
          side: BorderSide(color: border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: loading
              ? SizedBox(
                  key: const ValueKey<String>('loading'),
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
                )
              : Row(
                  key: const ValueKey<String>('content'),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (icon != null) ...<Widget>[
                      Icon(icon, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: fg),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
