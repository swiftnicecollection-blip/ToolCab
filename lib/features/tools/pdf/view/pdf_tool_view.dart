import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/coming_soon_view.dart';

/// Type of PDF tool.
enum PdfToolType {
  /// Convert text to PDF.
  textToPdf,

  /// Extract text from PDF.
  pdfToText,

  /// Merge multiple PDFs.
  merge,

  /// Split a PDF.
  split,

  /// Compress a PDF.
  compress,
}

/// PDF tool view.
class PdfToolView extends StatelessWidget {
  const PdfToolView({super.key, required this.tool});

  /// The PDF tool type.
  final PdfToolType tool;

  @override
  Widget build(BuildContext context) {
    final (String title, IconData icon, String description) = switch (tool) {
      PdfToolType.textToPdf => (
          'Text to PDF',
          Icons.text_fields,
          'Convert plain text documents into professional PDF files.',
        ),
      PdfToolType.pdfToText => (
          'PDF to Text',
          Icons.notes,
          'Extract and copy text content from PDF documents.',
        ),
      PdfToolType.merge => (
          'Merge PDF',
          Icons.merge,
          'Combine multiple PDF files into a single document.',
        ),
      PdfToolType.split => (
          'Split PDF',
          Icons.call_split,
          'Divide a PDF into separate pages or sections.',
        ),
      PdfToolType.compress => (
          'Compress PDF',
          Icons.compress,
          'Reduce PDF file size while maintaining quality.',
        ),
    };

    return ComingSoonView(
      title: title,
      icon: icon,
      color: AppColors.categoryPdf,
      description: description,
    );
  }
}
