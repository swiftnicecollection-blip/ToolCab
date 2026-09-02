import '../../../history/data/models/history_entry.dart';

/// Repository for user activity history.
///
/// Delegates to the centralized HistoryRepository.
class HomeHistoryRepository {
  /// Returns the list of history entries.
  Future<List<HistoryEntry>> getHistory() {
    final HistoryRepository repository = HistoryRepository();
    return repository.getEntries();
  }

  /// Adds a history entry.
  Future<void> addHistoryEntry(HistoryEntry entry) async {
    final HistoryRepository repository = HistoryRepository();
    await repository.saveEntry(entry);
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    final HistoryRepository repository = HistoryRepository();
    await repository.clearHistory();
  }
}
