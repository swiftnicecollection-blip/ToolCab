import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/navigation_service.dart';
import '../data/models/document_model.dart';
import '../data/models/pdf_models.dart';
import '../data/repositories/draft_repository.dart';
import '../data/repositories/pdf_repository.dart';
import '../service/text_to_pdf_service.dart';

/// Controller for the Text → PDF module.
class TextToPdfController extends GetxController {
  /// PDF generation service.
  final TextToPdfService _service = Get.find<TextToPdfService>();

  /// PDF repository.
  final PdfRepository _repository = Get.find<PdfRepository>();

  /// Draft repository.
  final DraftRepository _draftRepository = Get.find<DraftRepository>();

  /// Navigation service.
  final NavigationService _navigationService = Get.find<NavigationService>();

  /// Text editing controller.
  final TextEditingController textController = TextEditingController();

  /// Document title.
  final RxString documentTitle = RxString('Untitled Document');

  /// Current document settings.
  final Rx<PdfPageSize> pageSize = Rx<PdfPageSize>(PdfPageSize.a4);
  final Rx<PdfOrientation> orientation =
      Rx<PdfOrientation>(PdfOrientation.portrait);
  final Rx<PdfMargin> margin = Rx<PdfMargin>(PdfMargin.normal);
  final Rx<PdfLineSpacing> lineSpacing =
      Rx<PdfLineSpacing>(PdfLineSpacing.normal);
  final Rx<double> fontSize = Rx<double>(12);
  final Rx<PdfTextAlign> textAlign = Rx<PdfTextAlign>(PdfTextAlign.left);
  final Rx<PdfPageNumberPosition> pageNumbers =
      Rx<PdfPageNumberPosition>(PdfPageNumberPosition.off);

  /// Whether PDF generation is in progress.
  final RxBool isGenerating = RxBool(false);

  /// Whether a draft exists.
  final RxBool hasDraft = RxBool(false);

  /// Generated PDF file.
  final Rx<File?> generatedFile = Rx<File?>(null);

  /// Autosave timer.
  Timer? _autosaveTimer;

  /// Whether the document has content.
  bool get hasContent => textController.text.trim().isNotEmpty;

  /// Word count.
  int get wordCount {
    final String text = textController.text.trim();
    if (text.isEmpty) {
      return 0;
    }
    return text.split(RegExp(r'\s+')).length;
  }

  /// Character count.
  int get charCount => textController.text.length;

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
    super.onClose();
  }

  /// Initializes the controller.
  Future<void> _initialize() async {
    hasDraft.value = _draftRepository.loadDraft() != null;
  }

  /// Called when text changes - schedules autosave.
  void _onTextChanged() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), _saveDraft);
  }

  /// Saves the current document as a draft.
  Future<void> _saveDraft() async {
    if (!hasContent) {
      return;
    }
    final DocumentModel doc = _buildDocument();
    await _draftRepository.saveDraft(doc);
  }

  /// Builds a document model from current state.
  DocumentModel _buildDocument() {
    return DocumentModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: documentTitle.value,
      content: textController.text,
      pageSize: pageSize.value,
      orientation: orientation.value,
      margin: margin.value,
      lineSpacing: lineSpacing.value,
      fontSize: fontSize.value,
      textAlign: textAlign.value,
      pageNumbers: pageNumbers.value,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Loads a saved draft.
  void loadDraft() {
    final DocumentModel? draft = _draftRepository.loadDraft();
    if (draft != null) {
      documentTitle.value = draft.title;
      textController.text = draft.content;
      pageSize.value = draft.pageSize;
      orientation.value = draft.orientation;
      margin.value = draft.margin;
      lineSpacing.value = draft.lineSpacing;
      fontSize.value = draft.fontSize;
      textAlign.value = draft.textAlign;
      pageNumbers.value = draft.pageNumbers;
      hasDraft.value = false;
    }
  }

  /// Discards the saved draft.
  Future<void> discardDraft() async {
    await _draftRepository.clearDraft();
    hasDraft.value = false;
  }

  /// Updates the document title.
  void setTitle(String title) {
    documentTitle.value = title.trim().isEmpty ? 'Untitled Document' : title;
  }

  /// Generates the PDF.
  Future<void> generatePdf() async {
    if (!hasContent) {
      Get.snackbar(
        'Empty Document',
        'Your document is empty. Please add some text first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    isGenerating.value = true;
    try {
      final File file = await _service.generatePdf(_buildDocument());
      generatedFile.value = file;

      // Save to history.
      final PdfHistoryEntry entry = PdfHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        operation: PdfOperation.textToPdf,
        date: DateTime.now(),
        fileName: file.path.split('/').last,
        fileSize: await file.length(),
        filePath: file.path,
      );
      await _repository.saveHistoryEntry(entry);

      // Save as recent file.
      final PdfFileItem recentFile = PdfFileItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: file.path.split('/').last,
        filePath: file.path,
        fileSize: await file.length(),
        createdAt: DateTime.now(),
        source: 'created',
      );
      await _repository.saveRecentFile(recentFile);

      // Clear draft after successful generation.
      await _draftRepository.clearDraft();
      hasDraft.value = false;

      Get.snackbar(
        'PDF Created',
        'Your PDF has been generated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      Get.snackbar(
        'Generation Failed',
        'Unable to create this PDF. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isGenerating.value = false;
    }
  }

  /// Shares the generated PDF.
  Future<void> sharePdf() async {
    final File? file = generatedFile.value;
    if (file == null) {
      return;
    }
    await _service.sharePdf(file);
  }

  /// Sends document text to Text → Audio.
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
}
