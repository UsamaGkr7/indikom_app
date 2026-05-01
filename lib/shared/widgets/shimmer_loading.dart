import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../core/theme/app_colors.dart';

class ShimmerLoading {
  /// Shimmer effect for product cards
  static Widget productCard() {
    return Shimmer(
      color: Colors.blue,
      // highlightColor: Colors.grey[200]!,
      colorOpacity: 0.4,
      duration: Duration(seconds: 5),
      direction: ShimmerDirection.fromLTRB(),
      // highlightColor: Colors.grey[200]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer for list items
  static Widget listItem() {
    return Shimmer(
      color: AppColors.cardBackground,
      // highlightColor: Colors.grey[200]!,

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Shimmer for banner carousel
  static Widget banner() {
    return Shimmer(
      color: Colors.black,
      // highlightColor: Colors.grey[200]!,
      colorOpacity: 0.4,
      duration: Duration(seconds: 5),

      direction: ShimmerDirection.fromLTRB(),

      child: Container(
        margin: const EdgeInsets.all(8),
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Shimmer for category cards
  static Widget categoryCard() {
    return Shimmer(
      color: AppColors.cardBackground,
      // highlightColor: Colors.grey[200]!,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: 50,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  /// Shimmer for product detail image
  static Widget productDetailImage() {
    return Shimmer(
      color: AppColors.cardBackground,
      // highlightColor: Colors.grey[200]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Shimmer for text lines
  static Widget textLines({int lines = 3, double height = 12}) {
    return Shimmer(
      color: AppColors.cardBackground,
      // highlightColor: Colors.grey[200]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          lines,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: height,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Shimmer for circular avatar
  static Widget circularAvatar({double size = 50}) {
    return Shimmer(
      color: AppColors.cardBackground,
      // highlightColor: Colors.grey[200]!,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Shimmer for rectangular container
  static Widget container({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Shimmer(
      color: AppColors.cardBackground,
      // highlightColor: Colors.grey[200]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(9.0, 4.0),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ]),
      ),
    );
  }
}
