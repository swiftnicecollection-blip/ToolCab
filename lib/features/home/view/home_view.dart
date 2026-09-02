import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/feedback/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../controller/home_controller.dart';
import '../widgets/animated_bottom_navigation.dart';
import '../widgets/dashboard_feature_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/home_hero_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_file_tile.dart';

/// Home dashboard — the heart of the ToolCab application.
///
/// Features:
/// - Animated header with greeting and date
/// - Premium search bar
/// - Hero section with branding
/// - AI & Language tools
/// - Productivity tools
/// - PDF Tools
/// - Recent files with empty state
/// - Animated bottom navigation
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Header
            const DashboardHeader(),
            const SizedBox(height: AppSpacing.lg),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Hero section
                    const HomeHeroCard(),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick actions
                    _QuickActionsSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // AI & Language
                    const SectionHeader(
                      title: 'AI & Language',
                      subtitle: 'Smart productivity powered by AI.',
                      icon: Icons.auto_awesome_rounded,
                      iconColor: AppColors.categoryAi,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _AiToolsSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // Productivity
                    const SectionHeader(
                      title: 'Productivity',
                      subtitle: 'Everyday tools for everyone.',
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.categoryCalendar,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _UtilitiesSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // PDF Tools
                    SectionHeader(
                      title: 'PDF Tools',
                      subtitle: 'Powerful document management.',
                      icon: Icons.picture_as_pdf_rounded,
                      iconColor: AppColors.categoryPdf,
                      actionLabel: 'View All',
                      onActionTap: () => Get.toNamed(AppRoutes.pdfDashboard),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PdfToolsSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // Recent files
                    const SectionHeader(
                      title: 'Recent Files',
                      subtitle: 'Your recently accessed documents.',
                      icon: Icons.folder_open_rounded,
                      iconColor: AppColors.grey500,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _RecentFilesSection(),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            const AnimatedBottomNavigation(),
          ],
        ),
      ),
    );
  }
}

/// Quick actions horizontal scroll row.
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: <Widget>[
          QuickActionCard(
            icon: Icons.document_scanner_outlined,
            label: 'Scan',
            color: AppColors.categoryOcr,
            onTap: () => Get.toNamed(AppRoutes.imageOcr),
          ),
          QuickActionCard(
            icon: Icons.translate_rounded,
            label: 'Translate',
            color: AppColors.categoryTranslation,
            onTap: () => Get.toNamed(AppRoutes.translator),
          ),
          QuickActionCard(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Create PDF',
            color: AppColors.categoryPdf,
            onTap: () => Get.toNamed(AppRoutes.textToPdf),
          ),
          QuickActionCard(
            icon: Icons.mic_none_rounded,
            label: 'Speech to Text',
            color: AppColors.categorySpeech,
            onTap: () => Get.toNamed(AppRoutes.speechToText),
          ),
          QuickActionCard(
            icon: Icons.record_voice_over_outlined,
            label: 'Text to Speech',
            color: AppColors.categorySpeech,
            onTap: () => Get.toNamed(AppRoutes.textToSpeech),
          ),
          QuickActionCard(
            icon: Icons.qr_code_scanner_rounded,
            label: 'QR Scanner',
            color: AppColors.categoryQr,
            onTap: () => Get.toNamed(AppRoutes.qrScanner),
          ),
        ],
      ),
    );
  }
}

/// AI & Language tools section with large feature cards.
class _AiToolsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final double horizontalPadding = ResponsiveUtils.screenPadding(context);

    final List<Widget> cards = <Widget>[
      DashboardFeatureCard(
        icon: Icons.record_voice_over_rounded,
        title: 'Text → Audio',
        description: 'Turn written text into natural speech.',
        color: AppColors.categorySpeech,
        onTap: () => Get.toNamed(AppRoutes.textToSpeech),
      ),
      DashboardFeatureCard(
        icon: Icons.mic_rounded,
        title: 'Audio → Text',
        description: 'Convert speech into editable text.',
        color: AppColors.categorySpeech,
        onTap: () => Get.toNamed(AppRoutes.speechToText),
      ),
      DashboardFeatureCard(
        icon: Icons.translate_rounded,
        title: 'Language Translator',
        description: 'Translate text across supported languages.',
        color: AppColors.categoryTranslation,
        onTap: () => Get.toNamed(AppRoutes.translator),
      ),
      DashboardFeatureCard(
        icon: Icons.document_scanner_rounded,
        title: 'Image → Text (OCR)',
        description: 'Extract text from images.',
        color: AppColors.categoryOcr,
        onTap: () => Get.toNamed(AppRoutes.imageOcr),
      ),
    ];

    if (isTablet) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.2,
          children: cards,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < cards.length; i++) ...<Widget>[
            cards[i],
            if (i < cards.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

/// PDF Tools section with compact cards.
class _PdfToolsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final double horizontalPadding = ResponsiveUtils.screenPadding(context);

    final List<Widget> cards = <Widget>[
      _PdfToolCard(
        icon: Icons.note_add_outlined,
        label: 'Text → PDF',
        color: AppColors.categoryPdf,
        onTap: () => Get.toNamed(AppRoutes.textToPdf),
      ),
      _PdfToolCard(
        icon: Icons.notes_rounded,
        label: 'PDF → Text',
        color: AppColors.categoryPdf,
        onTap: () => Get.toNamed(AppRoutes.pdfToText),
      ),
      _PdfToolCard(
        icon: Icons.merge_type_rounded,
        label: 'Merge PDFs',
        color: AppColors.categoryPdf,
        onTap: () => Get.toNamed(AppRoutes.mergePdf),
      ),
      _PdfToolCard(
        icon: Icons.content_cut_rounded,
        label: 'Split PDFs',
        color: AppColors.categoryPdf,
        onTap: () => Get.toNamed(AppRoutes.splitPdf),
      ),
      _PdfToolCard(
        icon: Icons.compress_rounded,
        label: 'Compress PDF',
        color: AppColors.categoryPdf,
        onTap: () => Get.toNamed(AppRoutes.compressPdf),
      ),
    ];

    if (isTablet) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.4,
          children: cards,
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        children: cards,
      ),
    );
  }
}

/// Compact PDF tool card.
class _PdfToolCard extends StatefulWidget {
  const _PdfToolCard({
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
  State<_PdfToolCard> createState() => _PdfToolCardState();
}

class _PdfToolCardState extends State<_PdfToolCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 120,
          margin: const EdgeInsets.only(right: AppSpacing.md),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

/// Utilities section with QR Scanner and Calendar cards.
class _UtilitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = ResponsiveUtils.screenPadding(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _UtilityCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'QR Scanner',
              description: 'Scan QR codes instantly.',
              color: AppColors.categoryQr,
              onTap: () => Get.toNamed(AppRoutes.qrScanner),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _UtilityCard(
              icon: Icons.calendar_month_rounded,
              title: 'Calendar',
              description: 'Organize your events and schedule.',
              color: AppColors.categoryCalendar,
              onTap: () => Get.toNamed(AppRoutes.calendar),
            ),
          ),
        ],
      ),
    );
  }
}

/// Utility card with icon, title, and description.
class _UtilityCard extends StatelessWidget {
  const _UtilityCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(
                  alpha: 0.3,
                ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    color.withValues(alpha: 0.20),
                    color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent files section with empty state.
class _RecentFilesSection extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isLoadingRecentFiles.value) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }

        if (controller.recentFiles.isEmpty) {
          return const EmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No recent files yet.',
            description:
                'Files you create or process will appear here for quick access.',
            iconColor: AppColors.grey400,
          );
        }

        return Column(
          children: <Widget>[
            for (int i = 0; i < controller.recentFiles.length; i++) ...<Widget>[
              RecentFileTile(file: controller.recentFiles[i]),
              if (i < controller.recentFiles.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}
