import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../controller/pdf_to_text_controller.dart';
import '../data/models/extraction_models.dart';

/// Page selection interface with grid, range input, and actions.
class PdfPageSelectionView extends GetView<PdfToTextController> {
  const PdfPageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Select Pages',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Choose which pages to extract text from.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Obx(
            () {
              final int pageCount =
                  controller.analysisResult.value?.pageCount ?? 0;
              final int selected = controller.pageSelection.value.mode ==
                      PdfPageSelectionMode.all
                  ? pageCount
                  : controller.pageSelection.value.selectedPages.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$selected of $pageCount pages selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Range input
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '1-5, 2,4,7',
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
                  const SizedBox(height: AppSpacing.lg),
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
                      TextButton.icon(
                        onPressed: controller.clearPageSelection,
                        icon: const Icon(Icons.clear_all_rounded, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: AppSpacing.buttonHeight,
                    child: ElevatedButton.icon(
                      onPressed: controller.startExtraction,
                      icon:
                          const Icon(Icons.document_scanner_rounded, size: 20),
                      label: Text(
                          'Extract $selected page${selected == 1 ? '' : 's'}',),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.categoryPdf,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
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
        width: 48,
        height: 48,
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
