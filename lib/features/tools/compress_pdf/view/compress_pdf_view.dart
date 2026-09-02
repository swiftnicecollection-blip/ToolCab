import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/feedback/error_state.dart';
import '../controller/compress_pdf_controller.dart';
import '../data/models/compress_models.dart';

/// Compress PDFs main screen.
class CompressPdfView extends GetView<CompressPdfController> {
  const CompressPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress PDF'),
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
      case CompressPdfState.idle:
        return _buildIdle(context);
      case CompressPdfState.analyzing:
        return const _ProcessingView(operation: 'Analyzing PDF...');
      case CompressPdfState.ready:
        return _buildReady(context);
      case CompressPdfState.processing:
        return const _ProcessingView(operation: 'Compressing PDF...');
      case CompressPdfState.success:
        return _buildSuccess(context);
      case CompressPdfState.notReduced:
        return _buildNotReduced(context);
      case CompressPdfState.error:
        return ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.reset,
        );
      case CompressPdfState.cancelled:
        return EmptyState(
          icon: Icons.cancel_outlined,
          title: 'Compression Cancelled',
          description: 'The compression was cancelled. No changes were saved.',
          actionLabel: 'Start Over',
          onActionTap: controller.reset,
          iconColor: AppColors.warning,
        );
      case CompressPdfState.selecting:
      case CompressPdfState.configuring:
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
            icon: Icons.compress_rounded,
            title: 'No PDF selected',
            description: 'Choose a PDF to start compressing.',
            iconColor: AppColors.grey400,
          ),
        ],
      ),
    );
  }

  /// Builds the ready state with PDF info and compression settings.
  Widget _buildReady(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PdfInfoCard(),
          const SizedBox(height: AppSpacing.xl),
          _CompressionLevelSelector(),
          const SizedBox(height: AppSpacing.xl),
          _OutputNameField(),
          const SizedBox(height: AppSpacing.xl),
          _ActionButtons(),
        ],
      ),
    );
  }

  /// Builds the success screen.
  Widget _buildSuccess(BuildContext context) {
    return _SuccessView();
  }

  /// Builds the not-reduced screen.
  Widget _buildNotReduced(BuildContext context) {
    return _NotReducedView();
  }
}

/// Hero card for PDF selection.
class _HeroCard extends GetView<CompressPdfController> {
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
              Icons.compress_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Reduce PDF Size',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Make your PDF smaller while preserving the best possible quality.',
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
class _PdfInfoCard extends GetView<CompressPdfController> {
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
                    '${controller.selectedFileSize.value > 0 ? _formatSize(controller.selectedFileSize.value) : 'Size unavailable'} • '
                    '${controller.pageCount.value} pages',
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

/// Compression level selector.
class _CompressionLevelSelector extends GetView<CompressPdfController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Compression Level',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _LevelOption(
            level: CompressionLevel.low,
            icon: Icons.high_quality_rounded,
            recommended: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _LevelOption(
            level: CompressionLevel.medium,
            icon: Icons.balance_rounded,
            recommended: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          const _LevelOption(
            level: CompressionLevel.high,
            icon: Icons.compress_rounded,
            recommended: false,
          ),
        ],
      ),
    );
  }
}

/// Single compression level option.
class _LevelOption extends GetView<CompressPdfController> {
  const _LevelOption({
    required this.level,
    required this.icon,
    required this.recommended,
  });

  final CompressionLevel level;
  final IconData icon;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final CompressionSettings settings = level == CompressionLevel.low
        ? const CompressionSettings(level: CompressionLevel.low)
        : level == CompressionLevel.medium
            ? const CompressionSettings(level: CompressionLevel.medium)
            : const CompressionSettings(level: CompressionLevel.high);

    return Obx(
      () {
        final bool selected = controller.settings.value.level == level;
        return InkWell(
          onTap: () => controller.setCompressionLevel(level),
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
                      Row(
                        children: <Widget>[
                          Text(
                            settings.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (recommended) ...<Widget>[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                'Recommended',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        settings.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
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
      },
    );
  }
}

/// Output filename field.
class _OutputNameField extends GetView<CompressPdfController> {
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
            hintText: 'ToolCab_Compressed_2026-08-13.pdf',
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
class _ActionButtons extends GetView<CompressPdfController> {
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
              onPressed: controller.startCompression,
              icon: const Icon(Icons.compress_rounded, size: 20),
              label: const Text('Compress PDF'),
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
                Icons.compress_rounded,
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
              'Optimizing your document...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            TextButton.icon(
              onPressed: () =>
                  Get.find<CompressPdfController>().cancelOperation(),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success view with comparison.
class _SuccessView extends GetView<CompressPdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CompressionResult? result = controller.currentResult.value;
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
                    'PDF Compressed Successfully',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    result.compressedFileName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Comparison
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _ComparisonItem(
                          label: 'Original',
                          value: result.formattedOriginalSize,
                          color: AppColors.grey600,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: _ComparisonItem(
                          label: 'Compressed',
                          value: result.formattedCompressedSize,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Saved ${result.formattedBytesSaved}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '${result.compressionPercent.toStringAsFixed(1)}% smaller',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.success),
                        ),
                      ],
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
              onTap: controller.openCompressedPdf,
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              color: AppColors.info,
              onTap: controller.shareCompressedPdf,
            ),
            const SizedBox(height: AppSpacing.md),
            Obx(
              () => _ActionButton(
                icon: controller.currentResult.value?.isFavorite == true
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: controller.currentResult.value?.isFavorite == true
                    ? 'Favorited'
                    : 'Favorite',
                color: controller.currentResult.value?.isFavorite == true
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
              icon: Icons.refresh_rounded,
              label: 'Compress Another',
              color: AppColors.categoryPdf,
              onTap: controller.reset,
            ),
          ],
        ),
      );
    });
  }
}

/// Comparison item.
class _ComparisonItem extends StatelessWidget {
  const _ComparisonItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

/// Not-reduced view.
class _NotReducedView extends GetView<CompressPdfController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CompressionResult? result = controller.currentResult.value;
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
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: AppShadows.medium,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 36,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'This PDF could not be reduced further.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Original: ${result.formattedOriginalSize} • '
                    'Compressed: ${result.formattedCompressedSize}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _ActionButton(
              icon: Icons.compress_rounded,
              label: 'Try Higher Compression',
              color: AppColors.categoryPdf,
              onTap: () {
                controller.setCompressionLevel(CompressionLevel.high);
                controller.startCompression();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionButton(
              icon: Icons.refresh_rounded,
              label: 'Keep Original',
              color: AppColors.grey600,
              onTap: controller.reset,
            ),
          ],
        ),
      );
    });
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
