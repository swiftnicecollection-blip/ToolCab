/// Model representing a supported text-to-speech language.
class TtsLanguage {
  const TtsLanguage({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });

  /// Language code passed to the TTS engine (e.g., 'en-US').
  final String code;

  /// Human-readable language name.
  final String name;

  /// Flag emoji for UI display.
  final String flagEmoji;

  /// List of commonly supported TTS languages.
  static const List<TtsLanguage> supported = <TtsLanguage>[
    TtsLanguage(code: 'en-US', name: 'English (US)', flagEmoji: '🇺🇸'),
    TtsLanguage(code: 'en-GB', name: 'English (UK)', flagEmoji: '🇬🇧'),
    TtsLanguage(code: 'ur-PK', name: 'Urdu', flagEmoji: '🇵🇰'),
    TtsLanguage(code: 'hi-IN', name: 'Hindi', flagEmoji: '🇮🇳'),
    TtsLanguage(code: 'ar-SA', name: 'Arabic', flagEmoji: '🇸🇦'),
    TtsLanguage(code: 'fr-FR', name: 'French', flagEmoji: '🇫🇷'),
    TtsLanguage(code: 'de-DE', name: 'German', flagEmoji: '🇩🇪'),
    TtsLanguage(code: 'es-ES', name: 'Spanish', flagEmoji: '🇪🇸'),
    TtsLanguage(code: 'zh-CN', name: 'Chinese', flagEmoji: '🇨🇳'),
    TtsLanguage(code: 'ja-JP', name: 'Japanese', flagEmoji: '🇯🇵'),
  ];

  /// Finds a language by its code, falling back to English (US).
  static TtsLanguage fromCode(String code) {
    return supported.firstWhere(
      (TtsLanguage lang) => lang.code == code,
      orElse: () => supported.first,
    );
  }
}
