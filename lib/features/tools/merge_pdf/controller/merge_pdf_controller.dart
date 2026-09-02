import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../pdf/data/models/pdf_models.dart';
import '../../pdf/data/repositories/pdf_repository.dart';
import '../data/models/merge_models.dart';
import '../service/merge_pdf_service.dart';

/// Controller for the Merge PDF module.
///
/// Manages multi-file selection, reordering, validation,
/// merging, output management, history, and favorites.
class MergePdfController extends GetxController {
  /// Merge service.
  final MergePdfService _service = Get.find<MergePdfService>();

  /// PDF repository for history and recent files.
  final PdfRepository _pdfRepository = Get.find<PdfRepository>();

  /// Current flow state.
  final Rx<MergePdfState> state = Rx<MergePdfState>(MergePdfState.idle);

  /// Selected PDF files.
  final RxList<MergePdfItem> selectedFiles = RxList<MergePdfItem>([]);

  /// Output file name.
  final RxString outputFileName = RxString('');

  /// Whether processing is in progress.
  final RxBool isProcessing = RxBool(false);

  /// Error message.
  final RxString errorMessage = RxString('');

  /// Current merge result.
  final Rx<MergePdfResult?> currentResult = Rx<MergePdfResult?>(null);

  /// Whether the result is a favorite.
  final RxBool isFavorite = RxBool(false);

  /// Total pages across all selected files.
  int get totalPages => selectedFiles.fold<int>(
      0, (int sum, MergePdfItem f) => sum + f.pageCount,);

  /// Total size across all selected files.
  int get totalSize =>
      selectedFiles.fold<int>(0, (int sum, MergePdfItem f) => sum + f.fileSize);

  /// Formatted total size.
  String get formattedTotalSize {
    if (totalSize < 1024) {
      return '$totalSize B';
    }
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initializes the controller.
  Future<void> _initialize() async {
    outputFileName.value = _service.defaultFileName();
  }

  /// Selects multiple PDF files.
  Future<void> selectPdfs() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf'],
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) {
        return; // Cancelled.
      }

      state.value = MergePdfState.selecting;
      for (final PlatformFile file in result.files) {
        final String path = file.path!;
        // Validate the file.
        final String? error = await _service.validatePdf(path);
        if (error != null) {
          Get.snackbar(
            'Invalid PDF',
            '$error ${file.name}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          continue;
        }
        // Analyze the file.
        final MergePdfItem item = await _service.analyzePdf(path);
        selectedFiles.add(item);
      }

      state.value =
          selectedFiles.length >= 2 ? MergePdfState.ready : MergePdfState.idle;
    } catch (_) {
      errorMessage.value = 'Unable to select PDF files.';
      state.value = MergePdfState.error;
    }
  }

  /// Adds more PDF files to the existing selection.
  Future<void> addMorePdfs() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['pdf'],
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      for (final PlatformFile file in result.files) {
        final String path = file.path!;
        final String? error = await _service.validatePdf(path);
        if (error != null) {
          Get.snackbar(
            'Invalid PDF',
            '$error ${file.name}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          continue;
        }
        final MergePdfItem item = await _service.analyzePdf(path);
        selectedFiles.add(item);
      }

      state.value = MergePdfState.ready;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Unable to add more PDFs.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Removes a PDF from the selection.
  void removePdf(String id) {
    selectedFiles.removeWhere((MergePdfItem f) => f.id == id);
    if (selectedFiles.length < 2) {
      state.value = MergePdfState.idle;
    }
  }

  /// Reorders the selected files.
  void reorderPdfs(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final MergePdfItem item = selectedFiles.removeAt(oldIndex);
    selectedFiles.insert(newIndex, item);
  }

  /// Moves a PDF up in the order.
  void moveUp(int index) {
    if (index <= 0) {
      return;
    }
    final MergePdfItem item = selectedFiles.removeAt(index);
    selectedFiles.insert(index - 1, item);
  }

  /// Moves a PDF down in the order.
  void moveDown(int index) {
    if (index >= selectedFiles.length - 1) {
      return;
    }
    final MergePdfItem item = selectedFiles.removeAt(index);
    selectedFiles.insert(index + 1, item);
  }

  /// Sets the output file name.
  // ignore: use_setters_to_change_properties
  void setOutputFileName(String name) {
    outputFileName.value = name;
  }

  /// Starts the merge process.
  Future<void> startMerge() async {
    if (selectedFiles.length < 2) {
      Get.snackbar(
        'Not Enough Files',
        'Select at least 2 PDF files to merge.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate output filename.
    final String? nameError = _service.validateFileName(outputFileName.value);
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

    state.value = MergePdfState.processing;
    isProcessing.value = true;
    errorMessage.value = '';

    try {
      final MergePdfResult result = await _service.mergePdfs(
        items: selectedFiles.toList(),
        outputName: outputFileName.value,
      );
      currentResult.value = result;
      isFavorite.value = false;

      // Save to PDF history.
      final PdfHistoryEntry entry = PdfHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        operation: PdfOperation.merge,
        date: DateTime.now(),
        fileName: result.fileName,
        fileSize: result.fileSize,
        pageCount: result.pageCount,
        filePath: result.filePath,
      );
      await _pdfRepository.saveHistoryEntry(entry);

      // Save as recent file.
      final PdfFileItem recentFile = PdfFileItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: result.fileName,
        filePath: result.filePath,
        fileSize: result.fileSize,
        pageCount: result.pageCount,
        createdAt: DateTime.now(),
        source: 'created',
      );
      await _pdfRepository.saveRecentFile(recentFile);

      state.value = MergePdfState.success;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      state.value = MergePdfState.error;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Shares the merged PDF.
  Future<void> shareMergedPdf() async {
    final MergePdfResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(result.filePath)]),
      );
    } catch (_) {
      Get.snackbar(
        'Share Failed',
        'Unable to share the merged PDF.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Opens the merged PDF.
  Future<void> openMergedPdf() async {
    final MergePdfResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(result.filePath)]),
      );
    } catch (_) {
      Get.snackbar(
        'Open Failed',
        'Unable to open the merged PDF.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Toggles favorite status for the merged result.
  Future<void> toggleFavorite() async {
    final MergePdfResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    isFavorite.value = !isFavorite.value;

    // Update the history entry.
    final List<PdfHistoryEntry> history =
        await _pdfRepository.getHistoryEntries();
    final int index = history.indexWhere(
      (PdfHistoryEntry e) => e.filePath == result.filePath,
    );
    if (index >= 0) {
      final PdfHistoryEntry updated = history[index].copyWith(
        isFavorite: isFavorite.value,
      );
      await _pdfRepository.updateHistoryEntry(updated);
    }
  }

  /// Deletes the merged output file.
  Future<void> deleteOutput() async {
    final MergePdfResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    try {
      final File file = File(result.filePath);
      if (file.existsSync()) {
        await file.delete();
      }
      // Remove from history.
      final List<PdfHistoryEntry> history =
          await _pdfRepository.getHistoryEntries();
      final int index = history.indexWhere(
        (PdfHistoryEntry e) => e.filePath == result.filePath,
      );
      if (index >= 0) {
        await _pdfRepository.deleteHistoryEntry(history[index].id);
      }
      currentResult.value = null;
      state.value = MergePdfState.idle;
      Get.snackbar(
        'Deleted',
        'Merged PDF deleted.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Delete Failed',
        'Unable to delete the merged PDF.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Resets the flow.
  void reset() {
    state.value = MergePdfState.idle;
    selectedFiles.clear();
    currentResult.value = null;
    errorMessage.value = '';
    isFavorite.value = false;
    outputFileName.value = _service.defaultFileName();
  }
}
