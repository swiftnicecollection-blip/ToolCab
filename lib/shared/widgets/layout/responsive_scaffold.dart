import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

/// Responsive scaffold that constrains content width on large screens.
///
/// On tablets and desktops, content is centered with a maximum width
/// to maintain readability and a premium layout.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.padding,
    this.safeArea = true,
  });

  /// Body content.
  final Widget body;

  /// Optional app bar.
  final PreferredSizeWidget? appBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Background color.
  final Color? backgroundColor;

  /// Padding around the body.
  final EdgeInsetsGeometry? padding;

  /// Whether to apply safe area insets.
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: safeArea,
        bottom: safeArea,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive padding that adapts to the device width.
class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal,
    this.vertical,
  });

  /// Child widget.
  final Widget child;

  /// Horizontal padding.
  final double? horizontal;

  /// Vertical padding.
  final double? vertical;

  @override
  Widget build(BuildContext context) {
    final double h = horizontal ?? ResponsiveUtils.screenPadding(context);
    final double v = vertical ?? AppSpacing.lg;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      child: child,
    );
  }
}
