import 'dart:convert';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/extraction_models.dart';

/// Repository for PDF → Text extraction history and favorites.
///
/// Handles history persistence using Hive local storage.
class PdfToTextRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for PDF → Text history.
  static const String _historyKey = 'pdf_to_text_history';

  /// Saves an extraction result to history.
  Future<void> saveResult(PdfExtractionResult result) async {
    final List<Map<String, dynamic>> entries = await _readHistory();
    entries.insert(0, result.toJson());

    // Trim to maximum history items.
    if (entries.length > AppConstants.maxHistoryItems) {
      entries.removeRange(AppConstants.maxHistoryItems, entries.length);
    }

    await _writeHistory(entries);
  }

  /// Returns extraction history (newest first).
  Future<List<PdfExtractionResult>> getHistory() async {
    final List<Map<String, dynamic>> entries = await _readHistory();
    return entries.map(PdfExtractionResult.fromJson).toList(growable: false);
  }

  /// Updates a history entry (e.g., favorite status).
  Future<void> updateResult(PdfExtractionResult result) async {
    final List<Map<String, dynamic>> entries = await _readHistory();
    final int index = entries.indexWhere(
      (Map<String, dynamic> e) => e['id'] == result.id,
    );
    if (index >= 0) {
      entries[index] = result.toJson();
      await _writeHistory(entries);
    }
  }

  /// Deletes a history entry by ID.
  Future<void> deleteResult(String id) async {
    final List<Map<String, dynamic>> entries = await _readHistory();
    entries.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeHistory(entries);
  }

  /// Clears all PDF → Text history.
  Future<void> clearHistory() async {
    await _storageService.history.delete(_historyKey);
  }

  /// Reads history entries from storage.
  Future<List<Map<String, dynamic>>> _readHistory() async {
    final dynamic raw = _storageService.history.get(_historyKey);
    if (raw == null) {
      return <Map<String, dynamic>>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw as String) as List<dynamic>;
      return decoded
          .map((dynamic e) => e as Map<String, dynamic>)
          .toList(growable: false);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Writes history entries to storage.
  Future<void> _writeHistory(List<Map<String, dynamic>> entries) async {
    await _storageService.history.put(_historyKey, jsonEncode(entries));
  }
}
