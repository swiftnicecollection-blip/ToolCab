import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controller/stt_controller.dart';
import '../data/models/stt_history_entry.dart';
import '../widgets/stt_history_tile.dart';
import '../widgets/stt_recording_card.dart';
import '../widgets/stt_transcript_editor.dart';

/// Speech-to-Text screen.
///
/// Features:
/// - Live microphone card with recording animation
/// - Real-time transcript editor
/// - Recording controls (start, pause, resume, stop, clear)
/// - Transcript actions (copy, share, save, send to TTS)
/// - History with search and sort
class SttView extends GetView<SttController> {
  const SttView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio → Text'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.snackbar(
              'History',
              'Scroll down to view your transcription history.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            ),
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

              // Language selector
              _LanguageSelector(),
              const SizedBox(height: AppSpacing.xl),

              // Recording card
              const SttRecordingCard(),
              const SizedBox(height: AppSpacing.xl),

              // Transcript editor
              const SttTranscriptEditor(),
              const SizedBox(height: AppSpacing.xl),

              // Recording controls
              _RecordingControls(),
              const SizedBox(height: AppSpacing.xl),

              // Transcript actions
              _TranscriptActions(),
              const SizedBox(height: AppSpacing.xl),

              // History section
              const SectionHeader(
                title: 'History',
                subtitle: 'Your recent transcriptions.',
              ),
              const SizedBox(height: AppSpacing.md),
              _HistorySection(),
            ],
          ),
        ),
      ),
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
              Icons.mic_rounded,
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
                  'Convert Speech into\nText',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Capture meetings, lectures, interviews, and voice notes instantly.',
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

/// Language selector dropdown.
class _LanguageSelector extends GetView<SttController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: InkWell(
          onTap: () => _showLanguagePicker(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  _flagFor(controller.selectedLanguageCode.value),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Recognition Language',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      Text(
                        _nameFor(controller.selectedLanguageCode.value),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the language picker bottom sheet.
  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Select Language',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.languages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, String> lang =
                        controller.languages[index];
                    final bool isSelected =
                        lang['code'] == controller.selectedLanguageCode.value;
                    return ListTile(
                      leading: Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(lang['name']!),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        controller.selectLanguage(lang['code']!);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns the flag emoji for a language code.
  String _flagFor(String code) {
    for (final Map<String, String> lang in controller.languages) {
      if (lang['code'] == code) {
        return lang['flag']!;
      }
    }
    return '🇺🇸';
  }

  /// Returns the language name for a code.
  String _nameFor(String code) {
    for (final Map<String, String> lang in controller.languages) {
      if (lang['code'] == code) {
        return lang['name']!;
      }
    }
    return 'English (US)';
  }
}

/// Recording control buttons.
class _RecordingControls extends GetView<SttController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final SttState state = controller.state.value;
        final bool isListening = state == SttState.listening;
        final bool isPaused = state == SttState.paused;
        final bool isLoading = controller.isLoading.value;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Start / Resume button
              _ControlButton(
                icon: isPaused
                    ? Icons.play_arrow_rounded
                    : isListening
                        ? Icons.pause_rounded
                        : Icons.mic_rounded,
                label: isPaused
                    ? 'Resume'
                    : isListening
                        ? 'Pause'
                        : 'Start',
                color: AppColors.categorySpeech,
                enabled: !isLoading,
                loading: isLoading,
                onTap: isPaused
                    ? controller.resumeListening
                    : isListening
                        ? controller.pauseListening
                        : controller.startListening,
              ),
              const SizedBox(width: AppSpacing.xl),

              // Stop button
              _ControlButton(
                icon: Icons.stop_rounded,
                label: 'Stop',
                color: AppColors.error,
                enabled: isListening || isPaused,
                onTap: controller.stopListening,
              ),
              const SizedBox(width: AppSpacing.xl),

              // Clear button
              _ControlButton(
                icon: Icons.clear_rounded,
                label: 'Clear',
                color: AppColors.grey500,
                enabled: controller.transcriptController.text.isNotEmpty,
                onTap: controller.clearTranscript,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated control button.
class _ControlButton extends StatefulWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;
  final bool loading;

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.loading
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        size: 26,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Transcript action buttons.
class _TranscriptActions extends GetView<SttController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          _ActionChip(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: controller.copyTranscript,
          ),
          _ActionChip(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: controller.shareTranscript,
          ),
          _ActionChip(
            icon: Icons.save_alt_rounded,
            label: 'Save',
            onTap: controller.saveTranscript,
          ),
          _ActionChip(
            icon: Icons.record_voice_over_rounded,
            label: 'Text → Audio',
            onTap: controller.sendToTts,
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// History section with search, sort, and entries.
class _HistorySection extends GetView<SttController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Search + sort row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  onChanged: controller.onHistorySearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search history...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.newestFirst.value
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    size: 20,
                  ),
                  onPressed: controller.toggleSortOrder,
                  tooltip: controller.newestFirst.value
                      ? 'Newest first'
                      : 'Oldest first',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // History entries
        Obx(
          () {
            final List<SttHistoryEntry> entries = controller.filteredHistory;
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No transcriptions yet.',
                description:
                    'Your speech-to-text conversions will appear here.',
                iconColor: AppColors.grey400,
              );
            }

            return Column(
              children: <Widget>[
                for (int i = 0; i < entries.length; i++) ...<Widget>[
                  SttHistoryTile(
                    entry: entries[i],
                    onDelete: () =>
                        controller.deleteHistoryEntry(entries[i].id),
                  ),
                  if (i < entries.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
