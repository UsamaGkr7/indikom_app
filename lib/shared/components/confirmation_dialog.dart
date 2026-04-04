import 'package:flutter/material.dart';
import '../widgets/app_button.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Confirm Action',
        content: 'Are you sure?',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(cancelText)),
        AppButton(text: confirmText, onPressed: onConfirm),
      ],
    );
  }
}
