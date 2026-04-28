import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarHelper {
  /// Show a beautiful animated snackbar with decorative elements
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onActionTap,
    String? actionLabel,
  }) {
    // Determine colors and icon based on type
    final config = _getConfigForType(type);

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: config.contentType,
        color: config.color,
        // ✅ Enable decorative blob design
        inMaterialBanner: false,
        // ✅ Custom styling
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        messageTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      // ✅ Add action button to SnackBar (not content)
      action: onActionTap != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionTap,
            )
          : null,
      duration: duration,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Convenience methods for common snackbar types
  static void success(BuildContext context, String message,
      {String title = 'Success',
      Duration duration = const Duration(seconds: 2)}) {
    show(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.success,
      duration: duration,
    );
  }

  static void error(BuildContext context, String message,
      {String title = 'Error',
      Duration duration = const Duration(seconds: 4)}) {
    show(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.error,
      duration: duration,
    );
  }

  static void warning(BuildContext context, String message,
      {String title = 'Warning',
      Duration duration = const Duration(seconds: 4)}) {
    show(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
    );
  }

  static void info(BuildContext context, String message,
      {String title = 'Info', Duration duration = const Duration(seconds: 4)}) {
    show(
      context: context,
      title: title,
      message: message,
      type: SnackbarType.info,
      duration: duration,
    );
  }

  /// Internal config helper
  static ({ContentType contentType, Color color}) _getConfigForType(
      SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return (contentType: ContentType.success, color: AppColors.success);
      case SnackbarType.error:
        return (contentType: ContentType.failure, color: AppColors.error);
      case SnackbarType.warning:
        return (contentType: ContentType.warning, color: AppColors.warning);
      case SnackbarType.info:
        return (contentType: ContentType.help, color: Colors.grey.shade400);
    }
  }
}
