/// Model representing a translation history entry.
class TranslationHistoryEntry {
  const TranslationHistoryEntry({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguageCode,
    required this.sourceLanguageName,
    required this.targetLanguageCode,
    required this.targetLanguageName,
    required this.date,
    this.detectedLanguageCode,
    this.detectedLanguageName,
    this.isFavorite = false,
  });

  /// Creates an entry from a JSON map.
  factory TranslationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TranslationHistoryEntry(
      id: json['id'] as String,
      originalText: json['original_text'] as String,
      translatedText: json['translated_text'] as String,
      sourceLanguageCode: json['source_language_code'] as String,
      sourceLanguageName: json['source_language_name'] as String,
      targetLanguageCode: json['target_language_code'] as String,
      targetLanguageName: json['target_language_name'] as String,
      date: DateTime.parse(json['date'] as String),
      detectedLanguageCode: json['detected_language_code'] as String?,
      detectedLanguageName: json['detected_language_name'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// Unique entry ID.
  final String id;

  /// Original text.
  final String originalText;

  /// Translated text.
  final String translatedText;

  /// Source language code.
  final String sourceLanguageCode;

  /// Source language name.
  final String sourceLanguageName;

  /// Target language code.
  final String targetLanguageCode;

  /// Target language name.
  final String targetLanguageName;

  /// When the translation happened.
  final DateTime date;

  /// Detected language code (if auto-detect was used).
  final String? detectedLanguageCode;

  /// Detected language name.
  final String? detectedLanguageName;

  /// Whether this entry is a favorite.
  final bool isFavorite;

  /// Returns a text preview (max 50 characters).
  String get textPreview {
    if (translatedText.length <= 50) {
      return translatedText;
    }
    return '${translatedText.substring(0, 47)}...';
  }

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'original_text': originalText,
        'translated_text': translatedText,
        'source_language_code': sourceLanguageCode,
        'source_language_name': sourceLanguageName,
        'target_language_code': targetLanguageCode,
        'target_language_name': targetLanguageName,
        'date': date.toIso8601String(),
        'detected_language_code': detectedLanguageCode,
        'detected_language_name': detectedLanguageName,
        'is_favorite': isFavorite,
      };

  /// Returns a copy with updated favorite status.
  TranslationHistoryEntry copyWith({bool? isFavorite}) {
    return TranslationHistoryEntry(
      id: id,
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguageCode: sourceLanguageCode,
      sourceLanguageName: sourceLanguageName,
      targetLanguageCode: targetLanguageCode,
      targetLanguageName: targetLanguageName,
      date: date,
      detectedLanguageCode: detectedLanguageCode,
      detectedLanguageName: detectedLanguageName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
