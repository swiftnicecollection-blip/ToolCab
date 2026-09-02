import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Service wrapping the `speech_to_text` package with error handling.
///
/// Provides methods for initialization, listening control,
/// and language configuration.
class SpeechRecognitionService {
  /// SpeechToText instance.
  final SpeechToText _speech = SpeechToText();

  /// Whether the engine has been initialized.
  bool _initialized = false;

  /// Whether speech recognition is available.
  bool get isAvailable => _speech.isAvailable;

  /// Whether the engine is currently listening.
  bool get isListening => _speech.isListening;

  /// Available locales.
  List<LocaleName> _locales = <LocaleName>[];

  /// Available locales.
  List<LocaleName> get locales => _locales;

  /// Initializes the speech recognition engine.
  Future<bool> initialize() async {
    if (_initialized) {
      return _speech.isAvailable;
    }
    try {
      final bool available = await _speech.initialize();
      _initialized = true;
      if (available) {
        _locales = await _speech.locales();
      }
      return available;
    } catch (_) {
      return false;
    }
  }

  /// Starts listening for speech.
  Future<bool> listen({
    required String localeId,
    required void Function(SpeechRecognitionResult result) onResult,
  }) async {
    if (!_initialized) {
      final bool ok = await initialize();
      if (!ok) {
        return false;
      }
    }
    try {
      await _speech.listen(
        localeId: localeId,
        onResult: onResult,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        // ignore: deprecated_member_use
        partialResults: true,
        // ignore: deprecated_member_use
        listenMode: ListenMode.dictation,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Stops listening and returns the final result.
  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Ignore stop errors.
    }
  }

  /// Cancels the current listening session.
  Future<void> cancel() async {
    try {
      await _speech.cancel();
    } catch (_) {
      // Ignore cancel errors.
    }
  }

  /// Disposes the speech recognition engine.
  Future<void> dispose() async {
    try {
      await _speech.stop();
    } catch (_) {
      // Ignore dispose errors.
    }
  }
}
