import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InputDecorations {
  /// Light Input Decoration Theme
  static InputDecorationTheme get lightInputTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: TextStyle(color: AppColors.textSecondary),
    errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
  );

  /// Dark Input Decoration Theme
  static InputDecorationTheme get darkInputTheme => InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E293B),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade700),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.white60),
    errorStyle: TextStyle(color: AppColors.error, fontSize: 12),
  );
}
