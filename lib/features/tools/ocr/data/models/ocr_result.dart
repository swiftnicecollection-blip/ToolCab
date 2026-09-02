/// Model representing the result of an OCR scan.
class OcrResult {
  const OcrResult({
    required this.text,
    this.imagePath,
    this.languageCode = 'en',
  });

  /// Extracted text.
  final String text;

  /// Path to the source image (if available).
  final String? imagePath;

  /// Language code used for recognition.
  final String languageCode;

  /// Word count of the extracted text.
  int get wordCount {
    if (text.trim().isEmpty) {
      return 0;
    }
    return text.trim().split(RegExp(r'\s+')).length;
  }

  /// Character count of the extracted text.
  int get charCount => text.length;

  /// Title derived from the text (first 40 chars).
  String get title {
    if (text.trim().isEmpty) {
      return 'Untitled Scan';
    }
    final String firstLine = text.trim().split('\n').first;
    if (firstLine.length <= 40) {
      return firstLine;
    }
    return '${firstLine.substring(0, 37)}...';
  }

  /// Text preview (first 100 chars).
  String get textPreview {
    if (text.length <= 100) {
      return text;
    }
    return '${text.substring(0, 97)}...';
  }
}
