import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/theme_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Settings view.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            // Appearance section
            const _SettingsSectionHeader(
              title: 'Appearance',
              subtitle: 'Customize your visual experience',
              icon: Icons.palette_outlined,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsCard(
              child: Obx(
                () => SwitchListTile(
                  secondary: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      themeService.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: themeService.isDarkMode,
                  onChanged: (_) => themeService.toggleTheme(),
                  activeTrackColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // General section
            const _SettingsSectionHeader(
              title: 'General',
              subtitle: 'App preferences',
              icon: Icons.settings_applications_rounded,
              color: AppColors.categoryTools,
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsCard(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              subtitle: 'Manage app notifications',
              onTap: () => Get.toNamed(AppRoutes.notifications),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              icon: Icons.storage_rounded,
              label: 'Storage',
              subtitle: 'Manage local storage and data',
              onTap: () => Get.snackbar(
                'Storage',
                'Storage settings coming soon.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              icon: Icons.translate_rounded,
              label: 'Language',
              subtitle: 'Choose app language',
              trailing: Text(
                'English',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              onTap: () => Get.snackbar(
                'Language',
                'Language selection coming soon.',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Support section
            const _SettingsSectionHeader(
              title: 'Support',
              subtitle: 'Help and resources',
              icon: Icons.support_agent_rounded,
              color: AppColors.categoryQr,
            ),
            const SizedBox(height: AppSpacing.md),
            _SettingsCard(
              icon: Icons.help_outline_rounded,
              label: 'Help & Support',
              subtitle: 'Get help with ToolCab',
              onTap: () => Get.toNamed(AppRoutes.help),
            ),
            const SizedBox(height: AppSpacing.sm),
            _SettingsCard(
              icon: Icons.info_outline_rounded,
              label: 'About',
              subtitle: 'Version and app information',
              onTap: () => Get.toNamed(AppRoutes.about),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // About footer
            Center(
              child: Column(
                children: <Widget>[
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'ToolCab',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'All-in-One AI Productivity Toolkit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Privacy note
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.shield_outlined,
                    size: 20,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Free • No login required • Your data stays on your device.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header with icon and description.
class _SettingsSectionHeader extends StatelessWidget {
  const _SettingsSectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Settings card with icon, title, subtitle, and optional child.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    this.icon,
    this.label,
    this.subtitle,
    this.onTap,
    this.child,
    this.trailing,
  });

  final IconData? icon;
  final String? label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    if (child != null) {
      return Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: child,
        ),
      );
    }

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            leading: icon != null
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 20),
                  )
                : null,
            title: label != null
                ? Text(
                    label!,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  )
                : null,
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  )
                : null,
            trailing: trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.grey400,
                ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
