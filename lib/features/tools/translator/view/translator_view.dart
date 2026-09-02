import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../controller/translator_controller.dart';
import '../data/models/translation_history_entry.dart';
import '../data/models/translator_language.dart';
import '../widgets/translation_history_tile.dart';

/// Language Translator screen.
///
/// Features:
/// - Source and target language selectors with swap
/// - Auto language detection
/// - Translation input and result cards
/// - Quick actions (copy, share, favorite, speak, clear)
/// - History and favorites with search
class TranslatorView extends GetView<TranslatorController> {
  const TranslatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Translator'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Get.snackbar(
              'History',
              'Scroll down to view your translation history.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            ),
            tooltip: 'History',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: () => Get.snackbar(
              'Favorites',
              'Scroll down to view your favorite translations.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 2),
            ),
            tooltip: 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Get.toNamed(AppRoutes.help),
            tooltip: 'Help',
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
              // Header
              _Header(),
              const SizedBox(height: AppSpacing.xl),

              // Language selectors
              _LanguageSelectors(),
              const SizedBox(height: AppSpacing.xl),

              // Translation input
              _TranslationInput(),
              const SizedBox(height: AppSpacing.xl),

              // Translate button
              _TranslateButton(),
              const SizedBox(height: AppSpacing.xl),

              // Result card
              _ResultCard(),
              const SizedBox(height: AppSpacing.xl),

              // Quick actions
              _QuickActions(),
              const SizedBox(height: AppSpacing.xl),

              // Favorites section
              const SectionHeader(
                title: 'Favorites',
                subtitle: 'Your saved translations.',
              ),
              const SizedBox(height: AppSpacing.md),
              _FavoritesSection(),
              const SizedBox(height: AppSpacing.xl),

              // History section
              const SectionHeader(
                title: 'History',
                subtitle: 'Your recent translations.',
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

/// Header with illustration and headline.
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          // Illustration
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.categoryTranslation,
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.categoryTranslation.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.translate_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          // Headline
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Translate Instantly',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Communicate in multiple languages with AI-powered translation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Source and target language selectors with swap button.
class _LanguageSelectors extends GetView<TranslatorController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          // Source language
          Expanded(
            child: _LanguageSelector(
              label: 'From',
              languageCode: controller.sourceLanguageCode.value,
              onTap: () => _showLanguagePicker(
                context,
                isSource: true,
              ),
            ),
          ),
          // Swap button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: GestureDetector(
              onTap: controller.swapLanguages,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
          // Target language
          Expanded(
            child: _LanguageSelector(
              label: 'To',
              languageCode: controller.targetLanguageCode.value,
              onTap: () => _showLanguagePicker(
                context,
                isSource: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the language picker bottom sheet.
  void _showLanguagePicker(BuildContext context, {required bool isSource}) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  isSource
                      ? 'Select Source Language'
                      : 'Select Target Language',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (isSource)
                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text('Auto Detect'),
                  trailing: controller.autoDetect.value
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    controller.enableAutoDetect();
                    Navigator.of(context).pop();
                  },
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.languages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final TranslatorLanguage lang = controller.languages[index];
                    final bool isSelected = isSource
                        ? lang.code == controller.sourceLanguageCode.value
                        : lang.code == controller.targetLanguageCode.value;
                    return ListTile(
                      leading: Text(
                        lang.flagEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(lang.name),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        if (isSource) {
                          controller.selectSourceLanguage(lang.code);
                        } else {
                          controller.selectTargetLanguage(lang.code);
                        }
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Single language selector button.
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.label,
    required this.languageCode,
    required this.onTap,
  });

  final String label;
  final String languageCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TranslatorLanguage lang = TranslatorLanguage.fromCode(languageCode);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                Text(
                  lang.flagEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    lang.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Translation input card.
class _TranslationInput extends GetView<TranslatorController> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Auto-detect indicator
          Obx(
            () => controller.autoDetect.value
                ? Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          controller.detectedLanguageCode.value.isEmpty
                              ? 'Auto-detect enabled'
                              : 'Detected: ${controller.detectedLanguage.name}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Text field
          TextField(
            controller: controller.sourceController,
            maxLines: 6,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              border: InputBorder.none,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Counters
          Obx(
            () => Row(
              children: <Widget>[
                Icon(
                  Icons.text_fields_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${controller.charCount.value} chars',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.abc_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${controller.wordCount.value} words',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Translate button.
class _TranslateButton extends GetView<TranslatorController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Obx(
        () => SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.translate,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.categoryTranslation,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.categoryTranslation.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: controller.isLoading.value
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
                      Icon(Icons.translate_rounded, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      Text('Translate'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Translation result card.
class _ResultCard extends GetView<TranslatorController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final String result = controller.translatedText.value;
        if (result.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.categoryTranslation.withValues(alpha: 0.10),
                AppColors.secondary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppShadows.soft,
            border: Border.all(
              color: AppColors.categoryTranslation.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.translate_rounded,
                    size: 20,
                    color: AppColors.categoryTranslation,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Translation',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Translated text
              Text(
                result,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Quick action buttons.
class _QuickActions extends GetView<TranslatorController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          _ActionChip(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: controller.copyTranslation,
          ),
          _ActionChip(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: controller.shareTranslation,
          ),
          _ActionChip(
            icon: Icons.favorite_rounded,
            label: 'Favorite',
            onTap: controller.favoriteCurrentTranslation,
          ),
          _ActionChip(
            icon: Icons.record_voice_over_rounded,
            label: 'Text → Audio',
            onTap: controller.sendToTts,
          ),
          _ActionChip(
            icon: Icons.clear_rounded,
            label: 'Clear',
            color: AppColors.error,
            onTap: controller.clearAll,
          ),
        ],
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
    final Color accent = color ?? AppColors.categoryTranslation;
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

/// Favorites section.
class _FavoritesSection extends GetView<TranslatorController> {
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
            final List<TranslationHistoryEntry> entries =
                controller.filteredFavorites;
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_rounded,
                title: 'No favorites yet.',
                description:
                    'Tap the favorite button to save translations here.',
                iconColor: AppColors.grey400,
              );
            }

            return Column(
              children: <Widget>[
                for (int i = 0; i < entries.length; i++) ...<Widget>[
                  TranslationHistoryTile(
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
class _HistorySection extends GetView<TranslatorController> {
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
            final List<TranslationHistoryEntry> entries =
                controller.filteredHistory;
            if (entries.isEmpty) {
              return const EmptyState(
                icon: Icons.history_rounded,
                title: 'No translations yet.',
                description:
                    'Your translations will appear here automatically.',
                iconColor: AppColors.grey400,
              );
            }

            return Column(
              children: <Widget>[
                for (int i = 0; i < entries.length; i++) ...<Widget>[
                  TranslationHistoryTile(
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
