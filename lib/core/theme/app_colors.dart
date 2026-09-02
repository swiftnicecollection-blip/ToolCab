import 'package:flutter/material.dart';

/// Centralized color palette for the ToolCab design system.
///
/// All UI colors should be derived from this palette to maintain
/// a consistent, premium brand identity across the application.
abstract final class AppColors {
  /// Primary brand color — deep indigo conveying trust & intelligence.
  static const Color primary = Color(0xFF4F46E5);

  /// Secondary brand color — violet supporting the primary.
  static const Color secondary = Color(0xFF7C3AED);

  /// Accent color — vibrant cyan for highlights & CTAs.
  static const Color accent = Color(0xFF06B6D4);

  /// Success / positive states.
  static const Color success = Color(0xFF10B981);

  /// Warning / caution states.
  static const Color warning = Color(0xFFF59E0B);

  /// Error / destructive states.
  static const Color error = Color(0xFFEF4444);

  /// Info / informational states.
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Neutral / Greys
  // ---------------------------------------------------------------------------

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ---------------------------------------------------------------------------
  // Light Theme Surface Colors
  // ---------------------------------------------------------------------------

  /// Light theme background.
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// Light theme surface (cards, sheets, dialogs).
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light theme surface variant (subtle contrast).
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);

  /// Light theme text primary.
  static const Color lightTextPrimary = Color(0xFF0F172A);

  /// Light theme text secondary.
  static const Color lightTextSecondary = Color(0xFF475569);

  /// Light theme outline / borders.
  static const Color lightOutline = Color(0xFFE2E8F0);

  /// Light theme scaffold background gradient start.
  static const Color lightGradientStart = Color(0xFFEEF2FF);

  /// Light theme scaffold background gradient end.
  static const Color lightGradientEnd = Color(0xFFF8FAFC);

  // ---------------------------------------------------------------------------
  // Dark Theme Surface Colors
  // ---------------------------------------------------------------------------

  /// Dark theme background.
  static const Color darkBackground = Color(0xFF0B1220);

  /// Dark theme surface (cards, sheets, dialogs).
  static const Color darkSurface = Color(0xFF121A2B);

  /// Dark theme surface variant (subtle contrast).
  static const Color darkSurfaceVariant = Color(0xFF1E293B);

  /// Dark theme text primary.
  static const Color darkTextPrimary = Color(0xFFF1F5F9);

  /// Dark theme text secondary.
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  /// Dark theme outline / borders.
  static const Color darkOutline = Color(0xFF1E293B);

  /// Dark theme scaffold background gradient start.
  static const Color darkGradientStart = Color(0xFF0F172A);

  /// Dark theme scaffold background gradient end.
  static const Color darkGradientEnd = Color(0xFF0B1220);

  // ---------------------------------------------------------------------------
  // Feature Category Colors
  // ---------------------------------------------------------------------------

  /// Document tools category color.
  static const Color categoryDocument = Color(0xFF4F46E5);

  /// OCR category color.
  static const Color categoryOcr = Color(0xFF06B6D4);

  /// PDF category color.
  static const Color categoryPdf = Color(0xFFEF4444);

  /// Speech category color.
  static const Color categorySpeech = Color(0xFF8B5CF6);

  /// Translation category color.
  static const Color categoryTranslation = Color(0xFF10B981);

  /// QR category color.
  static const Color categoryQr = Color(0xFFF59E0B);

  /// Calendar category color.
  static const Color categoryCalendar = Color(0xFF3B82F6);

  /// AI category color.
  static const Color categoryAi = Color(0xFFEC4899);

  /// Tools category color.
  static const Color categoryTools = Color(0xFF64748B);
}
