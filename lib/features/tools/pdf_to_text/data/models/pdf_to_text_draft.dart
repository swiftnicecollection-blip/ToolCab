import 'extraction_models.dart';

/// Draft model for PDF → Text autosave.
class PdfToTextDraft {
  const PdfToTextDraft({
    required this.fileName,
    required this.filePath,
    required this.pageCount,
    required this.method,
    required this.pages,
    required this.text,
    this.fileSize,
    this.languageCode,
    this.createdAt,
  });

  factory PdfToTextDraft.fromJson(Map<String, dynamic> json) {
    return PdfToTextDraft(
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int?,
      pageCount: json['page_count'] as int? ?? 0,
      method: PdfExtractionMethod.values.firstWhere(
        (PdfExtractionMethod m) => m.name == json['method'],
        orElse: () => PdfExtractionMethod.selectableText,
      ),
      pages: json['pages'] as String? ?? 'all',
      text: json['text'] as String? ?? '',
      languageCode: json['language_code'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final String fileName;
  final String filePath;
  final int? fileSize;
  final int pageCount;
  final PdfExtractionMethod method;
  final String pages;
  final String text;
  final String? languageCode;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'page_count': pageCount,
        'method': method.name,
        'pages': pages,
        'text': text,
        'language_code': languageCode,
        'created_at': createdAt?.toIso8601String(),
      };
}
