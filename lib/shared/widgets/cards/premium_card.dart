import 'package:flutter/material.dart';

import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// Premium elevated card with soft shadows and rounded corners.
///
/// Provides a layered, modern card design with optional
/// gradient background, border, and press animation.
class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppInsets.card,
    this.margin,
    this.borderRadius = AppSpacing.radiusLg,
    this.elevation,
    this.color,
    this.gradient,
    this.border,
    this.animate = true,
  });

  /// Card content.
  final Widget child;

  /// Optional tap callback.
  final VoidCallback? onTap;

  /// Card padding.
  final EdgeInsetsGeometry padding;

  /// Card margin.
  final EdgeInsetsGeometry? margin;

  /// Corner radius.
  final double borderRadius;

  /// Shadow list.
  final List<BoxShadow>? elevation;

  /// Background color.
  final Color? color;

  /// Optional gradient background.
  final Gradient? gradient;

  /// Optional border.
  final Border? border;

  /// Whether to animate on press.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final Color bg = color ?? Theme.of(context).cardTheme.color!;
    final BoxDecoration decoration = BoxDecoration(
      color: gradient == null ? bg : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: elevation ?? AppShadows.medium,
    );

    final Widget card = Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (!animate || onTap == null) {
      return card;
    }

    return _PressableCard(child: card);
  }
}

/// Wraps a card with a subtle scale animation on press.
class _PressableCard extends StatefulWidget {
  const _PressableCard({required this.child});

  final Widget child;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
