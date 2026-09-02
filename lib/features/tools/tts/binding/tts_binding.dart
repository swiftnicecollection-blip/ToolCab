import 'package:get/get.dart';

import '../controller/tts_controller.dart';
import '../data/repositories/tts_repository.dart';
import '../service/tts_service.dart';

/// Bindings for the text-to-speech module.
class TtsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TtsService>(TtsService.new);
    Get.lazyPut<TtsRepository>(TtsRepository.new);
    Get.lazyPut<TtsController>(TtsController.new);
  }
}
