import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controller/tts_controller.dart';

/// Premium playback controls with animated buttons.
class TtsPlaybackControls extends GetView<TtsController> {
  const TtsPlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final bool isSpeaking = controller.isSpeaking.value;
        final bool isPaused = controller.isPaused.value;
        final bool isLoading = controller.isLoading.value;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.primary.withValues(alpha: 0.10),
                AppColors.secondary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Column(
            children: <Widget>[
              // Status text
              Text(
                isPaused
                    ? 'Paused'
                    : isSpeaking
                        ? 'Speaking...'
                        : 'Ready to speak',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isSpeaking
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Stop button
                  _ControlButton(
                    icon: Icons.stop_rounded,
                    label: 'Stop',
                    color: AppColors.error,
                    enabled: isSpeaking,
                    onTap: controller.stop,
                  ),
                  const SizedBox(width: AppSpacing.xl),

                  // Play / Pause / Resume button
                  _ControlButton(
                    icon: isPaused
                        ? Icons.play_arrow_rounded
                        : isSpeaking
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                    label: isPaused
                        ? 'Resume'
                        : isSpeaking
                            ? 'Pause'
                            : 'Play',
                    color: AppColors.primary,
                    enabled: !isLoading,
                    loading: isLoading,
                    onTap: isPaused
                        ? controller.resume
                        : isSpeaking
                            ? controller.pause
                            : controller.speak,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated control button with scale-on-press.
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: widget.loading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        size: 32,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
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
