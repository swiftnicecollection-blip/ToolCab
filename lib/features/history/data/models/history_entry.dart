import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';

/// Enum representing different tool types for history tracking.
enum HistoryToolType {
  /// Text-to-Audio (TTS)
  tts,

  /// Speech-to-Text (STT)
  stt,

  /// Language translation
  translator,

  /// OCR text extraction
  ocr,

  /// Text to PDF generation
  textToPdf,

  /// PDF to text extraction
  pdfToText,

  /// PDF merge operation
  mergePdf,

  /// PDF split operation
  splitPdf,

  /// PDF compression
  compressPdf,

  /// QR code scan
  qrScan,
}

/// Extension to get display names for tool types.
extension HistoryToolTypeExtension on HistoryToolType {
  /// Returns the display name for the tool type.
  String get displayName {
    switch (this) {
      case HistoryToolType.tts:
        return 'Text → Audio';
      case HistoryToolType.stt:
        return 'Audio → Text';
      case HistoryToolType.translator:
        return 'Translation';
      case HistoryToolType.ocr:
        return 'OCR Scan';
      case HistoryToolType.textToPdf:
        return 'Text → PDF';
      case HistoryToolType.pdfToText:
        return 'PDF → Text';
      case HistoryToolType.mergePdf:
        return 'Merge PDF';
      case HistoryToolType.splitPdf:
        return 'Split PDF';
      case HistoryToolType.compressPdf:
        return 'Compress PDF';
      case HistoryToolType.qrScan:
        return 'QR Scan';
    }
  }

  /// Returns the icon data for the tool type.
  String get iconName {
    switch (this) {
      case HistoryToolType.tts:
        return 'record_voice_over';
      case HistoryToolType.stt:
        return 'mic';
      case HistoryToolType.translator:
        return 'translate';
      case HistoryToolType.ocr:
        return 'document_scanner';
      case HistoryToolType.textToPdf:
      case HistoryToolType.pdfToText:
      case HistoryToolType.mergePdf:
      case HistoryToolType.splitPdf:
      case HistoryToolType.compressPdf:
        return 'picture_as_pdf';
      case HistoryToolType.qrScan:
        return 'qr_code_scanner';
    }
  }
}

/// Model representing a history entry.
class HistoryEntry {
  HistoryEntry({
    required this.id,
    required this.toolType,
    required this.title,
    required this.timestamp,
    this.description = '',
    this.filePath,
    this.fileName,
    this.metadata = const <String, dynamic>{},
    this.isFavorite = false,
  });

  /// Creates an entry from a JSON map.
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      toolType: HistoryToolType.values.firstWhere(
        (HistoryToolType t) => t.name == json['toolType'],
        orElse: () => HistoryToolType.tts,
      ),
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
      filePath: json['filePath'] as String?,
      fileName: json['fileName'] as String?,
      metadata:
          (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{},
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }

  /// Unique entry ID.
  final String id;

  /// The tool that was used.
  final HistoryToolType toolType;

  /// Title/name of the operation.
  final String title;

  /// Description of the operation.
  final String description;

  /// When the operation was performed.
  final DateTime timestamp;

  /// Associated file path (if any).
  final String? filePath;

  /// Associated file name (if any).
  final String? fileName;

  /// Additional metadata.
  final Map<String, dynamic> metadata;

  /// Whether this entry is favorited.
  bool isFavorite;

  /// Creates a copy with updated fields.
  HistoryEntry copyWith({
    String? id,
    HistoryToolType? toolType,
    String? title,
    String? description,
    DateTime? timestamp,
    String? filePath,
    String? fileName,
    Map<String, dynamic>? metadata,
    bool? isFavorite,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      metadata: metadata ?? this.metadata,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Converts the entry to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'toolType': toolType.name,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'filePath': filePath,
      'fileName': fileName,
      'metadata': metadata,
      'isFavorite': isFavorite,
    };
  }
}

/// Repository for managing operation history using Hive local storage.
class HistoryRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for history entries.
  static const String _historyKey = 'toolcab_history';

  /// Saves a history entry.
  Future<void> saveEntry(HistoryEntry entry) async {
    final List<Map<String, dynamic>> entries = await _readEntries();
    entries.insert(0, entry.toJson());

    // Trim to maximum history items.
    if (entries.length > AppConstants.maxHistoryItems) {
      entries.removeRange(AppConstants.maxHistoryItems, entries.length);
    }

    await _writeEntries(entries);
  }

  /// Returns all history entries (newest first).
  Future<List<HistoryEntry>> getEntries() async {
    final List<Map<String, dynamic>> entries = await _readEntries();
    return entries.map(HistoryEntry.fromJson).toList();
  }

  /// Returns favorite entries.
  Future<List<HistoryEntry>> getFavorites() async {
    final List<HistoryEntry> entries = await getEntries();
    return entries.where((HistoryEntry e) => e.isFavorite).toList();
  }

  /// Updates a history entry (e.g., favorite status).
  Future<void> updateEntry(HistoryEntry entry) async {
    final List<Map<String, dynamic>> entries = await _readEntries();
    final int index = entries.indexWhere(
      (Map<String, dynamic> e) => e['id'] == entry.id,
    );
    if (index >= 0) {
      entries[index] = entry.toJson();
      await _writeEntries(entries);
    }
  }

  /// Deletes a history entry by ID.
  Future<void> deleteEntry(String id) async {
    final List<Map<String, dynamic>> entries = await _readEntries();
    entries.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeEntries(entries);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    await _storageService.history.delete(_historyKey);
  }

  /// Reads history entries from storage.
  Future<List<Map<String, dynamic>>> _readEntries() async {
    final dynamic raw = _storageService.history.get(_historyKey);
    if (raw == null) {
      return <Map<String, dynamic>>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw as String) as List<dynamic>;
      return decoded.map((dynamic e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Writes history entries to storage.
  Future<void> _writeEntries(List<Map<String, dynamic>> entries) async {
    await _storageService.history.put(_historyKey, jsonEncode(entries));
  }
}
