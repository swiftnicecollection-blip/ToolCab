/// Document page size options.
enum PdfPageSize {
  a4,
  letter,
  legal,
  a5,
}

/// Document orientation options.
enum PdfOrientation {
  portrait,
  landscape,
}

/// Document margin options.
enum PdfMargin {
  small,
  normal,
  large,
}

/// Document line spacing options.
enum PdfLineSpacing {
  compact,
  normal,
  relaxed,
}

/// Page number position options.
enum PdfPageNumberPosition {
  off,
  bottomCenter,
  bottomRight,
  bottomLeft,
}

/// Text alignment options.
enum PdfTextAlign {
  left,
  center,
  right,
  justify,
}

/// Document model for Text → PDF.
class DocumentModel {
  const DocumentModel({
    this.id,
    this.title = 'Untitled Document',
    this.content = '',
    this.pageSize = PdfPageSize.a4,
    this.orientation = PdfOrientation.portrait,
    this.margin = PdfMargin.normal,
    this.lineSpacing = PdfLineSpacing.normal,
    this.fontSize = 12.0,
    this.textAlign = PdfTextAlign.left,
    this.pageNumbers = PdfPageNumberPosition.off,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a document from a JSON map.
  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? 'Untitled Document',
      content: json['content'] as String? ?? '',
      pageSize: PdfPageSize.values.firstWhere(
        (PdfPageSize s) => s.name == json['page_size'],
        orElse: () => PdfPageSize.a4,
      ),
      orientation: PdfOrientation.values.firstWhere(
        (PdfOrientation o) => o.name == json['orientation'],
        orElse: () => PdfOrientation.portrait,
      ),
      margin: PdfMargin.values.firstWhere(
        (PdfMargin m) => m.name == json['margin'],
        orElse: () => PdfMargin.normal,
      ),
      lineSpacing: PdfLineSpacing.values.firstWhere(
        (PdfLineSpacing l) => l.name == json['line_spacing'],
        orElse: () => PdfLineSpacing.normal,
      ),
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 12.0,
      textAlign: PdfTextAlign.values.firstWhere(
        (PdfTextAlign a) => a.name == json['text_align'],
        orElse: () => PdfTextAlign.left,
      ),
      pageNumbers: PdfPageNumberPosition.values.firstWhere(
        (PdfPageNumberPosition p) => p.name == json['page_numbers'],
        orElse: () => PdfPageNumberPosition.off,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String? id;
  final String title;
  final String content;
  final PdfPageSize pageSize;
  final PdfOrientation orientation;
  final PdfMargin margin;
  final PdfLineSpacing lineSpacing;
  final double fontSize;
  final PdfTextAlign textAlign;
  final PdfPageNumberPosition pageNumbers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Whether the document has content.
  bool get isEmpty => content.trim().isEmpty;

  /// Word count of the document.
  int get wordCount {
    if (content.trim().isEmpty) {
      return 0;
    }
    return content.trim().split(RegExp(r'\s+')).length;
  }

  /// Character count of the document.
  int get charCount => content.length;

  /// Creates a copy with updated fields.
  DocumentModel copyWith({
    String? title,
    String? content,
    PdfPageSize? pageSize,
    PdfOrientation? orientation,
    PdfMargin? margin,
    PdfLineSpacing? lineSpacing,
    double? fontSize,
    PdfTextAlign? textAlign,
    PdfPageNumberPosition? pageNumbers,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      pageSize: pageSize ?? this.pageSize,
      orientation: orientation ?? this.orientation,
      margin: margin ?? this.margin,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
      pageNumbers: pageNumbers ?? this.pageNumbers,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'content': content,
        'page_size': pageSize.name,
        'orientation': orientation.name,
        'margin': margin.name,
        'line_spacing': lineSpacing.name,
        'font_size': fontSize,
        'text_align': textAlign.name,
        'page_numbers': pageNumbers.name,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
