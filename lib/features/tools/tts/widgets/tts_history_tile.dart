import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../data/models/tts_history_entry.dart';

/// History tile for a text-to-speech entry.
class TtsHistoryTile extends StatelessWidget {
  const TtsHistoryTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  /// The history entry to display.
  final TtsHistoryEntry entry;

  /// Delete callback.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.categorySpeech.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: AppColors.categorySpeech,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.textPreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${entry.languageName} • ${DateFormat('MMM d, h:mm a').format(entry.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                if (entry.duration != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '~${entry.duration!.inSeconds}s • ${entry.speed.toStringAsFixed(1)}x speed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.categorySpeech,
                        ),
                  ),
                ],
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.error,
            ),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
