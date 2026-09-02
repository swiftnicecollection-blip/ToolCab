import 'dart:convert';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/tts_history_entry.dart';

/// Repository for text-to-speech.
///
/// Handles history persistence using Hive local storage.
class TtsRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for TTS history.
  static const String _historyKey = 'tts_history';

  /// Saves a TTS history entry.
  Future<void> saveHistoryEntry(TtsHistoryEntry entry) async {
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

  /// Returns a list of TTS history entries (newest first).
  Future<List<TtsHistoryEntry>> getHistoryEntries() async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    return entries.map(TtsHistoryEntry.fromJson).toList(growable: false);
  }

  /// Deletes a history entry by ID.
  Future<void> deleteHistoryEntry(String id) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    entries.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeHistoryEntries(entries);
  }

  /// Clears all TTS history.
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
