import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/initialization_service.dart';

/// Controller for the splash screen.
///
/// Handles initialization, session checking, and navigation
/// after the splash animation completes.
class SplashController extends GetxController {
  /// Whether initialization is complete.
  final RxBool isInitialized = RxBool(false);

  /// Whether initialization failed.
  final RxBool hasError = RxBool(false);

  /// Error message if initialization failed.
  final RxString errorMessage = RxString('');

  /// Whether the splash animation has completed.
  final RxBool animationComplete = RxBool(false);

  /// Whether navigation has been triggered.
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Run initialization and splash animation in parallel.
      final InitializationService initService =
          Get.find<InitializationService>();

      // Start initialization.
      final Future<void> initFuture = initService.initialize();

      // Ensure minimum splash duration for a smooth experience.
      final Future<void> splashFuture = Future<void>.delayed(
        AppConstants.splashDuration,
      );

      // Wait for both to complete.
      await Future.wait<void>(<Future<void>>[initFuture, splashFuture]);

      isInitialized.value = true;
      animationComplete.value = true;

      // Navigate directly to Home.
      _navigateToHome();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Something went wrong. Please try again.';
      isInitialized.value = true;
      animationComplete.value = true;
    }
  }

  /// Navigates directly to the Home screen.
  void _navigateToHome() {
    if (_navigated) {
      return;
    }
    _navigated = true;
    Get.offAllNamed(AppRoutes.home);
  }

  /// Retries initialization after an error.
  Future<void> retry() async {
    hasError.value = false;
    errorMessage.value = '';
    isInitialized.value = false;
    _navigated = false;
    await _initialize();
  }
}
