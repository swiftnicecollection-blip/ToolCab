import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../data/models/stt_history_entry.dart';
import '../data/repositories/stt_repository.dart';
import '../service/speech_recognition_service.dart';

/// Controller for the speech-to-text module.
///
/// Manages recording state, live transcription, permissions,
/// and history persistence.
class SttController extends GetxController {
  /// Speech recognition service.
  final SpeechRecognitionService _service =
      Get.find<SpeechRecognitionService>();

  /// STT repository.
  final SttRepository _repository = Get.find<SttRepository>();

  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Transcript text controller.
  final TextEditingController transcriptController = TextEditingController();

  /// Current recording state.
  final Rx<SttState> state = Rx<SttState>(SttState.idle);

  /// Selected language code.
  final RxString selectedLanguageCode = RxString('en-US');

  /// Recording duration in seconds.
  final RxInt recordingSeconds = RxInt(0);

  /// Current transcript word count.
  final RxInt wordCount = RxInt(0);

  /// Current transcript character count.
  final RxInt charCount = RxInt(0);

  /// Whether the engine is loading.
  final RxBool isLoading = RxBool(false);

  /// Whether microphone permission is granted.
  final RxBool hasPermission = RxBool(false);

  /// Whether the engine is available.
  final RxBool isEngineAvailable = RxBool(false);

  /// History entries.
  final RxList<SttHistoryEntry> historyEntries =
      RxList<SttHistoryEntry>(<SttHistoryEntry>[]);

  /// Search query for history.
  final RxString historySearchQuery = RxString('');

  /// Whether history is sorted newest first.
  final RxBool newestFirst = RxBool(true);

  /// Timer for recording duration.
  Timer? _timer;

  /// Whether the engine is currently listening.
  bool get isListening => _service.isListening;

  /// Whether the engine is paused.
  bool get isPaused => state.value == SttState.paused;

  /// Available languages (reusing TTS language list pattern).
  List<Map<String, String>> get languages => <Map<String, String>>[
        <String, String>{
          'code': 'en-US',
          'name': 'English (US)',
          'flag': '🇺🇸',
        },
        <String, String>{
          'code': 'en-GB',
          'name': 'English (UK)',
          'flag': '🇬🇧',
        },
        <String, String>{'code': 'ur-PK', 'name': 'Urdu', 'flag': '🇵🇰'},
        <String, String>{'code': 'hi-IN', 'name': 'Hindi', 'flag': '🇮🇳'},
        <String, String>{'code': 'ar-SA', 'name': 'Arabic', 'flag': '🇸🇦'},
        <String, String>{'code': 'fr-FR', 'name': 'French', 'flag': '🇫🇷'},
        <String, String>{'code': 'de-DE', 'name': 'German', 'flag': '🇩🇪'},
        <String, String>{'code': 'es-ES', 'name': 'Spanish', 'flag': '🇪🇸'},
        <String, String>{'code': 'zh-CN', 'name': 'Chinese', 'flag': '🇨🇳'},
        <String, String>{'code': 'ja-JP', 'name': 'Japanese', 'flag': '🇯🇵'},
      ];

  /// Filtered history entries based on search query.
  List<SttHistoryEntry> get filteredHistory {
    final List<SttHistoryEntry> entries = List<SttHistoryEntry>.of(
      historyEntries,
    );
    if (newestFirst.value) {
      entries.sort(
          (SttHistoryEntry a, SttHistoryEntry b) => b.date.compareTo(a.date),);
    } else {
      entries.sort(
          (SttHistoryEntry a, SttHistoryEntry b) => a.date.compareTo(b.date),);
    }
    final String query = historySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return entries;
    }
    return entries
        .where(
          (SttHistoryEntry e) =>
              e.transcript.toLowerCase().contains(query) ||
              e.languageName.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    transcriptController.addListener(_onTranscriptChanged);
    _initialize();
    _loadHistory();
  }

  @override
  void onClose() {
    _timer?.cancel();
    transcriptController.removeListener(_onTranscriptChanged);
    transcriptController.dispose();
    _service.dispose();
    super.onClose();
  }

  /// Initializes the speech recognition engine and requests permission.
  Future<void> _initialize() async {
    isLoading.value = true;

    // Request microphone permission.
    final PermissionStatus status = await Permission.microphone.request();
    hasPermission.value = status.isGranted;

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Required',
        'Microphone access is permanently denied. '
            'Please enable it in app settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } else if (!status.isGranted) {
      Get.snackbar(
        'Permission Denied',
        'Microphone access is required for speech recognition.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }

    // Initialize the engine.
    if (hasPermission.value) {
      isEngineAvailable.value = await _service.initialize();
      if (!isEngineAvailable.value) {
        Get.snackbar(
          'Engine Unavailable',
          'Speech recognition is not available on this device.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }

    isLoading.value = false;
  }

  /// Called when transcript text changes.
  void _onTranscriptChanged() {
    final String text = transcriptController.text;
    charCount.value = text.length;
    wordCount.value =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  /// Starts listening for speech.
  Future<void> startListening() async {
    if (!hasPermission.value) {
      await _initialize();
      if (!hasPermission.value) {
        return;
      }
    }

    if (!isEngineAvailable.value) {
      Get.snackbar(
        'Engine Unavailable',
        'Speech recognition is not available on this device.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    final bool ok = await _service.listen(
      localeId: selectedLanguageCode.value,
      onResult: _onSpeechResult,
    );
    isLoading.value = false;

    if (ok) {
      state.value = SttState.listening;
      _startTimer();
    } else {
      Get.snackbar(
        'Recognition Failed',
        'Unable to start speech recognition. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Handles speech recognition results.
  void _onSpeechResult(SpeechRecognitionResult result) {
    transcriptController.text = result.recognizedWords;
    if (result.finalResult) {
      state.value = SttState.completed;
      _stopTimer();
    }
  }

  /// Pauses listening.
  Future<void> pauseListening() async {
    await _service.stop();
    state.value = SttState.paused;
    _stopTimer();
  }

  /// Resumes listening.
  Future<void> resumeListening() async {
    await startListening();
  }

  /// Stops listening and saves the transcript.
  Future<void> stopListening() async {
    await _service.stop();
    state.value = SttState.completed;
    _stopTimer();

    final String text = transcriptController.text.trim();
    if (text.isNotEmpty) {
      unawaited(_saveHistoryEntry(text));
    }
  }

  /// Clears the current transcript.
  void clearTranscript() {
    transcriptController.clear();
    state.value = SttState.idle;
    _stopTimer();
    recordingSeconds.value = 0;
  }

  /// Copies the transcript to the clipboard.
  Future<void> copyTranscript() async {
    final String text = transcriptController.text.trim();
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Transcript copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Shares the transcript.
  Future<void> shareTranscript() async {
    final String text = transcriptController.text.trim();
    if (text.isEmpty) {
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Saves the transcript to history.
  Future<void> saveTranscript() async {
    final String text = transcriptController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Empty Transcript',
        'Nothing to save. Please transcribe some speech first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    unawaited(_saveHistoryEntry(text));
    Get.snackbar(
      'Saved',
      'Transcript saved to history.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Navigates to the text-to-speech module with the transcript.
  void sendToTts() {
    final String text = transcriptController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _navigationService.to(
      AppRoutes.textToSpeech,
      arguments: <String, String>{'text': text},
    );
  }

  /// Selects a recognition language.
  // ignore: use_setters_to_change_properties
  void selectLanguage(String code) {
    selectedLanguageCode.value = code;
  }

  /// Starts the recording timer.
  void _startTimer() {
    _timer?.cancel();
    recordingSeconds.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      recordingSeconds.value++;
    });
  }

  /// Stops the recording timer.
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Formats the recording duration.
  String get formattedDuration {
    final int minutes = recordingSeconds.value ~/ 60;
    final int seconds = recordingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Loads history entries from the repository.
  Future<void> _loadHistory() async {
    historyEntries.value = await _repository.getHistoryEntries();
  }

  /// Saves a history entry.
  Future<void> _saveHistoryEntry(String text) async {
    final SttHistoryEntry entry = SttHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      transcript: text,
      languageCode: selectedLanguageCode.value,
      languageName: _languageName(selectedLanguageCode.value),
      date: DateTime.now(),
      duration: Duration(seconds: recordingSeconds.value),
      wordCount: wordCount.value,
      charCount: charCount.value,
    );
    await _repository.saveHistoryEntry(entry);
    historyEntries.insert(0, entry);
  }

  /// Returns the human-readable language name.
  String _languageName(String code) {
    for (final Map<String, String> lang in languages) {
      if (lang['code'] == code) {
        return lang['name']!;
      }
    }
    return 'English (US)';
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    historyEntries.removeWhere((SttHistoryEntry e) => e.id == id);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    historyEntries.clear();
  }

  /// Updates the history search query.
  // ignore: use_setters_to_change_properties
  void onHistorySearchChanged(String query) {
    historySearchQuery.value = query;
  }

  /// Toggles history sort order.
  void toggleSortOrder() {
    newestFirst.value = !newestFirst.value;
  }
}

/// Recording state enum.
enum SttState {
  /// Not recording.
  idle,

  /// Listening for speech.
  listening,

  /// Paused.
  paused,

  /// Processing result.
  processing,

  /// Completed.
  completed,
}
