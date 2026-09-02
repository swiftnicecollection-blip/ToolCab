import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../data/models/extraction_models.dart';
import '../data/models/pdf_to_text_draft.dart';
import '../data/repositories/pdf_to_text_draft_repository.dart';
import '../data/repositories/pdf_to_text_repository.dart';
import '../service/pdf_ocr_service.dart';
import '../service/pdf_text_extraction_service.dart';

/// Controller for the PDF → Text module.
///
/// Manages the full extraction flow:
/// - PDF selection and analysis
/// - Page selection
/// - Native text extraction / OCR fallback
/// - Result editing
/// - History and favorites
class PdfToTextController extends GetxController {
  /// PDF text extraction service.
  final PdfTextExtractionService _extractionService =
      Get.find<PdfTextExtractionService>();

  /// OCR service.
  final PdfOcrService _ocrService = Get.find<PdfOcrService>();

  /// PDF → Text repository.
  final PdfToTextRepository _repository = Get.find<PdfToTextRepository>();

  /// Draft repository.
  final PdfToTextDraftRepository _draftRepository =
      Get.find<PdfToTextDraftRepository>();

  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Current flow state.
  final Rx<PdfToTextFlowState> state =
      Rx<PdfToTextFlowState>(PdfToTextFlowState.idle);

  /// Selected PDF file path.
  final RxString selectedFilePath = RxString('');

  /// Analysis result.
  final Rx<PdfAnalysisResult?> analysisResult = Rx<PdfAnalysisResult?>(null);

  /// Page selection.
  final Rx<PdfPageSelection> pageSelection =
      Rx<PdfPageSelection>(const PdfPageSelection());

  /// Extraction method.
  final Rx<PdfExtractionMethod> extractionMethod =
      Rx<PdfExtractionMethod>(PdfExtractionMethod.automatic);

  /// OCR language code.
  final RxString ocrLanguage = RxString('en');

  /// Whether to show page separators.
  final RxBool showPageSeparators = RxBool(true);

  /// Current extraction result.
  final Rx<PdfExtractionResult?> currentResult = Rx<PdfExtractionResult?>(null);

  /// Text editing controller.
  final TextEditingController textController = TextEditingController();

  /// History entries.
  final RxList<PdfExtractionResult> historyEntries =
      RxList<PdfExtractionResult>(<PdfExtractionResult>[]);

  /// Favorites.
  final RxList<PdfExtractionResult> favorites =
      RxList<PdfExtractionResult>(<PdfExtractionResult>[]);

  /// Whether processing is in progress.
  final RxBool isProcessing = RxBool(false);

  /// Current page being processed (1-based).
  final RxInt currentPage = RxInt(0);

  /// Total pages to process.
  final RxInt totalPages = RxInt(0);

  /// Error message.
  final RxString errorMessage = RxString('');

  /// Whether a draft exists.
  final RxBool hasDraft = RxBool(false);

  /// Whether the result is a favorite.
  final RxBool isFavorite = RxBool(false);

  /// Search query for history.
  final RxString historySearchQuery = RxString('');

  /// Search query for favorites.
  final RxString favoriteSearchQuery = RxString('');

  /// Autosave timer.
  Timer? _autosaveTimer;

  /// Whether extraction was cancelled.
  bool _cancelled = false;

  /// Temporary directory for rendered pages.
  String? _tempDir;

  /// Word count of the current text.
  int get wordCount {
    final String text = textController.text.trim();
    if (text.isEmpty) {
      return 0;
    }
    return text.split(RegExp(r'\s+')).length;
  }

  /// Character count of the current text.
  int get charCount => textController.text.length;

  /// Filtered history entries.
  List<PdfExtractionResult> get filteredHistory {
    final String query = historySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return historyEntries;
    }
    return historyEntries
        .where(
          (PdfExtractionResult e) =>
              e.title.toLowerCase().contains(query) ||
              e.text.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  /// Filtered favorites.
  List<PdfExtractionResult> get filteredFavorites {
    final String query = favoriteSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return favorites;
    }
    return favorites
        .where(
          (PdfExtractionResult e) =>
              e.title.toLowerCase().contains(query) ||
              e.text.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
    textController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    _autosaveTimer?.cancel();
    textController.removeListener(_onTextChanged);
    textController.dispose();
    _ocrService.dispose();
    _cleanupTempFiles();
    super.onClose();
  }

  /// Initializes the controller.
  Future<void> _initialize() async {
    historyEntries.value = await _repository.getHistory();
    favorites.value =
        historyEntries.where((PdfExtractionResult e) => e.isFavorite).toList();
    hasDraft.value = _draftRepository.loadDraft() != null;
    await _ocrService.initialize();
  }

  /// Called when text changes - schedules autosave.
  void _onTextChanged() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  /// Saves the current extraction as a draft.
  Future<void> _saveDraft() async {
    final PdfExtractionResult? result = currentResult.value;
    if (result == null || textController.text.trim().isEmpty) {
      return;
    }
    final PdfToTextDraft draft = PdfToTextDraft(
      fileName: result.fileName,
      filePath: result.filePath,
      fileSize: result.fileSize,
      pageCount: result.pageCount,
      method: result.method,
      pages: result.pages,
      text: textController.text,
      languageCode: result.languageCode,
      createdAt: DateTime.now(),
    );
    await _draftRepository.saveDraft(draft);
  }

  /// Loads a saved draft.
  void loadDraft() {
    final PdfToTextDraft? draft = _draftRepository.loadDraft();
    if (draft == null) {
      return;
    }
    textController.text = draft.text;
    currentResult.value = PdfExtractionResult(
      fileName: draft.fileName,
      filePath: draft.filePath,
      fileSize: draft.fileSize,
      pageCount: draft.pageCount,
      method: draft.method,
      pages: draft.pages,
      text: draft.text,
      languageCode: draft.languageCode,
      createdAt: draft.createdAt,
    );
    state.value = PdfToTextFlowState.success;
    hasDraft.value = false;
  }

  /// Discards the saved draft.
  Future<void> discardDraft() async {
    await _draftRepository.clearDraft();
    hasDraft.value = false;
  }

  /// Selects a PDF file.
  Future<void> selectPdf() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf'],
      );
      if (result == null || result.files.isEmpty) {
        return; // Cancelled.
      }
      final String path = result.files.first.path!;
      selectedFilePath.value = path;
      await analyzePdf(path);
    } catch (_) {
      errorMessage.value = 'Unable to select the PDF file.';
      state.value = PdfToTextFlowState.failed;
    }
  }

  /// Analyzes the selected PDF.
  Future<void> analyzePdf(String filePath) async {
    state.value = PdfToTextFlowState.analyzing;
    errorMessage.value = '';
    try {
      final PdfAnalysisResult result =
          await _extractionService.analyzePdf(filePath);
      analysisResult.value = result;

      if (!result.isSuccessful) {
        errorMessage.value = result.errorMessage ?? 'Unable to analyze PDF.';
        state.value = PdfToTextFlowState.failed;
        return;
      }

      // Initialize page selection.
      pageSelection.value = const PdfPageSelection();
      state.value = PdfToTextFlowState.analyzed;
    } catch (_) {
      errorMessage.value = 'Unable to analyze the PDF.';
      state.value = PdfToTextFlowState.failed;
    }
  }

  /// Sets the extraction method.
  // ignore: use_setters_to_change_properties
  void setExtractionMethod(PdfExtractionMethod method) {
    extractionMethod.value = method;
  }

  /// Sets the OCR language.
  void setOcrLanguage(String language) {
    if (!_ocrService.isLanguageSupported(language)) {
      Get.snackbar(
        'Language Unavailable',
        "That OCR language isn't available on this device.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    ocrLanguage.value = language;
  }

  /// Toggles page selection mode.
  void toggleSelectAll() {
    if (pageSelection.value.mode == PdfPageSelectionMode.all) {
      pageSelection.value = const PdfPageSelection(
        mode: PdfPageSelectionMode.specific,
      );
    } else {
      pageSelection.value = const PdfPageSelection(
        mode: PdfPageSelectionMode.all,
      );
    }
  }

  /// Toggles a specific page.
  void togglePage(int page) {
    final PdfPageSelection current = pageSelection.value;
    final Set<int> pages = Set<int>.of(current.selectedPages);
    if (pages.contains(page)) {
      pages.remove(page);
    } else {
      pages.add(page);
    }
    pageSelection.value = PdfPageSelection(
      selectedPages: pages,
      mode: PdfPageSelectionMode.specific,
    );
  }

  /// Clears all selected pages.
  void clearPageSelection() {
    pageSelection.value = const PdfPageSelection(
      mode: PdfPageSelectionMode.specific,
    );
  }

  /// Validates and applies a page range input.
  ///
  /// Supports formats like: 1-5, 2,4,7, 1-3,8-10
  bool applyPageRange(String input) {
    final int pageCount = analysisResult.value?.pageCount ?? 0;
    if (pageCount <= 0) {
      return false;
    }

    final Set<int> pages = <int>{};
    final List<String> parts = input.split(',');
    for (final String part in parts) {
      final String trimmed = part.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      if (trimmed.contains('-')) {
        final List<String> range = trimmed.split('-');
        if (range.length != 2) {
          return false;
        }
        final int? start = int.tryParse(range[0].trim());
        final int? end = int.tryParse(range[1].trim());
        if (start == null || end == null || start < 1 || end < 1) {
          return false;
        }
        if (start > end) {
          return false;
        }
        for (int i = start; i <= end; i++) {
          if (i > pageCount) {
            return false;
          }
          pages.add(i);
        }
      } else {
        final int? page = int.tryParse(trimmed);
        if (page == null || page < 1 || page > pageCount) {
          return false;
        }
        pages.add(page);
      }
    }

    if (pages.isEmpty) {
      return false;
    }

    pageSelection.value = PdfPageSelection(
      selectedPages: pages,
      mode: PdfPageSelectionMode.specific,
    );
    return true;
  }

  /// Returns the list of selected page numbers.
  List<int> getSelectedPages() {
    final int pageCount = analysisResult.value?.pageCount ?? 0;
    if (pageSelection.value.mode == PdfPageSelectionMode.all) {
      return List<int>.generate(pageCount, (int i) => i + 1);
    }
    final List<int> pages = pageSelection.value.selectedPages.toList()..sort();
    return pages.where((int p) => p >= 1 && p <= pageCount).toList();
  }

  /// Starts the extraction process.
  Future<void> startExtraction() async {
    final String filePath = selectedFilePath.value;
    if (filePath.isEmpty) {
      return;
    }

    final List<int> pages = getSelectedPages();
    if (pages.isEmpty) {
      Get.snackbar(
        'No Pages Selected',
        'Please select at least one page to extract.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    state.value = PdfToTextFlowState.extracting;
    isProcessing.value = true;
    _cancelled = false;
    errorMessage.value = '';
    totalPages.value = pages.length;
    currentPage.value = 0;

    try {
      final PdfExtractionMethod method = extractionMethod.value;
      final Map<int, String> extractedText = <int, String>{};

      if (method == PdfExtractionMethod.automatic) {
        // Try native text extraction first.
        final Map<int, String> nativeText =
            await _extractionService.extractTextFromPages(filePath, pages);
        for (final int page in pages) {
          if (_cancelled) {
            break;
          }
          currentPage.value = page;
          if (nativeText.containsKey(page) &&
              nativeText[page]!.trim().isNotEmpty) {
            extractedText[page] = nativeText[page]!;
          } else {
            // Fall back to OCR for this page.
            final String? imagePath =
                await _extractionService.renderPageToImage(filePath, page);
            if (imagePath != null) {
              final String ocrText =
                  await _ocrService.extractTextFromImage(imagePath);
              if (ocrText.trim().isNotEmpty) {
                extractedText[page] = ocrText;
              }
            }
          }
        }
      } else if (method == PdfExtractionMethod.selectableText) {
        final Map<int, String> nativeText =
            await _extractionService.extractTextFromPages(filePath, pages);
        for (final int page in pages) {
          if (_cancelled) {
            break;
          }
          currentPage.value = page;
          if (nativeText.containsKey(page)) {
            extractedText[page] = nativeText[page]!;
          }
        }
      } else {
        // OCR method.
        for (final int page in pages) {
          if (_cancelled) {
            break;
          }
          currentPage.value = page;
          final String? imagePath =
              await _extractionService.renderPageToImage(filePath, page);
          if (imagePath != null) {
            final String ocrText =
                await _ocrService.extractTextFromImage(imagePath);
            if (ocrText.trim().isNotEmpty) {
              extractedText[page] = ocrText;
            }
          }
        }
      }

      if (_cancelled) {
        state.value = PdfToTextFlowState.cancelled;
        return;
      }

      // Build the final text.
      final StringBuffer buffer = StringBuffer();
      final List<int> sortedPages = extractedText.keys.toList()..sort();
      for (int i = 0; i < sortedPages.length; i++) {
        final int page = sortedPages[i];
        if (showPageSeparators.value) {
          buffer.writeln('--- Page $page ---');
          buffer.writeln();
        }
        buffer.write(extractedText[page]!.trim());
        if (i < sortedPages.length - 1) {
          buffer.writeln();
          buffer.writeln();
        }
      }

      final String finalText = buffer.toString().trim();
      if (finalText.isEmpty) {
        errorMessage.value =
            'No readable text found. This PDF may contain images, handwriting, '
            'or text that the selected OCR engine cannot recognize.';
        state.value = PdfToTextFlowState.failed;
        return;
      }

      // Determine the effective method.
      final PdfExtractionMethod effectiveMethod;
      if (method == PdfExtractionMethod.automatic) {
        effectiveMethod = extractedText.length == pages.length
            ? PdfExtractionMethod.selectableText
            : PdfExtractionMethod.ocr;
      } else {
        effectiveMethod = method;
      }

      final PdfExtractionResult result = PdfExtractionResult(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: filePath.split('/').last,
        filePath: filePath,
        fileSize: analysisResult.value?.fileSize,
        pageCount: analysisResult.value?.pageCount ?? pages.length,
        method: effectiveMethod,
        pages: pageSelection.value.serialized,
        text: finalText,
        languageCode: effectiveMethod == PdfExtractionMethod.ocr
            ? ocrLanguage.value
            : null,
        createdAt: DateTime.now(),
      );

      currentResult.value = result;
      textController.text = finalText;
      isFavorite.value = false;

      // Save to history.
      await _repository.saveResult(result);
      historyEntries.insert(0, result);

      // Clear draft.
      await _draftRepository.clearDraft();
      hasDraft.value = false;

      state.value = PdfToTextFlowState.success;
    } catch (_) {
      errorMessage.value = 'Extraction failed. Please try again.';
      state.value = PdfToTextFlowState.failed;
    } finally {
      isProcessing.value = false;
      currentPage.value = 0;
      _cleanupTempFiles();
    }
  }

  /// Cancels the current extraction.
  void cancelExtraction() {
    _cancelled = true;
  }

  /// Copies the extracted text to clipboard.
  Future<void> copyText() async {
    final String text = textController.text.trim();
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
    final String text = textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Exports the extracted text as a TXT file.
  Future<void> exportTxt() async {
    final String text = textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String date = DateTime.now().toIso8601String().substring(0, 10);
      final String fileName = 'ToolCab_Extracted_Text_$date.txt';
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

  /// Sends the extracted text to the translator.
  void sendToTranslator() {
    final String text = textController.text.trim();
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
    final String text = textController.text.trim();
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
    final String text = textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _navigationService.to(
      AppRoutes.textToPdf,
      arguments: <String, String>{'text': text},
    );
  }

  /// Toggles favorite status for the current result.
  Future<void> toggleFavorite() async {
    final PdfExtractionResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    final bool newFavorite = !isFavorite.value;
    isFavorite.value = newFavorite;

    final PdfExtractionResult updated = result.copyWith(
      isFavorite: newFavorite,
    );
    currentResult.value = updated;

    await _repository.updateResult(updated);

    final int index = historyEntries.indexWhere(
      (PdfExtractionResult e) => e.id == result.id,
    );
    if (index >= 0) {
      historyEntries[index] = updated;
    }

    if (newFavorite) {
      if (!favorites.any((PdfExtractionResult e) => e.id == result.id)) {
        favorites.insert(0, updated);
      }
    } else {
      favorites.removeWhere((PdfExtractionResult e) => e.id == result.id);
    }
  }

  /// Toggles favorite status for a history entry.
  Future<void> toggleHistoryFavorite(PdfExtractionResult entry) async {
    final PdfExtractionResult updated = entry.copyWith(
      isFavorite: !entry.isFavorite,
    );
    await _repository.updateResult(updated);

    final int index = historyEntries.indexWhere(
      (PdfExtractionResult e) => e.id == entry.id,
    );
    if (index >= 0) {
      historyEntries[index] = updated;
    }

    if (updated.isFavorite) {
      if (!favorites.any((PdfExtractionResult e) => e.id == entry.id)) {
        favorites.insert(0, updated);
      }
    } else {
      favorites.removeWhere((PdfExtractionResult e) => e.id == entry.id);
    }
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String id) async {
    await _repository.deleteResult(id);
    historyEntries.removeWhere((PdfExtractionResult e) => e.id == id);
    favorites.removeWhere((PdfExtractionResult e) => e.id == id);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    historyEntries.clear();
    favorites.clear();
  }

  /// Loads a history entry into the editor.
  void loadHistoryEntry(PdfExtractionResult entry) {
    currentResult.value = entry;
    textController.text = entry.text;
    isFavorite.value = entry.isFavorite;
    state.value = PdfToTextFlowState.success;
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

  /// Resets the flow to the initial state.
  void reset() {
    state.value = PdfToTextFlowState.idle;
    selectedFilePath.value = '';
    analysisResult.value = null;
    pageSelection.value = const PdfPageSelection();
    extractionMethod.value = PdfExtractionMethod.automatic;
    currentResult.value = null;
    textController.clear();
    errorMessage.value = '';
    isFavorite.value = false;
    _cleanupTempFiles();
  }

  /// Cleans up temporary files.
  void _cleanupTempFiles() {
    if (_tempDir != null) {
      _extractionService.cleanupTempDirectory(_tempDir!);
      _tempDir = null;
    }
  }
}
