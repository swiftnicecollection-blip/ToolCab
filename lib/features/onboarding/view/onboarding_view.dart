import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/buttons/secondary_button.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/animated_page_indicator.dart';
import '../widgets/onboarding_illustration.dart';

/// Onboarding screen with three premium feature pages.
///
/// Features:
/// - Animated PageView with smooth transitions
/// - Hero animations per page
/// - Skip, Next, and Back navigation
/// - "Get Started" → Signup, "Already Have Account" → Login
/// - Responsive layout for all devices
class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top bar: Skip button
            _TopBar(),
            // PageView with onboarding pages
            Expanded(
              child: Obx(
                () => PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.pageCount,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (BuildContext context, int index) {
                    return _OnboardingPage(item: _onboardingItems[index]);
                  },
                ),
              ),
            ),
            // Bottom section: indicator + buttons
            _BottomSection(),
          ],
        ),
      ),
    );
  }
}

/// Top bar with skip button (hidden on last page).
class _TopBar extends GetView<OnboardingController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: controller.isLastPage
            ? const SizedBox.shrink()
            : Align(
                key: const ValueKey<String>('skip'),
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: TextButton(
                    onPressed: controller.skip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Bottom section: page indicator + action buttons.
class _BottomSection extends GetView<OnboardingController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Animated page indicator
          Obx(
            () => AnimatedPageIndicator(
              currentIndex: controller.currentPage.value,
              pageCount: controller.pageCount,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Get Started / Next button
          Obx(
            () => PrimaryButton(
              label: controller.isLastPage ? 'Get Started' : 'Next',
              icon: controller.isLastPage ? null : Icons.arrow_forward,
              onPressed: controller.next,
              height: AppSpacing.buttonHeight,
            ),
          ),
          // "Already Have Account" button (only on last page)
          Obx(
            () => controller.isLastPage
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: SecondaryButton(
                      label: 'Skip Onboarding',
                      onPressed: controller.skip,
                      height: AppSpacing.buttonHeight,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Single onboarding page with animated content.
class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({required this.item});

  final _OnboardingItemData item;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 40),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _scaleIn = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _fadeIn.value,
          child: Transform.translate(
            offset: _slideUp.value,
            child: Transform.scale(
              scale: _scaleIn.value,
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Spacer to push content above center
            const Spacer(flex: 2),
            // Illustration
            OnboardingIllustration(
              icon: widget.item.icon,
              color: widget.item.color,
              size: MediaQuery.of(context).size.width < 360 ? 120 : 160,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            // Title
            Text(
              widget.item.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                widget.item.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
            ),
            // Spacer to balance layout
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

/// Data model for onboarding page content.
class _OnboardingItemData {
  const _OnboardingItemData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

/// Onboarding page content data matching the specification.
const List<_OnboardingItemData> _onboardingItems = <_OnboardingItemData>[
  _OnboardingItemData(
    icon: Icons.auto_awesome,
    title: 'AI Productivity,\nAll in One Place',
    description:
        'Convert speech, translate languages, scan documents, manage PDFs, '
        'and boost productivity from one beautifully designed application.',
    color: AppColors.primary,
  ),
  _OnboardingItemData(
    icon: Icons.description,
    title: 'Powerful Document\nTools',
    description:
        'Merge, split, compress, convert, and manage PDF documents quickly '
        'with an intuitive and modern experience.',
    color: AppColors.categoryPdf,
  ),
  _OnboardingItemData(
    icon: Icons.qr_code_scanner,
    title: 'Smart Utilities for\nEveryone',
    description:
        'Use OCR, QR Scanner, Calendar, and intelligent productivity tools '
        'designed to simplify your everyday work.',
    color: AppColors.categoryOcr,
  ),
];
