import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/shared/widgets/similar_product_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  String? _selectedColor;
  int _quantity = 1;

  // Sample colors (in real app, this would come from API)
  final List<Map<String, dynamic>> _colors = [
    {'name': 'Green', 'value': '#2D5A4A'},
    {'name': 'Black', 'value': '#1a1a1a'},
    {'name': 'Brown', 'value': '#8B4513'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Product Image Carousel
                _buildImageCarousel(),

                // Product Info
                SliverToBoxAdapter(
                  child: _buildProductInfo(),
                ),

                // Color Selection
                SliverToBoxAdapter(
                  child: _buildColorSelection(),
                ),

                // AR View Button
                SliverToBoxAdapter(
                  child: _buildARViewButton(),
                ),

                // About Product
                SliverToBoxAdapter(
                  child: _buildAboutProduct(),
                ),

                // Technical Specifications
                SliverToBoxAdapter(
                  child: _buildTechnicalSpecs(),
                ),

                // Similar Products
                SliverToBoxAdapter(
                  child: _buildSimilarProducts(),
                ),

                // Bottom spacing for Add to Cart button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),

          // Add to Cart Button
          _buildAddToCartButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: Text(
        context.tr('product_detail'),
        style: AppTextStyles.h3,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            // Cart icon
          },
          icon: const Icon(Icons.shopping_cart_outlined,
              color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildImageCarousel() {
    final images = [widget.product.imageUrl]; // Add more images if available

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 300,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Hero(
                      // ✅ Add Hero widget for smooth image transition
                      tag: 'product_image_${widget.product.id}',
                      child: CachedNetworkImage(
                        imageUrl: images[index] ?? '',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.cardBackground,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.cardBackground,
                          child: const Icon(Icons.image,
                              size: 60, color: AppColors.textHint),
                        ),
                      ),
                    ));
              },
            ),

            // Image counter
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: _selectedImageIndex == index ? 24 : 8,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: _selectedImageIndex == index
                            ? AppColors.primary
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final originalPrice = double.tryParse(widget.product.price) ?? 0;
    final discountedPrice = originalPrice * 0.85; // 15% discount example

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category
          Text(
            widget.product.categoryName ?? context.tr('furniture'),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),

          // Product Name
          Text(
            widget.product.name,
            style: AppTextStyles.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),

          // Price Row
          Row(
            children: [
              Text(
                '\$${originalPrice.toStringAsFixed(0)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${discountedPrice.toStringAsFixed(0)}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '15% OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),

              // Stock Status
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('in_stock'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('colors'),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: _colors.map((color) {
              final isSelected = _selectedColor == color['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color['name'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(
                              int.parse('0x${color['value'].substring(1)}')),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        color['name'],
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildARViewButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // AR View functionality
              },
              icon: const Icon(Icons.view_in_ar, color: AppColors.primary),
              label: Text(context.tr('view_in_your_room')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Share functionality
              },
              icon: const Icon(Icons.share, color: AppColors.primary),
              label: Text(context.tr('share')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutProduct() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('about_the_product'),
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Know more
            },
            child: Row(
              children: [
                Text(
                  context.tr('know_more'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_forward,
                    size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('technical_specifications'),
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildSpecItem(
            context.tr('material_construction'),
            'Solid oak frame with high-density foam cushions and breathable linen upholstery.',
          ),
          const SizedBox(height: 16),
          _buildSpecItem(
            context.tr('assembly'),
            'Simple two-person assembly required. All tools and hardware included in the package.',
          ),
          const SizedBox(height: 16),
          _buildSpecItem(
            context.tr('maintenance'),
            'Fabric is stain-resistant. Spot clean with a damp cloth and mild detergent only.',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProducts() {
    // Sample similar products (in real app, fetch from API)
    final similarProducts = [
      {
        'name': 'Velvet Sofa',
        'price': '\$750',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Leather 3-Seater',
        'price': '\$549',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Modular Grey',
        'price': '\$2599',
        'image': 'https://via.placeholder.com/150'
      },
      {
        'name': 'Studio Loveseat',
        'price': '\$899',
        'image': 'https://via.placeholder.com/150'
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('similar_products'),
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  // See more
                },
                child: Row(
                  children: [
                    Text(
                      context.tr('see_more'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.arrow_forward,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: similarProducts.length,
            itemBuilder: (context, index) {
              return SimilarProductCard(
                imageUrl: similarProducts[index]['image']!,
                title: similarProducts[index]['name']!,
                price: similarProducts[index]['price']!,
                onTap: () {
                  // Navigate to product detail
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    icon: const Icon(Icons.remove, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$_quantity',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Add to Cart Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add to cart functionality
                },
                icon: const Icon(Icons.shopping_cart, size: 20),
                label: Text(
                  context.tr('add_to_cart'),
                  style: AppTextStyles.buttonLarge,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
