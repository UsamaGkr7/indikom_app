import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class ProductCard extends StatelessWidget {
  final String? imageUrl; // ✅ Made nullable
  final String title;
  final String price;
  final String? originalPrice;
  final String? discount;
  final VoidCallback? onTap;
  final int? productId;

  const ProductCard(
      {super.key,
      this.imageUrl, // ✅ Optional now
      required this.title,
      required this.price,
      this.originalPrice,
      this.discount,
      this.onTap,
      this.productId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Hero(
                    tag: 'product_image_${productId ?? title.hashCode}',
                    child: _buildProductImage()),
              ),
            ),

            // Discount Badge
            if (discount != null)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    discount!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        price,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          originalPrice!,
                          style: AppTextStyles.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Helper method to build product image with null handling
  Widget _buildProductImage() {
    // Show placeholder if imageUrl is null or empty
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: AppColors.cardBackground,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: AppColors.textHint,
          ),
        ),
      );
    }

    // Load network image
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: AppColors.cardBackground,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        print('❌ Product image load error: $error');
        print('❌ URL: $url');
        return Container(
          color: AppColors.cardBackground,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 40,
                  color: AppColors.textHint,
                ),
                SizedBox(height: 4),
                Text(
                  'No Image',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
