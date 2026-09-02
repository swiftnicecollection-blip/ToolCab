import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

import '../data/models/merge_models.dart';

/// Service for merging PDF documents.
///
/// Uses pdfx to render source pages, then the pdf package to
/// rebuild them into a single merged document. Processes locally.
class MergePdfService {
  /// Analyzes a PDF file and returns its metadata.
  Future<MergePdfItem> analyzePdf(String filePath) async {
    final File file = File(filePath);
    final int fileSize = await file.length();
    int pageCount = 0;
    final String fileName = filePath.split(Platform.pathSeparator).last;
    try {
      final pdfx.PdfDocument doc = await pdfx.PdfDocument.openFile(filePath);
      pageCount = doc.pagesCount;
      await doc.close();
    } catch (_) {}
    return MergePdfItem(
      id: '${DateTime.now().microsecondsSinceEpoch}_$filePath',
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      pageCount: pageCount,
      createdAt: file.statSync().modified,
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

  /// Merges the given PDF files into one output PDF.
  /// Renders each page to a high-quality image and rebuilds them,
  /// preserving page dimensions and orientation.
  Future<MergePdfResult> mergePdfs({
    required List<MergePdfItem> items,
    required String outputName,
    String? outputDirectory,
  }) async {
    if (items.length < 2) {
      throw Exception('Select at least 2 PDF files to merge.');
    }

    final Directory dir = outputDirectory != null
        ? Directory(outputDirectory)
        : await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final String safeName = _sanitizeFileName(outputName);
    final File outputFile = File('${dir.path}/$safeName');
    final pw.Document merged = pw.Document(
      title: safeName.replaceAll(RegExp(r'\.pdf$'), ''),
      author: 'ToolCab',
    );

    int totalPages = 0;

    for (final MergePdfItem item in items) {
      final pdfx.PdfDocument source =
          await pdfx.PdfDocument.openFile(item.filePath);
      try {
        for (int i = 1; i <= source.pagesCount; i++) {
          final pdfx.PdfPage page = await source.getPage(i);
          final pdfx.PdfPageImage? image = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: pdfx.PdfPageImageFormat.png,
          );
          await page.close();
          if (image == null) {
            continue;
          }
          final double w = page.width;
          final double h = page.height;
          final PdfPageFormat format = page.width > page.height
              ? PdfPageFormat(w, h).landscape
              : PdfPageFormat(w, h);
          final pdfx.PdfPageImage pageImage = image;
          merged.addPage(
            pw.Page(
              pageFormat: format,
              build: (_) => pw.Image(
                pw.MemoryImage(pageImage.bytes),
                fit: pw.BoxFit.fill,
              ),
            ),
          );
          totalPages++;
        }
      } finally {
        await source.close();
      }
    }

    await outputFile.writeAsBytes(await merged.save());

    final int fileSize = await outputFile.length();
    return MergePdfResult(
      filePath: outputFile.path,
      fileName: safeName,
      fileSize: fileSize,
      pageCount: totalPages,
      sourceDocumentCount: items.length,
      createdAt: DateTime.now(),
    );
  }

  /// Validates an output file name.
  String? validateFileName(String name) {
    if (name.trim().isEmpty) {
      return 'Filename cannot be empty.';
    }
    if (!name.toLowerCase().endsWith('.pdf')) {
      return 'Filename must end with .pdf';
    }
    final String base = name.replaceAll(RegExp(r'\.pdf$'), '');
    if (base.isEmpty) {
      return 'Filename cannot be empty.';
    }
    if (base.contains(RegExp(r'[\\/:*?"<>|]'))) {
      return 'Filename contains invalid characters.';
    }
    if (base.trim() != base) {
      return 'Filename cannot have leading/trailing spaces.';
    }
    return null;
  }

  /// Generates a default output filename.
  String defaultFileName() {
    final String date = DateTime.now().toIso8601String().substring(0, 10);
    return 'ToolCab_Merged_$date.pdf';
  }

  /// Sanitizes a file name for safe saving.
  String _sanitizeFileName(String name) {
    final String safe = name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    if (safe.isEmpty) {
      return defaultFileName();
    }
    if (!safe.toLowerCase().endsWith('.pdf')) {
      return '$safe.pdf';
    }
    return safe;
  }
}
