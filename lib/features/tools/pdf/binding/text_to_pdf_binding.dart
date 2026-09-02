import 'package:get/get.dart';

import '../controller/text_to_pdf_controller.dart';
import '../data/repositories/draft_repository.dart';
import '../data/repositories/pdf_repository.dart';
import '../service/text_to_pdf_service.dart';

/// Bindings for the Text → PDF module.
class TextToPdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TextToPdfService>(TextToPdfService.new);
    Get.lazyPut<PdfRepository>(PdfRepository.new);
    Get.lazyPut<DraftRepository>(DraftRepository.new);
    Get.lazyPut<TextToPdfController>(TextToPdfController.new);
  }
}
