import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../data/models/history_entry.dart';

/// History view showcasing recent operations across all tools.
class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final HistoryRepository _repository = HistoryRepository();
  final RxList<HistoryEntry> _entries = <HistoryEntry>[].obs;
  final RxBool _isLoading = true.obs;
  final RxString _searchQuery = RxString('');
  final RxBool _showFavoritesOnly = RxBool(false);

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Loads history from storage.
  Future<void> _loadHistory() async {
    _isLoading.value = true;
    try {
      _entries.value = await _repository.getEntries();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Returns filtered entries based on search and favorites filter.
  List<HistoryEntry> get _filteredEntries {
    List<HistoryEntry> entries = List<HistoryEntry>.of(_entries);

    if (_showFavoritesOnly.value) {
      entries = entries.where((HistoryEntry e) => e.isFavorite).toList();
    }

    final String query = _searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      entries = entries
          .where((HistoryEntry e) =>
              e.title.toLowerCase().contains(query) ||
              e.description.toLowerCase().contains(query) ||
              e.toolType.displayName.toLowerCase().contains(query),)
          .toList();
    }

    return entries;
  }

  /// Toggles favorite status for an entry.
  Future<void> _toggleFavorite(HistoryEntry entry) async {
    final HistoryEntry updated = entry.copyWith(isFavorite: !entry.isFavorite);
    await _repository.updateEntry(updated);
    await _loadHistory();
  }

  /// Deletes an entry.
  Future<void> _deleteEntry(HistoryEntry entry) async {
    await _repository.deleteEntry(entry.id);
    await _loadHistory();
  }

  /// Clears all history.
  Future<void> _clearHistory() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
              'Are you sure you want to clear all history? This cannot be undone.',),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _repository.clearHistory();
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: <Widget>[
          Obx(() {
            return IconButton(
              icon: Icon(
                _showFavoritesOnly.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _showFavoritesOnly.value ? AppColors.error : null,
              ),
              onPressed: () {
                _showFavoritesOnly.value = !_showFavoritesOnly.value;
              },
              tooltip: 'Favorites',
            );
          }),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: _clearHistory,
            tooltip: 'Clear History',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Search bar.
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search history...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (String value) {
                  _searchQuery.value = value;
                },
              ),
            ),

            // Content.
            Expanded(
              child: Obx(() {
                if (_isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  );
                }

                final List<HistoryEntry> entries = _filteredEntries;

                if (entries.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _HistoryTile(
                      entry: entries[index],
                      onFavorite: () => _toggleFavorite(entries[index]),
                      onDelete: () => _deleteEntry(entries[index]),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _showFavoritesOnly.value ? 'No favorites yet' : 'No activity yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _showFavoritesOnly.value
                  ? 'Favorite items to find them quickly.'
                  : 'Operations you perform will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single history tile.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.onFavorite,
    required this.onDelete,
  });

  final HistoryEntry entry;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  /// Returns the color associated with the tool type.
  Color get _toolColor {
    switch (entry.toolType) {
      case HistoryToolType.tts:
      case HistoryToolType.stt:
        return AppColors.categorySpeech;
      case HistoryToolType.translator:
        return AppColors.categoryTranslation;
      case HistoryToolType.ocr:
        return AppColors.categoryOcr;
      case HistoryToolType.textToPdf:
      case HistoryToolType.pdfToText:
      case HistoryToolType.mergePdf:
      case HistoryToolType.splitPdf:
      case HistoryToolType.compressPdf:
        return AppColors.categoryPdf;
      case HistoryToolType.qrScan:
        return AppColors.categoryQr;
    }
  }

  /// Returns the icon for the tool type.
  IconData get _toolIcon {
    switch (entry.toolType) {
      case HistoryToolType.tts:
        return Icons.record_voice_over_rounded;
      case HistoryToolType.stt:
        return Icons.mic_rounded;
      case HistoryToolType.translator:
        return Icons.translate_rounded;
      case HistoryToolType.ocr:
        return Icons.document_scanner_rounded;
      case HistoryToolType.textToPdf:
      case HistoryToolType.pdfToText:
      case HistoryToolType.mergePdf:
      case HistoryToolType.splitPdf:
      case HistoryToolType.compressPdf:
        return Icons.picture_as_pdf_rounded;
      case HistoryToolType.qrScan:
        return Icons.qr_code_scanner_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Show details or open file if available.
            if (entry.filePath != null) {
              _tryOpenFile(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _toolColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(_toolIcon, size: 20, color: _toolColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${entry.toolType.displayName} • ${Formatters.relativeTime(entry.timestamp)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    entry.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: entry.isFavorite
                        ? AppColors.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Attempts to open the associated file.
  void _tryOpenFile(BuildContext context) {
    final String? path = entry.filePath;
    if (path == null) return;

    final File file = File(path);
    if (!file.existsSync()) {
      Get.snackbar(
        'File Unavailable',
        'This file is no longer available.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
