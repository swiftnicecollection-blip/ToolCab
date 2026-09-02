import 'dart:convert';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/ocr_history_entry.dart';

/// Repository for OCR results.
///
/// Handles history and favorites persistence using Hive local storage.
class OcrRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for OCR history.
  static const String _historyKey = 'ocr_history';

  /// Saves an OCR history entry.
  Future<void> saveHistoryEntry(OcrHistoryEntry entry) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    entries.insert(0, entry.toJson());

    // Trim to maximum history items.
    if (entries.length > AppConstants.maxHistoryItems) {
      entries.removeRange(
        AppConstants.maxHistoryItems,
        entries.length,
      );
    }

    await _writeHistoryEntries(entries);
  }

  /// Returns a list of OCR history entries (newest first).
  Future<List<OcrHistoryEntry>> getHistoryEntries() async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    return entries.map(OcrHistoryEntry.fromJson).toList(growable: false);
  }

  /// Updates a history entry (e.g., favorite status).
  Future<void> updateHistoryEntry(OcrHistoryEntry entry) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    final int index = entries.indexWhere(
      (Map<String, dynamic> e) => e['id'] == entry.id,
    );
    if (index >= 0) {
      entries[index] = entry.toJson();
      await _writeHistoryEntries(entries);
    }
  }

  /// Deletes a history entry by ID.
  Future<void> deleteHistoryEntry(String id) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    entries.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeHistoryEntries(entries);
  }

  /// Clears all OCR history.
  Future<void> clearHistory() async {
    await _storageService.history.delete(_historyKey);
  }

  /// Reads history entries from storage.
  Future<List<Map<String, dynamic>>> _readHistoryEntries() async {
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
  Future<void> _writeHistoryEntries(
    List<Map<String, dynamic>> entries,
  ) async {
    await _storageService.history.put(
      _historyKey,
      jsonEncode(entries),
    );
  }
}
