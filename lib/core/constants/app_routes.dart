/// Central route definitions for the ToolCab application.
abstract final class AppRoutes {
  // -------------------------------------------------------------------
  // Initial & Core
  // -------------------------------------------------------------------
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // -------------------------------------------------------------------
  // Main
  // -------------------------------------------------------------------
  static const String home = '/home';

  // -------------------------------------------------------------------
  // Tools
  // -------------------------------------------------------------------
  static const String textToSpeech = '/tools/tts';
  static const String speechToText = '/tools/stt';
  static const String translator = '/tools/translator';
  static const String imageOcr = '/tools/ocr';
  static const String pdfDashboard = '/tools/pdf';
  static const String textToPdf = '/tools/pdf/text-to-pdf';
  static const String pdfToText = '/tools/pdf/pdf-to-text';
  static const String pdfToTextHistory = '/tools/pdf/pdf-to-text/history';
  static const String mergePdf = '/tools/pdf/merge';
  static const String splitPdf = '/tools/pdf/split';
  static const String compressPdf = '/tools/pdf/compress';
  static const String qrScanner = '/tools/qr-scanner';

  // -------------------------------------------------------------------
  // Utilities
  // -------------------------------------------------------------------
  static const String calendar = '/calendar';
  static const String history = '/history';

  // -------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------
  static const String settings = '/settings';
  static const String notifications = '/settings/notifications';
  static const String help = '/settings/help';
  static const String about = '/settings/about';
}
