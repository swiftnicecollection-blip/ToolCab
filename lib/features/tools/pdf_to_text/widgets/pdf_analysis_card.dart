import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../controller/pdf_to_text_controller.dart';
import '../data/models/extraction_models.dart';

/// PDF information card shown after analysis.
class PdfAnalysisCard extends GetView<PdfToTextController> {
  const PdfAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PdfAnalysisResult? analysis = controller.analysisResult.value;
      if (analysis == null) {
        return const SizedBox.shrink();
      }

      return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
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
                        analysis.fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        _formatSize(analysis.fileSize),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _InfoRow(
              icon: Icons.tag_rounded,
              label: 'Pages',
              value: '${analysis.pageCount}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.text_fields_rounded,
              label: 'Content',
              value: _contentTypeLabel(analysis.contentType),
            ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.rule_rounded,
              label: 'Status',
              value: analysis.hasSelectableText
                  ? 'Selectable text detected'
                  : 'Scanned PDF detected',
            ),
            if (!analysis.hasSelectableText) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Text(
                  'This PDF contains images rather than selectable text. '
                  'OCR will be used to extract text.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  String _contentTypeLabel(PdfContentType type) {
    return switch (type) {
      PdfContentType.text => 'Text-based',
      PdfContentType.scanned => 'Scanned / Image',
      PdfContentType.mixed => 'Mixed',
    };
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

/// Info row for the analysis card.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
