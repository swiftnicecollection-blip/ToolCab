import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controller/stt_controller.dart';

/// Premium microphone card with recording animation and status.
class SttRecordingCard extends GetView<SttController> {
  const SttRecordingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final SttState state = controller.state.value;
        final bool isActive = state == SttState.listening;
        final bool isPaused = state == SttState.paused;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? <Color>[
                      AppColors.categorySpeech.withValues(alpha: 0.20),
                      AppColors.primary.withValues(alpha: 0.05),
                    ]
                  : <Color>[
                      AppColors.categorySpeech.withValues(alpha: 0.10),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: AppShadows.medium,
            border: Border.all(
              color: isActive
                  ? AppColors.categorySpeech.withValues(alpha: 0.4)
                  : Theme.of(context).colorScheme.outlineVariant.withValues(
                        alpha: 0.3,
                      ),
            ),
          ),
          child: Column(
            children: <Widget>[
              // Animated microphone
              _AnimatedMicrophone(isActive: isActive, isPaused: isPaused),
              const SizedBox(height: AppSpacing.lg),

              // Status text
              Text(
                _statusText(state),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isActive
                          ? AppColors.categorySpeech
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Recording duration
              Text(
                controller.formattedDuration,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Returns the status text for the current state.
  String _statusText(SttState state) {
    switch (state) {
      case SttState.idle:
        return 'Tap to start listening';
      case SttState.listening:
        return 'Listening...';
      case SttState.paused:
        return 'Paused';
      case SttState.processing:
        return 'Processing...';
      case SttState.completed:
        return 'Transcription complete';
    }
  }
}

/// Animated microphone icon with pulse effect.
class _AnimatedMicrophone extends StatefulWidget {
  const _AnimatedMicrophone({
    required this.isActive,
    required this.isPaused,
  });

  final bool isActive;
  final bool isPaused;

  @override
  State<_AnimatedMicrophone> createState() => _AnimatedMicrophoneState();
}

class _AnimatedMicrophoneState extends State<_AnimatedMicrophone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedMicrophone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        final double scale =
            widget.isActive ? 1.0 + (_controller.value * 0.15) : 1.0;
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.categorySpeech
                : AppColors.categorySpeech.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.categorySpeech.withValues(
                  alpha: widget.isActive
                      ? 0.30 + (_controller.value * 0.20)
                      : 0.10,
                ),
                blurRadius: 24,
                spreadRadius: scale * 4,
              ),
            ],
          ),
          child: Transform.scale(
            scale: scale,
            child: Icon(
              widget.isPaused
                  ? Icons.pause_rounded
                  : widget.isActive
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
              size: 40,
              color: widget.isActive ? Colors.white : AppColors.categorySpeech,
            ),
          ),
        );
      },
    );
  }
}
