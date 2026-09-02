import 'package:google_ml_kit/google_ml_kit.dart';

import '../data/models/ocr_result.dart';

/// Service wrapping the Google ML Kit text recognition engine.
///
/// Processes images locally on-device and respects user privacy.
class OcrService {
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
      _recognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Extracts text from an image file.
  ///
  /// Processes the image locally and returns an [OcrResult].
  Future<OcrResult> extractTextFromImage(String imagePath) async {
    if (!_initialized) {
      final bool ok = await initialize();
      if (!ok) {
        throw Exception('OCR engine unavailable');
      }
    }

    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText =
        await _recognizer!.processImage(inputImage);

    // Build clean normalized text preserving block/line structure.
    final StringBuffer buffer = StringBuffer();
    for (final TextBlock block in recognizedText.blocks) {
      for (final TextLine line in block.lines) {
        buffer.writeln(line.text);
      }
      buffer.writeln();
    }

    final String text = buffer.toString().trim();
    return OcrResult(
      text: text,
      imagePath: imagePath,
    );
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
