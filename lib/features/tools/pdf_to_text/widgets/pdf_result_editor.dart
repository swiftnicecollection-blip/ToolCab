import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../controller/pdf_to_text_controller.dart';
import '../data/models/extraction_models.dart';

/// Professional text editor for extracted PDF text.
///
/// Features editing, search, copy, share, export,
/// and integration with Translator, Text → Audio, and Text → PDF.
class PdfResultEditor extends GetView<PdfToTextController> {
  const PdfResultEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Result header
        _ResultHeader(),
        const Divider(height: 1),
        // Action bar
        _ActionBar(),
        const Divider(height: 1),
        // OCR warning banner if applicable
        _OcrWarningBanner(),
        // Text editor
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: controller.textController,
              maxLines: null,
              minLines: 10,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Extracted text will appear here...',
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ),
        ),
        // Bottom info bar
        _BottomInfoBar(),
      ],
    );
  }
}

/// Result header with title, method badge, and stats.
class _ResultHeader extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PdfExtractionResult? result = controller.currentResult.value;
      if (result == null) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    result.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: (result.method == PdfExtractionMethod.ocr
                            ? AppColors.info
                            : AppColors.success)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    result.method == PdfExtractionMethod.ocr
                        ? 'OCR'
                        : 'Selectable Text',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: result.method == PdfExtractionMethod.ocr
                              ? AppColors.info
                              : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${result.pageCount} pages • ${result.wordCount} words • '
              '${result.charCount} characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

/// Action bar with copy, share, export, translate, speak, PDF.
class _ActionBar extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: <Widget>[
          _ActionChip(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: controller.copyText,
          ),
          _ActionChip(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: controller.shareText,
          ),
          _ActionChip(
            icon: Icons.save_alt_rounded,
            label: 'Export TXT',
            onTap: controller.exportTxt,
          ),
          _ActionChip(
            icon: Icons.translate_rounded,
            label: 'Translate',
            onTap: controller.sendToTranslator,
          ),
          _ActionChip(
            icon: Icons.record_voice_over_rounded,
            label: 'Read Aloud',
            onTap: controller.sendToTts,
          ),
          _ActionChip(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Create PDF',
            onTap: controller.sendToPdf,
          ),
          Obx(
            () => _ActionChip(
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
        ],
      ),
    );
  }
}

/// Single action chip.
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.grey600;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: c),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: c,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// OCR warning banner.
class _OcrWarningBanner extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final PdfExtractionResult? result = controller.currentResult.value;
      if (result == null || result.method != PdfExtractionMethod.ocr) {
        return const SizedBox.shrink();
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.warning.withValues(alpha: 0.08),
        child: const Row(
          children: <Widget>[
            Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.warning,),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'OCR results may require manual correction.',
                style: TextStyle(fontSize: 13, color: AppColors.warning),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Bottom info bar with word/char counts.
class _BottomInfoBar extends GetView<PdfToTextController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: <Widget>[
            Text(
              '${controller.wordCount} words',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '${controller.charCount} characters',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const Spacer(),
            if (controller.hasDraft.value)
              const Text(
                'Draft saved',
                style: TextStyle(fontSize: 12, color: AppColors.grey500),
              ),
          ],
        ),
      ),
    );
  }
}
