import 'dart:convert';

import '../../../../../core/services/storage_service.dart';
import '../models/document_model.dart';

/// Repository for document draft autosave.
class DraftRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for the current draft.
  static const String _draftKey = 'text_to_pdf_draft';

  /// Saves a document draft.
  Future<void> saveDraft(DocumentModel document) async {
    await _storageService.cache.put(_draftKey, jsonEncode(document.toJson()));
  }

  /// Loads the saved draft if one exists.
  DocumentModel? loadDraft() {
    final dynamic raw = _storageService.cache.get(_draftKey);
    if (raw == null) {
      return null;
    }
    try {
      final Map<String, dynamic> json =
          jsonDecode(raw as String) as Map<String, dynamic>;
      return DocumentModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clears the saved draft.
  Future<void> clearDraft() async {
    await _storageService.cache.delete(_draftKey);
  }
}
