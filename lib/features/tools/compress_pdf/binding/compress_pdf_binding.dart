import 'package:get/get.dart';

import '../../pdf/data/repositories/pdf_repository.dart';
import '../controller/compress_pdf_controller.dart';
import '../service/compress_pdf_service.dart';

/// Bindings for the Compress PDF module.
class CompressPdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompressPdfService>(CompressPdfService.new);
    Get.lazyPut<PdfRepository>(PdfRepository.new);
    Get.lazyPut<CompressPdfController>(CompressPdfController.new);
  }
}
