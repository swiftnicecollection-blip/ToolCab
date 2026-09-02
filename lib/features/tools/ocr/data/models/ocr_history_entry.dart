/// Model representing an OCR history entry.
class OcrHistoryEntry {
  const OcrHistoryEntry({
    required this.id,
    required this.title,
    required this.textPreview,
    required this.fullText,
    required this.createdAt,
    this.imagePath,
    this.languageCode = 'en',
    this.wordCount = 0,
    this.charCount = 0,
    this.isFavorite = false,
    this.filePath,
  });

  /// Creates an entry from a JSON map.
  factory OcrHistoryEntry.fromJson(Map<String, dynamic> json) {
    return OcrHistoryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      textPreview: json['text_preview'] as String,
      fullText: json['full_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      imagePath: json['image_path'] as String?,
      languageCode: json['language_code'] as String? ?? 'en',
      wordCount: json['word_count'] as int? ?? 0,
      charCount: json['char_count'] as int? ?? 0,
      isFavorite: json['is_favorite'] as bool? ?? false,
      filePath: json['file_path'] as String?,
    );
  }

  /// Unique entry ID.
  final String id;

  /// Document title.
  final String title;

  /// Text preview (first 100 chars).
  final String textPreview;

  /// Full extracted text.
  final String fullText;

  /// When the scan happened.
  final DateTime createdAt;

  /// Path to the source image (if available).
  final String? imagePath;

  /// Language code used for recognition.
  final String languageCode;

  /// Word count of the extracted text.
  final int wordCount;

  /// Character count of the extracted text.
  final int charCount;

  /// Whether this entry is a favorite.
  final bool isFavorite;

  /// Path to an exported file (if applicable).
  final String? filePath;

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'text_preview': textPreview,
        'full_text': fullText,
        'created_at': createdAt.toIso8601String(),
        'image_path': imagePath,
        'language_code': languageCode,
        'word_count': wordCount,
        'char_count': charCount,
        'is_favorite': isFavorite,
        'file_path': filePath,
      };

  /// Returns a copy with updated favorite status.
  OcrHistoryEntry copyWith({bool? isFavorite}) {
    return OcrHistoryEntry(
      id: id,
      title: title,
      textPreview: textPreview,
      fullText: fullText,
      createdAt: createdAt,
      imagePath: imagePath,
      languageCode: languageCode,
      wordCount: wordCount,
      charCount: charCount,
      isFavorite: isFavorite ?? this.isFavorite,
      filePath: filePath,
    );
  }
}
