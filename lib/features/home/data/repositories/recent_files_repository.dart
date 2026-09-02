import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/recent_file_item.dart';

/// Repository for recently accessed files using Hive local storage.
class RecentFilesRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for recent files.
  static const String _recentFilesKey = 'recent_files';

  /// Returns the list of recent files.
  Future<List<RecentFileItem>> getRecentFiles() async {
    final dynamic raw = _storageService.recentFiles.get(_recentFilesKey);
    if (raw == null) {
      return <RecentFileItem>[];
    }
    try {
      final List<dynamic> decoded = jsonDecode(raw as String) as List<dynamic>;
      return decoded
          .map(
              (dynamic e) => RecentFileItem.fromJson(e as Map<String, dynamic>),)
          .toList();
    } catch (_) {
      return <RecentFileItem>[];
    }
  }

  /// Adds a recent file.
  Future<void> addRecentFile(RecentFileItem file) async {
    final List<RecentFileItem> files = await getRecentFiles();
    // Remove existing entry with same path.
    files.removeWhere((RecentFileItem f) => f.filePath == file.filePath);
    // Insert at beginning.
    files.insert(0, file);
    // Trim to maximum.
    if (files.length > AppConstants.maxRecentFiles) {
      files.removeRange(AppConstants.maxRecentFiles, files.length);
    }
    await _writeFiles(files);
  }

  /// Removes a recent file by name.
  Future<void> removeRecentFile(String fileName) async {
    final List<RecentFileItem> files = await getRecentFiles();
    files.removeWhere((RecentFileItem f) => f.name == fileName);
    await _writeFiles(files);
  }

  /// Clears all recent files.
  Future<void> clearRecentFiles() async {
    await _storageService.recentFiles.delete(_recentFilesKey);
  }

  /// Writes files to storage.
  Future<void> _writeFiles(List<RecentFileItem> files) async {
    final List<Map<String, dynamic>> jsonList =
        files.map((RecentFileItem f) => f.toJson()).toList();
    await _storageService.recentFiles
        .put(_recentFilesKey, jsonEncode(jsonList));
  }
}
