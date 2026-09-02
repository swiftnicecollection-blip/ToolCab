/// State for the PDF compression flow.
enum CompressPdfState {
  idle,
  selecting,
  analyzing,
  ready,
  configuring,
  processing,
  success,
  notReduced,
  error,
  cancelled,
}

/// Compression levels.
enum CompressionLevel {
  low,
  medium,
  high,
}

/// Settings for a compression operation.
class CompressionSettings {
  const CompressionSettings({
    this.level = CompressionLevel.medium,
    this.includeImages = true,
  });

  final CompressionLevel level;
  final bool includeImages;

  /// Scale factor for page rendering based on compression level.
  double get scaleFactor {
    return switch (level) {
      CompressionLevel.low => 1.0,
      CompressionLevel.medium => 0.75,
      CompressionLevel.high => 0.5,
    };
  }

  /// JPEG quality for image re-encoding.
  int get jpegQuality {
    return switch (level) {
      CompressionLevel.low => 92,
      CompressionLevel.medium => 75,
      CompressionLevel.high => 55,
    };
  }

  /// Display name for the compression level.
  String get label {
    return switch (level) {
      CompressionLevel.low => 'High Quality',
      CompressionLevel.medium => 'Balanced',
      CompressionLevel.high => 'Maximum',
    };
  }

  /// Description for the compression level.
  String get description {
    return switch (level) {
      CompressionLevel.low =>
        'Small size reduction with maximum quality preservation.',
      CompressionLevel.medium =>
        'Good size reduction while maintaining quality. Recommended.',
      CompressionLevel.high =>
        'Significantly reduce file size with possible quality reduction.',
    };
  }

  /// Storage key suffix.
  String get key => level.name;
}

/// Result of a compression operation.
class CompressionResult {
  const CompressionResult({
    required this.originalFilePath,
    required this.originalFileName,
    required this.originalFileSize,
    required this.compressedFilePath,
    required this.compressedFileName,
    required this.compressedFileSize,
    required this.pageCount,
    required this.level,
    this.createdAt,
    this.isFavorite = false,
  });

  final String originalFilePath;
  final String originalFileName;
  final int originalFileSize;
  final String compressedFilePath;
  final String compressedFileName;
  final int compressedFileSize;
  final int pageCount;
  final CompressionLevel level;
  final DateTime? createdAt;
  final bool isFavorite;

  /// Actual bytes saved.
  int get bytesSaved => originalFileSize - compressedFileSize;

  /// Actual compression percentage (0-100).
  /// Returns 0 if the output is not smaller.
  double get compressionPercent {
    if (originalFileSize <= 0 || compressedFileSize >= originalFileSize) {
      return 0;
    }
    return ((originalFileSize - compressedFileSize) / originalFileSize * 100)
        .clamp(0, 100);
  }

  /// Whether the output is meaningfully smaller.
  bool get isReduced => compressedFileSize < originalFileSize;

  /// Formatted original size.
  String get formattedOriginalSize => _formatSize(originalFileSize);

  /// Formatted compressed size.
  String get formattedCompressedSize => _formatSize(compressedFileSize);

  /// Formatted bytes saved.
  String get formattedBytesSaved => _formatSize(bytesSaved);

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Copy with updated favorite state.
  CompressionResult copyWith({bool? isFavorite}) {
    return CompressionResult(
      originalFilePath: originalFilePath,
      originalFileName: originalFileName,
      originalFileSize: originalFileSize,
      compressedFilePath: compressedFilePath,
      compressedFileName: compressedFileName,
      compressedFileSize: compressedFileSize,
      pageCount: pageCount,
      level: level,
      createdAt: createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
