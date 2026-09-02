import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../pdf/data/models/pdf_models.dart';
import '../../pdf/data/repositories/pdf_repository.dart';
import '../data/models/split_models.dart';
import '../service/split_pdf_service.dart';

/// Controller for the Split PDF module.
///
/// Manages single-PDF selection, page selection, split modes,
/// output generation, history, favorites, and result management.
class SplitPdfController extends GetxController {
  /// Split service.
  final SplitPdfService _service = Get.find<SplitPdfService>();

  /// PDF repository for history and recent files.
  final PdfRepository _pdfRepository = Get.find<PdfRepository>();

  /// Current flow state.
  final Rx<SplitPdfState> state = Rx<SplitPdfState>(SplitPdfState.idle);

  /// Selected PDF file path.
  final RxString selectedFilePath = RxString('');

  /// Selected PDF file name.
  final RxString selectedFileName = RxString('');

  /// Selected PDF file size.
  final RxInt selectedFileSize = RxInt(0);

  /// Selected PDF page count.
  final RxInt pageCount = RxInt(0);

  /// Selected page numbers.
  final RxSet<int> selectedPages = RxSet<int>(<int>{});

  /// Current split mode.
  final Rx<SplitMode> splitMode = Rx<SplitMode>(SplitMode.extractSelected);

  /// Base output filename.
  final RxString baseFileName = RxString('');

  /// Whether processing is in progress.
  final RxBool isProcessing = RxBool(false);

  /// Error message.
  final RxString errorMessage = RxString('');

  /// Current split result.
  final Rx<SplitPdfResult?> currentResult = Rx<SplitPdfResult?>(null);

  /// Whether extraction was cancelled.
  bool _cancelled = false;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initializes the controller.
  Future<void> _initialize() async {
    baseFileName.value = _service.defaultBaseFileName();
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
      state.value = SplitPdfState.analyzing;

      // Validate the file.
      final String? error = await _service.validatePdf(path);
      if (error != null) {
        errorMessage.value = error;
        state.value = SplitPdfState.error;
        return;
      }

      // Analyze the file.
      final info = await _service.analyzePdf(path);
      selectedFilePath.value = path;
      selectedFileName.value = info.fileName;
      selectedFileSize.value = info.fileSize;
      pageCount.value = info.pageCount;
      selectedPages.clear();
      splitMode.value = SplitMode.extractSelected;
      baseFileName.value = _service.defaultBaseFileName();

      state.value = SplitPdfState.ready;
    } catch (_) {
      errorMessage.value = 'Unable to select or analyze the PDF.';
      state.value = SplitPdfState.error;
    }
  }

  /// Toggles a page in the selection.
  void togglePage(int pageNumber) {
    if (selectedPages.contains(pageNumber)) {
      selectedPages.remove(pageNumber);
    } else {
      selectedPages.add(pageNumber);
    }
  }

  /// Selects all pages.
  void selectAllPages() {
    selectedPages.clear();
    for (int i = 1; i <= pageCount.value; i++) {
      selectedPages.add(i);
    }
  }

  /// Clears all selected pages.
  void clearPageSelection() {
    selectedPages.clear();
  }

  /// Sets the split mode.
  // ignore: use_setters_to_change_properties
  void setSplitMode(SplitMode mode) {
    splitMode.value = mode;
  }

  /// Sets the base output filename.
  // ignore: use_setters_to_change_properties
  void setBaseFileName(String name) {
    baseFileName.value = name;
  }

  /// Validates and applies a page range string.
  /// Returns an error message, or null on success.
  String? applyPageRange(String input) {
    final List<int>? pages = _service.parsePageRange(
      input,
      pageCount: pageCount.value,
    );
    if (pages == null) {
      return 'Invalid page range. Pages must be between 1 and ${pageCount.value}.';
    }
    selectedPages.clear();
    selectedPages.addAll(pages);
    return null;
  }

  /// Validates and applies multiple ranges.
  /// Returns a list of page groups, or null on error.
  List<List<int>>? getRangeGroups(String input) {
    return _service.parseRanges(input, pageCount: pageCount.value);
  }

  /// Starts the split operation.
  Future<void> startSplit() async {
    if (selectedFilePath.value.isEmpty || pageCount.value == 0) {
      errorMessage.value = 'Please select a PDF first.';
      state.value = SplitPdfState.error;
      return;
    }

    final String? nameError = _service.validateBaseFileName(baseFileName.value);
    if (nameError != null) {
      Get.snackbar(
        'Invalid Filename',
        nameError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    state.value = SplitPdfState.processing;
    isProcessing.value = true;
    _cancelled = false;
    errorMessage.value = '';

    try {
      final SplitMode mode = splitMode.value;
      final List<SplitOutputFile> outputs = <SplitOutputFile>[];

      if (mode == SplitMode.extractSelected) {
        if (selectedPages.isEmpty) {
          Get.snackbar(
            'No Pages Selected',
            'Please select at least one page to extract.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          state.value = SplitPdfState.ready;
          return;
        }
        final List<int> pages = selectedPages.toList()..sort();
        final SplitOutputFile output = await _service.extractPages(
          filePath: selectedFilePath.value,
          sourceFileName: selectedFileName.value,
          pageNumbers: pages,
          outputName: '${baseFileName.value}_Extracted.pdf',
        );
        outputs.add(output);
      } else if (mode == SplitMode.byRanges) {
        // Will be populated via UI input.
        state.value = SplitPdfState.configuring;
        return;
      } else {
        // Every page mode.
        final List<SplitOutputFile> all = await _service.splitEveryPage(
          filePath: selectedFilePath.value,
          baseFileName: baseFileName.value,
          pageCount: pageCount.value,
        );
        outputs.addAll(all);
      }

      if (_cancelled) {
        state.value = SplitPdfState.cancelled;
        return;
      }

      final SplitPdfResult result = SplitPdfResult(
        sourceFileName: selectedFileName.value,
        sourcePageCount: pageCount.value,
        mode: mode,
        outputs: outputs,
        createdAt: DateTime.now(),
      );
      currentResult.value = result;

      // Save to history and recent files.
      for (final SplitOutputFile output in outputs) {
        final PdfHistoryEntry entry = PdfHistoryEntry(
          id: output.id,
          operation: PdfOperation.split,
          date: DateTime.now(),
          fileName: output.fileName,
          fileSize: output.fileSize,
          pageCount: output.pageCount,
          filePath: output.filePath,
        );
        await _pdfRepository.saveHistoryEntry(entry);

        final PdfFileItem recentFile = PdfFileItem(
          id: output.id,
          fileName: output.fileName,
          filePath: output.filePath,
          fileSize: output.fileSize,
          pageCount: output.pageCount,
          createdAt: DateTime.now(),
          source: 'created',
        );
        await _pdfRepository.saveRecentFile(recentFile);
      }

      state.value = SplitPdfState.success;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      state.value = SplitPdfState.error;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Continues the split by ranges mode.
  Future<void> splitWithRanges(List<List<int>> ranges) async {
    if (_cancelled) {
      state.value = SplitPdfState.cancelled;
      return;
    }

    try {
      final List<SplitOutputFile> outputs = await _service.splitByRanges(
        filePath: selectedFilePath.value,
        baseFileName: baseFileName.value,
        ranges: ranges,
      );

      final SplitPdfResult result = SplitPdfResult(
        sourceFileName: selectedFileName.value,
        sourcePageCount: pageCount.value,
        mode: SplitMode.byRanges,
        outputs: outputs,
        createdAt: DateTime.now(),
      );
      currentResult.value = result;

      for (final SplitOutputFile output in outputs) {
        final PdfHistoryEntry entry = PdfHistoryEntry(
          id: output.id,
          operation: PdfOperation.split,
          date: DateTime.now(),
          fileName: output.fileName,
          fileSize: output.fileSize,
          pageCount: output.pageCount,
          filePath: output.filePath,
        );
        await _pdfRepository.saveHistoryEntry(entry);

        final PdfFileItem recentFile = PdfFileItem(
          id: output.id,
          fileName: output.fileName,
          filePath: output.filePath,
          fileSize: output.fileSize,
          pageCount: output.pageCount,
          createdAt: DateTime.now(),
          source: 'created',
        );
        await _pdfRepository.saveRecentFile(recentFile);
      }

      state.value = SplitPdfState.success;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      state.value = SplitPdfState.error;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Shares a single output file.
  Future<void> shareOutput(SplitOutputFile output) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(output.filePath)]),
      );
    } catch (_) {
      Get.snackbar(
        'Share Failed',
        'Unable to share ${output.fileName}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Shares all output files.
  Future<void> shareAllOutputs() async {
    final SplitPdfResult? result = currentResult.value;
    if (result == null || result.outputs.isEmpty) {
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: result.outputs
              .map((SplitOutputFile f) => XFile(f.filePath))
              .toList(),
        ),
      );
    } catch (_) {
      Get.snackbar(
        'Share Failed',
        'Unable to share the output files.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Toggles favorite status for an output file.
  Future<void> toggleFavorite(SplitOutputFile output) async {
    final SplitPdfResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    final List<SplitOutputFile> updated =
        result.outputs.map((SplitOutputFile f) {
      if (f.id == output.id) {
        return SplitOutputFile(
          id: f.id,
          filePath: f.filePath,
          fileName: f.fileName,
          fileSize: f.fileSize,
          pageCount: f.pageCount,
          createdAt: f.createdAt,
          isFavorite: !f.isFavorite,
        );
      }
      return f;
    }).toList();

    currentResult.value = SplitPdfResult(
      sourceFileName: result.sourceFileName,
      sourcePageCount: result.sourcePageCount,
      mode: result.mode,
      outputs: updated,
      createdAt: result.createdAt,
    );

    // Update history entry.
    final List<PdfHistoryEntry> history =
        await _pdfRepository.getHistoryEntries();
    final int index = history.indexWhere(
      (PdfHistoryEntry e) => e.id == output.id,
    );
    if (index >= 0) {
      final PdfHistoryEntry target = history[index];
      final PdfHistoryEntry updatedEntry = target.copyWith(
        isFavorite: !target.isFavorite,
      );
      await _pdfRepository.updateHistoryEntry(updatedEntry);
    }
  }

  /// Deletes an output file.
  Future<void> deleteOutput(SplitOutputFile output) async {
    try {
      final File file = File(output.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      // Remove from history.
      final List<PdfHistoryEntry> history =
          await _pdfRepository.getHistoryEntries();
      final int index = history.indexWhere(
        (PdfHistoryEntry e) => e.id == output.id,
      );
      if (index >= 0) {
        await _pdfRepository.deleteHistoryEntry(history[index].id);
      }

      // Update current result.
      final SplitPdfResult? result = currentResult.value;
      if (result != null) {
        result.outputs.removeWhere((SplitOutputFile f) => f.id == output.id);
        currentResult.value = result;
      }

      Get.snackbar(
        'Deleted',
        '${output.fileName} deleted.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Delete Failed',
        'Unable to delete ${output.fileName}.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Cancels the current operation.
  void cancelOperation() {
    _cancelled = true;
  }

  /// Resets the flow.
  void reset() {
    state.value = SplitPdfState.idle;
    selectedFilePath.value = '';
    selectedFileName.value = '';
    selectedFileSize.value = 0;
    pageCount.value = 0;
    selectedPages.clear();
    splitMode.value = SplitMode.extractSelected;
    currentResult.value = null;
    errorMessage.value = '';
    baseFileName.value = _service.defaultBaseFileName();
  }
}
