import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/models/recent_file_item.dart';

/// Recent file tile with preview, delete, and share actions.
class RecentFileTile extends StatelessWidget {
  const RecentFileTile({super.key, required this.file});

  /// The file to display.
  final RecentFileItem file;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppShadows.soft,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
        ),
      ),
      child: Row(
        children: <Widget>[
          // File icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: file.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(file.icon, color: file.color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${file.type} • ${DateFormat('MMM d, yyyy').format(file.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          // Actions
          _FileAction(
            icon: Icons.visibility_outlined,
            tooltip: 'Preview',
            onTap: () {
              // TODO: Open file preview.
            },
          ),
          _FileAction(
            icon: Icons.share_outlined,
            tooltip: 'Share',
            onTap: () {
              // TODO: Share file.
            },
          ),
          _FileAction(
            icon: Icons.delete_outline,
            tooltip: 'Delete',
            color: AppColors.error,
            onTap: () {
              // TODO: Delete file.
            },
          ),
        ],
      ),
    );
  }
}

/// Small circular action button for file tiles.
class _FileAction extends StatelessWidget {
  const _FileAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = color ?? AppColors.grey500;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
