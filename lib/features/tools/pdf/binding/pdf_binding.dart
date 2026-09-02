import 'package:get/get.dart';

import '../controller/pdf_tools_controller.dart';
import '../data/repositories/pdf_repository.dart';
import '../service/pdf_file_service.dart';

/// Bindings for the PDF tools dashboard.
class PdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfFileService>(PdfFileService.new);
    Get.lazyPut<PdfRepository>(PdfRepository.new);
    Get.lazyPut<PdfToolsController>(PdfToolsController.new);
  }
}
