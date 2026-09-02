import 'package:get/get.dart';

import '../../core/constants/app_routes.dart';
import '../../features/calendar/view/calendar_view.dart';
import '../../features/history/view/history_view.dart';
import '../../features/home/binding/home_binding.dart';
import '../../features/home/view/home_view.dart';
import '../../features/onboarding/binding/onboarding_binding.dart';
import '../../features/onboarding/view/onboarding_view.dart';
import '../../features/settings/view/about_view.dart';
import '../../features/settings/view/help_view.dart';
import '../../features/settings/view/notifications_view.dart';
import '../../features/settings/view/settings_view.dart';
import '../../features/splash/binding/splash_binding.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/tools/compress_pdf/binding/compress_pdf_binding.dart';
import '../../features/tools/compress_pdf/view/compress_pdf_view.dart';
import '../../features/tools/merge_pdf/binding/merge_pdf_binding.dart';
import '../../features/tools/merge_pdf/view/merge_pdf_view.dart';
import '../../features/tools/ocr/binding/ocr_binding.dart';
import '../../features/tools/ocr/view/ocr_view.dart';
import '../../features/tools/pdf/binding/pdf_binding.dart';
import '../../features/tools/pdf/binding/text_to_pdf_binding.dart';
import '../../features/tools/pdf/view/pdf_dashboard_view.dart';
import '../../features/tools/pdf/view/text_to_pdf_view.dart';
import '../../features/tools/pdf_to_text/binding/pdf_to_text_binding.dart';
import '../../features/tools/pdf_to_text/view/pdf_to_text_history_view.dart';
import '../../features/tools/pdf_to_text/view/pdf_to_text_view.dart';
import '../../features/tools/qr_scanner/view/qr_scanner_view.dart';
import '../../features/tools/split_pdf/binding/split_pdf_binding.dart';
import '../../features/tools/split_pdf/view/split_pdf_view.dart';
import '../../features/tools/stt/binding/stt_binding.dart';
import '../../features/tools/stt/view/stt_view.dart';
import '../../features/tools/translator/binding/translator_binding.dart';
import '../../features/tools/translator/view/translator_view.dart';
import '../../features/tools/tts/binding/tts_binding.dart';
import '../../features/tools/tts/view/tts_view.dart';

/// Route table for the ToolCab application.
abstract final class AppPages {
  /// Initial route.
  static const String initial = AppRoutes.splash;

  /// All application routes.
  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    // -------------------------------------------------------------------
    // Core
    // -------------------------------------------------------------------
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),

    // -------------------------------------------------------------------
    // Main
    // -------------------------------------------------------------------
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),

    // -------------------------------------------------------------------
    // Tools
    // -------------------------------------------------------------------
    GetPage<dynamic>(
      name: AppRoutes.textToSpeech,
      page: () => const TtsView(),
      binding: TtsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.speechToText,
      page: () => const SttView(),
      binding: SttBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.translator,
      page: () => const TranslatorView(),
      binding: TranslatorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.imageOcr,
      page: () => const OcrView(),
      binding: OcrBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.pdfDashboard,
      page: () => const PdfDashboardView(),
      binding: PdfBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.textToPdf,
      page: () => const TextToPdfView(),
      binding: TextToPdfBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.pdfToText,
      page: () => const PdfToTextView(),
      binding: PdfToTextBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.pdfToTextHistory,
      page: () => const PdfToTextHistoryView(),
      binding: PdfToTextBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.mergePdf,
      page: () => const MergePdfView(),
      binding: MergePdfBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.splitPdf,
      page: () => const SplitPdfView(),
      binding: SplitPdfBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.compressPdf,
      page: () => const CompressPdfView(),
      binding: CompressPdfBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.qrScanner,
      page: () => const QrScannerView(),
      transition: Transition.rightToLeft,
    ),

    // -------------------------------------------------------------------
    // Utilities
    // -------------------------------------------------------------------
    GetPage<dynamic>(
      name: AppRoutes.calendar,
      page: () => const CalendarView(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      transition: Transition.rightToLeft,
    ),
    // -------------------------------------------------------------------
    // Settings
    // -------------------------------------------------------------------
    GetPage<dynamic>(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.help,
      page: () => const HelpView(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: AppRoutes.about,
      page: () => const AboutView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
