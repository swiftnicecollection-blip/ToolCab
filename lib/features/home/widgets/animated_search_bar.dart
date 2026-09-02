import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../controller/home_controller.dart';

/// Premium floating search bar with animated focus.
class AnimatedSearchBar extends GetView<HomeController> {
  const AnimatedSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: controller.isSearchFocused.value
              ? AppShadows.primary(AppColors.primary)
              : AppShadows.medium,
          border: Border.all(
            color: controller.isSearchFocused.value
                ? AppColors.primary.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
          ),
        ),
        child: TextField(
          onChanged: controller.onSearchChanged,
          onTap: () => controller.onSearchFocusChanged(true),
          onSubmitted: (_) => controller.onSearchFocusChanged(false),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search tools, files, history...',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: controller.isSearchFocused.value
                  ? AppColors.primary
                  : AppColors.grey500,
            ),
            suffixIcon: controller.isSearchFocused.value
                ? IconButton(
                    icon: const Icon(Icons.mic_none_rounded),
                    onPressed: () {
                      // Voice search placeholder (future feature).
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ),
    );
  }
}
