/// Model representing a text-to-speech history entry.
class TtsHistoryEntry {
  const TtsHistoryEntry({
    required this.id,
    required this.text,
    required this.languageCode,
    required this.languageName,
    required this.voiceName,
    required this.speed,
    required this.pitch,
    required this.date,
    this.duration,
  });

  /// Creates an entry from a JSON map.
  factory TtsHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TtsHistoryEntry(
      id: json['id'] as String,
      text: json['text'] as String,
      languageCode: json['language_code'] as String,
      languageName: json['language_name'] as String,
      voiceName: json['voice_name'] as String,
      speed: (json['speed'] as num).toDouble(),
      pitch: (json['pitch'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      duration: json['duration_seconds'] != null
          ? Duration(seconds: json['duration_seconds'] as int)
          : null,
    );
  }

  /// Unique entry ID.
  final String id;

  /// Text that was spoken.
  final String text;

  /// Language code (e.g., 'en-US').
  final String languageCode;

  /// Human-readable language name.
  final String languageName;

  /// Voice name.
  final String voiceName;

  /// Speech speed (0.5–2.0).
  final double speed;

  /// Speech pitch (0.5–2.0).
  final double pitch;

  /// When the conversion happened.
  final DateTime date;

  /// Estimated duration in seconds.
  final Duration? duration;

  /// Returns a text preview (max 50 characters).
  String get textPreview {
    if (text.length <= 50) {
      return text;
    }
    return '${text.substring(0, 47)}...';
  }

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'text': text,
        'language_code': languageCode,
        'language_name': languageName,
        'voice_name': voiceName,
        'speed': speed,
        'pitch': pitch,
        'date': date.toIso8601String(),
        'duration_seconds': duration?.inSeconds,
      };
}
