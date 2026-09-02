import 'dart:convert';

import '../../../../../core/services/storage_service.dart';
import '../models/pdf_to_text_draft.dart';

/// Repository for PDF → Text draft autosave.
class PdfToTextDraftRepository {
  /// Storage service for Hive access.
  final StorageService _storageService = StorageService.instance;

  /// Storage key for the current draft.
  static const String _draftKey = 'pdf_to_text_draft';

  /// Saves a PDF → Text draft.
  Future<void> saveDraft(PdfToTextDraft draft) async {
    await _storageService.cache.put(_draftKey, jsonEncode(draft.toJson()));
  }

  /// Loads the saved draft if one exists.
  PdfToTextDraft? loadDraft() {
    final dynamic raw = _storageService.cache.get(_draftKey);
    if (raw == null) {
      return null;
    }
    try {
      final Map<String, dynamic> json =
          jsonDecode(raw as String) as Map<String, dynamic>;
      return PdfToTextDraft.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clears the saved draft.
  Future<void> clearDraft() async {
    await _storageService.cache.delete(_draftKey);
  }
}
