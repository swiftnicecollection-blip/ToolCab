import 'package:get/get.dart';

import '../controller/splash_controller.dart';

/// Bindings for the splash screen.
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(SplashController.new);
  }
}
