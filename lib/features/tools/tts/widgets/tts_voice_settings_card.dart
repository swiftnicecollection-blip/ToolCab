import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controller/tts_controller.dart';
import '../data/models/tts_language.dart';

/// Voice settings card with language, speed, pitch, and volume controls.
class TtsVoiceSettingsCard extends GetView<TtsController> {
  const TtsVoiceSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Section title
          Row(
            children: <Widget>[
              const Icon(
                Icons.tune_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Voice Settings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Language selector
          _LanguageSelector(),
          const SizedBox(height: AppSpacing.lg),

          // Speed slider
          Obx(
            () => _SliderControl(
              icon: Icons.speed_rounded,
              label: 'Speed',
              valueLabel: '${controller.speed.value.toStringAsFixed(1)}x',
              value: controller.speed.value,
              min: 0.5,
              max: 2,
              divisions: 15,
              onChanged: controller.setSpeed,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Pitch slider
          Obx(
            () => _SliderControl(
              icon: Icons.music_note_rounded,
              label: 'Pitch',
              valueLabel: controller.pitch.value.toStringAsFixed(1),
              value: controller.pitch.value,
              min: 0.5,
              max: 2,
              divisions: 15,
              onChanged: controller.setPitch,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Volume slider
          Obx(
            () => _SliderControl(
              icon: Icons.volume_up_rounded,
              label: 'Volume',
              valueLabel: '${(controller.volume.value * 100).round()}%',
              value: controller.volume.value,
              min: 0,
              max: 1,
              divisions: 10,
              onChanged: controller.setVolume,
            ),
          ),
        ],
      ),
    );
  }
}

/// Language selector dropdown.
class _LanguageSelector extends GetView<TtsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
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
                controller.selectedLanguage.flagEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Language',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      controller.selectedLanguage.name,
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
                    final TtsLanguage lang = controller.languages[index];
                    final bool isSelected =
                        lang.code == controller.selectedLanguageCode.value;
                    return ListTile(
                      leading: Text(
                        lang.flagEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(lang.name),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        controller.selectLanguage(lang.code);
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
}

/// Slider control with icon, label, and value display.
class _SliderControl extends StatelessWidget {
  const _SliderControl({
    required this.icon,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    valueLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: AppColors.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
