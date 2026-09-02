import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service responsible for application navigation.
///
/// Wraps GetX navigation utilities with application-specific
/// helpers and transition animations.
class NavigationService extends GetxService {
  /// Navigates to the given [route].
  Future<T?>? to<T>(String route, {dynamic arguments}) {
    return Get.toNamed<T>(route, arguments: arguments);
  }

  /// Navigates to the given [route] and removes the current route.
  Future<T?>? off<T>(String route, {dynamic arguments}) {
    return Get.offNamed<T>(route, arguments: arguments);
  }

  /// Navigates to the given [route] and removes all previous routes.
  Future<T?>? offAll<T>(String route, {dynamic arguments}) {
    return Get.offAllNamed<T>(route, arguments: arguments);
  }

  /// Navigates back to the previous route.
  void back([dynamic result]) {
    Get.back(result: result);
  }

  /// Navigates back with a result value.
  void backWithResult<T>(T result) {
    Get.back<T>(result: result);
  }

  /// Whether it's possible to navigate back.
  bool get canGoBack => Get.key.currentState?.canPop() ?? false;

  /// Opens a dialog.
  Future<T?>? showDialog<T>(Widget widget, {bool barrierDismissible = true}) {
    return Get.dialog<T>(
      widget,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  /// Opens a bottom sheet.
  Future<T?>? showBottomSheet<T>(Widget widget, {bool isDismissible = true}) {
    return Get.bottomSheet<T>(
      widget,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Shows a snackbar.
  void showSnackbar(String message, {String? title, bool isError = false}) {
    Get.snackbar(
      title ?? (isError ? 'Error' : 'Success'),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? const Color(0xFFEF4444)
          : Get.theme.snackBarTheme.backgroundColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
