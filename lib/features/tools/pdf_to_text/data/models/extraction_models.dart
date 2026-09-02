/// Extraction method used for PDF → Text.
enum PdfExtractionMethod { automatic, selectableText, ocr }

/// PDF content type detected during analysis.
enum PdfContentType { text, scanned, mixed }

/// State for the PDF → Text flow.
enum PdfToTextFlowState {
  idle,
  analyzing,
  analyzed,
  selectingPages,
  extracting,
  success,
  failed,
  cancelled,
}

/// Model representing a PDF analysis result.
class PdfAnalysisResult {
  const PdfAnalysisResult({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.pageCount,
    required this.contentType,
    required this.hasSelectableText,
    this.createdAt,
    this.isPasswordProtected = false,
    this.errorMessage,
  });

  final String fileName;
  final String filePath;
  final int fileSize;
  final int pageCount;
  final PdfContentType contentType;
  final bool hasSelectableText;
  final DateTime? createdAt;
  final bool isPasswordProtected;
  final String? errorMessage;

  bool get isSuccessful => errorMessage == null;
}

/// Model representing a page in the PDF.
class PdfPageInfo {
  const PdfPageInfo({
    required this.pageNumber,
    this.hasText = false,
    this.thumbnailPath,
  });

  final int pageNumber;
  final bool hasText;
  final String? thumbnailPath;

  PdfPageInfo copyWith({bool? hasText, String? thumbnailPath}) {
    return PdfPageInfo(
      pageNumber: pageNumber,
      hasText: hasText ?? this.hasText,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}

/// Page selection mode.
enum PdfPageSelectionMode { all, specific }

/// Model representing a page selection.
class PdfPageSelection {
  const PdfPageSelection({
    this.selectedPages = const <int>{},
    this.mode = PdfPageSelectionMode.all,
  });

  factory PdfPageSelection.fromSerialized(
    String serialized, {
    int pageCount = 0,
  }) {
    if (serialized == 'all') {
      return const PdfPageSelection(mode: PdfPageSelectionMode.all);
    }
    final Set<int> pages = serialized
        .split(',')
        .where((String s) => s.trim().isNotEmpty)
        .map(int.tryParse)
        .whereType<int>()
        .where((int p) => p >= 1 && p <= pageCount)
        .toSet();
    return PdfPageSelection(
      selectedPages: pages,
      mode: PdfPageSelectionMode.specific,
    );
  }

  final Set<int> selectedPages;
  final PdfPageSelectionMode mode;

  PdfPageSelection copyWith({
    Set<int>? selectedPages,
    PdfPageSelectionMode? mode,
  }) {
    return PdfPageSelection(
      selectedPages: selectedPages ?? this.selectedPages,
      mode: mode ?? this.mode,
    );
  }

  bool isSelected(int page) {
    if (mode == PdfPageSelectionMode.all) {
      return true;
    }
    return selectedPages.contains(page);
  }

  String get serialized {
    if (mode == PdfPageSelectionMode.all) {
      return 'all';
    }
    final List<int> sorted = selectedPages.toList()..sort();
    return sorted.join(',');
  }
}

/// Model representing the result of text extraction.
class PdfExtractionResult {
  const PdfExtractionResult({
    required this.fileName,
    required this.filePath,
    required this.pageCount,
    required this.method,
    required this.pages,
    required this.text,
    this.fileSize,
    this.languageCode,
    this.id,
    this.createdAt,
    this.isFavorite = false,
  });

  factory PdfExtractionResult.fromJson(Map<String, dynamic> json) {
    return PdfExtractionResult(
      id: json['id'] as String?,
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
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  final String? id;
  final String fileName;
  final String filePath;
  final int? fileSize;
  final int pageCount;
  final PdfExtractionMethod method;
  final String pages;
  final String text;
  final String? languageCode;
  final DateTime? createdAt;
  final bool isFavorite;

  int get wordCount {
    if (text.trim().isEmpty) {
      return 0;
    }
    return text.trim().split(RegExp(r'\s+')).length;
  }

  int get charCount => text.length;

  String get textPreview {
    if (text.length <= 100) {
      return text;
    }
    return '${text.substring(0, 97)}...';
  }

  String get title => fileName.replaceAll(RegExp(r'\.pdf$'), '');

  PdfExtractionResult copyWith({bool? isFavorite}) {
    return PdfExtractionResult(
      id: id,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      pageCount: pageCount,
      method: method,
      pages: pages,
      text: text,
      languageCode: languageCode,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'page_count': pageCount,
        'method': method.name,
        'pages': pages,
        'text': text,
        'language_code': languageCode,
        'created_at': createdAt?.toIso8601String(),
        'is_favorite': isFavorite,
      };
}
