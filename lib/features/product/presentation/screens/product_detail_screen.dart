import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/features/product/data/repositories/product_repository.dart';
import 'package:indikom_app/shared/widgets/shimmer_loading.dart';
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

  // ✅ State for full product detail
  ProductModel? _fullProduct;
  bool _isLoadingFullProduct = false;

  // Similar products state
  bool _similarProductsLoading = false;
  List<Map<String, dynamic>> _similarProducts = [];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Green', 'value': '#2D5A4A'},
    {'name': 'Black', 'value': '#1a1a1a'},
    {'name': 'Brown', 'value': '#8B4513'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFullProduct();
    _loadSimilarProducts();
  }

  // ✅ Fetch full product detail by slug
  Future<void> _loadFullProduct() async {
    // If product already has detailed fields, skip fetch
    if (widget.product.description != null ||
        widget.product.variants.isNotEmpty ||
        widget.product.specifications.isNotEmpty ||
        widget.product.dimensions != null) {
      _fullProduct = widget.product;
      return;
    }

    setState(() => _isLoadingFullProduct = true);

    try {
      print('🔄 Fetching full product detail for slug: ${widget.product.slug}');
      final fullProduct =
          await ProductRepository().fetchProductBySlug(widget.product.slug);
      print('✅ Loaded full product: ${fullProduct.name}');

      setState(() {
        _fullProduct = fullProduct;
        _isLoadingFullProduct = false;
      });
    } catch (e) {
      print('❌ Error loading full product: $e');
      setState(() {
        _fullProduct = widget.product; // Fallback to list product
        _isLoadingFullProduct = false;
      });
    }
  }

  // ✅ Helper to get the product to display
  ProductModel get _displayProduct => _fullProduct ?? widget.product;

  // ✅ Fetch similar products from API
  Future<void> _loadSimilarProducts() async {
    setState(() => _similarProductsLoading = true);

    try {
      print('🔍 Loading similar products for:');
      print('  - Current Product: ${widget.product.name}');
      print(
          '  - Category Slug: ${widget.product.categoryName?.toLowerCase().replaceAll(' ', '-')}');
      print(
          '  - Sub-Category Slug: ${widget.product.subCategoryName?.toLowerCase().replaceAll(' ', '-')}');

      List<ProductModel> similarProducts = [];

      // ✅ Step 1: Try fetching from same SUB-CATEGORY slug first
      if (widget.product.subCategoryName != null) {
        try {
          final subCategorySlug = widget.product.subCategoryName!
              .toLowerCase()
              .replaceAll(' ', '-');

          print(
              '🔄 Attempt 1: Fetching by sub-category slug: $subCategorySlug');
          similarProducts = await ProductRepository().fetchProducts(
            subCategorySlug: subCategorySlug, // ✅ Send slug, not ID
          );

          print('📊 Found ${similarProducts.length} products from API');

          // ✅ CLIENT-SIDE FILTER: Double-check slug matches
          similarProducts = similarProducts
              .where((p) =>
                  p.subCategoryName?.toLowerCase().replaceAll(' ', '-') ==
                  subCategorySlug)
              .toList();

          print(
              '📊 After client-side filter: ${similarProducts.length} products');
        } catch (e) {
          print('⚠️ Sub-category slug fetch failed: $e');
        }
      }

      // ✅ Step 2: If no results, fall back to CATEGORY slug
      if (similarProducts.isEmpty && widget.product.categoryName != null) {
        try {
          final categorySlug =
              widget.product.categoryName!.toLowerCase().replaceAll(' ', '-');

          print('🔄 Attempt 2: Fetching by category slug: $categorySlug');
          similarProducts = await ProductRepository().fetchProducts(
            categorySlug: categorySlug, // ✅ Send slug, not ID
          );

          print('📊 Found ${similarProducts.length} products from API');

          // ✅ CLIENT-SIDE FILTER: Double-check slug matches
          similarProducts = similarProducts
              .where((p) =>
                  p.categoryName?.toLowerCase().replaceAll(' ', '-') ==
                  categorySlug)
              .toList();

          print(
              '📊 After client-side filter: ${similarProducts.length} products');
        } catch (e) {
          print('⚠️ Category slug fetch failed: $e');
        }
      }

      // ✅ Step 3: If still no results, fetch ALL products
      if (similarProducts.isEmpty) {
        try {
          print('🔄 Attempt 3: Fetching all products');
          final allProducts = await ProductRepository().fetchProducts();
          similarProducts = allProducts;
          print('📊 Found ${similarProducts.length} total products');
        } catch (e) {
          print('⚠️ All products fetch failed: $e');
        }
      }

      // ✅ Filter out current product and take top 4
      print(
          '📊 Before excluding current product: ${similarProducts.length} products');

      final filteredProducts =
          similarProducts.where((p) => p.id != widget.product.id).toList();

      print(
          '📊 After excluding current product: ${filteredProducts.length} products');

      setState(() {
        _similarProducts = filteredProducts
            .take(4)
            .map((product) => {
                  'name': product.name,
                  'price':
                      '\$${product.effectivePrice?.toStringAsFixed(0) ?? product.price}',
                  'image':
                      product.displayImage ?? 'https://via.placeholder.com/150',
                  'product': product,
                })
            .toList();

        _similarProductsLoading = false;
      });

      print('✅ Final similar products:');
      for (var p in _similarProducts) {
        print('   - ${p['name']} (category: ${p['categoryName']})');
      }
    } catch (e) {
      print('❌ Error loading similar products: $e');
      setState(() => _similarProductsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loading while fetching full product
    if (_isLoadingFullProduct && _fullProduct == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildImageCarousel(),
                SliverToBoxAdapter(child: _buildProductInfo()),
                SliverToBoxAdapter(child: _buildRatingSection()),
                SliverToBoxAdapter(child: _buildARViewButton()),
                SliverToBoxAdapter(child: _buildAboutProduct()),
                SliverToBoxAdapter(child: _buildTagsSection()),
                SliverToBoxAdapter(child: _buildTechnicalSpecs()),
                SliverToBoxAdapter(child: _buildSimilarProducts()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
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
          onPressed: () {},
          icon: const Icon(Icons.shopping_cart_outlined,
              color: AppColors.primary),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // image  carousel to show multi images in one list

  Widget _buildImageCarousel() {
    print('🖼️ [DEBUG] _buildImageCarousel() called');
    print('🖼️ [DEBUG] _displayProduct: ${_displayProduct.name}');
    print('🖼️ [DEBUG] Thumbnail: ${_displayProduct.thumbnail}');
    print('🖼️ [DEBUG] File: ${_displayProduct.file}');
    print('🖼️ [DEBUG] Images count: ${_displayProduct.images.length}');

    for (var i = 0; i < _displayProduct.images.length; i++) {
      print('🖼️ [DEBUG]   Image $i: ${_displayProduct.images[i].image}');
    }

    final images = _displayProduct.allImageUrls;
    print('🖼️ [DEBUG] Total images in carousel: ${images.length}');
    print('🖼️ [DEBUG] Images: $images');

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
                print('🖼️ [DEBUG] Building image $index: ${images[index]}');
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Hero(
                    tag: 'product_image_${_displayProduct.slug}_$index',
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          ShimmerLoading.productDetailImage(),
                      errorWidget: (context, url, error) {
                        print('❌ [DEBUG] Image load error: $error');
                        print('❌ [DEBUG] URL: $url');
                        return Container(
                          color: AppColors.cardBackground,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image,
                                  size: 50, color: AppColors.textHint),
                              SizedBox(height: 8),
                              Text('Failed to load',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_displayProduct.categoryName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _displayProduct.categoryName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (_displayProduct.subCategoryName != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _displayProduct.subCategoryName!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _displayProduct.name,
            style: AppTextStyles.h2.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_displayProduct.discountPrice != null)
                Text(
                  '\$${_displayProduct.discountPrice}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textHint,
                  ),
                ),
              if (_displayProduct.discountPrice != null)
                const SizedBox(width: 8),
              Text(
                '\$${_displayProduct.effectivePrice?.toStringAsFixed(0) ?? _displayProduct.price}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
              ),
              if (_displayProduct.discountPercentage != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_displayProduct.discountPercentage}% OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _displayProduct.stock > 0
                          ? AppColors.success
                          : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _displayProduct.stock > 0
                        ? context.tr('in_stock')
                        : context.tr('out_of_stock'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _displayProduct.stock > 0
                          ? AppColors.success
                          : AppColors.error,
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

  Widget _buildRatingSection() {
    if (_displayProduct.rating == null && _displayProduct.reviewCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                final rating = _displayProduct.rating?.toDouble() ?? 0;
                return Icon(
                  index < rating.floor()
                      ? Icons.star
                      : index < rating
                          ? Icons.star_half
                          : Icons.star_border,
                  color: AppColors.primary,
                  size: 20,
                );
              }),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            _displayProduct.rating?.toStringAsFixed(1) ?? '0.0',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Text(
            '(${_displayProduct.reviewCount} reviews)',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
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
              onPressed: _displayProduct.hasAr
                  ? () {
                      print('Opening AR view: ${_displayProduct.arFile}');
                    }
                  : null,
              icon: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.view_in_ar,
                  size: 25,
                  color: _displayProduct.hasAr
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              ),
              label: Text(
                _displayProduct.hasAr
                    ? context.tr('view_in_your_room')
                    : context.tr('ar_not_available'),
                textAlign: TextAlign.center,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _displayProduct.hasAr
                    ? AppColors.primary
                    : AppColors.textHint,
                side: BorderSide(
                  color: _displayProduct.hasAr
                      ? AppColors.primary
                      : AppColors.border,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, color: AppColors.primary),
              label: Text(context.tr('share')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
          if (_displayProduct.description != null &&
              _displayProduct.description!.isNotEmpty)
            Text(
              _displayProduct.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            )
          else
            ShimmerLoading.textLines(lines: 3, height: 14),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {},
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

  Widget _buildTagsSection() {
    if (_displayProduct.tags == null || _displayProduct.tags!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final tags = _displayProduct.tags!.split(',');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style:
                AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.where((tag) => tag.trim().isNotEmpty).map((tag) {
              final trimmedTag = tag.trim();
              final capitalizedTag = trimmedTag.capitalize();
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  capitalizedTag,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalSpecs() {
    final hasSpecs = _displayProduct.specifications.isNotEmpty;
    final hasBrand =
        _displayProduct.brand != null && _displayProduct.brand!.isNotEmpty;
    final hasWeight = _getFirstVariantWeight() != null;
    final hasDimensions = _displayProduct.dimensions != null &&
        _displayProduct.dimensions!.isNotEmpty;

    if (!hasSpecs && !hasBrand && !hasWeight && !hasDimensions) {
      return const SizedBox.shrink();
    }

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
          if (hasSpecs) ...[
            ..._displayProduct.specifications
                .map((spec) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildSpecItem(
                        spec.key.capitalize(),
                        '${spec.value}${spec.unit != null && spec.unit!.isNotEmpty ? ' ${spec.unit}' : ''}',
                      ),
                    ))
                .toList(),
            if (hasBrand || hasWeight || hasDimensions)
              const Divider(height: 24),
          ],
          if (hasBrand) _buildSpecItem('Brand', _displayProduct.brand!),
          if (hasDimensions)
            _buildSpecItem('Dimensions', _displayProduct.dimensions!),
          if (hasWeight)
            _buildSpecItem('Weight', '${_getFirstVariantWeight()} kg'),
        ],
      ),
    );
  }

  String? _getFirstVariantWeight() {
    if (_displayProduct.variants.isEmpty) return null;
    final weight = _displayProduct.variants.first.weight;
    return weight != null && weight.isNotEmpty ? weight : null;
  }

  Widget _buildSpecItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
                onPressed: () {},
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
          if (_similarProductsLoading)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => ShimmerLoading.productCard(),
            )
          else if (_similarProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No similar products found',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _similarProducts.length,
              itemBuilder: (context, index) {
                return SimilarProductCard(
                  imageUrl: _similarProducts[index]['image']!,
                  title: _similarProducts[index]['name']!,
                  price: _similarProducts[index]['price']!,
                  onTap: () {
                    final product =
                        _similarProducts[index]['product'] as ProductModel;
                    context.push(RoutePaths.productDetail, extra: product);
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
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600),
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
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
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
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
