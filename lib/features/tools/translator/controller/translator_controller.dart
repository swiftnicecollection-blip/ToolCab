import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../data/models/translation_history_entry.dart';
import '../data/models/translator_language.dart';
import '../data/repositories/translation_repository.dart';
import '../service/translation_service.dart';

/// Controller for the language translator module.
///
/// Manages text input, language selection, translation state,
/// history, and favorites.
class TranslatorController extends GetxController {
  /// Translation service.
  final TranslationService _service = Get.find<TranslationService>();

  /// Translation repository.
  final TranslationRepository _repository = Get.find<TranslationRepository>();

  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Source text controller.
  final TextEditingController sourceController = TextEditingController();

  /// Translated text.
  final RxString translatedText = RxString('');

  /// Source language code.
  final RxString sourceLanguageCode = RxString('en');

  /// Target language code.
  final RxString targetLanguageCode = RxString('ur');

  /// Whether to auto-detect the source language.
  final RxBool autoDetect = RxBool(true);

  /// Detected language code.
  final RxString detectedLanguageCode = RxString('');

  /// Whether translation is in progress.
  final RxBool isLoading = RxBool(false);

  /// Whether a translation model is downloading.
  final RxBool isModelDownloading = RxBool(false);

  /// Error message from last translation attempt.
  final RxString errorMessage = RxString('');

  /// Current text character count.
  final RxInt charCount = RxInt(0);

  /// Current text word count.
  final RxInt wordCount = RxInt(0);

  /// History entries.
  final RxList<TranslationHistoryEntry> historyEntries =
      RxList<TranslationHistoryEntry>(<TranslationHistoryEntry>[]);

  /// Favorites list.
  final RxList<TranslationHistoryEntry> favorites =
      RxList<TranslationHistoryEntry>(<TranslationHistoryEntry>[]);

  /// Search query for history.
  final RxString historySearchQuery = RxString('');

  /// Search query for favorites.
  final RxString favoriteSearchQuery = RxString('');

  /// Available languages.
  List<TranslatorLanguage> get languages => TranslatorLanguage.supported;

  /// Source language model.
  TranslatorLanguage get sourceLanguage =>
      TranslatorLanguage.fromCode(sourceLanguageCode.value);

  /// Target language model.
  TranslatorLanguage get targetLanguage =>
      TranslatorLanguage.fromCode(targetLanguageCode.value);

  /// Detected language model.
  TranslatorLanguage get detectedLanguage =>
      TranslatorLanguage.fromCode(detectedLanguageCode.value);

  /// Whether the source text is valid for translation.
  bool get hasValidText => sourceController.text.trim().isNotEmpty;

  /// Whether the result is available.
  bool get hasResult => translatedText.value.trim().isNotEmpty;

  /// Filtered history entries based on search query.
  List<TranslationHistoryEntry> get filteredHistory {
    final String query = historySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return historyEntries;
    }
    return historyEntries
        .where(
          (TranslationHistoryEntry e) =>
              e.originalText.toLowerCase().contains(query) ||
              e.translatedText.toLowerCase().contains(query) ||
              e.sourceLanguageName.toLowerCase().contains(query) ||
              e.targetLanguageName.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  /// Filtered favorites based on search query.
  List<TranslationHistoryEntry> get filteredFavorites {
    final String query = favoriteSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return favorites;
    }
    return favorites
        .where(
          (TranslationHistoryEntry e) =>
              e.originalText.toLowerCase().contains(query) ||
              e.translatedText.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    sourceController.addListener(_onSourceTextChanged);
    _initialize();
    _loadHistory();
  }

  @override
  void onClose() {
    sourceController.removeListener(_onSourceTextChanged);
    sourceController.dispose();
    _service.dispose();
    super.onClose();
  }

  /// Initializes the translation service.
  Future<void> _initialize() async {
    isLoading.value = true;
    await _service.initialize();
    isLoading.value = false;
  }

  /// Called when source text changes.
  void _onSourceTextChanged() {
    final String text = sourceController.text;
    charCount.value = text.length;
    wordCount.value =
        text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

    // Auto-detect language if enabled and text is not empty.
    if (autoDetect.value && text.trim().isNotEmpty) {
      unawaited(_detectLanguage(text));
    }
  }

  /// Detects the language of the given text.
  Future<void> _detectLanguage(String text) async {
    final String? detected = await _service.detectLanguage(text);
    if (detected != null && detected != targetLanguageCode.value) {
      detectedLanguageCode.value = detected;
      sourceLanguageCode.value = detected;
    }
  }

  /// Translates the current text.
  Future<void> translate() async {
    final String text = sourceController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Empty Text',
        'Please enter some text to translate.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (sourceLanguageCode.value == targetLanguageCode.value) {
      Get.snackbar(
        'Same Language',
        'Source and target language are the same. Please choose different languages.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final String result = await _service.translate(
        text: text,
        sourceLanguageCode: sourceLanguageCode.value,
        targetLanguageCode: targetLanguageCode.value,
      );
      translatedText.value = result;
      unawaited(_saveHistoryEntry(text, result));
    } on TranslationException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Translation Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      errorMessage.value = 'Translation failed. Please try again.';
      Get.snackbar(
        'Translation Failed',
        'Unable to translate. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Swaps the source and target languages.
  void swapLanguages() {
    final String temp = sourceLanguageCode.value;
    sourceLanguageCode.value = targetLanguageCode.value;
    targetLanguageCode.value = temp;

    // Swap text too.
    final String original = sourceController.text;
    sourceController.text = translatedText.value;
    translatedText.value = original;

    autoDetect.value = false;
    detectedLanguageCode.value = '';
  }

  /// Selects the source language.
  void selectSourceLanguage(String code) {
    sourceLanguageCode.value = code;
    autoDetect.value = false;
    detectedLanguageCode.value = '';
  }

  /// Selects the target language.
  // ignore: use_setters_to_change_properties
  void selectTargetLanguage(String code) {
    targetLanguageCode.value = code;
  }

  /// Enables auto language detection.
  void enableAutoDetect() {
    autoDetect.value = true;
    detectedLanguageCode.value = '';
    if (sourceController.text.trim().isNotEmpty) {
      _detectLanguage(sourceController.text);
    }
  }

  /// Copies the translated text.
  Future<void> copyTranslation() async {
    final String text = translatedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Translation copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Shares the translated text.
  Future<void> shareTranslation() async {
    final String text = translatedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Clears both text fields.
  void clearAll() {
    sourceController.clear();
    translatedText.value = '';
    detectedLanguageCode.value = '';
    errorMessage.value = '';
  }

  /// Favorites the current translation.
  Future<void> favoriteCurrentTranslation() async {
    final String original = sourceController.text.trim();
    final String translated = translatedText.value.trim();
    if (original.isEmpty || translated.isEmpty) {
      return;
    }

    final TranslationHistoryEntry entry = TranslationHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      originalText: original,
      translatedText: translated,
      sourceLanguageCode: sourceLanguageCode.value,
      sourceLanguageName: sourceLanguage.name,
      targetLanguageCode: targetLanguageCode.value,
      targetLanguageName: targetLanguage.name,
      date: DateTime.now(),
      detectedLanguageCode: detectedLanguageCode.value.isEmpty
          ? null
          : detectedLanguageCode.value,
      detectedLanguageName:
          detectedLanguageCode.value.isEmpty ? null : detectedLanguage.name,
      isFavorite: true,
    );
    await _repository.saveHistoryEntry(entry);
    historyEntries.insert(0, entry);
    favorites.insert(0, entry);

    Get.snackbar(
      'Favorited',
      'Translation saved to favorites.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Toggles favorite status for a history entry.
  Future<void> toggleFavorite(TranslationHistoryEntry entry) async {
    final TranslationHistoryEntry updated = entry.copyWith(
      isFavorite: !entry.isFavorite,
    );
    await _repository.updateHistoryEntry(updated);

    final int index = historyEntries.indexWhere(
      (TranslationHistoryEntry e) => e.id == entry.id,
    );
    if (index >= 0) {
      historyEntries[index] = updated;
    }

    if (updated.isFavorite) {
      if (!favorites.any((TranslationHistoryEntry e) => e.id == entry.id)) {
        favorites.insert(0, updated);
      }
    } else {
      favorites.removeWhere(
        (TranslationHistoryEntry e) => e.id == entry.id,
      );
    }
  }

  /// Loads history entries from the repository.
  Future<void> _loadHistory() async {
    historyEntries.value = await _repository.getHistoryEntries();
    favorites.value = historyEntries
        .where((TranslationHistoryEntry e) => e.isFavorite)
        .toList();
  }

  /// Saves a translation to history.
  Future<void> _saveHistoryEntry(String original, String translated) async {
    final TranslationHistoryEntry entry = TranslationHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      originalText: original,
      translatedText: translated,
      sourceLanguageCode: sourceLanguageCode.value,
      sourceLanguageName: sourceLanguage.name,
      targetLanguageCode: targetLanguageCode.value,
      targetLanguageName: targetLanguage.name,
      date: DateTime.now(),
      detectedLanguageCode: detectedLanguageCode.value.isEmpty
          ? null
          : detectedLanguageCode.value,
      detectedLanguageName:
          detectedLanguageCode.value.isEmpty ? null : detectedLanguage.name,
    );
    await _repository.saveHistoryEntry(entry);
    historyEntries.insert(0, entry);
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    historyEntries.removeWhere((TranslationHistoryEntry e) => e.id == id);
    favorites.removeWhere((TranslationHistoryEntry e) => e.id == id);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    historyEntries.clear();
    favorites.clear();
  }

  /// Updates the history search query.
  // ignore: use_setters_to_change_properties
  void onHistorySearchChanged(String query) {
    historySearchQuery.value = query;
  }

  /// Updates the favorite search query.
  // ignore: use_setters_to_change_properties
  void onFavoriteSearchChanged(String query) {
    favoriteSearchQuery.value = query;
  }

  /// Navigates to the text-to-speech module with the translation.
  void sendToTts() {
    final String text = translatedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    _navigationService.to(
      AppRoutes.textToSpeech,
      arguments: <String, String>{'text': text},
    );
  }
}
