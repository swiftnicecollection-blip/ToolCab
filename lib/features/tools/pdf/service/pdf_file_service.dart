import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../data/models/pdf_models.dart';

/// Service for PDF file selection, validation, and metadata.
class PdfFileService {
  /// Picks a single PDF file.
  Future<PdfFileItem?> pickPdf() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    final PlatformFile file = result.files.first;
    final String path = file.path!;
    final File f = File(path);
    final int size = await f.length();
    return PdfFileItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fileName: file.name,
      filePath: path,
      fileSize: size,
      createdAt: DateTime.now(),
      source: 'imported',
    );
  }

  /// Picks multiple PDF files.
  Future<List<PdfFileItem>> pickMultiplePdfs() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['pdf'],
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) {
      return <PdfFileItem>[];
    }
    final List<PdfFileItem> items = <PdfFileItem>[];
    for (final PlatformFile file in result.files) {
      final String path = file.path!;
      final File f = File(path);
      final int size = await f.length();
      items.add(
        PdfFileItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          fileName: file.name,
          filePath: path,
          fileSize: size,
          createdAt: DateTime.now(),
          source: 'imported',
        ),
      );
    }
    return items;
  }

  /// Validates that a file is a PDF.
  bool isValidPdf(String path) {
    final File file = File(path);
    if (!file.existsSync()) {
      return false;
    }
    final String ext = path.toLowerCase();
    return ext.endsWith('.pdf');
  }
}
