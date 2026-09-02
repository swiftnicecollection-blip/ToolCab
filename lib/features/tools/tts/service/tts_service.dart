import 'package:flutter_tts/flutter_tts.dart';

/// Service wrapping the `flutter_tts` package with error handling.
///
/// Provides methods for initialization, speech control, and
/// voice/language configuration.
class TtsService {
  /// FlutterTTS instance.
  final FlutterTts _tts = FlutterTts();

  /// Whether the engine has been initialized.
  bool _initialized = false;

  /// Whether speech is currently in progress.
  bool get isSpeaking => _isSpeaking;
  bool _isSpeaking = false;

  /// Whether speech is currently paused.
  bool get isPaused => _isPaused;
  bool _isPaused = false;

  /// Available device voices.
  List<dynamic> _voices = <dynamic>[];

  /// Available device voices.
  List<dynamic> get voices => _voices;

  /// Last text that was spoken.
  String _lastText = '';

  /// Initializes the TTS engine.
  Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }
    try {
      // Configure completion handler.
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });
      _tts.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });
      _tts.setPauseHandler(() {
        _isPaused = true;
      });
      _tts.setContinueHandler(() {
        _isPaused = false;
      });

      // Load available voices.
      final dynamic voicesResult = await _tts.getVoices;
      if (voicesResult is List<dynamic>) {
        _voices = voicesResult;
      }

      _initialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Speaks the given text.
  Future<bool> speak(String text) async {
    if (!_initialized) {
      final bool ok = await initialize();
      if (!ok) {
        return false;
      }
    }
    try {
      _lastText = text;
      _isSpeaking = true;
      _isPaused = false;
      final dynamic result = await _tts.speak(text);
      return result == 1 || result == true;
    } catch (_) {
      _isSpeaking = false;
      return false;
    }
  }

  /// Pauses the current speech.
  Future<void> pause() async {
    try {
      await _tts.pause();
      _isPaused = true;
    } catch (_) {
      // Ignore if already paused.
    }
  }

  /// Resumes paused speech.
  Future<void> resume() async {
    try {
      await _tts.speak(_lastText);
      _isPaused = false;
      _isSpeaking = true;
    } catch (_) {
      // Ignore if no text to resume.
    }
  }

  /// Stops the current speech.
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
      _isPaused = false;
    } catch (_) {
      // Ignore stop errors.
    }
  }

  /// Sets the speech language.
  Future<void> setLanguage(String languageCode) async {
    try {
      await _tts.setLanguage(languageCode);
    } catch (_) {
      // Language may not be supported by the device.
    }
  }

  /// Sets the speech speed (0.5–2.0).
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate);
    } catch (_) {
      // Ignore speed errors.
    }
  }

  /// Sets the speech pitch (0.5–2.0).
  Future<void> setPitch(double pitch) async {
    try {
      await _tts.setPitch(pitch);
    } catch (_) {
      // Ignore pitch errors.
    }
  }

  /// Sets the speech volume (0.0–1.0).
  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume);
    } catch (_) {
      // Ignore volume errors.
    }
  }

  /// Disposes the TTS engine.
  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Ignore dispose errors.
    }
  }
}
