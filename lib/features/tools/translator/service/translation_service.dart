import 'package:google_ml_kit/google_ml_kit.dart';

/// Service for translation operations using Google ML Kit on-device translation.
///
/// Provides real text translation with downloadable language models.
/// Supports offline translation once models are downloaded.
class TranslationService {
  /// On-device translator instance.
  OnDeviceTranslator? _translator;

  /// Currently active source language code.
  String _sourceLanguageCode = 'en';

  /// Currently active target language code.
  String _targetLanguageCode = 'ur';

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Whether a model is currently downloading.
  bool _isModelDownloading = false;

  /// Error message from last operation.
  String? _lastError;

  /// Returns true if a model download is in progress.
  bool get isModelDownloading => _isModelDownloading;

  /// Returns the last error message, if any.
  String? get lastError => _lastError;

  /// Map of supported language codes to their ML Kit language enum.
  static final Map<String, TranslateLanguage> supportedLanguages =
      <String, TranslateLanguage>{
    'en': TranslateLanguage.english,
    'ur': TranslateLanguage.urdu,
    'hi': TranslateLanguage.hindi,
    'ar': TranslateLanguage.arabic,
    'fr': TranslateLanguage.french,
    'de': TranslateLanguage.german,
    'es': TranslateLanguage.spanish,
    'it': TranslateLanguage.italian,
    'pt': TranslateLanguage.portuguese,
    'tr': TranslateLanguage.turkish,
    'ru': TranslateLanguage.russian,
    'zh': TranslateLanguage.chinese,
    'ja': TranslateLanguage.japanese,
    'ko': TranslateLanguage.korean,
    'bn': TranslateLanguage.bengali,
    'fa': TranslateLanguage.persian,
  };

  /// List of supported language codes.
  static List<String> get supportedLanguageCodes =>
      supportedLanguages.keys.toList();

  /// Whether the given language code is supported.
  static bool isLanguageSupported(String code) =>
      supportedLanguages.containsKey(code);

  /// Initializes the translation service.
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }
    _initialized = true;
    return true;
  }

  /// Translates the given text using on-device ML Kit translation.
  ///
  /// Downloads the required language model if not already available.
  /// Returns the translated text, or throws on failure.
  Future<String> translate({
    required String text,
    required String sourceLanguageCode,
    required String targetLanguageCode,
  }) async {
    _lastError = null;

    if (text.trim().isEmpty) {
      throw const TranslationException('Please enter some text to translate.');
    }

    if (sourceLanguageCode == targetLanguageCode) return text;

    if (!isLanguageSupported(sourceLanguageCode)) {
      throw const TranslationException(
        'Source language is not supported. Please choose a supported language.',
      );
    }

    if (!isLanguageSupported(targetLanguageCode)) {
      throw const TranslationException(
        'Target language is not supported. Please choose a supported language.',
      );
    }

    try {
      // Dispose previous translator if languages changed.
      if (_translator != null &&
          (_sourceLanguageCode != sourceLanguageCode ||
              _targetLanguageCode != targetLanguageCode)) {
        await _translator!.close();
        _translator = null;
      }

      // Create translator for the requested language pair.
      _sourceLanguageCode = sourceLanguageCode;
      _targetLanguageCode = targetLanguageCode;

      final TranslateLanguage sourceLang =
          supportedLanguages[sourceLanguageCode]!;
      final TranslateLanguage targetLang =
          supportedLanguages[targetLanguageCode]!;

      _translator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );

      // Ensure the model is downloaded.
      final modelManager = OnDeviceTranslatorModelManager();
      final bool isSourceDownloaded =
          await modelManager.isModelDownloaded(sourceLanguageCode);
      final bool isTargetDownloaded =
          await modelManager.isModelDownloaded(targetLanguageCode);

      if (!isSourceDownloaded || !isTargetDownloaded) {
        _isModelDownloading = true;
        try {
          if (!isSourceDownloaded) {
            await modelManager.downloadModel(sourceLanguageCode);
          }
          if (!isTargetDownloaded) {
            await modelManager.downloadModel(targetLanguageCode);
          }
        } catch (e) {
          _isModelDownloading = false;
          throw const TranslationException(
            'Unable to download translation model. Please check your internet connection and try again.',
          );
        }
        _isModelDownloading = false;
      }

      // Perform the translation.
      final String result = await _translator!.translateText(text);
      if (result.trim().isEmpty) {
        throw const TranslationException(
          'Translation returned empty result. Please try again.',
        );
      }
      return result;
    } on TranslationException {
      rethrow;
    } catch (e) {
      _isModelDownloading = false;
      final String message = e.toString().toLowerCase();
      if (message.contains('network') || message.contains('connection')) {
        throw const TranslationException(
          'Network error. Please check your connection and try again.',
        );
      }
      if (message.contains('model') || message.contains('download')) {
        throw const TranslationException(
          'Translation model unavailable. Please download it and try again.',
        );
      }
      throw const TranslationException(
        'Translation failed. Please try again.',
      );
    }
  }

  /// Detects the language of the given text using heuristic analysis.
  ///
  /// Returns the detected language code or null if detection fails.
  Future<String?> detectLanguage(String text) async {
    if (text.trim().isEmpty) {
      return null;
    }

    final String sample = text.trim();

    // Arabic / Urdu (Arabic script).
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(sample)) {
      return 'ar';
    }
    // Chinese.
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(sample)) {
      return 'zh';
    }
    // Japanese.
    if (RegExp(r'[\u3040-\u30FF]').hasMatch(sample)) {
      return 'ja';
    }
    // Korean.
    if (RegExp(r'[\uAC00-\uD7AF]').hasMatch(sample)) {
      return 'ko';
    }
    // Russian / Cyrillic.
    if (RegExp(r'[\u0400-\u04FF]').hasMatch(sample)) {
      return 'ru';
    }
    // Hindi / Devanagari.
    if (RegExp(r'[\u0900-\u097F]').hasMatch(sample)) {
      return 'hi';
    }
    // Bengali.
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(sample)) {
      return 'bn';
    }
    // Persian (additional Arabic-range characters).
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(sample)) {
      return 'fa';
    }
    // Punjabi / Gurmukhi.
    if (RegExp(r'[\u0A00-\u0A7F]').hasMatch(sample)) {
      return 'pa';
    }
    // Default to English for Latin script.
    return 'en';
  }

  /// Disposes the translation service and releases resources.
  Future<void> dispose() async {
    if (_translator != null) {
      await _translator!.close();
      _translator = null;
    }
    _initialized = false;
  }
}

/// Exception thrown when translation fails.
class TranslationException implements Exception {
  const TranslationException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => message;
}
