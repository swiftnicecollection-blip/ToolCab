import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/tts_history_entry.dart';
import '../data/models/tts_language.dart';
import '../data/repositories/tts_repository.dart';
import '../service/tts_service.dart';

/// Controller for the text-to-speech module.
///
/// Manages text input, voice settings, playback state,
/// and history persistence.
class TtsController extends GetxController {
  /// TTS service.
  final TtsService _ttsService = Get.find<TtsService>();

  /// TTS repository.
  final TtsRepository _repository = Get.find<TtsRepository>();

  /// Text input controller.
  final TextEditingController textController = TextEditingController();

  /// Current text character count.
  final RxInt charCount = RxInt(0);

  /// Current text word count.
  final RxInt wordCount = RxInt(0);

  /// Selected language.
  final RxString selectedLanguageCode = RxString('en-US');

  /// Selected voice name.
  final RxString selectedVoiceName = RxString('');

  /// Speech speed (0.5–2.0).
  final RxDouble speed = RxDouble(0.5);

  /// Speech pitch (0.5–2.0).
  final RxDouble pitch = RxDouble(1);

  /// Speech volume (0.0–1.0).
  final RxDouble volume = RxDouble(1);

  /// Whether speech is currently in progress.
  final RxBool isSpeaking = RxBool(false);

  /// Whether speech is paused.
  final RxBool isPaused = RxBool(false);

  /// Whether the engine is loading.
  final RxBool isLoading = RxBool(false);

  /// Whether initialization failed.
  final RxBool initFailed = RxBool(false);

  /// Maximum text length.
  static const int maxTextLength = 5000;

  /// Maximum text length for display.
  int get maxLength => maxTextLength;

  /// Available languages.
  List<TtsLanguage> get languages => TtsLanguage.supported;

  /// Selected language model.
  TtsLanguage get selectedLanguage =>
      TtsLanguage.fromCode(selectedLanguageCode.value);

  /// Whether the current text is valid for speaking.
  bool get hasValidText => textController.text.trim().isNotEmpty;

  /// List of history entries.
  final RxList<TtsHistoryEntry> historyEntries =
      RxList<TtsHistoryEntry>(<TtsHistoryEntry>[]);

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_onTextChanged);
    _initialize();
    _loadHistory();
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    _ttsService.dispose();
    super.onClose();
  }

  /// Initializes the TTS engine.
  Future<void> _initialize() async {
    isLoading.value = true;
    final bool ok = await _ttsService.initialize();
    if (!ok) {
      initFailed.value = true;
    }
    isLoading.value = false;
  }

  /// Called when text changes.
  void _onTextChanged() {
    final String text = textController.text;
    charCount.value = text.length;
    wordCount.value =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  /// Speaks the current text.
  Future<void> speak() async {
    final String text = textController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Empty Text',
        'Please enter some text to speak.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (initFailed.value) {
      Get.snackbar(
        'Engine Unavailable',
        'Text-to-speech is not available on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;

    // Apply voice settings.
    await _ttsService.setLanguage(selectedLanguageCode.value);
    await _ttsService.setSpeechRate(speed.value);
    await _ttsService.setPitch(pitch.value);
    await _ttsService.setVolume(volume.value);

    final bool ok = await _ttsService.speak(text);
    isLoading.value = false;

    if (ok) {
      isSpeaking.value = true;
      isPaused.value = false;
      unawaited(_saveHistoryEntry(text));
    } else {
      Get.snackbar(
        'Playback Failed',
        'Unable to start speech. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Pauses the current speech.
  Future<void> pause() async {
    await _ttsService.pause();
    isPaused.value = true;
    isSpeaking.value = true;
  }

  /// Resumes paused speech.
  Future<void> resume() async {
    await _ttsService.resume();
    isPaused.value = false;
    isSpeaking.value = true;
  }

  /// Stops the current speech.
  Future<void> stop() async {
    await _ttsService.stop();
    isSpeaking.value = false;
    isPaused.value = false;
  }

  /// Copies text to the clipboard.
  Future<void> copyText() async {
    final String text = textController.text;
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Text copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Pastes text from the clipboard.
  Future<void> pasteText() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      textController.text = data!.text!;
    }
  }

  /// Clears the text input.
  void clearText() {
    textController.clear();
  }

  /// Shares the current text.
  Future<void> shareText() async {
    final String text = textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Selects a language.
  Future<void> selectLanguage(String languageCode) async {
    selectedLanguageCode.value = languageCode;
    await _ttsService.setLanguage(languageCode);
  }

  /// Selects a voice.
  Future<void> selectVoice(String voiceName) async {
    selectedVoiceName.value = voiceName;
  }

  /// Updates speech speed.
  Future<void> setSpeed(double value) async {
    speed.value = value;
    await _ttsService.setSpeechRate(value);
  }

  /// Updates speech pitch.
  Future<void> setPitch(double value) async {
    pitch.value = value;
    await _ttsService.setPitch(value);
  }

  /// Updates speech volume.
  Future<void> setVolume(double value) async {
    volume.value = value;
    await _ttsService.setVolume(value);
  }

  /// Loads history entries from the repository.
  Future<void> _loadHistory() async {
    historyEntries.value = await _repository.getHistoryEntries();
  }

  /// Saves a history entry after successful speech.
  Future<void> _saveHistoryEntry(String text) async {
    final TtsHistoryEntry entry = TtsHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      languageCode: selectedLanguageCode.value,
      languageName: selectedLanguage.name,
      voiceName:
          selectedVoiceName.value.isEmpty ? 'Default' : selectedVoiceName.value,
      speed: speed.value,
      pitch: pitch.value,
      date: DateTime.now(),
      duration: _estimateDuration(text, speed.value),
    );
    await _repository.saveHistoryEntry(entry);
    historyEntries.insert(0, entry);
  }

  /// Estimates the speech duration based on word count and speed.
  Duration _estimateDuration(String text, double speechSpeed) {
    final int words =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    // Average speaking rate: ~150 words per minute at 1.0 speed.
    final double minutes = words / (150.0 * speechSpeed);
    return Duration(seconds: (minutes * 60).round());
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    historyEntries.removeWhere((TtsHistoryEntry e) => e.id == id);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    historyEntries.clear();
  }
}
