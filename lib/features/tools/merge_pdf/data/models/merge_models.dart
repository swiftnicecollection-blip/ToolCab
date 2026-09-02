/// State for the PDF merge flow.
enum MergePdfState {
  idle,
  selecting,
  ready,
  processing,
  success,
  error,
  cancelled,
}

/// Model representing a single PDF file selected for merging.
class MergePdfItem {
  const MergePdfItem({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    this.pageCount = 0,
    this.createdAt,
  });

  final String id;
  final String filePath;
  final String fileName;
  final int fileSize;
  final int pageCount;
  final DateTime? createdAt;

  /// Formatted file size.
  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Result of a successful merge operation.
class MergePdfResult {
  const MergePdfResult({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.pageCount,
    required this.sourceDocumentCount,
    this.createdAt,
  });

  final String filePath;
  final String fileName;
  final int fileSize;
  final int pageCount;
  final int sourceDocumentCount;
  final DateTime? createdAt;

  /// Formatted file size.
  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    }
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
