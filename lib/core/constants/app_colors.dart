import 'package:flutter/material.dart';

/// Brand colors for Indikom App (Custom Modern Design)
class AppColors {
  // Primary
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryVariant = Color(0xFF4F46E5);

  // Secondary
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryVariant = Color(0xFF059669);

  // Background
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600

  // Error
  static const Color error = Color(0xFFEF4444); // Red 500

  // Success
  static const Color success = Color(0xFF10B981); // Emerald 500

  // Warning
  static const Color warning = Color(0xFFF59E0B); // Amber 500

  static const MaterialColor primarySwatch =
      MaterialColor(0xFF6366F1, <int, Color>{
        50: Color(0xFFE0E7FF),
        100: Color(0xFFB4C2FF),
        200: Color(0xFF8EA7FF),
        300: Color(0xFF6B91FF),
        400: Color(0xFF4F7CFF),
        500: Color(0xFF6366F1),
        600: Color(0xFF5048E0),
        700: Color(0xFF4338CE),
        800: Color(0xFF3730BC),
        900: Color(0xFF2B256D),
      });
}
