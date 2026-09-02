import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart' as pdfx;

import '../data/models/compress_models.dart';

/// Service for compressing PDF documents.
///
/// Uses pdfx to render source pages at reduced resolution and
/// the pdf package to rebuild the document with JPEG-compressed
/// images, achieving genuine file-size reduction.
/// Processes locally on-device.
class CompressPdfService {
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

  /// Compresses a PDF by rendering pages at reduced resolution
  /// and re-encoding them as JPEG images.
  ///
  /// Returns a [CompressionResult] with actual file sizes.
  Future<CompressionResult> compressPdf({
    required String filePath,
    required String outputName,
    required CompressionSettings settings,
    String? outputDirectory,
  }) async {
    final File source = File(filePath);
    if (!source.existsSync()) {
      throw Exception('The selected PDF could not be found.');
    }

    final int originalSize = await source.length();
    final String originalName = filePath.split(Platform.pathSeparator).last;

    final Directory dir = outputDirectory != null
        ? Directory(outputDirectory)
        : await getApplicationDocumentsDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final String safeName = _sanitizeFileName(outputName);
    final File outputFile = File('${dir.path}/$safeName');

    final pdfx.PdfDocument sourceDoc =
        await pdfx.PdfDocument.openFile(filePath);
    final int pageCount = sourceDoc.pagesCount;

    final pw.Document compressed = pw.Document(
      title: safeName.replaceAll(RegExp(r'\.pdf$'), ''),
      author: 'ToolCab',
    );

    try {
      for (int i = 1; i <= pageCount; i++) {
        final pdfx.PdfPage page = await sourceDoc.getPage(i);
        final pdfx.PdfPageImage? image = await page.render(
          width: page.width * settings.scaleFactor,
          height: page.height * settings.scaleFactor,
          format: pdfx.PdfPageImageFormat.jpeg,
          quality: settings.jpegQuality,
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
        compressed.addPage(
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
      await sourceDoc.close();
    }

    await outputFile.writeAsBytes(await compressed.save());
    final int compressedSize = await outputFile.length();

    return CompressionResult(
      originalFilePath: filePath,
      originalFileName: originalName,
      originalFileSize: originalSize,
      compressedFilePath: outputFile.path,
      compressedFileName: safeName,
      compressedFileSize: compressedSize,
      pageCount: pageCount,
      level: settings.level,
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
    return 'ToolCab_Compressed_$date.pdf';
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
