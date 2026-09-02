import 'package:get/get.dart';

import '../../core/services/initialization_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/theme_service.dart';

/// Global bindings for application-wide services.
///
/// These services are available throughout the entire app lifecycle.
class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.put<StorageService>(StorageService.instance, permanent: true);
    Get.put<ThemeService>(ThemeService(), permanent: true);
    Get.put<NavigationService>(NavigationService(), permanent: true);
    Get.put<InitializationService>(InitializationService(), permanent: true);
  }
}
