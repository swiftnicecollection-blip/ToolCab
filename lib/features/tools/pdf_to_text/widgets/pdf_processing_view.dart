import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../controller/pdf_to_text_controller.dart';

/// Premium processing screen for PDF → Text extraction.
class PdfProcessingView extends GetView<PdfToTextController> {
  const PdfProcessingView({
    super.key,
    required this.operation,
    this.showProgress = false,
  });

  /// Operation label.
  final String operation;

  /// Whether to show page progress.
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              builder: (BuildContext context, double value, Widget? child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.categoryPdf.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      size: 40,
                      color: AppColors.categoryPdf,
                    ),
                  ),
                );
              },
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
            if (showProgress) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Obx(
                () {
                  final int current = controller.currentPage.value;
                  final int total = controller.totalPages.value;
                  if (current > 0 && total > 0) {
                    return Text(
                      'Processing page $current of $total',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your document is processed locally whenever possible.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: controller.cancelExtraction,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
