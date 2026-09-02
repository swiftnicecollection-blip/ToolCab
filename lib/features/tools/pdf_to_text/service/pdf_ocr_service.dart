import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';

/// Service for OCR-based text extraction from PDF pages.
///
/// Uses Google ML Kit Text Recognition on rendered PDF pages.
/// Processes images locally on-device and respects user privacy.
class PdfOcrService {
  /// Text recognizer instance.
  TextRecognizer? _recognizer;

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Initializes the OCR recognizer.
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }
    try {
      _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Extracts text from a rendered page image.
  ///
  /// Returns the recognized text or an empty string if no text was found.
  Future<String> extractTextFromImage(String imagePath) async {
    if (!_initialized) {
      final bool ok = await initialize();
      if (!ok) {
        return '';
      }
    }

    try {
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _recognizer!.processImage(inputImage);

      final StringBuffer buffer = StringBuffer();
      for (final TextBlock block in recognizedText.blocks) {
        for (final TextLine line in block.lines) {
          buffer.writeln(line.text);
        }
        buffer.writeln();
      }
      return buffer.toString().trim();
    } catch (_) {
      return '';
    } finally {
      // Clean up the temporary image file.
      try {
        final File file = File(imagePath);
        if (file.existsSync()) {
          await file.delete();
        }
      } catch (_) {
        // Best-effort cleanup.
      }
    }
  }

  /// Returns the list of supported OCR language codes.
  ///
  /// The installed Google ML Kit implementation supports Latin-script
  /// text recognition. Not all languages may be available on every device.
  List<String> get supportedLanguages => const <String>[
        'en', // English
        'fr', // French
        'de', // German
        'es', // Spanish
        'it', // Italian
        'pt', // Portuguese
      ];

  /// Whether a language code is supported.
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode.toLowerCase());
  }

  /// Disposes the OCR recognizer.
  Future<void> dispose() async {
    if (_initialized && _recognizer != null) {
      await _recognizer!.close();
      _initialized = false;
      _recognizer = null;
    }
  }
}
