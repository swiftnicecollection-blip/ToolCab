import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../data/models/ocr_history_entry.dart';
import '../data/models/ocr_result.dart';
import '../data/repositories/ocr_repository.dart';
import '../service/ocr_service.dart';

/// Controller for the OCR module.
///
/// Manages image selection, OCR processing, extracted text,
/// history, and favorites.
class OcrController extends GetxController {
  /// OCR service.
  final OcrService _service = Get.find<OcrService>();

  /// OCR repository.
  final OcrRepository _repository = Get.find<OcrRepository>();

  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Image picker.
  final ImagePicker _imagePicker = ImagePicker();

  /// Current OCR state.
  final Rx<OcrState> state = Rx<OcrState>(OcrState.idle);

  /// Selected image path.
  final RxString imagePath = RxString('');

  /// Extracted text.
  final RxString extractedText = RxString('');

  /// Current OCR result.
  final Rx<OcrResult?> currentResult = Rx<OcrResult?>(null);

  /// History entries.
  final RxList<OcrHistoryEntry> historyEntries =
      RxList<OcrHistoryEntry>(<OcrHistoryEntry>[]);

  /// Favorites list.
  final RxList<OcrHistoryEntry> favorites =
      RxList<OcrHistoryEntry>(<OcrHistoryEntry>[]);

  /// Search query for history.
  final RxString historySearchQuery = RxString('');

  /// Search query for favorites.
  final RxString favoriteSearchQuery = RxString('');

  /// Whether the engine is loading.
  final RxBool isLoading = RxBool(false);

  /// Error message.
  final RxString errorMessage = RxString('');

  /// Filtered history entries.
  List<OcrHistoryEntry> get filteredHistory {
    final String query = historySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return historyEntries;
    }
    return historyEntries
        .where(
          (OcrHistoryEntry e) =>
              e.title.toLowerCase().contains(query) ||
              e.fullText.toLowerCase().contains(query) ||
              e.languageCode.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  /// Filtered favorites.
  List<OcrHistoryEntry> get filteredFavorites {
    final String query = favoriteSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return favorites;
    }
    return favorites
        .where(
          (OcrHistoryEntry e) =>
              e.title.toLowerCase().contains(query) ||
              e.fullText.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
    _loadHistory();
  }

  @override
  void onClose() {
    _service.dispose();
    super.onClose();
  }

  /// Initializes the OCR service.
  Future<void> _initialize() async {
    isLoading.value = true;
    await _service.initialize();
    isLoading.value = false;
  }

  /// Loads history entries from the repository.
  Future<void> _loadHistory() async {
    historyEntries.value = await _repository.getHistoryEntries();
    favorites.value =
        historyEntries.where((OcrHistoryEntry e) => e.isFavorite).toList();
  }

  /// Captures an image using the camera.
  Future<void> captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        imagePath.value = image.path;
        state.value = OcrState.previewing;
      }
    } catch (_) {
      errorMessage.value = 'Unable to access the camera.';
      state.value = OcrState.error;
    }
  }

  /// Picks an image from the gallery.
  Future<void> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (image != null) {
        imagePath.value = image.path;
        state.value = OcrState.previewing;
      }
    } catch (_) {
      errorMessage.value = 'Unable to access the gallery.';
      state.value = OcrState.error;
    }
  }

  /// Processes the selected image and extracts text.
  Future<void> processImage() async {
    if (imagePath.value.isEmpty) {
      return;
    }

    state.value = OcrState.processing;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final OcrResult result =
          await _service.extractTextFromImage(imagePath.value);
      extractedText.value = result.text;
      currentResult.value = result;

      if (result.text.trim().isEmpty) {
        errorMessage.value =
            'No text was detected. Try taking a clearer photo with better lighting.';
        state.value = OcrState.error;
      } else {
        state.value = OcrState.success;
      }
    } catch (_) {
      errorMessage.value = 'Unable to process the image. Please try again.';
      state.value = OcrState.error;
    } finally {
      isLoading.value = false;
    }
  }

  /// Saves the current OCR result to history.
  Future<void> saveResult() async {
    final OcrResult? result = currentResult.value;
    if (result == null || result.text.trim().isEmpty) {
      return;
    }

    final OcrHistoryEntry entry = OcrHistoryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: result.title,
      textPreview: result.textPreview,
      fullText: result.text,
      createdAt: DateTime.now(),
      imagePath: result.imagePath,
      languageCode: result.languageCode,
      wordCount: result.wordCount,
      charCount: result.charCount,
    );
    await _repository.saveHistoryEntry(entry);
    historyEntries.insert(0, entry);

    Get.snackbar(
      'Saved',
      'OCR result saved to history.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Copies the extracted text.
  Future<void> copyText() async {
    final String text = extractedText.value.trim();
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

  /// Shares the extracted text.
  Future<void> shareText() async {
    final String text = extractedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Sends the extracted text to the translator.
  void sendToTranslator() {
    final String text = extractedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    _navigationService.to(
      AppRoutes.translator,
      arguments: <String, String>{'text': text},
    );
  }

  /// Sends the extracted text to text-to-speech.
  void sendToTts() {
    final String text = extractedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    _navigationService.to(
      AppRoutes.textToSpeech,
      arguments: <String, String>{'text': text},
    );
  }

  /// Sends the extracted text to text-to-PDF.
  void sendToPdf() {
    final String text = extractedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    _navigationService.to(
      AppRoutes.textToPdf,
      arguments: <String, String>{'text': text},
    );
  }

  /// Exports the extracted text as a TXT file.
  Future<void> exportTxt() async {
    final String text = extractedText.value.trim();
    if (text.isEmpty) {
      return;
    }
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String fileName =
          'toolcab_ocr_${DateTime.now().millisecondsSinceEpoch}.txt';
      final File file = File('${dir.path}/$fileName');
      await file.writeAsString(text);
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(file.path)]),
      );
    } catch (_) {
      Get.snackbar(
        'Export Failed',
        'Unable to export the text file.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Toggles favorite status for a history entry.
  Future<void> toggleFavorite(OcrHistoryEntry entry) async {
    final OcrHistoryEntry updated = entry.copyWith(
      isFavorite: !entry.isFavorite,
    );
    await _repository.updateHistoryEntry(updated);

    final int index = historyEntries.indexWhere(
      (OcrHistoryEntry e) => e.id == entry.id,
    );
    if (index >= 0) {
      historyEntries[index] = updated;
    }

    if (updated.isFavorite) {
      if (!favorites.any((OcrHistoryEntry e) => e.id == entry.id)) {
        favorites.insert(0, updated);
      }
    } else {
      favorites.removeWhere((OcrHistoryEntry e) => e.id == entry.id);
    }
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    historyEntries.removeWhere((OcrHistoryEntry e) => e.id == id);
    favorites.removeWhere((OcrHistoryEntry e) => e.id == id);
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

  /// Resets the OCR state.
  void reset() {
    state.value = OcrState.idle;
    imagePath.value = '';
    extractedText.value = '';
    currentResult.value = null;
    errorMessage.value = '';
  }
}

/// OCR state enum.
enum OcrState {
  /// Initial state.
  idle,

  /// Image selected, previewing.
  previewing,

  /// Processing the image.
  processing,

  /// OCR completed successfully.
  success,

  /// No text detected or error.
  error,
}
