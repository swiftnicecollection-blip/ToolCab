import 'package:get/get.dart';

import '../../pdf/data/repositories/pdf_repository.dart';
import '../controller/merge_pdf_controller.dart';
import '../service/merge_pdf_service.dart';

/// Bindings for the Merge PDF module.
class MergePdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MergePdfService>(MergePdfService.new);
    Get.lazyPut<PdfRepository>(PdfRepository.new);
    Get.lazyPut<MergePdfController>(MergePdfController.new);
  }
}
