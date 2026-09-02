import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/feedback/empty_state.dart';
import '../controller/pdf_to_text_controller.dart';
import '../data/models/extraction_models.dart';

/// PDF → Text history and favorites screen.
class PdfToTextHistoryView extends GetView<PdfToTextController> {
  const PdfToTextHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PDF → Text History'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'History'), Tab(text: 'Favorites')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _HistoryTab(
                title: 'history',
                query: controller.historySearchQuery,
                onSearch: controller.onHistorySearchChanged,
                entries: controller.filteredHistory,
                emptyTitle: 'No history yet',),
            _HistoryTab(
                title: 'favorites',
                query: controller.favoriteSearchQuery,
                onSearch: controller.onFavoriteSearchChanged,
                entries: controller.filteredFavorites,
                emptyTitle: 'No favorites yet',),
          ],
        ),
      ),
    );
  }
}

/// Generic tab with search and list.
class _HistoryTab extends StatelessWidget {
  const _HistoryTab({
    required this.title,
    required this.query,
    required this.onSearch,
    required this.entries,
    required this.emptyTitle,
  });

  final String title;
  final RxString query;
  final ValueChanged<String> onSearch;
  final List<PdfExtractionResult> entries;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search $title...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (entries.isEmpty) {
              return EmptyState(
                icon: title == 'history'
                    ? Icons.history_rounded
                    : Icons.favorite_border_rounded,
                title: emptyTitle,
                description: title == 'history'
                    ? 'Your PDF → Text conversions will appear here.'
                    : 'Favorite your extractions for quick access.',
                iconColor: AppColors.grey400,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: entries.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) =>
                  _HistoryTile(entry: entries[index]),
            );
          }),
        ),
      ],
    );
  }
}

/// History/favorite tile.
class _HistoryTile extends GetView<PdfToTextController> {
  const _HistoryTile({required this.entry});

  final PdfExtractionResult entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
        ),
      ),
      child: InkWell(
        onTap: () {
          controller.loadHistoryEntry(entry);
          Get.back();
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    entry.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 18,
                    color:
                        entry.isFavorite ? AppColors.error : AppColors.grey400,
                  ),
                  onPressed: () => controller.toggleHistoryFavorite(entry),
                  tooltip:
                      entry.isFavorite ? 'Remove favorite' : 'Add favorite',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  onPressed: () => controller.deleteHistoryEntry(entry.id!),
                  tooltip: 'Delete',
                ),
              ],
            ),
            Text(
              '${entry.method == PdfExtractionMethod.ocr ? 'OCR' : 'Selectable Text'} • '
              '${entry.wordCount} words • ${entry.charCount} chars',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              entry.textPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
