/// PDF operation types.
enum PdfOperation {
  /// Create PDF from text.
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

/// PDF processing status.
enum PdfStatus {
  /// Not started.
  idle,

  /// Selecting a file.
  selecting,

  /// Processing.
  processing,

  /// Completed successfully.
  success,

  /// Failed.
  failed,

  /// Cancelled.
  cancelled,
}

/// Model representing a PDF file.
class PdfFileItem {
  const PdfFileItem({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    this.fileSize,
    this.pageCount,
    this.thumbnailPath,
    this.isFavorite = false,
    this.source,
  });

  /// Creates a file item from a JSON map.
  factory PdfFileItem.fromJson(Map<String, dynamic> json) {
    return PdfFileItem(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int?,
      pageCount: json['page_count'] as int?,
      thumbnailPath: json['thumbnail_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFavorite: json['is_favorite'] as bool? ?? false,
      source: json['source'] as String?,
    );
  }

  /// Unique ID.
  final String id;

  /// File name.
  final String fileName;

  /// Path to the PDF file.
  final String filePath;

  /// File size in bytes.
  final int? fileSize;

  /// Page count if known.
  final int? pageCount;

  /// Path to a thumbnail image if available.
  final String? thumbnailPath;

  /// When the file was created/added.
  final DateTime createdAt;

  /// Whether this file is a favorite.
  final bool isFavorite;

  /// Source of the file (e.g., 'imported', 'created').
  final String? source;

  /// Creates a copy with updated favorite status.
  PdfFileItem copyWith({bool? isFavorite}) {
    return PdfFileItem(
      id: id,
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      pageCount: pageCount,
      thumbnailPath: thumbnailPath,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      source: source,
    );
  }

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'file_name': fileName,
        'file_path': filePath,
        'file_size': fileSize,
        'page_count': pageCount,
        'thumbnail_path': thumbnailPath,
        'created_at': createdAt.toIso8601String(),
        'is_favorite': isFavorite,
        'source': source,
      };
}

/// Model representing a PDF history entry.
class PdfHistoryEntry {
  const PdfHistoryEntry({
    required this.id,
    required this.operation,
    required this.date,
    this.fileName,
    this.fileSize,
    this.pageCount,
    this.filePath,
    this.status = PdfStatus.success,
    this.isFavorite = false,
  });

  /// Creates a history entry from a JSON map.
  factory PdfHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PdfHistoryEntry(
      id: json['id'] as String,
      operation: PdfOperation.values.firstWhere(
        (PdfOperation op) => op.name == json['operation'],
        orElse: () => PdfOperation.textToPdf,
      ),
      date: DateTime.parse(json['date'] as String),
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      pageCount: json['page_count'] as int?,
      filePath: json['file_path'] as String?,
      status: PdfStatus.values.firstWhere(
        (PdfStatus s) => s.name == json['status'],
        orElse: () => PdfStatus.success,
      ),
      isFavorite: json['is_favorite'] as bool? ?? false,
    );
  }

  /// Unique ID.
  final String id;

  /// The PDF operation performed.
  final PdfOperation operation;

  /// When the operation happened.
  final DateTime date;

  /// Output file name.
  final String? fileName;

  /// Output file size in bytes.
  final int? fileSize;

  /// Page count if known.
  final int? pageCount;

  /// Path to the output file.
  final String? filePath;

  /// Status of the operation.
  final PdfStatus status;

  /// Whether this entry is a favorite.
  final bool isFavorite;

  /// Returns the operation display name.
  String get operationName {
    switch (operation) {
      case PdfOperation.textToPdf:
        return 'Text → PDF';
      case PdfOperation.pdfToText:
        return 'PDF → Text';
      case PdfOperation.merge:
        return 'Merge PDFs';
      case PdfOperation.split:
        return 'Split PDF';
      case PdfOperation.compress:
        return 'Compress PDF';
    }
  }

  /// Creates a copy with updated favorite status.
  PdfHistoryEntry copyWith({
    bool? isFavorite,
    PdfStatus? status,
    String? filePath,
  }) {
    return PdfHistoryEntry(
      id: id,
      operation: operation,
      date: date,
      fileName: fileName,
      fileSize: fileSize,
      pageCount: pageCount,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Converts to a JSON-serializable map for Hive storage.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'operation': operation.name,
        'date': date.toIso8601String(),
        'file_name': fileName,
        'file_size': fileSize,
        'page_count': pageCount,
        'file_path': filePath,
        'status': status.name,
        'is_favorite': isFavorite,
      };
}
