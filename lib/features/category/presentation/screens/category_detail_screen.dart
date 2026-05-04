import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/core/utils/responsive_utils.dart';
import 'package:indikom_app/features/category/presentation/bloc/sub_category_bloc.dart';
import 'package:indikom_app/features/home/presentation/bloc/banner_bloc.dart';
import 'package:indikom_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:indikom_app/features/product/data/models/product_model.dart';
import 'package:indikom_app/features/product/data/repositories/product_repository.dart';
import 'package:indikom_app/shared/widgets/product_card.dart';
import 'package:indikom_app/shared/widgets/shimmer_loading.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categorySlug;
  final String? categoryThumbnail;
  final String? categoryIcon;
  final int? categoryId;

  const CategoryDetailScreen({
    super.key,
    required this.categorySlug,
    this.categoryThumbnail,
    this.categoryIcon,
    this.categoryId,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // State variables for products
  List<ProductModel> _allProducts = [];
  List<ProductModel> _topDeals = [];
  List<ProductModel> _everydayItems = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadSubCategories();
    _loadCategoryProducts();
  }

  // Load sub-categories for this category
  void _loadSubCategories() {
    context.read<SubCategoryBloc>().add(
          LoadSubCategoriesEvent(categoryId: widget.categoryId),
        );
  }

  // ✅ Load all products for this category
  Future<void> _loadCategoryProducts() async {
    if (widget.categoryId == null) return;

    setState(() => _isLoadingProducts = true);

    try {
      print('📦 Loading products for category ID: ${widget.categoryId}');

      final allProducts = await ProductRepository().fetchProducts(
        categorySlug: widget.categorySlug,
      );

      print('📦 Total products loaded: ${allProducts.length}');

      // ✅ Filter products
      final topDeals = allProducts.where((p) => p.isTopDeal).toList();

      final everydayItems = allProducts.where((p) => p.isDailyUseItem).toList();

      print('️ Top Deals: ${topDeals.length}');
      print('🏷️ Everyday Items: ${everydayItems.length}');

      setState(() {
        _allProducts = allProducts;
        _topDeals = topDeals;
        _everydayItems = everydayItems;
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() => _isLoadingProducts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          // Banner
          BlocBuilder<BannerBloc, BannerState>(
            builder: (context, state) {
              if (state is BannerLoading) {
                return SliverToBoxAdapter(child: ShimmerLoading.banner());
              }

              if (state is BannerLoaded && state.banners.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BannerCarousel(banners: state.banners),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox(height: 250));
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Sub-Categories Section
          SliverToBoxAdapter(child: _buildSubCategoriesSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ✅ Top Deals Section
          if (_isLoadingProducts)
            SliverToBoxAdapter(child: _buildShimmerSection('Top Deals'))
          else if (_topDeals.isNotEmpty)
            SliverToBoxAdapter(child: _buildTopDealsSection())
          else
            const SliverToBoxAdapter(child: SizedBox.shrink()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ✅ Everyday Items Section
          if (_isLoadingProducts)
            SliverToBoxAdapter(
                child: _buildShimmerSection(
                    'Everyday ${widget.categorySlug.toTitleCase()}'))
          else if (_everydayItems.isNotEmpty)
            SliverToBoxAdapter(child: _buildEverydaySection())
          else
            const SliverToBoxAdapter(child: SizedBox.shrink()),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
        widget.categorySlug.toTitleCase(),
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

  Widget _buildSubCategoriesSection() {
    return BlocBuilder<SubCategoryBloc, SubCategoryState>(
      builder: (context, state) {
        if (state is SubCategoryLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: Responsive.horizontalPadding(context, false),
                child: ShimmerLoading.container(width: 120, height: 24),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => ShimmerLoading.categoryCard(),
                ),
              ),
            ],
          );
        }

        if (state is SubCategoriesLoaded && state.subCategories.isNotEmpty) {
          final filteredSubCategories = widget.categoryId != null
              ? state.subCategories
                  .where((sub) => sub.category == widget.categoryId)
                  .toList()
              : state.subCategories;

          if (filteredSubCategories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Shop by ${widget.categorySlug.toTitleCase()}',
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredSubCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final subCategory = filteredSubCategories[index];
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '${RoutePaths.productList}?category=${widget.categorySlug}&subCategory=${subCategory.slug}',
                        );
                      },
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 58,
                              height: 62,
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: subCategory.thumbnail != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(
                                        subCategory.thumbnail!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.category,
                                                size: 28),
                                      ),
                                    )
                                  : const Icon(Icons.category, size: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              subCategory.name,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ✅ Top Deals Section
  Widget _buildTopDealsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e), // Dark background for top deals
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Deals',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all top deals
                },
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const Icon(Icons.arrow_forward,
                        size: 16, color: AppColors.secondary),
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
            itemCount: _topDeals.length > 4 ? 4 : _topDeals.length,
            itemBuilder: (context, index) {
              final product = _topDeals[index];
              return _buildDarkProductCard(product);
            },
          ),
        ],
      ),
    );
  }

  // ✅ Everyday Items Section
  Widget _buildEverydaySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Everyday ${widget.categorySlug.toTitleCase()}',
                style: AppTextStyles.h3,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all everyday items
                },
                child: Row(
                  children: [
                    Text(
                      'See All',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
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
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _everydayItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = _everydayItems[index];
                return Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildEverydayProductCard(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Dark Product Card for Top Deals
  Widget _buildDarkProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        context.push(RoutePaths.productDetail, extra: product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.displayImage != null
                    ? Image.network(
                        product.displayImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.cardBackground,
                          child: const Icon(Icons.image, size: 40),
                        ),
                      )
                    : Container(
                        color: AppColors.cardBackground,
                        child: const Icon(Icons.image, size: 40),
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
                    product.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.categoryName != null)
                    Text(
                      product.categoryName!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${product.effectivePrice?.toStringAsFixed(0) ?? product.price}',
                        style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      if (product.discountPrice != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          '\$${product.discountPrice}',
                          style: AppTextStyles.bodySmall.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.white),
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

  // ✅ Everyday Product Card (Horizontal)
  Widget _buildEverydayProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () {
        context.push(RoutePaths.productDetail, extra: product);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: product.displayImage != null
                  ? Image.network(
                      product.displayImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardBackground,
                        child: const Icon(Icons.image, size: 40),
                      ),
                    )
                  : Container(
                      color: AppColors.cardBackground,
                      child: const Icon(Icons.image, size: 40),
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
                  product.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.effectivePrice?.toStringAsFixed(0) ?? product.price}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Shimmer Loading for Sections
  Widget _buildShimmerSection(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading.container(width: 150, height: 24),
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
            itemCount: 4,
            itemBuilder: (_, __) => ShimmerLoading.productCard(),
          ),
        ],
      ),
    );
  }
}

extension StringExtensions on String {
  String toTitleCase() {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
