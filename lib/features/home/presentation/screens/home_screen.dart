import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:indikom_app/features/home/bloc/home_bloc.dart';
import 'package:indikom_app/features/home/presentation/bloc/banner_bloc.dart';
import 'package:indikom_app/features/home/presentation/widgets/banner_carousel.dart';
import 'package:indikom_app/features/product/data/models/product_model.dart';
import 'package:indikom_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:indikom_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:indikom_app/shared/widgets/category_card.dart';
import 'package:indikom_app/shared/widgets/product_card.dart';
import 'package:indikom_app/shared/widgets/promotional_banner.dart';
import 'package:indikom_app/shared/widgets/section_header.dart';
import 'package:indikom_app/shared/widgets/shimmer_loading.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/language_switcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print("at home screen called::::::");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load once per dependency change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  void _loadHomeData() {
    print('load home data called:::::::');

    context.read<HomeBloc>().add(LoadHomeDataEvent());
    context.read<CategoryBloc>().add(LoadCategoriesEvent());

    // ✅ Load ALL products (no filters)
    context.read<ProductBloc>().add(const LoadProductsEvent(
        categoryName: null,
        subCategoryName: null,
        searchQuery: null,
        filterType: null));
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

          // Categories Section with Shimmer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCategoriesSection(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

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
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ✅ Featured Products with Shimmer (is_featured: true)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFeaturedProducts(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ✅ Home Appliances Section (category_name: "Home Appliances")
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildHomeAppliancesSection(context),
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
              'Indi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Kom',
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
        const LanguageSwitcher(showDropdown: false),
        const SizedBox(width: 12),
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
            hintText: context.tr('search_hint'),
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
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        // ✅ Show shimmer while loading
        if (state is CategoryLoading) {
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
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: Responsive.horizontalPadding(context, false),
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ShimmerLoading.categoryCard(),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // ✅ Show error state
        if (state is CategoryError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: Responsive.horizontalPadding(context, false),
                child: Text(
                  context.tr('categories'),
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: Center(
                  child: Text(
                    'Failed to load categories',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        // ✅ Show actual categories
        if (state is CategoriesLoaded && state.categories.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: Responsive.horizontalPadding(context, false),
                child: Text(
                  context.tr('categories'),
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: Responsive.horizontalPadding(context, false),
                  children: state.categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CategoryCard(
                        imageUrl: category.thumbnail,
                        iconUrl: category.icon, // ✅ Pass icon URL
                        label: category.name,
                        onTap: () {
                          // ✅ Navigate using slug (more reliable than name)
                          context.push(
                            '${RoutePaths.categoryDetail}?category=${category.slug}',
                            extra: {
                              'thumbnail': category.thumbnail,
                              'icon': category.icon,
                              'categoryId':
                                  category.id, // ✅ Pass the category ID (int)
                            },
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }

        // Fallback - empty state
        return const SizedBox.shrink();
      },
    );
  }

  // ✅ Featured Products Section (is_featured: true)
  Widget _buildFeaturedProducts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return ShimmerLoading.container(
                  width: 150,
                  height: 24,
                  borderRadius: BorderRadius.circular(4),
                );
              }
              return SectionHeader(
                  title: context.tr('featured_products'),
                  onSeeAllPressed: () {
                    // ✅ Navigate to featured products filter
                    context.push(
                      '${RoutePaths.productList}?filter=featured',
                    );
                  });
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return Responsive.isMobile(context)
                    ? _buildShimmerGrid(2)
                    : Responsive.isTablet(context)
                        ? _buildShimmerGrid(3)
                        : _buildShimmerGrid(4);
              }

              if (state is ProductsLoaded) {
                // ✅ Filter products where is_featured: true
                final featuredProducts =
                    state.products.where((p) => p.isFeatured).take(4).toList();

                return Responsive.isMobile(context)
                    ? _buildProductGrid(2, products: featuredProducts)
                    : Responsive.isTablet(context)
                        ? _buildProductGrid(3, products: featuredProducts)
                        : _buildProductGrid(4, products: featuredProducts);
              }

              return _buildShimmerGrid(2);
            },
          ),
        ),
      ],
    );
  }

  // ✅ Home Appliances Section (category_name: "Home Appliances")
  Widget _buildHomeAppliancesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return ShimmerLoading.container(
                  width: 150,
                  height: 24,
                  borderRadius: BorderRadius.circular(4),
                );
              }
              return SectionHeader(
                  title: 'Home Appliances',
                  onSeeAllPressed: () {
                    // ✅ Navigate to home appliances filter
                    context.push(
                      '${RoutePaths.productList}?category=home-appliances',
                    );
                  });
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: Responsive.horizontalPadding(context, false),
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return Responsive.isMobile(context)
                    ? _buildShimmerGrid(2)
                    : Responsive.isTablet(context)
                        ? _buildShimmerGrid(3)
                        : _buildShimmerGrid(4);
              }

              if (state is ProductsLoaded) {
                // ✅ Filter products where category_name: "Home Appliances"
                final homeAppliancesProducts = state.products
                    .where((p) => p.categoryName == 'Home Appliances')
                    .take(4)
                    .toList();

                return Responsive.isMobile(context)
                    ? _buildProductGrid(2, products: homeAppliancesProducts)
                    : Responsive.isTablet(context)
                        ? _buildProductGrid(3, products: homeAppliancesProducts)
                        : _buildProductGrid(4,
                            products: homeAppliancesProducts);
              }

              return _buildShimmerGrid(2);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerGrid(int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => ShimmerLoading.productCard(),
    );
  }

  Widget _buildProductGrid(int crossAxisCount, {List<ProductModel>? products}) {
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

        return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 900),
          openBuilder: (BuildContext context, VoidCallback _) {
            return ProductDetailScreen(product: product);
          },
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return GestureDetector(
              onTap: openContainer,
              child: ProductCard(
                productId: product.id,

                // ✅ Use displayImage helper which handles nulls
                imageUrl:
                    product.displayImage ?? 'https://via.placeholder.com/200',

                title: product.name,

                // ✅ Use effectivePrice if available, fallback to price
                price: product.effectivePrice != null
                    ? '\$${product.effectivePrice!.toStringAsFixed(0)}'
                    : '\$${double.tryParse(product.price)?.toStringAsFixed(0) ?? product.price}',

                // ✅ Use discountPrice for strikethrough original price (not product.price)
                originalPrice: product.discountPrice != null
                    ? '\$${product.discountPrice}'
                    : null,

                // ✅ Safe: no ! needed after null check
                discount: product.discountPercentage != null
                    ? '${product.discountPercentage}% OFF' // ✅ Removed redundant !
                    : null,
              ),
            );
          },
          closedElevation: 0,
          openElevation: 0,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          closedColor: Colors.transparent,
          tappable: false,
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
            label: context.tr('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: context.tr('orders'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.tr('profile'),
          ),
        ],
      ),
    );
  }
}
