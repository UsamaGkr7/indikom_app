import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final IconData icon;
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonTap,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.grey.shade400),
        SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 8),
        Text(subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        if (buttonText != null && onButtonTap != null) ...[
          SizedBox(height: 24),
          ElevatedButton(onPressed: onButtonTap, child: Text(buttonText!)),
        ],
      ],
    );
  }
}
