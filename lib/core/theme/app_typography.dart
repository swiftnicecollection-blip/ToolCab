import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale for the ToolCab design system.
///
/// Uses Poppins for headings and Inter for body text,
/// providing a premium, modern, readable experience.
abstract final class AppTypography {
  /// Display — largest heading, used for splash & empty states.
  static TextTheme get display => GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 44,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.2,
        ),
      );

  /// Headline — prominent section titles.
  static TextTheme get headline => GoogleFonts.poppinsTextTheme().copyWith(
        headlineLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.35,
        ),
      );

  /// Title — card titles, app bar titles.
  static TextTheme get title => GoogleFonts.poppinsTextTheme().copyWith(
        titleLarge: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
        ),
      );

  /// Body — primary reading text.
  static TextTheme get body => GoogleFonts.interTextTheme().copyWith(
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          height: 1.45,
        ),
      );

  /// Label — buttons, chips, form labels.
  static TextTheme get label => GoogleFonts.interTextTheme().copyWith(
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          height: 1.4,
        ),
      );

  /// Complete [TextTheme] merging all scales.
  static TextTheme get textTheme => GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: display.displayLarge,
        displayMedium: display.displayMedium,
        displaySmall: display.displaySmall,
        headlineLarge: headline.headlineLarge,
        headlineMedium: headline.headlineMedium,
        headlineSmall: headline.headlineSmall,
        titleLarge: title.titleLarge,
        titleMedium: title.titleMedium,
        titleSmall: title.titleSmall,
        bodyLarge: body.bodyLarge,
        bodyMedium: body.bodyMedium,
        bodySmall: body.bodySmall,
        labelLarge: label.labelLarge,
        labelMedium: label.labelMedium,
        labelSmall: label.labelSmall,
      );

  /// Button text style.
  static TextStyle get buttonText =>
      const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3);

  /// Navigation bar label style.
  static TextStyle get navigationLabel =>
      const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.2);
}
