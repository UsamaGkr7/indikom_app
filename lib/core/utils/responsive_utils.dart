import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints (Material Design inspired)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  // Reusable padding/margin
  static EdgeInsets horizontalPadding(BuildContext context, bool vertical) {
    if (isDesktop(context)) {
      return EdgeInsets.symmetric(horizontal: 250, vertical: vertical ? 30 : 0);
    }
    if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 50, vertical: vertical ? 15 : 0);
    }
    return EdgeInsets.symmetric(horizontal: 0, vertical: 0);
  }

  // Optional: responsive font size
  static double fontSize(
    BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}
