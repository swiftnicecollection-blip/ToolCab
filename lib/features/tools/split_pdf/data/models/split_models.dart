/// State for the PDF split flow.
enum SplitPdfState {
  idle,
  selecting,
  analyzing,
  ready,
  selectingPages,
  configuring,
  validating,
  processing,
  success,
  error,
  cancelled,
}

/// Split modes.
enum SplitMode {
  extractSelected,
  byRanges,
  everyPage,
}

/// Model representing a generated split output file.
class SplitOutputFile {
  const SplitOutputFile({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.pageCount,
    this.createdAt,
    this.isFavorite = false,
  });

  final String id;
  final String filePath;
  final String fileName;
  final int fileSize;
  final int pageCount;
  final DateTime? createdAt;
  final bool isFavorite;

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

/// Result of a successful split operation.
class SplitPdfResult {
  const SplitPdfResult({
    required this.sourceFileName,
    required this.sourcePageCount,
    required this.mode,
    required this.outputs,
    this.createdAt,
  });

  final String sourceFileName;
  final int sourcePageCount;
  final SplitMode mode;
  final List<SplitOutputFile> outputs;
  final DateTime? createdAt;

  /// Total pages across all outputs.
  int get totalPages =>
      outputs.fold<int>(0, (int sum, SplitOutputFile f) => sum + f.pageCount);

  /// Total size across all outputs.
  int get totalSize =>
      outputs.fold<int>(0, (int sum, SplitOutputFile f) => sum + f.fileSize);

  /// Formatted total size.
  String get formattedTotalSize {
    if (totalSize < 1024) {
      return '$totalSize B';
    }
    if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
