import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

/// Premium hero section for the ToolCab home screen.
///
/// Features a subtle 3D-layered card composition, floating productivity
/// icons, and an animated gradient background — all lightweight and fast.
class HomeHeroCard extends StatefulWidget {
  const HomeHeroCard({super.key});

  @override
  State<HomeHeroCard> createState() => _HomeHeroCardState();
}

class _HomeHeroCardState extends State<HomeHeroCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 0.99 : 1.0,
        duration: AppAnimations.quick,
        curve: AppAnimations.easeOut,
        child: AnimatedContainer(
          duration: AppAnimations.standard,
          curve: AppAnimations.easeOutCubic,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
          ),
          padding: EdgeInsets.all(
            isTablet ? AppSpacing.xxl : AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? <Color>[
                      AppColors.darkSurface,
                      AppColors.darkBackground,
                    ]
                  : <Color>[
                      AppColors.lightSurface,
                      AppColors.lightSurfaceVariant,
                    ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: _hovered ? AppShadows.medium : AppShadows.soft,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Stack(
            children: <Widget>[
              // Background gradient orb
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.primary
                            .withValues(alpha: isDark ? 0.25 : 0.12),
                        AppColors.primary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.secondary
                            .withValues(alpha: isDark ? 0.15 : 0.08),
                        AppColors.secondary.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Top row: badge + icons
                  Row(
                    children: <Widget>[
                      // "AI Productivity" badge
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  'AI Productivity Toolkit',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Floating mini icons
                      const _MiniIcon(
                        icon: Icons.document_scanner_rounded,
                        color: AppColors.categoryOcr,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const _MiniIcon(
                        icon: Icons.translate_rounded,
                        color: AppColors.categoryTranslation,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    'Everything you need,\nin one place.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Convert, translate, scan, organize, and optimize — all in one beautifully designed toolkit.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick stats row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _StatItem(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Tools',
                        count: '11+',
                        color: AppColors.primary,
                      ),
                      _StatItem(
                        icon: Icons.local_print_shop_rounded,
                        label: 'PDF Features',
                        count: '6',
                        color: AppColors.categoryPdf,
                      ),
                      _StatItem(
                        icon: Icons.shield_outlined,
                        label: 'Local-First',
                        count: '🔒',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating mini icon button in hero.
class _MiniIcon extends StatelessWidget {
  const _MiniIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppAnimations.slowest + const Duration(milliseconds: 200),
      curve: AppAnimations.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        final double clamped = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: clamped,
          child: Transform.translate(
            offset: Offset(0, -8 * (1 - clamped)),
            child: Transform.scale(scale: clamped, child: child),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

/// Stat item in hero.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          count,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
