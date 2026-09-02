import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Animated gradient background with floating shapes for the splash screen.
class AnimatedSplashBackground extends StatefulWidget {
  const AnimatedSplashBackground({super.key, required this.child});

  /// Child widget displayed on top of the background.
  final Widget child;

  @override
  State<AnimatedSplashBackground> createState() =>
      _AnimatedSplashBackgroundState();
}

class _AnimatedSplashBackgroundState extends State<AnimatedSplashBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  AppColors.darkGradientStart,
                  AppColors.darkGradientEnd,
                ]
              : <Color>[
                  AppColors.lightGradientStart,
                  AppColors.lightGradientEnd,
                ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          // Animated gradient blobs
          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return Stack(
                children: <Widget>[
                  _FloatingShape(
                    animation: _controller,
                    offset: const Offset(0.1, 0.1),
                    size: 200,
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  _FloatingShape(
                    animation: _controller,
                    offset: const Offset(0.8, 0.2),
                    size: 150,
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  _FloatingShape(
                    animation: _controller,
                    offset: const Offset(0.2, 0.7),
                    size: 120,
                    color: AppColors.accent.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  _FloatingShape(
                    animation: _controller,
                    offset: const Offset(0.7, 0.8),
                    size: 100,
                    color: AppColors.primary.withValues(alpha: 0.05),
                    shape: BoxShape.rectangle,
                  ),
                  _FloatingShape(
                    animation: _controller,
                    offset: const Offset(0.5, 0.4),
                    size: 80,
                    color: AppColors.secondary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ],
              );
            },
          ),
          // Content
          widget.child,
        ],
      ),
    );
  }
}

/// A single floating shape with animated position and rotation.
class _FloatingShape extends StatelessWidget {
  const _FloatingShape({
    required this.animation,
    required this.offset,
    required this.size,
    required this.color,
    required this.shape,
  });

  final Animation<double> animation;
  final Offset offset;
  final double size;
  final Color color;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double t = animation.value;
        final double driftX = math.sin(t * 2 * math.pi) * 20;
        final double driftY = math.cos(t * 2 * math.pi) * 15;
        final double rotation = t * 2 * math.pi * 0.5;

        return Positioned(
          left:
              MediaQuery.sizeOf(context).width * offset.dx - size / 2 + driftX,
          top:
              MediaQuery.sizeOf(context).height * offset.dy - size / 2 + driftY,
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: shape,
                borderRadius: shape == BoxShape.rectangle
                    ? BorderRadius.circular(24)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
