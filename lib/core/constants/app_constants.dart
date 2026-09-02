/// Global application constants for ToolCab.
abstract final class AppConstants {
  /// Application name.
  static const String appName = 'ToolCab';

  /// Application tagline.
  static const String tagline = 'All-in-One AI Productivity Toolkit';

  /// Application description used in onboarding and about screens.
  static const String description =
      'A modern AI-powered productivity suite combining document tools, '
      'OCR, PDF utilities, speech tools, translation, QR scanning, '
      'calendar management, and AI utilities in one beautiful experience.';

  /// Application version.
  static const String version = '1.0.0';

  /// Default locale.
  static const String defaultLocale = 'en';

  /// Maximum items stored in history.
  static const int maxHistoryItems = 100;

  /// Maximum recent files stored.
  static const int maxRecentFiles = 20;

  /// Animation durations.
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  /// Splash screen minimum display duration.
  static const Duration splashDuration = Duration(milliseconds: 4000);

  /// Support email for help & feedback.
  static const String supportEmail = 'support@toolcab.app';

  /// Privacy policy URL.
  static const String privacyPolicyUrl = 'https://toolcab.app/privacy';

  /// Terms of service URL.
  static const String termsUrl = 'https://toolcab.app/terms';

  /// Play Store URL.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.toolcab.app';

  /// App Store URL.
  static const String appStoreUrl = 'https://apps.apple.com/app/id0000000000';

  /// App logo (temporary placeholder asset path).
  static const String appLogoPath = 'assets/images/logo.png';

  /// App logo (temporary placeholder network-independent asset).
  static const String appLogoMarkPath = 'assets/icons/logo_mark.png';

  /// Default user avatar placeholder.
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';
}

/// Hive storage box names.
abstract final class HiveBoxes {
  /// Settings box — theme, preferences.
  static const String settings = 'settings';

  /// Recent files box.
  static const String recentFiles = 'recent_files';

  /// History box.
  static const String history = 'history';

  /// Onboarding box — stores onboarding completion state.
  static const String onboarding = 'onboarding';

  /// Cache box — offline data.
  static const String cache = 'cache';
}

/// Settings keys stored in the Hive settings box.
abstract final class SettingsKeys {
  /// Theme mode: 'system', 'light', or 'dark'.
  static const String themeMode = 'theme_mode';

  /// Locale language code.
  static const String locale = 'locale';

  /// Whether onboarding has been completed.
  static const String onboardingCompleted = 'onboarding_completed';

  /// Whether the user is authenticated.
  static const String isAuthenticated = 'is_authenticated';

  /// Whether biometric auth is enabled.
  static const String biometricEnabled = 'biometric_enabled';

  /// Whether notifications are enabled.
  static const String notificationsEnabled = 'notifications_enabled';

  /// Default language for translation.
  static const String defaultTranslateLanguage = 'default_translate_language';

  /// Default speech rate.
  static const String speechRate = 'speech_rate';

  /// Default speech pitch.
  static const String speechPitch = 'speech_pitch';

  /// Whether history tracking is enabled.
  static const String historyEnabled = 'history_enabled';

  /// Whether offline mode is enabled.
  static const String offlineMode = 'offline_mode';

  /// Theme seed color value.
  static const String seedColor = 'seed_color';
}

/// SharedPreferences keys.
abstract final class PrefsKeys {
  /// Whether the user has completed onboarding.
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  /// Whether the user is logged in.
  static const String isLoggedIn = 'is_logged_in';

  /// Last signed-in user email.
  static const String lastEmail = 'last_email';

  /// Last used locale.
  static const String locale = 'locale';
}

/// Animation duration constants for UI feedback.
abstract final class AppDurations {
  /// Fast micro-interaction duration.
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation duration.
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animation duration.
  static const Duration slow = Duration(milliseconds: 500);

  /// Debounce duration for search inputs.
  static const Duration debounce = Duration(milliseconds: 400);
}
