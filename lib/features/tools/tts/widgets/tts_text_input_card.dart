import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controller/tts_controller.dart';

/// Text input card with character/word counter and action buttons.
class TtsTextInputCard extends GetView<TtsController> {
  const TtsTextInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.medium,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Text field
          TextField(
            controller: controller.textController,
            maxLines: 6,
            minLines: 3,
            maxLength: controller.maxLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Type or paste text to convert to speech...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              border: InputBorder.none,
              counterText: '',
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Counter row
          Obx(
            () => Row(
              children: <Widget>[
                Icon(
                  Icons.text_fields_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${controller.charCount.value} chars',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.abc_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${controller.wordCount.value} words',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                Text(
                  '${controller.charCount.value}/${controller.maxLength}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: controller.charCount.value >=
                                controller.maxLength
                            ? AppColors.error
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Action buttons row
          Row(
            children: <Widget>[
              _ActionChip(
                icon: Icons.content_paste_rounded,
                label: 'Paste',
                onTap: controller.pasteText,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ActionChip(
                icon: Icons.copy_rounded,
                label: 'Copy',
                onTap: controller.copyText,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ActionChip(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: controller.shareText,
              ),
              const Spacer(),
              _ActionChip(
                icon: Icons.clear_rounded,
                label: 'Clear',
                color: AppColors.error,
                onTap: controller.clearText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small action chip button.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
