import 'package:get/get.dart';

import '../controller/pdf_to_text_controller.dart';
import '../data/repositories/pdf_to_text_draft_repository.dart';
import '../data/repositories/pdf_to_text_repository.dart';
import '../service/pdf_ocr_service.dart';
import '../service/pdf_text_extraction_service.dart';

/// Bindings for the PDF → Text module.
class PdfToTextBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfTextExtractionService>(PdfTextExtractionService.new);
    Get.lazyPut<PdfOcrService>(PdfOcrService.new);
    Get.lazyPut<PdfToTextRepository>(PdfToTextRepository.new);
    Get.lazyPut<PdfToTextDraftRepository>(PdfToTextDraftRepository.new);
    Get.lazyPut<PdfToTextController>(PdfToTextController.new);
  }
}
