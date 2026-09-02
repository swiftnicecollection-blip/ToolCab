import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/feedback/error_state.dart';
import '../controller/split_pdf_controller.dart';
import '../data/models/split_models.dart';

/// Split PDFs main screen.
class SplitPdfView extends GetView<SplitPdfController> {
  const SplitPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split PDF'),
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
      case SplitPdfState.idle:
        return _buildIdle(context);
      case SplitPdfState.analyzing:
        return const _ProcessingView(operation: 'Analyzing PDF...');
      case SplitPdfState.ready:
        return _buildReady(context);
      case SplitPdfState.configuring:
        return _buildConfiguring(context);
      case SplitPdfState.processing:
        return const _ProcessingView(operation: 'Splitting PDF...');
      case SplitPdfState.success:
        return _buildSuccess(context);
      case SplitPdfState.error:
        return ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.reset,
        );
      case SplitPdfState.cancelled:
        return EmptyState(
          icon: Icons.cancel_outlined,
          title: 'Split Cancelled',
          description: 'The split was cancelled. No changes were saved.',
          actionLabel: 'Start Over',
          onActionTap: controller.reset,
          iconColor: AppColors.warning,
        );
      case SplitPdfState.selecting:
      case SplitPdfState.selectingPages:
      case SplitPdfState.validating:
        return const _ProcessingView(operation: 'Preparing...');
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
          const EmptyState(
            icon: Icons.content_cut_rounded,
            title: 'No PDF selected',
            description: 'Choose a PDF to start splitting pages.',
            iconColor: AppColors.grey400,
          ),
        ],
      ),
    );
  }

  /// Builds the ready state with PDF info and page selection.
  Widget _buildReady(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PdfInfoCard(),
          const SizedBox(height: AppSpacing.xl),
          _SplitModeSelector(),
          const SizedBox(height: AppSpacing.xl),
          _PageSelectionSection(),
          const SizedBox(height: AppSpacing.xl),
          _OutputNameField(),
          const SizedBox(height: AppSpacing.xl),
          _ActionButtons(),
        ],
      ),
    );
  }

  /// Builds the configuring state for by-ranges mode.
  Widget _buildConfiguring(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Enter Page Ranges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Separate ranges with semicolons (;).\nExample: 1-3; 4-6; 7-10',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            decoration: const InputDecoration(
              hintText: '1-3; 4-6; 7-10',
              labelText: 'Page Ranges',
              prefixIcon: Icon(Icons.tag_rounded, size: 20),
              isDense: true,
            ),
            onSubmitted: (String value) {
              final List<List<int>>? ranges = controller.getRangeGroups(value);
              if (ranges == null) {
                Get.snackbar(
                  'Invalid Page Range',
                  'Pages must be between 1 and ${controller.pageCount.value}.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFEF4444),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
              controller.splitWithRanges(ranges);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: controller.startSplit,
              icon: const Icon(Icons.content_cut_rounded, size: 20),
              label: const Text('Split by Ranges'),
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

  /// Builds the success screen.
  Widget _buildSuccess(BuildContext context) {
    return _SuccessView();
  }
}

/// Hero card for PDF selection.
class _HeroCard extends GetView<SplitPdfController> {
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
              Icons.content_cut_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Split Your PDF',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Extract pages or divide your document into smaller PDFs.',
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
              onPressed: controller.selectPdf,
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: const Text('Select PDF'),
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

/// PDF info card after analysis.
class _PdfInfoCard extends GetView<SplitPdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: AppShadows.medium,
          border: Border.all(
            color: AppColors.categoryPdf.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.categoryPdf.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppColors.categoryPdf,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    controller.selectedFileName.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${controller.pageCount.value} pages • '
                    '${_formatSize(controller.selectedFileSize.value)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Split mode selector.
class _SplitModeSelector extends GetView<SplitPdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Split Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ModeOption(
            title: 'Extract Pages',
            description: 'Select specific pages to extract.',
            icon: Icons.select_all_rounded,
            selected: controller.splitMode.value == SplitMode.extractSelected,
            onTap: () => controller.setSplitMode(SplitMode.extractSelected),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ModeOption(
            title: 'Split by Ranges',
            description: 'Divide into parts by page ranges.',
            icon: Icons.format_list_numbered_rounded,
            selected: controller.splitMode.value == SplitMode.byRanges,
            onTap: () => controller.setSplitMode(SplitMode.byRanges),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ModeOption(
            title: 'Every Page',
            description: 'Split each page into its own PDF.',
            icon: Icons.grid_view_rounded,
            selected: controller.splitMode.value == SplitMode.everyPage,
            onTap: () => controller.setSplitMode(SplitMode.everyPage),
          ),
        ],
      ),
    );
  }
}

/// Single mode option card.
class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.categoryPdf.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: selected
                ? AppColors.categoryPdf
                : Theme.of(context).colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppShadows.soft : null,
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
              child: Icon(icon, color: AppColors.categoryPdf, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.categoryPdf : AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Page selection section.
class _PageSelectionSection extends GetView<SplitPdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Page Selection',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(
            () => Text(
              '${controller.selectedPages.length} of '
              '${controller.pageCount.value} pages selected',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Range input
          TextField(
            decoration: const InputDecoration(
              hintText: 'e.g. 1-5, 2,4,7',
              labelText: 'Page Range',
              prefixIcon: Icon(Icons.tag_rounded, size: 20),
              isDense: true,
            ),
            onSubmitted: (String value) {
              final String? error = controller.applyPageRange(value);
              if (error != null) {
                Get.snackbar(
                  'Invalid Page Range',
                  error,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFFEF4444),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          // Page grid
          Obx(
            () => Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (int i = 1; i <= controller.pageCount.value; i++)
                  _PageChip(
                    pageNumber: i,
                    selected: controller.selectedPages.contains(i),
                    onTap: () => controller.togglePage(i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              TextButton.icon(
                onPressed: controller.selectAllPages,
                icon: const Icon(Icons.select_all_rounded, size: 18),
                label: const Text('Select All'),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton.icon(
                onPressed: controller.clearPageSelection,
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Page chip for selection.
class _PageChip extends StatelessWidget {
  const _PageChip({
    required this.pageNumber,
    required this.selected,
    required this.onTap,
  });

  final int pageNumber;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.categoryPdf
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected
                ? AppColors.categoryPdf
                : Theme.of(context).colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
          ),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : null,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

/// Output filename field.
class _OutputNameField extends GetView<SplitPdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Obx(
        () => TextField(
          controller:
              TextEditingController(text: controller.baseFileName.value),
          onChanged: controller.setBaseFileName,
          decoration: const InputDecoration(
            labelText: 'Output Base Filename',
            hintText: 'ToolCab_Split_2026-08-11',
            prefixIcon:
                Icon(Icons.drive_file_rename_outline_rounded, size: 20),
            isDense: true,
          ),
        ),
      ),
    );
  }
}

/// Action buttons.
class _ActionButtons extends GetView<SplitPdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: controller.startSplit,
              icon: const Icon(Icons.content_cut_rounded, size: 20),
              label: const Text('Split PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.categoryPdf,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: OutlinedButton(
              onPressed: controller.reset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.grey600,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: const Text('Choose Another PDF'),
            ),
          ),
        ],
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
                Icons.content_cut_rounded,
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
              'Your document is processed locally.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: () => Get.find<SplitPdfController>().cancelOperation(),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success view.
class _SuccessView extends GetView<SplitPdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final SplitPdfResult? result = controller.currentResult.value;
      if (result == null) {
        return const SizedBox.shrink();
      }
      return Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
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
                          result.outputs.length > 1
                              ? 'PDF Split into ${result.outputs.length} Files'
                              : 'PDF Split Successfully',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${result.outputs.length} outputs • '
                          '${result.totalPages} pages • '
                          '${result.formattedTotalSize}',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.share_rounded,
                          label: 'Share All',
                          color: AppColors.info,
                          onTap: controller.shareAllOutputs,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Generated Files',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (int i = 0; i < result.outputs.length; i++) ...<Widget>[
                    _OutputTile(output: result.outputs[i]),
                    if (i < result.outputs.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Output file tile.
class _OutputTile extends GetView<SplitPdfController> {
  const _OutputTile({required this.output});

  final SplitOutputFile output;

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
                  output.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${output.pageCount} page${output.pageCount == 1 ? '' : 's'} • '
                  '${output.formattedSize}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              output.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 18,
              color: output.isFavorite ? AppColors.error : AppColors.grey400,
            ),
            onPressed: () => controller.toggleFavorite(output),
            tooltip: output.isFavorite ? 'Remove favorite' : 'Add favorite',
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 18),
            onPressed: () => controller.shareOutput(output),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
            onPressed: () => controller.deleteOutput(output),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

/// Action button.
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
