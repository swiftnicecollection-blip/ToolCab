import 'package:get/get.dart';

import '../controller/stt_controller.dart';
import '../data/repositories/stt_repository.dart';
import '../service/speech_recognition_service.dart';

/// Bindings for the speech-to-text module.
class SttBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpeechRecognitionService>(SpeechRecognitionService.new);
    Get.lazyPut<SttRepository>(SttRepository.new);
    Get.lazyPut<SttController>(SttController.new);
  }
}
