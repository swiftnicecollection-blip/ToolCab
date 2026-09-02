import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controller/tts_controller.dart';
import '../widgets/tts_history_tile.dart';
import '../widgets/tts_playback_controls.dart';
import '../widgets/tts_text_input_card.dart';
import '../widgets/tts_voice_settings_card.dart';

/// Text-to-Speech screen.
///
/// Features:
/// - Large text input with paste/copy/share/clear
/// - Voice settings (language, speed, pitch, volume)
/// - Premium playback controls
/// - History with local storage
class TtsView extends GetView<TtsController> {
  const TtsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text → Audio'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: _scrollToHistory,
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Get.toNamed(AppRoutes.help),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              _Header(),
              const SizedBox(height: AppSpacing.xl),

              // Text input card
              const TtsTextInputCard(),
              const SizedBox(height: AppSpacing.xl),

              // Voice settings
              const TtsVoiceSettingsCard(),
              const SizedBox(height: AppSpacing.xl),

              // Playback controls
              const TtsPlaybackControls(),
              const SizedBox(height: AppSpacing.xl),

              // History section
              const SectionHeader(
                title: 'History',
                subtitle: 'Your recent text-to-speech conversions.',
              ),
              const SizedBox(height: AppSpacing.md),
              _HistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Scrolls to the history section.
  void _scrollToHistory() {
    // Simple approach: show a snackbar since we don't have a scroll controller.
    Get.snackbar(
      'History',
      'Scroll down to view your history.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Header with illustration and headline.
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          // Illustration
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.categorySpeech,
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.categorySpeech.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Headline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Convert Text into\nNatural Speech',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Listen to documents, notes, articles, and more.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// History section with entries or empty state.
class _HistorySection extends GetView<TtsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.historyEntries.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No history yet.',
            description: 'Your text-to-speech conversions will appear here.',
            iconColor: AppColors.grey400,
          );
        }

        return Column(
          children: <Widget>[
            for (int i = 0;
                i < controller.historyEntries.length;
                i++) ...<Widget>[
              TtsHistoryTile(
                entry: controller.historyEntries[i],
                onDelete: () => controller
                    .deleteHistoryEntry(controller.historyEntries[i].id),
              ),
              if (i < controller.historyEntries.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}
