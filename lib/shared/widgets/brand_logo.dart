import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final double fontSize;
  final bool horizontal;

  const BrandLogo({
    super.key,
    this.fontSize = 24,
    this.horizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Indi',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Kom',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      );
    } else {
      // Vertical layout (if needed)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Indi',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            'Kom',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
        ],
      );
    }
  }
}
