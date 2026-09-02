import 'package:get/get.dart';

import '../controller/translator_controller.dart';
import '../data/repositories/translation_repository.dart';
import '../service/translation_service.dart';

/// Bindings for the translator module.
class TranslatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TranslationService>(TranslationService.new);
    Get.lazyPut<TranslationRepository>(TranslationRepository.new);
    Get.lazyPut<TranslatorController>(TranslatorController.new);
  }
}
