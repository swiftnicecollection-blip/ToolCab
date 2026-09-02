import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/feedback/error_state.dart';
import '../controller/merge_pdf_controller.dart';
import '../data/models/merge_models.dart';

/// Merge PDFs main screen.
class MergePdfView extends GetView<MergePdfController> {
  const MergePdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merge PDFs'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.toNamed(AppRoutes.pdfDashboard),
            tooltip: 'PDF Tools',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Get.toNamed(AppRoutes.help),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildBody(context),
          ),
        ),
      ),
    );
  }

  /// Builds the body based on the current state.
  Widget _buildBody(BuildContext context) {
    switch (controller.state.value) {
      case MergePdfState.idle:
        return _buildIdle(context);
      case MergePdfState.selecting:
        return const _ProcessingView(operation: 'Analyzing PDFs...');
      case MergePdfState.ready:
        return _buildReady(context);
      case MergePdfState.processing:
        return const _ProcessingView(operation: 'Merging PDFs...');
      case MergePdfState.success:
        return _buildSuccess(context);
      case MergePdfState.error:
        return ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.reset,
        );
      case MergePdfState.cancelled:
        return EmptyState(
          icon: Icons.cancel_outlined,
          title: 'Merge Cancelled',
          description: 'The merge was cancelled. No changes were saved.',
          actionLabel: 'Start Over',
          onActionTap: controller.reset,
          iconColor: AppColors.warning,
        );
    }
  }

  /// Builds the idle state with hero card.
  Widget _buildIdle(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _HeroCard(),
          const SizedBox(height: AppSpacing.xl),
          _EmptyState(),
        ],
      ),
    );
  }

  /// Builds the ready state with reorderable list.
  Widget _buildReady(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SummaryCard(),
                const SizedBox(height: AppSpacing.lg),
                _ReorderableList(),
                const SizedBox(height: AppSpacing.lg),
                _OutputNameField(),
                const SizedBox(height: AppSpacing.lg),
                _MergeButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the success screen.
  Widget _buildSuccess(BuildContext context) {
    return _SuccessCard();
  }
}

/// Hero card for PDF selection.
class _HeroCard extends GetView<MergePdfController> {
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
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.categoryPdf.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.merge_type_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Combine PDFs',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Merge multiple PDF documents into a single file.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: controller.selectPdfs,
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: const Text('Select PDFs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.categoryPdf,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no PDFs are selected.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.picture_as_pdf_rounded,
      title: 'No PDFs selected',
      description: 'Choose at least two PDF documents to combine them.',
      iconColor: AppColors.grey400,
    );
  }
}

/// Summary card with document count, pages, and size.
class _SummaryCard extends GetView<MergePdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
            _SummaryItem(
              icon: Icons.description_rounded,
              label: 'Documents',
              value: '${controller.selectedFiles.length}',
            ),
            const SizedBox(width: AppSpacing.lg),
            _SummaryItem(
              icon: Icons.tag_rounded,
              label: 'Total Pages',
              value: '${controller.totalPages}',
            ),
            const SizedBox(width: AppSpacing.lg),
            _SummaryItem(
              icon: Icons.storage_rounded,
              label: 'Total Size',
              value: controller.formattedTotalSize,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single summary item.
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.categoryPdf),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Reorderable list of selected PDFs.
class _ReorderableList extends GetView<MergePdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.selectedFiles.length,
        onReorderItem: controller.reorderPdfs,
        itemBuilder: (BuildContext context, int index) {
          final MergePdfItem item = controller.selectedFiles[index];
          return _SelectedPdfTile(
            key: ValueKey<String>(item.id),
            item: item,
            index: index,
          );
        },
      ),
    );
  }
}

/// Single selected PDF tile.
class _SelectedPdfTile extends GetView<MergePdfController> {
  const _SelectedPdfTile({
    super.key,
    required this.item,
    required this.index,
  });

  final MergePdfItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
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
          // Position number
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.categoryPdf.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.categoryPdf,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // PDF icon
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
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${item.pageCount > 0 ? '${item.pageCount} pages' : 'Pages unavailable'} • ${item.formattedSize}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          // Move up/down
          IconButton(
            icon: const Icon(Icons.arrow_upward_rounded, size: 18),
            onPressed: () => controller.moveUp(index),
            tooltip: 'Move Up',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
            onPressed: () => controller.moveDown(index),
            tooltip: 'Move Down',
            visualDensity: VisualDensity.compact,
          ),
          // Remove
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
            onPressed: () => controller.removePdf(item.id),
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
          ),
          // Drag handle
          const Icon(
            Icons.drag_handle_rounded,
            size: 20,
            color: AppColors.grey400,
          ),
        ],
      ),
    );
  }
}

/// Output filename field.
class _OutputNameField extends GetView<MergePdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Obx(
        () => TextField(
          controller:
              TextEditingController(text: controller.outputFileName.value),
          onChanged: controller.setOutputFileName,
          decoration: const InputDecoration(
            labelText: 'Output Filename',
            hintText: 'ToolCab_Merged_2026-08-11.pdf',
            prefixIcon:
                Icon(Icons.drive_file_rename_outline_rounded, size: 20),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

/// Merge button.
class _MergeButton extends GetView<MergePdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: controller.startMerge,
          icon: const Icon(Icons.merge_type_rounded, size: 20),
          label: const Text('Merge PDFs'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.categoryPdf,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

/// Processing view.
class _ProcessingView extends StatelessWidget {
  const _ProcessingView({required this.operation});

  final String operation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.categoryPdf.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.merge_type_rounded,
                size: 40,
                color: AppColors.categoryPdf,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              operation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const CircularProgressIndicator(strokeWidth: 2.5),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your documents are processed locally.',
              textAlign: TextAlign.center,
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

/// Success card.
class _SuccessCard extends GetView<MergePdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final MergePdfResult? result = controller.currentResult.value;
      if (result == null) {
        return const SizedBox.shrink();
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    AppColors.success.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: AppShadows.medium,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 36,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'PDFs Merged Successfully',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    result.fileName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${result.sourceDocumentCount} documents • '
                    '${result.pageCount} pages • ${result.formattedSize}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _ActionButton(
              icon: Icons.visibility_rounded,
              label: 'Open PDF',
              color: AppColors.primary,
              onTap: controller.openMergedPdf,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              color: AppColors.info,
              onTap: controller.shareMergedPdf,
            ),
            const SizedBox(height: AppSpacing.md),
            Obx(
              () => _ActionButton(
                icon: controller.isFavorite.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: controller.isFavorite.value ? 'Favorited' : 'Favorite',
                color: controller.isFavorite.value
                    ? AppColors.error
                    : AppColors.grey600,
                onTap: controller.toggleFavorite,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppColors.error,
              onTap: controller.deleteOutput,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.add_rounded,
              label: 'Merge More',
              color: AppColors.categoryPdf,
              onTap: controller.reset,
            ),
          ],
        ),
      );
    });
  }
}

/// Action button for success screen.
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
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.10),
          foregroundColor: color,
          elevation: 0,
        ),
      ),
    );
  }
}
