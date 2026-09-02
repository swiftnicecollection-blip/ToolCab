import 'package:get/get.dart';

import '../../history/data/models/history_entry.dart';
import '../controller/home_controller.dart';
import '../data/repositories/notifications_repository.dart';
import '../data/repositories/recent_files_repository.dart';

/// Bindings for the home dashboard.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<RecentFilesRepository>(RecentFilesRepository.new);
    Get.lazyPut<HistoryRepository>(HistoryRepository.new);
    Get.lazyPut<NotificationsRepository>(NotificationsRepository.new);

    // Controller
    Get.lazyPut<HomeController>(HomeController.new);
  }
}
