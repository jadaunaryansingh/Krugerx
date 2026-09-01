import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 650 &&
      MediaQuery.sizeOf(context).width < 1100;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktop;
        } else if (constraints.maxWidth >= 650 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Utility for consistent responsive padding
class KrugerPadding {
  /// Base responsive padding around main content blocks
  static EdgeInsets page(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return const EdgeInsets.all(48.0);
    } else if (Responsive.isTablet(context)) {
      return const EdgeInsets.all(32.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }

  /// Responsive padding for the New Tab Page center content
  static EdgeInsets ntp(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 120.0, vertical: 64.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0);
    }
  }
}
