import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../controller/text_to_pdf_controller.dart';
import '../data/models/document_model.dart';

/// Text → PDF document editor screen.
class TextToPdfView extends GetView<TextToPdfController> {
  const TextToPdfView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.documentTitle.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _showSettingsSheet(context),
            tooltip: 'Document Settings',
          ),
          IconButton(
            icon: const Icon(Icons.record_voice_over_rounded),
            onPressed: controller.sendToTts,
            tooltip: 'Text → Audio',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Formatting toolbar
            _FormattingToolbar(),
            const Divider(height: 1),
            // Editor
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: TextField(
                  controller: controller.textController,
                  maxLines: null,
                  minLines: 10,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your document...',
                    border: InputBorder.none,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: controller.fontSize.value,
                      ),
                ),
              ),
            ),
            // Bottom bar
            _BottomBar(),
          ],
        ),
      ),
    );
  }

  /// Shows the document settings bottom sheet.
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _SettingsSheet();
      },
    );
  }
}

/// Formatting toolbar.
class _FormattingToolbar extends GetView<TextToPdfController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: <Widget>[
          // Font size
          Obx(
            () => PopupMenuButton<double>(
              icon: Text(
                '${controller.fontSize.value.round()}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              tooltip: 'Font Size',
              onSelected: (double size) => controller.fontSize.value = size,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<double>>[
                for (final double size in <double>[10, 12, 14, 16, 18, 20, 24])
                  PopupMenuItem<double>(
                    value: size,
                    child: Text('$size pt'),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Alignment
          Obx(
            () => PopupMenuButton<PdfTextAlign>(
              icon: Icon(
                switch (controller.textAlign.value) {
                  PdfTextAlign.left => Icons.format_align_left_rounded,
                  PdfTextAlign.center => Icons.format_align_center_rounded,
                  PdfTextAlign.right => Icons.format_align_right_rounded,
                  PdfTextAlign.justify => Icons.format_align_justify_rounded,
                },
                size: 20,
              ),
              tooltip: 'Text Alignment',
              onSelected: (PdfTextAlign align) =>
                  controller.textAlign.value = align,
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<PdfTextAlign>>[
                const PopupMenuItem<PdfTextAlign>(
                  value: PdfTextAlign.left,
                  child: Text('Left'),
                ),
                const PopupMenuItem<PdfTextAlign>(
                  value: PdfTextAlign.center,
                  child: Text('Center'),
                ),
                const PopupMenuItem<PdfTextAlign>(
                  value: PdfTextAlign.right,
                  child: Text('Right'),
                ),
                const PopupMenuItem<PdfTextAlign>(
                  value: PdfTextAlign.justify,
                  child: Text('Justify'),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Word/char count
          Obx(
            () => Text(
              '${controller.wordCount} words',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom action bar.
class _BottomBar extends GetView<TextToPdfController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: AppShadows.soft,
      ),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed:
                controller.isGenerating.value ? null : controller.generatePdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.categoryPdf,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.categoryPdf.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: controller.isGenerating.value
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.picture_as_pdf_rounded, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text('Generate PDF'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Document settings bottom sheet.
class _SettingsSheet extends GetView<TextToPdfController> {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Document Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Page size
          _SettingSection(
            label: 'Page Size',
            child: Obx(
              () => SegmentedButton<PdfPageSize>(
                segments: const <ButtonSegment<PdfPageSize>>[
                  ButtonSegment<PdfPageSize>(
                    value: PdfPageSize.a4,
                    label: Text('A4'),
                  ),
                  ButtonSegment<PdfPageSize>(
                    value: PdfPageSize.letter,
                    label: Text('Letter'),
                  ),
                  ButtonSegment<PdfPageSize>(
                    value: PdfPageSize.legal,
                    label: Text('Legal'),
                  ),
                ],
                selected: <PdfPageSize>{controller.pageSize.value},
                onSelectionChanged: (Set<PdfPageSize> selection) {
                  controller.pageSize.value = selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Orientation
          _SettingSection(
            label: 'Orientation',
            child: Obx(
              () => SegmentedButton<PdfOrientation>(
                segments: const <ButtonSegment<PdfOrientation>>[
                  ButtonSegment<PdfOrientation>(
                    value: PdfOrientation.portrait,
                    icon: Icon(Icons.portrait_rounded),
                    label: Text('Portrait'),
                  ),
                  ButtonSegment<PdfOrientation>(
                    value: PdfOrientation.landscape,
                    icon: Icon(Icons.landscape_rounded),
                    label: Text('Landscape'),
                  ),
                ],
                selected: <PdfOrientation>{controller.orientation.value},
                onSelectionChanged: (Set<PdfOrientation> selection) {
                  controller.orientation.value = selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Margins
          _SettingSection(
            label: 'Margins',
            child: Obx(
              () => SegmentedButton<PdfMargin>(
                segments: const <ButtonSegment<PdfMargin>>[
                  ButtonSegment<PdfMargin>(
                    value: PdfMargin.small,
                    label: Text('Small'),
                  ),
                  ButtonSegment<PdfMargin>(
                    value: PdfMargin.normal,
                    label: Text('Normal'),
                  ),
                  ButtonSegment<PdfMargin>(
                    value: PdfMargin.large,
                    label: Text('Large'),
                  ),
                ],
                selected: <PdfMargin>{controller.margin.value},
                onSelectionChanged: (Set<PdfMargin> selection) {
                  controller.margin.value = selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Line spacing
          _SettingSection(
            label: 'Line Spacing',
            child: Obx(
              () => SegmentedButton<PdfLineSpacing>(
                segments: const <ButtonSegment<PdfLineSpacing>>[
                  ButtonSegment<PdfLineSpacing>(
                    value: PdfLineSpacing.compact,
                    label: Text('Compact'),
                  ),
                  ButtonSegment<PdfLineSpacing>(
                    value: PdfLineSpacing.normal,
                    label: Text('Normal'),
                  ),
                  ButtonSegment<PdfLineSpacing>(
                    value: PdfLineSpacing.relaxed,
                    label: Text('Relaxed'),
                  ),
                ],
                selected: <PdfLineSpacing>{controller.lineSpacing.value},
                onSelectionChanged: (Set<PdfLineSpacing> selection) {
                  controller.lineSpacing.value = selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Page numbers
          _SettingSection(
            label: 'Page Numbers',
            child: Obx(
              () => SegmentedButton<PdfPageNumberPosition>(
                segments: const <ButtonSegment<PdfPageNumberPosition>>[
                  ButtonSegment<PdfPageNumberPosition>(
                    value: PdfPageNumberPosition.off,
                    label: Text('Off'),
                  ),
                  ButtonSegment<PdfPageNumberPosition>(
                    value: PdfPageNumberPosition.bottomCenter,
                    label: Text('Center'),
                  ),
                  ButtonSegment<PdfPageNumberPosition>(
                    value: PdfPageNumberPosition.bottomRight,
                    label: Text('Right'),
                  ),
                ],
                selected: <PdfPageNumberPosition>{
                  controller.pageNumbers.value,
                },
                onSelectionChanged: (Set<PdfPageNumberPosition> selection) {
                  controller.pageNumbers.value = selection.first;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Done button
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: Get.back,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Setting section with label and control.
class _SettingSection extends StatelessWidget {
  const _SettingSection({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}
