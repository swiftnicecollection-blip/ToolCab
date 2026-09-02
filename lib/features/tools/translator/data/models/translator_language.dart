/// Model representing a supported translation language.
///
/// Only languages supported by Google ML Kit on-device translation
/// are included in this list.
class TranslatorLanguage {
  const TranslatorLanguage({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });

  /// Language code (e.g., 'en').
  final String code;

  /// Human-readable language name.
  final String name;

  /// Flag emoji for UI display.
  final String flagEmoji;

  /// List of languages supported by Google ML Kit on-device translation.
  static const List<TranslatorLanguage> supported = <TranslatorLanguage>[
    TranslatorLanguage(code: 'en', name: 'English', flagEmoji: '🇬🇧'),
    TranslatorLanguage(code: 'ur', name: 'Urdu', flagEmoji: '🇵🇰'),
    TranslatorLanguage(code: 'hi', name: 'Hindi', flagEmoji: '🇮🇳'),
    TranslatorLanguage(code: 'ar', name: 'Arabic', flagEmoji: '🇸🇦'),
    TranslatorLanguage(code: 'fr', name: 'French', flagEmoji: '🇫🇷'),
    TranslatorLanguage(code: 'de', name: 'German', flagEmoji: '🇩🇪'),
    TranslatorLanguage(code: 'es', name: 'Spanish', flagEmoji: '🇪🇸'),
    TranslatorLanguage(code: 'it', name: 'Italian', flagEmoji: '🇮🇹'),
    TranslatorLanguage(code: 'pt', name: 'Portuguese', flagEmoji: '🇵🇹'),
    TranslatorLanguage(code: 'tr', name: 'Turkish', flagEmoji: '🇹🇷'),
    TranslatorLanguage(code: 'ru', name: 'Russian', flagEmoji: '🇷🇺'),
    TranslatorLanguage(code: 'zh', name: 'Chinese', flagEmoji: '🇨🇳'),
    TranslatorLanguage(code: 'ja', name: 'Japanese', flagEmoji: '🇯🇵'),
    TranslatorLanguage(code: 'ko', name: 'Korean', flagEmoji: '🇰🇷'),
    TranslatorLanguage(code: 'bn', name: 'Bengali', flagEmoji: '🇧🇩'),
    TranslatorLanguage(code: 'fa', name: 'Persian', flagEmoji: '🇮🇷'),
  ];

  /// Finds a language by its code, falling back to English.
  static TranslatorLanguage fromCode(String code) {
    return supported.firstWhere(
      (TranslatorLanguage lang) => lang.code == code,
      orElse: () => supported.first,
    );
  }
}
