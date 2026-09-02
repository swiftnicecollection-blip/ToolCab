import 'package:get/get.dart';

import '../controller/onboarding_controller.dart';

/// Bindings for the onboarding flow.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(OnboardingController.new);
  }
}
