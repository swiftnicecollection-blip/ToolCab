import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controller/ocr_controller.dart';
import '../data/models/ocr_history_entry.dart';
import '../widgets/ocr_history_tile.dart';

/// OCR Dashboard screen.
///
/// Features:
/// - Premium scanner card with camera/gallery actions
/// - Document quality tips
/// - Image preview and processing states
/// - Extracted text editor with actions
/// - History and favorites with search
class OcrView extends GetView<OcrController> {
  const OcrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image → Text'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.snackbar(
              'History',
              'Scroll down to view your OCR history.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            ),
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: Get.back,
            tooltip: 'Back',
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
              // Scanner card
              _ScannerCard(),
              const SizedBox(height: AppSpacing.xl),

              // Usage banner
              _UsageBanner(),
              const SizedBox(height: AppSpacing.xl),

              // Image preview / processing / result
              Obx(() {
                switch (controller.state.value) {
                  case OcrState.previewing:
                    return _ImagePreviewCard();
                  case OcrState.processing:
                    return _ProcessingCard();
                  case OcrState.success:
                    return _ResultCard();
                  case OcrState.error:
                    return _ErrorCard();
                  case OcrState.idle:
                    return const SizedBox.shrink();
                }
              }),
              const SizedBox(height: AppSpacing.xl),

              // Favorites section
              const SectionHeader(
                title: 'Favorites',
                subtitle: 'Your saved OCR scans.',
              ),
              const SizedBox(height: AppSpacing.md),
              _FavoritesSection(),
              const SizedBox(height: AppSpacing.xl),

              // History section
              const SectionHeader(
                title: 'History',
                subtitle: 'Your recent OCR scans.',
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

/// Premium scanner card with scan actions.
class _ScannerCard extends GetView<OcrController> {
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
            AppColors.categoryOcr.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.medium,
        border: Border.all(
          color: AppColors.categoryOcr.withValues(alpha: 0.3),
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
                  AppColors.categoryOcr,
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Title
          Text(
            'Scan & Extract Text',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Description
          Text(
            'Turn photos, documents, notes, and printed pages '
            'into editable text instantly.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Action buttons
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Scan Document',
                  color: AppColors.categoryOcr,
                  onTap: controller.captureImage,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Import Image',
                  color: AppColors.primary,
                  onTap: controller.pickImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Privacy note
          Row(
            children: <Widget>[
              const Icon(
                Icons.shield_outlined,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Text is processed on your device whenever possible.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
class _UsageBanner extends GetView<OcrController> {
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
                color: AppColors.categoryOcr,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Unlimited OCR scans',
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

/// Image preview with scan button.
class _ImagePreviewCard extends GetView<OcrController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Image.file(
              File(controller.imagePath.value),
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  height: 240,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, size: 48),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Actions
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionButton(
                  icon: Icons.document_scanner_rounded,
                  label: 'Scan',
                  color: AppColors.categoryOcr,
                  onTap: controller.processImage,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Retake',
                  color: AppColors.grey500,
                  onTap: controller.pickImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Processing state with animated indicator.
class _ProcessingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          children: <Widget>[
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Extracting text...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Analyzing your document on-device.',
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

/// Result card with extracted text editor and actions.
class _ResultCard extends GetView<OcrController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Result card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppShadows.soft,
              border: Border.all(
                color: AppColors.categoryOcr.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.document_scanner_rounded,
                      size: 20,
                      color: AppColors.categoryOcr,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Extracted Text',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.save_alt_rounded,
                        size: 20,
                        color: AppColors.categoryOcr,
                      ),
                      onPressed: controller.saveResult,
                      tooltip: 'Save to history',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Text editor
                TextField(
                  controller: TextEditingController(
                    text: controller.extractedText.value,
                  ),
                  maxLines: 10,
                  minLines: 5,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
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
                icon: Icons.translate_rounded,
                label: 'Translate',
                onTap: controller.sendToTranslator,
              ),
              _ActionChip(
                icon: Icons.record_voice_over_rounded,
                label: 'Text → Audio',
                onTap: controller.sendToTts,
              ),
              _ActionChip(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Text → PDF',
                onTap: controller.sendToPdf,
              ),
              _ActionChip(
                icon: Icons.file_download_rounded,
                label: 'Export TXT',
                onTap: controller.exportTxt,
              ),
              _ActionChip(
                icon: Icons.clear_rounded,
                label: 'Reset',
                color: AppColors.error,
                onTap: controller.reset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Error state card.
class _ErrorCard extends GetView<OcrController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'OCR Processing Failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Obx(
              () => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _RetryButton(
                  label: 'Try Again',
                  onTap: controller.processImage,
                ),
                const SizedBox(width: AppSpacing.md),
                _RetryButton(
                  label: 'Choose Another',
                  onTap: controller.pickImage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Retry button.
class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.categoryOcr,
        side: BorderSide(color: AppColors.categoryOcr.withValues(alpha: 0.5)),
      ),
      child: Text(label),
    );
  }
}

/// Favorites section.
class _FavoritesSection extends GetView<OcrController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextField(
            onChanged: controller.onFavoriteSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search favorites...',
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
        const SizedBox(height: AppSpacing.md),
        // Favorites list
        Obx(
          () {
            final List<OcrHistoryEntry> entries = controller.filteredFavorites;
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_rounded,
                title: 'No favorites yet.',
                description: 'Your saved OCR scans will appear here.',
                iconColor: AppColors.grey400,
              );
            }

            return Column(
              children: <Widget>[
                for (int i = 0; i < entries.length; i++) ...<Widget>[
                  OcrHistoryTile(
                    entry: entries[i],
                    onToggleFavorite: () =>
                        controller.toggleFavorite(entries[i]),
                    onDelete: () =>
                        controller.deleteHistoryEntry(entries[i].id),
                  ),
                  if (i < entries.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// History section.
class _HistorySection extends GetView<OcrController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: TextField(
            onChanged: controller.onHistorySearchChanged,
            decoration: InputDecoration(
              hintText: 'Search history...',
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
        const SizedBox(height: AppSpacing.md),
        // History list
        Obx(
          () {
            final List<OcrHistoryEntry> entries = controller.filteredHistory;
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No scans yet.',
                description:
                    'Scan a document or import an image to get started.',
                iconColor: AppColors.grey400,
              );
            }

            return Column(
              children: <Widget>[
                for (int i = 0; i < entries.length; i++) ...<Widget>[
                  OcrHistoryTile(
                    entry: entries[i],
                    onToggleFavorite: () =>
                        controller.toggleFavorite(entries[i]),
                    onDelete: () =>
                        controller.deleteHistoryEntry(entries[i].id),
                  ),
                  if (i < entries.length - 1)
                    const SizedBox(height: AppSpacing.sm),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Action button for scanner card.
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

/// Small action chip button.
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
    final Color accent = color ?? AppColors.categoryOcr;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
