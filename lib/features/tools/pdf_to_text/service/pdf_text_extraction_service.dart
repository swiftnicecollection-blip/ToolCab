import 'dart:io';

import 'package:pdfx/pdfx.dart';

import '../data/models/extraction_models.dart';
import 'pdf_text_parser.dart';

/// Service for PDF text extraction.
///
/// Uses a lightweight PDF parser for native/selectable text extraction
/// and pdfx for page rendering (used for OCR fallback and previews).
class PdfTextExtractionService {
  /// PDF text parser for native text extraction.
  final PdfTextParser _parser = PdfTextParser();

  /// Opens a PDF document and analyzes it.
  Future<PdfAnalysisResult> analyzePdf(String filePath) async {
    final File file = File(filePath);
    if (!file.existsSync()) {
      return PdfAnalysisResult(
        fileName: filePath.split('/').last,
        filePath: filePath,
        fileSize: 0,
        pageCount: 0,
        contentType: PdfContentType.scanned,
        hasSelectableText: false,
        errorMessage: 'The selected file could not be found.',
      );
    }

    try {
      final int fileSize = await file.length();
      final PdfDocument document = await PdfDocument.openFile(filePath);
      final int pageCount = document.pagesCount;
      await document.close();

      // Extract text to detect whether selectable text exists.
      final Map<int, String> extracted = await _parser.extractText(filePath);
      final int textPages = extracted.length;

      final bool hasSelectableText = textPages > 0;
      final PdfContentType contentType;
      if (textPages == 0) {
        contentType = PdfContentType.scanned;
      } else if (textPages < pageCount) {
        contentType = PdfContentType.mixed;
      } else {
        contentType = PdfContentType.text;
      }

      return PdfAnalysisResult(
        fileName: filePath.split('/').last,
        filePath: filePath,
        fileSize: fileSize,
        pageCount: pageCount,
        contentType: contentType,
        hasSelectableText: hasSelectableText,
        createdAt: file.statSync().modified,
      );
    } catch (e) {
      final String message = e.toString().toLowerCase();
      if (message.contains('password') || message.contains('encrypted')) {
        return PdfAnalysisResult(
          fileName: filePath.split('/').last,
          filePath: filePath,
          fileSize: 0,
          pageCount: 0,
          contentType: PdfContentType.scanned,
          hasSelectableText: false,
          isPasswordProtected: true,
          errorMessage: 'This PDF is password protected.',
        );
      }
      return PdfAnalysisResult(
        fileName: filePath.split('/').last,
        filePath: filePath,
        fileSize: 0,
        pageCount: 0,
        contentType: PdfContentType.scanned,
        hasSelectableText: false,
        errorMessage:
            'Unable to read this PDF. It may be corrupted or unsupported.',
      );
    }
  }

  /// Extracts selectable text from the specified pages.
  ///
  /// Returns a map of page number (1-based) to extracted text.
  Future<Map<int, String>> extractTextFromPages(
    String filePath,
    List<int> pages,
  ) async {
    final Map<int, String> allText = await _parser.extractText(filePath);
    final Map<int, String> result = <int, String>{};
    for (final int page in pages) {
      if (allText.containsKey(page)) {
        result[page] = allText[page]!;
      }
    }
    return result;
  }

  /// Renders a page to an image file for OCR processing.
  ///
  /// Returns the path to the rendered image, or null on failure.
  Future<String?> renderPageToImage(
    String filePath,
    int pageNumber, {
    String? outputDirectory,
  }) async {
    try {
      final PdfDocument document = await PdfDocument.openFile(filePath);
      try {
        if (pageNumber < 1 || pageNumber > document.pagesCount) {
          return null;
        }
        final PdfPage page = await document.getPage(pageNumber);
        final PdfPageImage? pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage == null) {
          return null;
        }

        final Directory dir = outputDirectory != null
            ? Directory(outputDirectory)
            : await Directory.systemTemp.createTemp('toolcab_pdf_ocr');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final String imagePath = '${dir.path}/page_$pageNumber.png';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(pageImage.bytes);
        return imagePath;
      } finally {
        await document.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Renders a page thumbnail for preview.
  Future<String?> renderPageThumbnail(
    String filePath,
    int pageNumber, {
    String? outputDirectory,
  }) async {
    try {
      final PdfDocument document = await PdfDocument.openFile(filePath);
      try {
        if (pageNumber < 1 || pageNumber > document.pagesCount) {
          return null;
        }
        final PdfPage page = await document.getPage(pageNumber);
        final PdfPageImage? pageImage = await page.render(
          width: 200,
          height: 280,
          format: PdfPageImageFormat.png,
        );
        await page.close();

        if (pageImage == null) {
          return null;
        }

        final Directory dir = outputDirectory != null
            ? Directory(outputDirectory)
            : await Directory.systemTemp.createTemp('toolcab_pdf_thumb');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        final String imagePath = '${dir.path}/thumb_$pageNumber.png';
        final File imageFile = File(imagePath);
        await imageFile.writeAsBytes(pageImage.bytes);
        return imagePath;
      } finally {
        await document.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Cleans up temporary files in a directory.
  Future<void> cleanupTempDirectory(String directoryPath) async {
    try {
      final Directory dir = Directory(directoryPath);
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}
