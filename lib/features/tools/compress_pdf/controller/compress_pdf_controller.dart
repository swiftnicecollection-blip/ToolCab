import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../pdf/data/models/pdf_models.dart';
import '../../pdf/data/repositories/pdf_repository.dart';
import '../data/models/compress_models.dart';
import '../service/compress_pdf_service.dart';

/// Controller for the Compress PDF module.
///
/// Manages single-PDF selection, compression settings,
/// compression execution, result comparison, history,
/// favorites, and result management.
class CompressPdfController extends GetxController {
  /// Compression service.
  final CompressPdfService _service = Get.find<CompressPdfService>();

  /// PDF repository for history and recent files.
  final PdfRepository _pdfRepository = Get.find<PdfRepository>();

  /// Current flow state.
  final Rx<CompressPdfState> state =
      Rx<CompressPdfState>(CompressPdfState.idle);

  /// Selected PDF file path.
  final RxString selectedFilePath = RxString('');

  /// Selected PDF file name.
  final RxString selectedFileName = RxString('');

  /// Selected PDF file size.
  final RxInt selectedFileSize = RxInt(0);

  /// Selected PDF page count.
  final RxInt pageCount = RxInt(0);

  /// Compression settings.
  final Rx<CompressionSettings> settings =
      Rx<CompressionSettings>(const CompressionSettings());

  /// Output file name.
  final RxString outputFileName = RxString('');

  /// Whether processing is in progress.
  final RxBool isProcessing = RxBool(false);

  /// Error message.
  final RxString errorMessage = RxString('');

  /// Current compression result.
  final Rx<CompressionResult?> currentResult = Rx<CompressionResult?>(null);

  /// Whether compression was cancelled.
  bool _cancelled = false;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// Initializes the controller.
  Future<void> _initialize() async {
    outputFileName.value = _service.defaultFileName();
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
      state.value = CompressPdfState.analyzing;

      // Validate the file.
      final String? error = await _service.validatePdf(path);
      if (error != null) {
        errorMessage.value = error;
        state.value = CompressPdfState.error;
        return;
      }

      // Analyze the file.
      final info = await _service.analyzePdf(path);
      selectedFilePath.value = path;
      selectedFileName.value = info.fileName;
      selectedFileSize.value = info.fileSize;
      pageCount.value = info.pageCount;
      settings.value = const CompressionSettings();
      outputFileName.value = _service.defaultFileName();

      state.value = CompressPdfState.ready;
    } catch (_) {
      errorMessage.value = 'Unable to select or analyze the PDF.';
      state.value = CompressPdfState.error;
    }
  }

  /// Sets the compression level.
  void setCompressionLevel(CompressionLevel level) {
    settings.value = CompressionSettings(
      level: level,
      includeImages: settings.value.includeImages,
    );
  }

  /// Sets the output file name.
  // ignore: use_setters_to_change_properties
  void setOutputFileName(String name) {
    outputFileName.value = name;
  }

  /// Starts the compression operation.
  Future<void> startCompression() async {
    if (selectedFilePath.value.isEmpty || pageCount.value == 0) {
      errorMessage.value = 'Please select a PDF first.';
      state.value = CompressPdfState.error;
      return;
    }

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

    state.value = CompressPdfState.processing;
    isProcessing.value = true;
    _cancelled = false;
    errorMessage.value = '';

    try {
      final CompressionResult result = await _service.compressPdf(
        filePath: selectedFilePath.value,
        outputName: outputFileName.value,
        settings: settings.value,
      );
      currentResult.value = result;

      if (_cancelled) {
        state.value = CompressPdfState.cancelled;
        return;
      }

      // Save to history and recent files.
      final PdfHistoryEntry entry = PdfHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        operation: PdfOperation.compress,
        date: DateTime.now(),
        fileName: result.compressedFileName,
        fileSize: result.compressedFileSize,
        pageCount: result.pageCount,
        filePath: result.compressedFilePath,
      );
      await _pdfRepository.saveHistoryEntry(entry);

      final PdfFileItem recentFile = PdfFileItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: result.compressedFileName,
        filePath: result.compressedFilePath,
        fileSize: result.compressedFileSize,
        pageCount: result.pageCount,
        createdAt: DateTime.now(),
        source: 'created',
      );
      await _pdfRepository.saveRecentFile(recentFile);

      // Determine result state honestly.
      if (result.isReduced) {
        state.value = CompressPdfState.success;
      } else {
        state.value = CompressPdfState.notReduced;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      state.value = CompressPdfState.error;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Shares the compressed PDF.
  Future<void> shareCompressedPdf() async {
    final CompressionResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(result.compressedFilePath)]),
      );
    } catch (_) {
      Get.snackbar(
        'Share Failed',
        'Unable to share the compressed PDF.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Opens the compressed PDF.
  Future<void> openCompressedPdf() async {
    final CompressionResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    try {
      await SharePlus.instance.share(
        ShareParams(files: <XFile>[XFile(result.compressedFilePath)]),
      );
    } catch (_) {
      Get.snackbar(
        'Open Failed',
        'Unable to open the compressed PDF.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Toggles favorite status for the compressed result.
  Future<void> toggleFavorite() async {
    final CompressionResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    final CompressionResult updated = result.copyWith(
      isFavorite: !result.isFavorite,
    );
    currentResult.value = updated;

    // Update history entry.
    final List<PdfHistoryEntry> history =
        await _pdfRepository.getHistoryEntries();
    final int index = history.indexWhere(
      (PdfHistoryEntry e) => e.filePath == result.compressedFilePath,
    );
    if (index >= 0) {
      final PdfHistoryEntry updatedEntry = history[index].copyWith(
        isFavorite: updated.isFavorite,
      );
      await _pdfRepository.updateHistoryEntry(updatedEntry);
    }
  }

  /// Deletes the compressed output file.
  Future<void> deleteOutput() async {
    final CompressionResult? result = currentResult.value;
    if (result == null) {
      return;
    }
    try {
      final File file = File(result.compressedFilePath);
      if (file.existsSync()) {
        await file.delete();
      }
      // Remove from history.
      final List<PdfHistoryEntry> history =
          await _pdfRepository.getHistoryEntries();
      final int index = history.indexWhere(
        (PdfHistoryEntry e) => e.filePath == result.compressedFilePath,
      );
      if (index >= 0) {
        await _pdfRepository.deleteHistoryEntry(history[index].id);
      }
      currentResult.value = null;
      state.value = CompressPdfState.ready;
      Get.snackbar(
        'Deleted',
        'Compressed PDF deleted.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Delete Failed',
        'Unable to delete the compressed PDF.',
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
    state.value = CompressPdfState.idle;
    selectedFilePath.value = '';
    selectedFileName.value = '';
    selectedFileSize.value = 0;
    pageCount.value = 0;
    settings.value = const CompressionSettings();
    currentResult.value = null;
    errorMessage.value = '';
    outputFileName.value = _service.defaultFileName();
  }
}
