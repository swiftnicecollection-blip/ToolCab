import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_routes.dart';

/// Controller for the onboarding flow.
///
/// Manages page navigation and completion state.
class OnboardingController extends GetxController {
  /// Page controller for the onboarding PageView.
  final PageController pageController = PageController();

  /// Current page index.
  final RxInt currentPage = RxInt(0);

  /// Total number of onboarding pages.
  final int pageCount = 3;

  /// Whether the user is on the last page.
  bool get isLastPage => currentPage.value == pageCount - 1;

  /// Called when the PageView page changes.
  // ignore: use_setters_to_change_properties
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  /// Advances to the next page or completes onboarding.
  void next() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      currentPage.value++;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Goes back to the previous page.
  void previous() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Skips onboarding entirely.
  Future<void> skip() async {
    await completeOnboarding();
  }

  /// Completes onboarding and navigates to home.
  Future<void> completeOnboarding() async {
    unawaited(Get.offAllNamed(AppRoutes.home));
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
