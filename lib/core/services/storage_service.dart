import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

/// Service responsible for initializing and managing Hive local storage.
///
/// Handles opening storage boxes, reading/writing settings,
/// and providing access to typed box collections.
class StorageService {
  StorageService._internal();

  /// Singleton instance of [StorageService].
  static final StorageService instance = StorageService._internal();

  /// Flag indicating whether Hive has been initialized.
  bool _initialized = false;

  /// Settings box.
  late Box<dynamic> _settingsBox;

  /// Recent files box.
  late Box<dynamic> _recentFilesBox;

  /// History box.
  late Box<dynamic> _historyBox;

  /// Onboarding box.
  late Box<dynamic> _onboardingBox;

  /// Cache box.
  late Box<dynamic> _cacheBox;

  /// Initializes Hive and opens all storage boxes.
  Future<void> init() async {
    if (_initialized) {
      return;
    }

    if (kIsWeb) {
      // On web, Hive uses IndexedDB automatically.
      await Hive.initFlutter();
    } else {
      final String directory = (await getApplicationDocumentsDirectory()).path;
      Hive.init(directory);
    }

    _settingsBox = await Hive.openBox<dynamic>(HiveBoxes.settings);
    _recentFilesBox = await Hive.openBox<dynamic>(HiveBoxes.recentFiles);
    _historyBox = await Hive.openBox<dynamic>(HiveBoxes.history);
    _onboardingBox = await Hive.openBox<dynamic>(HiveBoxes.onboarding);
    _cacheBox = await Hive.openBox<dynamic>(HiveBoxes.cache);

    _initialized = true;
  }

  // -------------------------------------------------------------------
  // Box Accessors
  // -------------------------------------------------------------------

  /// Settings box for preferences and theme configuration.
  Box<dynamic> get settings => _settingsBox;

  /// Recent files box for recently accessed documents.
  Box<dynamic> get recentFiles => _recentFilesBox;

  /// History box for user activity history.
  Box<dynamic> get history => _historyBox;

  /// Onboarding box for onboarding completion state.
  Box<dynamic> get onboarding => _onboardingBox;

  /// Cache box for offline data.
  Box<dynamic> get cache => _cacheBox;

  // -------------------------------------------------------------------
  // Generic Key-Value Helpers
  // -------------------------------------------------------------------

  /// Reads a value from the settings box.
  dynamic readSettings(String key) => _settingsBox.get(key);

  /// Writes a value to the settings box.
  Future<void> writeSettings(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Reads a value from the cache box.
  dynamic readCache(String key) => _cacheBox.get(key);

  /// Writes a value to the cache box.
  Future<void> writeCache(String key, dynamic value) async {
    await _cacheBox.put(key, value);
  }

  /// Reads a value from the onboarding box.
  dynamic readOnboarding(String key) => _onboardingBox.get(key);

  /// Writes a value to the onboarding box.
  Future<void> writeOnboarding(String key, dynamic value) async {
    await _onboardingBox.put(key, value);
  }

  /// Clears all application data from local storage.
  Future<void> clearAll() async {
    await _settingsBox.clear();
    await _recentFilesBox.clear();
    await _historyBox.clear();
    await _onboardingBox.clear();
    await _cacheBox.clear();
  }

  /// Closes all open boxes and shuts down Hive.
  Future<void> dispose() async {
    await Hive.close();
    _initialized = false;
  }
}
