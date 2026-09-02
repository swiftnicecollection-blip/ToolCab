import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'app/bindings/global_bindings.dart';
import 'core/services/storage_service.dart';
import 'core/services/theme_service.dart';

/// Application entry point.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage (Hive).
  await StorageService.instance.init();

  // Initialize global bindings.
  final GlobalBindings bindings = GlobalBindings();
  bindings.dependencies();

  // Load saved theme preference.
  await Get.find<ThemeService>().init();

  runApp(const ToolCabApp());
}
