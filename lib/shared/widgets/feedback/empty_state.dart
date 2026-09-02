import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Empty state widget with icon, title, description, and optional action.
///
/// Features a soft gradient icon container, staggered entrance animation,
/// and a clear primary action for a premium, polished feel.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onActionTap,
    this.iconColor,
    this.compact = false,
  });

  /// Icon to display.
  final IconData icon;

  /// Title text.
  final String title;

  /// Optional description text.
  final String? description;

  /// Optional action button label.
  final String? actionLabel;

  /// Action button callback.
  final VoidCallback? onActionTap;

  /// Icon color.
  final Color? iconColor;

  /// Whether to use a compact layout (for inline sections).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color color = iconColor ?? AppColors.grey400;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          compact ? AppSpacing.lg : AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Animated gradient icon container
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: AppAnimations.slower,
              curve: AppAnimations.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: compact ? 64 : 80,
                height: compact ? 64 : 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.04),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(
                  icon,
                  size: compact ? 32 : 40,
                  color: color,
                ),
              ),
            ),
            SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),

            // Title with staggered entrance
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: AppAnimations.slower,
              curve: AppAnimations.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: (compact
                        ? Theme.of(context).textTheme.titleSmall
                        : Theme.of(context).textTheme.titleMedium)
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),

            if (description != null) ...<Widget>[
              SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: AppAnimations.slower,
                curve: AppAnimations.easeOutCubic,
                builder: (BuildContext context, double value, Widget? child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ),
            ],

            if (actionLabel != null && onActionTap != null) ...<Widget>[
              SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xl),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: AppAnimations.slowest,
                curve: AppAnimations.easeOutCubic,
                builder: (BuildContext context, double value, Widget? child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: FilledButton.tonalIcon(
                  onPressed: onActionTap,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
