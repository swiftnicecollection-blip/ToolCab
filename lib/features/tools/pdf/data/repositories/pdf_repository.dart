import 'dart:convert';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/services/storage_service.dart';
import '../models/pdf_models.dart';

/// Repository for PDF files and history.
///
/// Handles recent files and history persistence using Hive.
class PdfRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for recent PDF files.
  static const String _recentKey = 'pdf_recent_files';

  /// Storage key for PDF history.
  static const String _historyKey = 'pdf_history';

  /// Saves a recent PDF file.
  Future<void> saveRecentFile(PdfFileItem file) async {
    final List<Map<String, dynamic>> files = await _readRecentFiles();
    files.removeWhere((Map<String, dynamic> e) => e['id'] == file.id);
    files.insert(0, file.toJson());
    if (files.length > AppConstants.maxRecentFiles) {
      files.removeRange(AppConstants.maxRecentFiles, files.length);
    }
    await _writeRecentFiles(files);
  }

  /// Returns recent PDF files (newest first).
  Future<List<PdfFileItem>> getRecentFiles() async {
    final List<Map<String, dynamic>> files = await _readRecentFiles();
    return files.map(PdfFileItem.fromJson).toList(growable: false);
  }

  /// Deletes a recent file.
  Future<void> deleteRecentFile(String id) async {
    final List<Map<String, dynamic>> files = await _readRecentFiles();
    files.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeRecentFiles(files);
  }

  /// Saves a PDF history entry.
  Future<void> saveHistoryEntry(PdfHistoryEntry entry) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    entries.insert(0, entry.toJson());
    if (entries.length > AppConstants.maxHistoryItems) {
      entries.removeRange(AppConstants.maxHistoryItems, entries.length);
    }
    await _writeHistoryEntries(entries);
  }

  /// Returns PDF history entries (newest first).
  Future<List<PdfHistoryEntry>> getHistoryEntries() async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    return entries.map(PdfHistoryEntry.fromJson).toList(growable: false);
  }

  /// Updates a history entry.
  Future<void> updateHistoryEntry(PdfHistoryEntry entry) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    final int index = entries.indexWhere(
      (Map<String, dynamic> e) => e['id'] == entry.id,
    );
    if (index >= 0) {
      entries[index] = entry.toJson();
      await _writeHistoryEntries(entries);
    }
  }

  /// Deletes a history entry.
  Future<void> deleteHistoryEntry(String id) async {
    final List<Map<String, dynamic>> entries = await _readHistoryEntries();
    entries.removeWhere((Map<String, dynamic> e) => e['id'] == id);
    await _writeHistoryEntries(entries);
  }

  /// Clears all PDF history.
  Future<void> clearHistory() async {
    await _storageService.history.delete(_historyKey);
  }

  /// Reads recent files from storage.
  Future<List<Map<String, dynamic>>> _readRecentFiles() async {
    final dynamic raw = _storageService.recentFiles.get(_recentKey);
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

  /// Writes recent files to storage.
  Future<void> _writeRecentFiles(List<Map<String, dynamic>> files) async {
    await _storageService.recentFiles.put(_recentKey, jsonEncode(files));
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
    await _storageService.history.put(_historyKey, jsonEncode(entries));
  }
}
