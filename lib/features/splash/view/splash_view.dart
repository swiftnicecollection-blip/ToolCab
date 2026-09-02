import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../controller/splash_controller.dart';
import '../widgets/animated_splash_background.dart';
import '../widgets/splash_logo.dart';

/// Splash screen with premium animated background and branding.
///
/// Animation timeline:
/// - 0–1s: Logo fade in
/// - 1–2s: Logo scale
/// - 2–3s: Tagline animation
/// - 3–4s: Loading animation
/// - 4s:   Navigate automatically (handled by [SplashController])
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashBackground(
        child: SafeArea(
          child: Obx(
            () {
              if (controller.hasError.value) {
                return _ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.retry,
                );
              }
              return _StaggeredSplashContent();
            },
          ),
        ),
      ),
    );
  }
}

/// Splash content driven by a single staggered animation timeline.
class _StaggeredSplashContent extends StatefulWidget {
  @override
  State<_StaggeredSplashContent> createState() =>
      _StaggeredSplashContentState();
}

class _StaggeredSplashContentState extends State<_StaggeredSplashContent>
    with SingleTickerProviderStateMixin {
  /// Total animation timeline length (4s matching [AppConstants.splashDuration]).
  static const Duration _timelineDuration = Duration(seconds: 4);

  late final AnimationController _controller;

  // Logo fade: 0–1s
  late final Animation<double> _logoFade;

  // Logo scale: 1–2s
  late final Animation<double> _logoScale;

  // Tagline fade + slide: 2–3s
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  // App name fade + slide: 1.8–2.6s
  late final Animation<double> _nameOpacity;
  late final Animation<Offset> _nameSlide;

  // Loading indicator: 3–4s
  late final Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _timelineDuration,
    );

    // 0–1s: Logo fade in
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.25, curve: Curves.easeOut),
      ),
    );

    // 1–2s: Logo scale (handled via CurvedAnimation on wider interval)
    _logoScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // 1.8–2.6s: App name fade + slide
    _nameOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.65, curve: Curves.easeOut),
      ),
    );
    _nameSlide =
        Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // 2–3s: Tagline fade + slide
    _taglineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // 3–4s: Loading indicator
    _loadingOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Animated logo (fade 0–1s, scale 1–2s)
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return SplashLogo(
                  size: MediaQuery.sizeOf(context).width < 360 ? 80 : 96,
                  fadeProgress: _logoFade.value,
                  scaleProgress: _logoScale.value,
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // App name (fade + slide 1.8–2.6s)
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _nameOpacity.value,
                  child: Transform.translate(
                    offset: _nameSlide.value,
                    child: child,
                  ),
                );
              },
              child: Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Tagline (fade + slide 2–3s)
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _taglineOpacity.value,
                  child: Transform.translate(
                    offset: _taglineSlide.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  AppConstants.tagline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Loading indicator (fade 3–4s)
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Opacity(
                  opacity: _loadingOpacity.value,
                  child: child,
                );
              },
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error view with retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Unable to Start',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Try Again',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
