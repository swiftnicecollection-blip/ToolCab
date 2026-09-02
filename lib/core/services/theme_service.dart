import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Service responsible for managing the application theme.
///
/// Persists the selected theme mode to local storage and
/// exposes reactive theme state to the UI.
class ThemeService extends GetxService {
  /// Reactive theme mode.
  final Rx<ThemeMode> themeMode = Rx<ThemeMode>(ThemeMode.system);

  /// Initializes the theme service by loading the saved preference.
  Future<void> init() async {
    final String? saved =
        StorageService.instance.readSettings(SettingsKeys.themeMode) as String?;
    themeMode.value = _parseThemeMode(saved);
  }

  /// Returns the current [ThemeMode].
  ThemeMode get currentMode => themeMode.value;

  /// Whether dark mode is currently active.
  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  /// Sets the theme mode and persists it.
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await StorageService.instance.writeSettings(
      SettingsKeys.themeMode,
      mode.name,
    );
  }

  /// Toggles between light and dark mode.
  Future<void> toggleTheme() async {
    final ThemeMode next = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }

  /// Parses a stored string into a [ThemeMode].
  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
