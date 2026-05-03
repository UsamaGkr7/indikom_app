import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/core/utils/responsive_utils.dart';
import 'package:indikom_app/features/category/presentation/bloc/sub_category_bloc.dart';
import 'package:indikom_app/features/home/presentation/bloc/banner_bloc.dart';
import 'package:indikom_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:indikom_app/shared/widgets/product_card.dart';
import 'package:indikom_app/shared/widgets/shimmer_loading.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/data/models/product_model.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categorySlug; // ✅ Changed from categorySlug to categorySlug
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
  @override
  void initState() {
    super.initState();

    print('🏷️ CategoryDetailScreen initialized');
    print('🏷️ Category Slug: ${widget.categorySlug}');
    print('🏷️ Category ID: ${widget.categoryId}');

    // ✅ Load sub-categories using categoryId
    if (widget.categoryId != null) {
      print('📡 Loading sub-categories for category ID: ${widget.categoryId}');
      context.read<SubCategoryBloc>().add(
            LoadSubCategoriesEvent(categoryId: widget.categoryId),
          );
    } else {
      print('⚠️ No categoryId provided, loading all sub-categories');
      context.read<SubCategoryBloc>().add(
            const LoadSubCategoriesEvent(categoryId: null),
          );
    }
  }

  Widget _buildBannerErrorWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Shimmer(
        enabled: true,
        color: AppColors.primaryLight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load banners',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // ✅ Retry loading banners
                context.read<BannerBloc>().add(LoadBannersEvent());
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          // Banner (Optional - can be category-specific banner)
          // SliverToBoxAdapter(
          //   child: _buildBanner(),
          // ),
          // Promotional Banner with Shimmer
          BlocBuilder<BannerBloc, BannerState>(
            builder: (context, state) {
              if (state is BannerLoading) {
                return SliverToBoxAdapter(
                  child: ShimmerLoading.banner(),
                );
              }

              if (state is BannerLoaded && state.banners.isNotEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BannerCarousel(banners: state.banners),
                  ),
                );
              }

              // ✅ Handle error state - show retry option
              if (state is BannerError) {
                return SliverToBoxAdapter(
                  child: _buildBannerErrorWidget(context),
                );
              }

              // ✅ Fallback - show shimmer again (not empty space)
              return SliverToBoxAdapter(
                child: ShimmerLoading.banner(),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Sub-Categories Section
          SliverToBoxAdapter(
            child: _buildSubCategoriesSection(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Top Deals Section
          SliverToBoxAdapter(
            child: _buildTopDealsSection(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Everyday Products Section
          SliverToBoxAdapter(
            child: _buildEverydaySection(),
          ),

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
        widget.categorySlug,
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

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            bottom: -50,
            child: Opacity(
              opacity: 0.2,
              child: Icon(
                Icons.shopping_bag,
                size: 200,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.categorySlug,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore our amazing collection',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                child: ShimmerLoading.container(
                  width: 120,
                  height: 24,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      ShimmerLoading.categoryCard(),
                ),
              ),
            ],
          );
        }

        if (state is SubCategoriesLoaded && state.subCategories.isNotEmpty) {
          // ✅ FILTER by category ID (int), not slug (String)
          final filteredSubCategories = widget.categoryId != null
              ? state.subCategories
                  .where((sub) => sub.category == widget.categoryId)
                  .toList()
              : state.subCategories; // If no categoryId, show all

          if (filteredSubCategories.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Shop by ${widget.categorySlug}', // Display name (slug or name)
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final subCategory = filteredSubCategories[index];
                    return GestureDetector(
                      onTap: () {
                        // ✅ Navigate using slug for both category and sub-category
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
                                        errorBuilder:
                                            (context, error, stackTrace) =>
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

  Widget _buildTopDealsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                style: AppTextStyles.h3,
              ),
              TextButton(
                onPressed: () {
                  // See all deals
                },
                child: Row(
                  children: [
                    Text(
                      context.tr('see_all'),
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
            itemBuilder: (context, index) {
              return ShimmerLoading.productCard();
            },
          ),
        ],
      ),
    );
  }

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
                'Everyday ${widget.categorySlug}',
                style: AppTextStyles.h3,
              ),
              TextButton(
                onPressed: () {
                  // See all
                },
                child: Row(
                  children: [
                    Text(
                      context.tr('see_all'),
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
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ShimmerLoading.productCard(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
