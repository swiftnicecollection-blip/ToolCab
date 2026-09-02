import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/services/theme_service.dart';
import '../core/theme/app_theme.dart';
import 'routes/app_pages.dart';

/// Root application widget.
class ToolCabApp extends StatelessWidget {
  const ToolCabApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find<ThemeService>();

    return Obx(
      () => GetMaterialApp(
        title: 'ToolCab',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeService.themeMode.value,
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 300),
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.textScalerOf(context).clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.3,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
