import 'package:get/get.dart';

import '../../pdf/data/repositories/pdf_repository.dart';
import '../controller/split_pdf_controller.dart';
import '../service/split_pdf_service.dart';

/// Bindings for the Split PDF module.
class SplitPdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplitPdfService>(SplitPdfService.new);
    Get.lazyPut<PdfRepository>(PdfRepository.new);
    Get.lazyPut<SplitPdfController>(SplitPdfController.new);
  }
}
