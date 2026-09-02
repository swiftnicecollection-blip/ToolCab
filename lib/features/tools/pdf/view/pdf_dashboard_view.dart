import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controller/pdf_tools_controller.dart';
import '../data/models/pdf_models.dart';

/// PDF Tools Dashboard.
///
/// Central workspace for all PDF operations.
class PdfDashboardView extends GetView<PdfToolsController> {
  const PdfDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Tools'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Get.snackbar(
              'Search',
              'Use the search field below to find documents.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            ),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Get.toNamed(AppRoutes.help),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Hero section
              _HeroCard(),
              const SizedBox(height: AppSpacing.xl),

              // Usage banner
              _UsageBanner(),
              const SizedBox(height: AppSpacing.xl),

              // Tool grid
              const SectionHeader(
                title: 'PDF Tools',
                subtitle: 'Everything you need for your documents.',
              ),
              const SizedBox(height: AppSpacing.md),
              _ToolGrid(),
              const SizedBox(height: AppSpacing.xl),

              // Search + filter
              _SearchFilterBar(),
              const SizedBox(height: AppSpacing.md),

              // Recent documents
              const SectionHeader(
                title: 'Recent Documents',
                subtitle: 'Your recently accessed PDF files.',
              ),
              const SizedBox(height: AppSpacing.md),
              _RecentFilesSection(),
              const SizedBox(height: AppSpacing.xl),

              // History
              const SectionHeader(
                title: 'PDF History',
                subtitle: 'Your recent PDF operations.',
              ),
              const SizedBox(height: AppSpacing.md),
              _HistorySection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero card with PDF illustration.
class _HeroCard extends GetView<PdfToolsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.categoryPdf.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.medium,
        border: Border.all(
          color: AppColors.categoryPdf.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.categoryPdf,
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Powerful PDF Tools',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create, convert, organize, and optimize your documents from one place.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  icon: Icons.upload_file_rounded,
                  label: 'Import PDF',
                  color: AppColors.categoryPdf,
                  onTap: controller.importPdf,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionButton(
                  icon: Icons.note_add_rounded,
                  label: 'Create PDF',
                  color: AppColors.primary,
                  onTap: () => controller.navigateToTool(
                    PdfOperation.textToPdf,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Usage tracking banner.
class _UsageBanner extends GetView<PdfToolsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(
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
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: AppColors.categoryPdf,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Unlimited PDF operations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// PDF tool grid.
class _ToolGrid extends GetView<PdfToolsController> {
  @override
  Widget build(BuildContext context) {
    final List<_ToolData> tools = <_ToolData>[
      const _ToolData(
        icon: Icons.note_add_rounded,
        title: 'Text → PDF',
        description: 'Create professional PDF documents from text.',
        action: 'Create PDF',
        operation: PdfOperation.textToPdf,
      ),
      const _ToolData(
        icon: Icons.notes_rounded,
        title: 'PDF → Text',
        description: 'Extract editable text from PDF documents.',
        action: 'Extract Text',
        operation: PdfOperation.pdfToText,
      ),
      const _ToolData(
        icon: Icons.merge_type_rounded,
        title: 'Merge PDFs',
        description: 'Combine multiple PDF files into one document.',
        action: 'Merge',
        operation: PdfOperation.merge,
      ),
      const _ToolData(
        icon: Icons.content_cut_rounded,
        title: 'Split PDF',
        description: 'Split PDF documents into separate pages or ranges.',
        action: 'Split',
        operation: PdfOperation.split,
      ),
      const _ToolData(
        icon: Icons.compress_rounded,
        title: 'Compress PDF',
        description: 'Reduce PDF file size while preserving quality.',
        action: 'Compress',
        operation: PdfOperation.compress,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < tools.length; i++) ...<Widget>[
            _ToolCard(data: tools[i]),
            if (i < tools.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// Tool card data.
class _ToolData {
  const _ToolData({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    required this.operation,
  });

  final IconData icon;
  final String title;
  final String description;
  final String action;
  final PdfOperation operation;
}

/// Single PDF tool card.
class _ToolCard extends GetView<PdfToolsController> {
  const _ToolCard({required this.data});

  final _ToolData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.navigateToTool(data.operation),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppShadows.soft,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
                  alpha: 0.3,
                ),
          ),
        ),
        child: Row(
          children: <Widget>[
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.categoryPdf.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                data.icon,
                color: AppColors.categoryPdf,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        data.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    data.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Action
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.categoryPdf.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                data.action,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.categoryPdf,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search and filter bar.
class _SearchFilterBar extends GetView<PdfToolsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search documents...',
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
          const SizedBox(width: AppSpacing.sm),
          // Filter
          Obx(
            () => PopupMenuButton<PdfFilter>(
              icon: const Icon(Icons.filter_list_rounded, size: 20),
              tooltip: 'Filter',
              initialValue: controller.filter.value,
              onSelected: controller.setFilter,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PdfFilter>>[
                const PopupMenuItem<PdfFilter>(
                  value: PdfFilter.all,
                  child: Text('All'),
                ),
                const PopupMenuItem<PdfFilter>(
                  value: PdfFilter.favorites,
                  child: Text('Favorites'),
                ),
                const PopupMenuItem<PdfFilter>(
                  value: PdfFilter.created,
                  child: Text('Created'),
                ),
                const PopupMenuItem<PdfFilter>(
                  value: PdfFilter.imported,
                  child: Text('Imported'),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Sort
          Obx(
            () => PopupMenuButton<PdfSort>(
              icon: const Icon(Icons.sort_rounded, size: 20),
              tooltip: 'Sort',
              initialValue: controller.sortOrder.value,
              onSelected: controller.setSortOrder,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<PdfSort>>[
                const PopupMenuItem<PdfSort>(
                  value: PdfSort.newest,
                  child: Text('Newest'),
                ),
                const PopupMenuItem<PdfSort>(
                  value: PdfSort.oldest,
                  child: Text('Oldest'),
                ),
                const PopupMenuItem<PdfSort>(
                  value: PdfSort.nameAsc,
                  child: Text('Name A-Z'),
                ),
                const PopupMenuItem<PdfSort>(
                  value: PdfSort.nameDesc,
                  child: Text('Name Z-A'),
                ),
                const PopupMenuItem<PdfSort>(
                  value: PdfSort.largest,
                  child: Text('Largest'),
                ),
                const PopupMenuItem<PdfSort>(
                  value: PdfSort.smallest,
                  child: Text('Smallest'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent files section.
class _RecentFilesSection extends GetView<PdfToolsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final List<PdfFileItem> files = controller.filteredRecentFiles;
        if (files.isEmpty) {
          return const EmptyState(
            icon: Icons.picture_as_pdf_rounded,
            title: 'No PDF documents yet',
            description: 'Create or import a PDF to get started.',
            iconColor: AppColors.grey400,
          );
        }

        return Column(
          children: <Widget>[
            for (int i = 0; i < files.length; i++) ...<Widget>[
              _FileTile(file: files[i]),
              if (i < files.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// File tile for recent documents.
class _FileTile extends GetView<PdfToolsController> {
  const _FileTile({required this.file});

  final PdfFileItem file;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.categoryPdf.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.categoryPdf,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  file.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${_formatSize(file.fileSize)} • ${file.source ?? 'imported'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              file.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 18,
              color: file.isFavorite ? AppColors.error : AppColors.grey400,
            ),
            onPressed: () => controller.toggleFavorite(file),
            tooltip: file.isFavorite ? 'Remove favorite' : 'Add favorite',
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
            onPressed: () => controller.deleteRecentFile(file.id),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  /// Formats a file size in bytes.
  String _formatSize(int? bytes) {
    if (bytes == null) {
      return 'Size unavailable';
    }
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// History section.
class _HistorySection extends GetView<PdfToolsController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final List<PdfHistoryEntry> entries = controller.historyEntries;
        if (entries.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No PDF history yet',
            description: 'Your PDF operations will appear here.',
            iconColor: AppColors.grey400,
          );
        }

        return Column(
          children: <Widget>[
            for (int i = 0; i < entries.length; i++) ...<Widget>[
              _HistoryTile(entry: entries[i]),
              if (i < entries.length - 1) const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// History tile.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final PdfHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.categoryPdf.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.categoryPdf,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.operationName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${entry.fileName ?? 'Document'} • '
                  '${entry.date.month}/${entry.date.day}/${entry.date.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button for hero card.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
