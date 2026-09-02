import 'dart:convert';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/stt_history_entry.dart';

/// Repository for speech-to-text.
///
/// Handles history persistence using Hive local storage.
class SttRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for STT history.
  static const String _historyKey = 'stt_history';

  /// Saves an STT history entry.
  Future<void> saveHistoryEntry(SttHistoryEntry entry) async {
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

  /// Returns a list of STT history entries (newest first).
  Future<List<SttHistoryEntry>> getHistoryEntries() async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    return entries.map(SttHistoryEntry.fromJson).toList(growable: false);
  }

  /// Deletes a history entry by ID.
  Future<void> deleteHistoryEntry(String id) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    entries.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeHistoryEntries(entries);
  }

  /// Clears all STT history.
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
