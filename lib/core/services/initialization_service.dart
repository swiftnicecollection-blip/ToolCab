import 'package:get/get.dart';

import 'storage_service.dart';
import 'theme_service.dart';

/// Service responsible for application initialization.
///
/// Initializes all core local services asynchronously without blocking the UI.
class InitializationService extends GetxService {
  /// Whether initialization is in progress.
  final RxBool isInitializing = RxBool(false);

  /// Whether initialization completed successfully.
  final RxBool isInitialized = RxBool(false);

  /// Whether initialization failed.
  final RxBool hasError = RxBool(false);

  /// Error message if initialization failed.
  final RxString errorMessage = RxString('');

  /// Initializes all application services.
  ///
  /// Each service is initialized independently with error handling
  /// so a single failure doesn't block the entire app.
  Future<void> initialize() async {
    isInitializing.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Initialize local storage (Hive).
      await StorageService.instance.init();

      // Load saved theme preference.
      await Get.find<ThemeService>().init();

      isInitialized.value = true;
    } catch (e) {
      hasError.value = true;
      errorMessage.value =
          'Failed to initialize application. Please try again.';
    } finally {
      isInitializing.value = false;
    }
  }
}
