/// Model representing a speech-to-text history entry.
class SttHistoryEntry {
  const SttHistoryEntry({
    required this.id,
    required this.transcript,
    required this.languageCode,
    required this.languageName,
    required this.date,
    this.duration,
    this.wordCount = 0,
    this.charCount = 0,
  });

  /// Creates an entry from a JSON map.
  factory SttHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SttHistoryEntry(
      id: json['id'] as String,
      transcript: json['transcript'] as String,
      languageCode: json['language_code'] as String,
      languageName: json['language_name'] as String,
      date: DateTime.parse(json['date'] as String),
      duration: json['duration_seconds'] != null
          ? Duration(seconds: json['duration_seconds'] as int)
          : null,
      wordCount: json['word_count'] as int? ?? 0,
      charCount: json['char_count'] as int? ?? 0,
    );
  }

  /// Unique entry ID.
  final String id;

  /// Transcribed text.
  final String transcript;

  /// Language code (e.g., 'en-US').
  final String languageCode;

  /// Human-readable language name.
  final String languageName;

  /// When the transcription happened.
  final DateTime date;

  /// Recording duration.
  final Duration? duration;

  /// Word count of the transcript.
  final int wordCount;

  /// Character count of the transcript.
  final int charCount;

  /// Returns a text preview (max 60 characters).
  String get textPreview {
    if (transcript.length <= 60) {
      return transcript;
    }
    return '${transcript.substring(0, 57)}...';
  }

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'transcript': transcript,
        'language_code': languageCode,
        'language_name': languageName,
        'date': date.toIso8601String(),
        'duration_seconds': duration?.inSeconds,
        'word_count': wordCount,
        'char_count': charCount,
      };
}
