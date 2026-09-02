import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/feedback/error_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controller/pdf_to_text_controller.dart';
import '../data/models/extraction_models.dart';
import '../widgets/pdf_analysis_card.dart';
import '../widgets/pdf_input_card.dart';
import '../widgets/pdf_page_selection_view.dart';
import '../widgets/pdf_processing_view.dart';
import '../widgets/pdf_result_editor.dart';

/// PDF → Text main screen.
class PdfToTextView extends GetView<PdfToTextController> {
  const PdfToTextView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF → Text'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.toNamed(AppRoutes.pdfToTextHistory),
            tooltip: 'History',
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

  /// Builds the body based on the current flow state.
  Widget _buildBody(BuildContext context) {
    switch (controller.state.value) {
      case PdfToTextFlowState.idle:
        return _buildIdle(context);
      case PdfToTextFlowState.analyzing:
        return const PdfProcessingView(
          operation: 'Analyzing PDF',
          showProgress: false,
        );
      case PdfToTextFlowState.analyzed:
        return _buildAnalyzed(context);
      case PdfToTextFlowState.selectingPages:
        return const PdfPageSelectionView();
      case PdfToTextFlowState.extracting:
        return const PdfProcessingView(
          operation: 'Extracting text',
          showProgress: true,
        );
      case PdfToTextFlowState.success:
        return const PdfResultEditor();
      case PdfToTextFlowState.failed:
        return _buildError(context);
      case PdfToTextFlowState.cancelled:
        return _buildCancelled(context);
    }
  }

  /// Builds the idle state with hero card and select PDF button.
  Widget _buildIdle(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PdfInputCard(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Recent Extractions',
            subtitle: 'Your recent PDF → Text conversions.',
          ),
          const SizedBox(height: AppSpacing.md),
          _HistorySection(),
        ],
      ),
    );
  }

  /// Builds the analyzed state with PDF info card.
  Widget _buildAnalyzed(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const PdfAnalysisCard(),
          const SizedBox(height: AppSpacing.xl),
          _ExtractionMethodSection(),
          const SizedBox(height: AppSpacing.xl),
          _PageSelectionSection(),
          const SizedBox(height: AppSpacing.xl),
          _ActionButtons(),
        ],
      ),
    );
  }

  /// Builds the error state.
  Widget _buildError(BuildContext context) {
    return ErrorState(
      message: controller.errorMessage.value,
      onRetry: controller.reset,
    );
  }

  /// Builds the cancelled state.
  Widget _buildCancelled(BuildContext context) {
    return EmptyState(
      icon: Icons.cancel_outlined,
      title: 'Extraction Cancelled',
      description: 'The extraction was cancelled. No changes were saved.',
      actionLabel: 'Start Over',
      onActionTap: controller.reset,
      iconColor: AppColors.warning,
    );
  }
}

/// Extraction method selection section.
class _ExtractionMethodSection extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Extraction Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Obx(
            () {
              final PdfAnalysisResult? analysis =
                  controller.analysisResult.value;
              final bool hasText = analysis?.hasSelectableText ?? false;

              return Column(
                children: <Widget>[
                  _MethodOption(
                    title: 'Automatic',
                    description: hasText
                        ? 'Extract selectable text, use OCR only where needed.'
                        : 'Use OCR to extract text from scanned pages.',
                    icon: Icons.auto_awesome_rounded,
                    selected: controller.extractionMethod.value ==
                        PdfExtractionMethod.automatic,
                    onTap: () => controller.setExtractionMethod(
                      PdfExtractionMethod.automatic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MethodOption(
                    title: 'Selectable Text',
                    description: 'Extract text directly from the PDF.',
                    icon: Icons.text_fields_rounded,
                    selected: controller.extractionMethod.value ==
                        PdfExtractionMethod.selectableText,
                    onTap: () => controller.setExtractionMethod(
                      PdfExtractionMethod.selectableText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MethodOption(
                    title: 'OCR',
                    description: 'Recognize text from page images.',
                    icon: Icons.document_scanner_rounded,
                    selected: controller.extractionMethod.value ==
                        PdfExtractionMethod.ocr,
                    onTap: () => controller.setExtractionMethod(
                      PdfExtractionMethod.ocr,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Single method option card.
class _MethodOption extends StatelessWidget {
  const _MethodOption({
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
class _PageSelectionSection extends GetView<PdfToTextController> {
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
            () {
              final int pageCount =
                  controller.analysisResult.value?.pageCount ?? 0;
              final int selectedCount = controller.pageSelection.value.mode ==
                      PdfPageSelectionMode.all
                  ? pageCount
                  : controller.pageSelection.value.selectedPages.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$selectedCount of $pageCount pages selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Page range input
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'e.g. 1-5, 2,4,7 or 1-3,8-10',
                      labelText: 'Page Range',
                      prefixIcon: Icon(Icons.tag_rounded, size: 20),
                      isDense: true,
                    ),
                    onSubmitted: (String value) {
                      if (!controller.applyPageRange(value)) {
                        Get.snackbar(
                          'Invalid Range',
                          'Please enter a valid page range.',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Page grid
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      for (int i = 1; i <= pageCount; i++)
                        _PageChip(
                          pageNumber: i,
                          selected:
                              controller.pageSelection.value.isSelected(i),
                          onTap: () => controller.togglePage(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      TextButton.icon(
                        onPressed: controller.toggleSelectAll,
                        icon: const Icon(Icons.select_all_rounded, size: 18),
                        label: Text(
                          controller.pageSelection.value.mode ==
                                  PdfPageSelectionMode.all
                              ? 'Deselect All'
                              : 'Select All',
                        ),
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
              );
            },
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

/// Action buttons for extraction.
class _ActionButtons extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: controller.startExtraction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.categoryPdf,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.document_scanner_rounded, size: 20),
                  SizedBox(width: AppSpacing.sm),
                  Text('Extract Text'),
                ],
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

/// History section.
class _HistorySection extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.historyEntries.isEmpty) {
          return const EmptyState(
            icon: Icons.history_rounded,
            title: 'No extractions yet',
            description: 'Your PDF → Text conversions will appear here.',
            iconColor: AppColors.grey400,
          );
        }

        return Column(
          children: <Widget>[
            for (int i = 0;
                i < controller.historyEntries.length;
                i++) ...<Widget>[
              _HistoryTile(entry: controller.historyEntries[i]),
              if (i < controller.historyEntries.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

/// History tile.
class _HistoryTile extends GetView<PdfToTextController> {
  const _HistoryTile({required this.entry});

  final PdfExtractionResult entry;

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
      child: InkWell(
        onTap: () => controller.loadHistoryEntry(entry),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                Icons.notes_rounded,
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
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${entry.method == PdfExtractionMethod.ocr ? 'OCR' : 'Selectable Text'} • '
                    '${entry.wordCount} words • '
                    '${entry.createdAt?.month}/${entry.createdAt?.day}/${entry.createdAt?.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                size: 18,
                color: entry.isFavorite ? AppColors.error : AppColors.grey400,
              ),
              onPressed: () => controller.toggleHistoryFavorite(entry),
              tooltip: entry.isFavorite ? 'Remove favorite' : 'Add favorite',
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
      ),
    );
  }
}
