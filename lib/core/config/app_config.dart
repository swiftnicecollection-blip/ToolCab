/// Application configuration.
///
/// Centralizes environment-specific configuration values.
abstract final class AppConfig {
  // -------------------------------------------------------------------
  // Feature Flags
  // -------------------------------------------------------------------

  /// Whether images require caching offline.
  static const bool offlineCachingEnabled = true;

  /// Maximum file size for OCR processing (in MB).
  static const int maxOcrFileSizeMb = 20;

  /// Maximum file size for PDF processing (in MB).
  static const int maxPdfFileSizeMb = 50;

  /// Whether analytics & crash reporting are enabled.
  static const bool analyticsEnabled = false;
}
