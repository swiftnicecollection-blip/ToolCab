import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

import '../data/models/split_models.dart';

/// Service for splitting PDF documents.
///
/// Uses pdfx to render source pages and the pdf package to
/// rebuild selected pages into one or more output PDFs.
/// Processes locally on-device.
class SplitPdfService {
  /// Analyzes a PDF file and returns metadata.
  Future<({String fileName, String filePath, int fileSize, int pageCount})>
      analyzePdf(String filePath) async {
    final File file = File(filePath);
    final int fileSize = await file.length();
    final String fileName = filePath.split(Platform.pathSeparator).last;
    final pdfx.PdfDocument doc = await pdfx.PdfDocument.openFile(filePath);
    final int pageCount = doc.pagesCount;
    await doc.close();
    return (
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      pageCount: pageCount,
    );
  }

  /// Validates that a PDF can be opened.
  Future<String?> validatePdf(String filePath) async {
    try {
      final pdfx.PdfDocument doc = await pdfx.PdfDocument.openFile(filePath);
      await doc.close();
      return null;
    } catch (e) {
      final String msg = e.toString().toLowerCase();
      if (msg.contains('password') || msg.contains('encrypted')) {
        return 'This PDF is password protected.';
      }
      return 'Unable to read this PDF.';
    }
  }

  /// Renders a single page to a high-quality PNG image.
  Future<pdfx.PdfPageImage?> renderPage(
    String filePath,
    int pageNumber,
  ) async {
    final pdfx.PdfDocument doc = await pdfx.PdfDocument.openFile(filePath);
    try {
      if (pageNumber < 1 || pageNumber > doc.pagesCount) {
        return null;
      }
      final pdfx.PdfPage page = await doc.getPage(pageNumber);
      final pdfx.PdfPageImage? image = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();
      return image;
    } finally {
      await doc.close();
    }
  }

  /// Renders a page thumbnail.
  Future<pdfx.PdfPageImage?> renderThumbnail(
    String filePath,
    int pageNumber,
  ) async {
    final pdfx.PdfDocument doc = await pdfx.PdfDocument.openFile(filePath);
    try {
      if (pageNumber < 1 || pageNumber > doc.pagesCount) {
        return null;
      }
      final pdfx.PdfPage page = await doc.getPage(pageNumber);
      final pdfx.PdfPageImage? image = await page.render(
        width: 120,
        height: 160,
        format: pdfx.PdfPageImageFormat.png,
      );
      await page.close();
      return image;
    } finally {
      await doc.close();
    }
  }

  /// Splits a PDF by extracting the given page numbers into one output PDF.
  Future<SplitOutputFile> extractPages({
    required String filePath,
    required String sourceFileName,
    required List<int> pageNumbers,
    required String outputName,
    String? outputDirectory,
  }) async {
    final Directory dir = outputDirectory != null
        ? Directory(outputDirectory)
        : await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final String safeName = _sanitizeFileName(outputName);
    final File outputFile = File('${dir.path}/$safeName');
    final pw.Document doc = pw.Document(
      title: safeName.replaceAll(RegExp(r'\.pdf$'), ''),
      author: 'ToolCab',
    );

    await _buildDocument(
      doc: doc,
      filePath: filePath,
      pageNumbers: pageNumbers,
    );

    await outputFile.writeAsBytes(await doc.save());
    final int fileSize = await outputFile.length();

    return SplitOutputFile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      filePath: outputFile.path,
      fileName: safeName,
      fileSize: fileSize,
      pageCount: pageNumbers.length,
      createdAt: DateTime.now(),
    );
  }

  /// Splits a PDF into multiple output PDFs by page ranges.
  Future<List<SplitOutputFile>> splitByRanges({
    required String filePath,
    required String baseFileName,
    required List<List<int>> ranges,
    String? outputDirectory,
  }) async {
    final Directory dir = outputDirectory != null
        ? Directory(outputDirectory)
        : await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final List<SplitOutputFile> outputs = <SplitOutputFile>[];
    final String base = baseFileName.replaceAll(RegExp(r'\.pdf$'), '');

    for (int i = 0; i < ranges.length; i++) {
      final List<int> pageNumbers = ranges[i];
      final String safeName = _sanitizeFileName('${base}_Part_${i + 1}.pdf');
      final File outputFile = File('${dir.path}/$safeName');
      final pw.Document doc = pw.Document(
        title: safeName.replaceAll(RegExp(r'\.pdf$'), ''),
        author: 'ToolCab',
      );

      await _buildDocument(
        doc: doc,
        filePath: filePath,
        pageNumbers: pageNumbers,
      );

      await outputFile.writeAsBytes(await doc.save());
      final int fileSize = await outputFile.length();

      outputs.add(
        SplitOutputFile(
          id: '${DateTime.now().microsecondsSinceEpoch}_$i',
          filePath: outputFile.path,
          fileName: safeName,
          fileSize: fileSize,
          pageCount: pageNumbers.length,
          createdAt: DateTime.now(),
        ),
      );
    }

    return outputs;
  }

  /// Splits every page of the PDF into individual output PDFs.
  Future<List<SplitOutputFile>> splitEveryPage({
    required String filePath,
    required String baseFileName,
    required int pageCount,
    String? outputDirectory,
  }) async {
    final Directory dir = outputDirectory != null
        ? Directory(outputDirectory)
        : await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final List<SplitOutputFile> outputs = <SplitOutputFile>[];
    final String base = baseFileName.replaceAll(RegExp(r'\.pdf$'), '');

    for (int i = 1; i <= pageCount; i++) {
      final String safeName = _sanitizeFileName('${base}_Page_$i.pdf');
      final File outputFile = File('${dir.path}/$safeName');
      final pw.Document doc = pw.Document(
        title: safeName.replaceAll(RegExp(r'\.pdf$'), ''),
        author: 'ToolCab',
      );

      await _buildDocument(
        doc: doc,
        filePath: filePath,
        pageNumbers: <int>[i],
      );

      await outputFile.writeAsBytes(await doc.save());
      final int fileSize = await outputFile.length();

      outputs.add(
        SplitOutputFile(
          id: '${DateTime.now().microsecondsSinceEpoch}_$i',
          filePath: outputFile.path,
          fileName: safeName,
          fileSize: fileSize,
          pageCount: 1,
          createdAt: DateTime.now(),
        ),
      );
    }

    return outputs;
  }

  /// Builds a PDF document from the given page numbers.
  Future<void> _buildDocument({
    required pw.Document doc,
    required String filePath,
    required List<int> pageNumbers,
  }) async {
    final pdfx.PdfDocument source = await pdfx.PdfDocument.openFile(filePath);
    try {
      for (final int pageNum in pageNumbers) {
        if (pageNum < 1 || pageNum > source.pagesCount) {
          continue;
        }
        final pdfx.PdfPage page = await source.getPage(pageNum);
        final pdfx.PdfPageImage? image = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: pdfx.PdfPageImageFormat.png,
        );
        await page.close();
        if (image == null) {
          continue;
        }
        final double w = page.width * 72 / 72;
        final double h = page.height * 72 / 72;
        final PdfPageFormat format = page.width > page.height
            ? PdfPageFormat(w, h).landscape
            : PdfPageFormat(w, h);
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (_) => pw.Image(
              pw.MemoryImage(image.bytes),
              fit: pw.BoxFit.fill,
            ),
          ),
        );
      }
    } finally {
      await source.close();
    }
  }

  /// Validates an output file name.
  String? validateBaseFileName(String name) {
    if (name.trim().isEmpty) {
      return 'Filename cannot be empty.';
    }
    if (name.contains(RegExp(r'[\\/:*?"<>|]'))) {
      return 'Filename contains invalid characters.';
    }
    if (name.trim() != name) {
      return 'Filename cannot have leading/trailing spaces.';
    }
    return null;
  }

  /// Generates a default base filename.
  String defaultBaseFileName() {
    final String date = DateTime.now().toIso8601String().substring(0, 10);
    return 'ToolCab_Split_$date';
  }

  /// Parses and validates a comma-separated page range string.
  /// Supports: 1-5, 2,4,7, 1-3,8-10
  List<int>? parsePageRange(String input, {required int pageCount}) {
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
          return null;
        }
        final int? start = int.tryParse(range[0].trim());
        final int? end = int.tryParse(range[1].trim());
        if (start == null || end == null || start < 1 || end < 1) {
          return null;
        }
        if (start > end) {
          return null;
        }
        if (end > pageCount) {
          return null;
        }
        for (int i = start; i <= end; i++) {
          pages.add(i);
        }
      } else {
        final int? page = int.tryParse(trimmed);
        if (page == null || page < 1 || page > pageCount) {
          return null;
        }
        pages.add(page);
      }
    }

    if (pages.isEmpty) {
      return null;
    }

    final List<int> sorted = pages.toList()..sort();
    return sorted;
  }

  /// Parses multiple comma-separated ranges into a list of page lists.
  List<List<int>>? parseRanges(
    String input, {
    required int pageCount,
  }) {
    final List<List<int>> result = <List<int>>[];
    final List<String> groups = input.split(';');
    for (final String group in groups) {
      final String trimmed = group.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final List<int>? pages = parsePageRange(trimmed, pageCount: pageCount);
      if (pages == null) {
        return null;
      }
      result.add(pages);
    }
    if (result.isEmpty) {
      return null;
    }
    return result;
  }

  /// Sanitizes a file name for safe saving.
  String _sanitizeFileName(String name) {
    final String safe = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    if (safe.isEmpty) {
      return 'ToolCab_Split.pdf';
    }
    if (!safe.toLowerCase().endsWith('.pdf')) {
      return '$safe.pdf';
    }
    return safe;
  }
}
