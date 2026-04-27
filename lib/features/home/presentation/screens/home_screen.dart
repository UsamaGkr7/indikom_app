import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/features/home/bloc/home_bloc.dart';
import 'package:indikom_app/features/home/presentation/bloc/banner_bloc.dart';
import 'package:indikom_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:indikom_app/features/product/data/models/product_model.dart';
import 'package:indikom_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:indikom_app/shared/widgets/category_card.dart';
import 'package:indikom_app/shared/widgets/product_card.dart';
import 'package:indikom_app/shared/widgets/promotional_banner.dart';
import 'package:indikom_app/shared/widgets/section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/extensions.dart'; // ✅ Import this
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/language_switcher.dart'; // ✅ Import this

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(LoadHomeDataEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          // Search Bar
          SliverToBoxAdapter(child: _buildSearchBar()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCategoriesSection(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Promotional Banner - FIXED ✅
          BlocBuilder<BannerBloc, BannerState>(
            builder: (context, state) {
              if (state is BannerLoading) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: Responsive.horizontalPadding(context, false),
                    height: 250,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
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

              // Fallback to empty space
              return const SliverToBoxAdapter(
                child: SizedBox(height: 250),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Featured Products
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFeaturedProducts(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Sofas Category
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCategorySection('sofas'),
            ),
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
      toolbarHeight: 70,
      leading: Container(),
      title: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            Text(
              'Indi', // ✅ Keep brand name as is (or translate if needed)
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Kom', // ✅ Keep brand name as is (or translate if needed)
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ✅ Language Switcher
        const LanguageSwitcher(showDropdown: false),
        const SizedBox(width: 12),
        // Cart Icon
        IconButton(
          onPressed: () {
            // Navigate to cart
          },
          icon: const Icon(Icons.shopping_cart_outlined),
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: Responsive.horizontalPadding(context, false),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: context.tr('search_hint'), // ✅ TRANSLATED
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: Text(
            context.tr('categories'), // ✅ TRANSLATED
            style: AppTextStyles.h3,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: Responsive.horizontalPadding(context, false),
            children: [
              CategoryCard(
                icon: 'assets/images/sofa3.jpeg',
                label: context.tr('sofas'), // ✅ TRANSLATED
                onTap: () {},
              ),
              const SizedBox(width: 12),
              CategoryCard(
                icon: 'assets/images/door4.jpeg',
                label: context.tr('doors'), // ✅ TRANSLATED
                onTap: () {},
              ),
              const SizedBox(width: 12),
              CategoryCard(
                icon: 'assets/images/wardrobe58.jpeg',
                label: context.tr('wardrobes'), // ✅ TRANSLATED
                onTap: () {},
              ),
              const SizedBox(width: 12),
              CategoryCard(
                icon: 'assets/images/appliance.jpeg',
                label: context.tr('appliances'), // ✅ TRANSLATED
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      margin: Responsive.horizontalPadding(context, false),
      height: 250,
      child: const PromotionalBanner(
        imageUrl: 'assets/images/banner_refrigerator.jpg',
        title: 'LOREM IPSUM DOLOR',
        subtitle: 'Lorem ipsum dolor sit amet consectetur.',
        discount: '15% OFF',
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: SectionHeader(
            title: context.tr('featured_products'),
            onSeeAllPressed: () {
              // Navigate to all products
              context.push(RoutePaths.productList);
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is ProductsLoaded) {
                final products = state.products.take(4).toList();

                if (products.isEmpty) {
                  return const Center(
                    child: Text('No products available'),
                  );
                }

                return Responsive.isMobile(context)
                    ? _buildProductGrid(2, products: products)
                    : Responsive.isTablet(context)
                        ? _buildProductGrid(3, products: products)
                        : _buildProductGrid(4, products: products);
              }

              if (state is ProductError) {
                return Center(
                  child: Text('Error: ${state.message}'),
                );
              }

              // Show placeholder products while loading
              return Responsive.isMobile(context)
                  ? _buildProductGrid(2)
                  : Responsive.isTablet(context)
                      ? _buildProductGrid(3)
                      : _buildProductGrid(4);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String categoryName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: SectionHeader(
            title: categoryName, // You can translate this too if needed
            onSeeAllPressed: () {},
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: Responsive.isMobile(context)
              ? _buildProductGrid(2)
              : Responsive.isTablet(context)
                  ? _buildProductGrid(3)
                  : _buildProductGrid(4),
        ),
      ],
    );
  }

  Widget _buildProductGrid(int crossAxisCount, {List<ProductModel>? products}) {
    // Use provided products or show placeholders
    final displayProducts = products ?? [];
    final isPlaceholder = products == null;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: isPlaceholder ? 4 : displayProducts.length,
      itemBuilder: (context, index) {
        if (isPlaceholder) {
          return const ProductCard(
            imageUrl: 'https://via.placeholder.com/200',
            title: 'Product Name',
            price: '\$999',
          );
        }

        final product = displayProducts[index];
        return ProductCard(
          imageUrl: product.imageUrl ?? 'https://via.placeholder.com/200',
          title: product.name,
          price: '\$${product.price}',
          originalPrice: product.originalPrice != null
              ? '\$${product.originalPrice}'
              : null,
          discount: product.discount != null
              ? '${product.discount!.toStringAsFixed(0)}% OFF'
              : null,
          onTap: () {
            context.push(RoutePaths.productDetail, extra: product);
          },
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
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
      child: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: context.tr('home'), // ✅ TRANSLATED
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: context.tr('orders'), // ✅ TRANSLATED
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.tr('profile'), // ✅ TRANSLATED
          ),
        ],
      ),
    );
  }
}
