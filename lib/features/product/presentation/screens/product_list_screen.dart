import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:indikom_app/shared/widgets/shimmer_loading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../data/models/product_model.dart';
import '../bloc/product_bloc.dart';
import '../widgets/filter_bottom_sheet.dart';

class ProductListScreen extends StatefulWidget {
  final String? categorySlug; // ✅ Changed from category to categorySlug
  final String? subCategorySlug; // ✅ New
  final String? searchQuery;
  final int? categoryId; // ✅ New: for API filtering
  final int? subCategoryId; // ✅ New: for API filtering

  const ProductListScreen({
    super.key,
    this.categorySlug,
    this.subCategorySlug,
    this.searchQuery,
    this.categoryId,
    this.subCategoryId,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _sortBy = 'name';
  String _sortOrder = 'asc';
  bool _isGridView = true;
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';

    // ✅ Load products with category/sub-category IDs for API filtering
    context.read<ProductBloc>().add(
          LoadProductsEvent(
            categoryName: widget.categorySlug,
            subCategoryName: widget.subCategorySlug,
            searchQuery: widget.searchQuery,
          ),
        );
  }

  @override
  void dispose() {
    // ✅ Clear filters when leaving this screen
    // This ensures home screen shows all products
    print('dispose called::::::');
    // Future.delayed(Duration(milliseconds: 100), () {
    //   if (mounted) {
    //     context.read<ProductBloc>().add(const LoadProductsEvent(
    //           categoryName: null,
    //           subCategoryName: null,
    //           searchQuery: null,
    //         ));
    //   }
    // });

    _searchController.dispose();
    super.dispose();
  }

  // ✅ Filter and sort products WITHOUT setState - returns new list
  List<ProductModel> _getFilteredAndSortedProducts(
      List<ProductModel> products) {
    var filtered = products.where((product) {
      final searchMatch = _searchController.text.isEmpty ||
          product.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          product.description!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return searchMatch;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return _sortOrder == 'asc'
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name);
        case 'price':
          final priceA = double.tryParse(a.price) ?? 0.0;
          final priceB = double.tryParse(b.price) ?? 0.0;
          return _sortOrder == 'asc'
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        case 'newest':
          return _sortOrder == 'asc'
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt);
        default:
          return 0;
      }
    });

    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        onSortChanged: (sortBy, sortOrder) {
          setState(() {
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Filter & View Toggle Bar
          _buildFilterBar(),

          // Product Count with Shimmer
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ShimmerLoading.container(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }
              if (state is ProductsLoaded) {
                final filtered = _getFilteredAndSortedProducts(state.products);
                return _buildProductCount(filtered.length);
              }
              return _buildProductCount(0);
            },
          ),

          // Products Grid/List with Shimmer
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          context.read<ProductBloc>().add(const LoadProductsEvent(
                categoryName: null,
                subCategoryName: null,
                searchQuery: null,
              ));
          context.pop();
        },
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      ),
      title: Text(
        widget.categorySlug?.replaceAll('-', ' ').toTitleCase() ??
            context.tr('all_products'),
        style: AppTextStyles.h3,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            print('🔄 Reloading all products before home navigation');
            context.read<ProductBloc>().add(const LoadProductsEvent(
                  categoryName: null,
                  subCategoryName: null,
                  searchQuery: null,
                ));
            context.push(RoutePaths.home);
          },
          icon: const Icon(Icons.home_outlined, color: AppColors.primary),
        ),
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.tr('search_products'),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.surface,
      child: Row(
        children: [
          // Filter Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.filter_list, size: 20),
              label: Text(context.tr('filter_sort')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Grid/List Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _isGridView = true),
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  padding: const EdgeInsets.all(8),
                ),
                // IconButton(
                //   onPressed: () => setState(() => _isGridView = false),
                //   icon: Icon(
                //     Icons.list,
                //     color: !_isGridView
                //         ? AppColors.primary
                //         : AppColors.textSecondary,
                //   ),
                //   padding: const EdgeInsets.all(8),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count ${context.tr('products')}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // ✅ Show shimmer while loading
        if (state is ProductLoading) {
          return _isGridView ? _buildShimmerGrid() : _buildShimmerList();
        }

        // ✅ Show products when loaded
        if (state is ProductsLoaded) {
          final _filteredProducts =
              _getFilteredAndSortedProducts(state.products);

          if (_filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('no_products_found'),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          if (_isGridView) {
            return _buildGridView(_filteredProducts);
          } else {
            return _buildListView(_filteredProducts);
          }
        }

        // ✅ Show error state
        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  context.tr('error_loading_products'),
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ✅ Shimmer Grid for Loading State
  Widget _buildShimmerGrid() {
    final crossAxisCount = Responsive.isMobile(context)
        ? 2
        : Responsive.isTablet(context)
            ? 3
            : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => ShimmerLoading.productCard(),
    );
  }

  // ✅ Shimmer List for Loading State
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => ShimmerLoading.listItem(),
    );
  }

  // ✅ Actual Grid with Products
  Widget _buildGridView(List<ProductModel> products) {
    final crossAxisCount = Responsive.isMobile(context)
        ? 2
        : Responsive.isTablet(context)
            ? 3
            : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        // In _buildProductGrid method, update the ProductCard:

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

  // ✅ Actual List with Products
  Widget _buildListView(List<ProductModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: 400),
          openBuilder: (BuildContext context, VoidCallback _) {
            return ProductDetailScreen(product: product);
          },
          closedBuilder: (BuildContext context, VoidCallback openContainer) {
            return GestureDetector(
              onTap: openContainer,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)),
                      child: product.file != null
                          ? Image.network(
                              product.file!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 120,
                                height: 120,
                                color: AppColors.cardBackground,
                                child: const Icon(Icons.image,
                                    size: 40, color: AppColors.textHint),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 120,
                              color: AppColors.cardBackground,
                              child: const Icon(Icons.image,
                                  size: 40, color: AppColors.textHint),
                            ),
                    ),

                    // Product Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  '\$${product.price}',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                  ),
                                ),
                                if (product.discountPrice != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${product.discountPrice}',
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
                    ),
                  ],
                ),
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
}

extension StringExtensions on String {
  String toTitleCase() {
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
