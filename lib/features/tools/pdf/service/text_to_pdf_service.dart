import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../data/models/document_model.dart';

/// Service for generating PDF documents from text.
///
/// Creates real PDF files with selectable text.
class TextToPdfService {
  /// Generates a PDF from a [DocumentModel] and saves it.
  Future<File> generatePdf(DocumentModel document) async {
    final pw.Document pdf = pw.Document(
      title: document.title,
      author: 'ToolCab',
    );

    // Page format based on settings.
    final PdfPageFormat format = _getPageFormat(document);

    // Margin values.
    final double margin = _getMargin(document.margin);

    // Line spacing.
    final double lineSpacing = _getLineSpacing(document.lineSpacing);

    // Text alignment.
    final pw.Alignment alignment = _getAlignment(document.textAlign);

    // Font size.
    final double fontSize = document.fontSize;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: pw.EdgeInsets.all(margin),
        footer: document.pageNumbers == PdfPageNumberPosition.off
            ? null
            : (pw.Context context) {
                final int pageNumber = context.pageNumber;
                final int totalPages = context.pagesCount;
                final String text = '$pageNumber / $totalPages';
                final pw.Alignment footerAlign = switch (document.pageNumbers) {
                  PdfPageNumberPosition.bottomCenter => pw.Alignment.center,
                  PdfPageNumberPosition.bottomRight => pw.Alignment.centerRight,
                  PdfPageNumberPosition.bottomLeft => pw.Alignment.centerLeft,
                  _ => pw.Alignment.center,
                };
                return pw.Container(
                  alignment: footerAlign,
                  child: pw.Text(
                    text,
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                );
              },
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              document.title,
              style: pw.TextStyle(
                fontSize: fontSize + 6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          for (final String paragraph in _splitParagraphs(document.content))
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Align(
                alignment: alignment,
                child: pw.Text(
                  paragraph,
                  style: pw.TextStyle(
                    fontSize: fontSize,
                    lineSpacing: lineSpacing,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Save to documents directory.
    final Directory dir = await getApplicationDocumentsDirectory();
    final String safeTitle = _sanitizeFileName(document.title);
    final String fileName = '$safeTitle.pdf';
    final File file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Shares a generated PDF file.
  Future<void> sharePdf(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: <XFile>[XFile(file.path)]),
    );
  }

  /// Returns the page format for the document.
  PdfPageFormat _getPageFormat(DocumentModel document) {
    final PdfPageFormat base = switch (document.pageSize) {
      PdfPageSize.a4 => PdfPageFormat.a4,
      PdfPageSize.letter => PdfPageFormat.letter,
      PdfPageSize.legal => PdfPageFormat.legal,
      PdfPageSize.a5 => PdfPageFormat.a5,
    };
    return document.orientation == PdfOrientation.landscape
        ? base.landscape
        : base;
  }

  /// Returns the margin value in points.
  double _getMargin(PdfMargin margin) {
    return switch (margin) {
      PdfMargin.small => 24,
      PdfMargin.normal => 48,
      PdfMargin.large => 72,
    };
  }

  /// Returns the line spacing factor.
  double _getLineSpacing(PdfLineSpacing spacing) {
    return switch (spacing) {
      PdfLineSpacing.compact => 1.0,
      PdfLineSpacing.normal => 1.5,
      PdfLineSpacing.relaxed => 2.0,
    };
  }

  /// Returns the text alignment for the PDF.
  pw.Alignment _getAlignment(PdfTextAlign align) {
    return switch (align) {
      PdfTextAlign.left => pw.Alignment.centerLeft,
      PdfTextAlign.center => pw.Alignment.center,
      PdfTextAlign.right => pw.Alignment.centerRight,
      PdfTextAlign.justify => pw.Alignment.centerLeft,
    };
  }

  /// Splits content into paragraphs.
  List<String> _splitParagraphs(String content) {
    return content
        .split(RegExp(r'\n\s*\n'))
        .map((String p) => p.trim())
        .where((String p) => p.isNotEmpty)
        .toList(growable: false);
  }

  /// Sanitizes a file name for safe saving.
  String _sanitizeFileName(String title) {
    final String sanitized = title
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    if (sanitized.isEmpty) {
      return 'ToolCab_Document_${DateTime.now().toIso8601String().substring(0, 10)}';
    }
    return sanitized;
  }
}
