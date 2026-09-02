import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/navigation_service.dart';
import '../data/models/recent_file_item.dart';
import '../data/repositories/recent_files_repository.dart';

/// Controller for the home dashboard.
///
/// Manages greeting, current date, recent files, premium status,
/// search, and navigation state.
class HomeController extends GetxController {
  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Recent files repository.
  final RecentFilesRepository _recentFilesRepository =
      Get.find<RecentFilesRepository>();

  /// Current greeting based on time of day.
  final RxString greeting = RxString('');

  /// Current date string.
  final RxString currentDate = RxString('');

  /// Search query.
  final RxString searchQuery = RxString('');

  /// Whether search is focused.
  final RxBool isSearchFocused = RxBool(false);

  /// Recent files list.
  final RxList<RecentFileItem> recentFiles = RxList<RecentFileItem>([]);

  /// Whether recent files are loading.
  final RxBool isLoadingRecentFiles = RxBool(false);

  /// Current bottom navigation index.
  final RxInt currentNavIndex = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
    _loadRecentFiles();
  }

  /// Updates the greeting and date based on current time.
  void _updateGreeting() {
    final DateTime now = DateTime.now();
    final int hour = now.hour;

    if (hour < 12) {
      greeting.value = 'Good Morning';
    } else if (hour < 17) {
      greeting.value = 'Good Afternoon';
    } else {
      greeting.value = 'Good Evening';
    }

    currentDate.value = DateFormat('EEEE, MMMM d').format(now);
  }

  /// Loads recent files from the repository.
  Future<void> _loadRecentFiles() async {
    isLoadingRecentFiles.value = true;
    try {
      recentFiles.value = await _recentFilesRepository.getRecentFiles();
    } finally {
      isLoadingRecentFiles.value = false;
    }
  }

  /// Updates the search query.
  // ignore: use_setters_to_change_properties
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Sets search focus state.
  // ignore: use_setters_to_change_properties
  void onSearchFocusChanged(bool focused) {
    isSearchFocused.value = focused;
  }

  /// Navigates to a route.
  void navigateTo(String route) {
    _navigationService.to(route);
  }

  /// Navigates to a route and clears the stack.
  void navigateToAndClear(String route) {
    _navigationService.offAll(route);
  }

  /// Handles bottom navigation tab selection.
  void onNavTap(int index) {
    if (index == currentNavIndex.value) {
      return;
    }
    currentNavIndex.value = index;
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        _navigationService.to(AppRoutes.history);
        break;
      case 2:
        _navigationService.to(AppRoutes.settings);
        break;
      case 3:
        _navigationService.to(AppRoutes.calendar);
        break;
    }
  }

  /// Navigates to notifications.
  void goToNotifications() {
    _navigationService.to(AppRoutes.notifications);
  }

  /// Navigates to settings.
  void goToSettings() {
    _navigationService.to(AppRoutes.settings);
  }
}
