import 'package:get/get.dart';

import '../controller/ocr_controller.dart';
import '../data/repositories/ocr_repository.dart';
import '../service/ocr_service.dart';

/// Bindings for the OCR module.
class OcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OcrService>(OcrService.new);
    Get.lazyPut<OcrRepository>(OcrRepository.new);
    Get.lazyPut<OcrController>(OcrController.new);
  }
}
