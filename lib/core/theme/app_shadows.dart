import 'package:flutter/material.dart';

/// Shadow system for the ToolCab design system.
///
/// Provides soft, premium elevation shadows used across cards,
/// buttons, sheets, and floating elements.
abstract final class AppShadows {
  /// Soft shadow for small cards and subtle surfaces.
  static List<BoxShadow> get soft => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Medium shadow for standard cards and elevated elements.
  static List<BoxShadow> get medium => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Large shadow for floating elements, FABs, and modals.
  static List<BoxShadow> get large => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ];

  /// Colored shadow for primary buttons and brand elements.
  static List<BoxShadow> primary(Color color) => <BoxShadow>[
        BoxShadow(
          color: color.withValues(alpha: 0.30),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: color.withValues(alpha: 0.12),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
}
