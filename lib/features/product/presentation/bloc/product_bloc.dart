import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  final String? categoryName;
  final String? subCategoryName;
  final String? searchQuery;
  final String? filterType;

  const LoadProductsEvent({
    this.categoryName,
    this.subCategoryName,
    this.searchQuery,
    this.filterType,
  });

  @override
  List<Object?> get props =>
      [categoryName, subCategoryName, searchQuery, filterType];
}

class LoadProductBySlugEvent extends ProductEvent {
  // ✅ Changed from ID to slug
  final String slug;

  const LoadProductBySlugEvent({required this.slug});

  @override
  List<Object?> get props => [slug];
}

class LoadProductsByCategoryEvent extends ProductEvent {
  final String category;

  const LoadProductsByCategoryEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

class LoadProductByIdEvent extends ProductEvent {
  final int id;

  const LoadProductByIdEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;

  const ProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductLoaded extends ProductState {
  final ProductModel product;

  const ProductLoaded({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;

  ProductBloc({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepository(),
        super(ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<LoadProductBySlugEvent>(_onLoadProductBySlug); // ✅ Changed handler
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final products = await _productRepository.fetchProducts(
        categorySlug: event.categoryName,
        subCategorySlug: event.subCategoryName,
        searchQuery: event.searchQuery,
      );

      // ✅ ADD THIS FILTERING LOGIC:
      List<ProductModel> filteredProducts = products;

      if (event.filterType == 'top_deals') {
        filteredProducts = products.where((p) => p.isTopDeal).toList();
        print('🔥 Filtered to ${filteredProducts.length} top deals');
      } else if (event.filterType == 'everyday') {
        filteredProducts = products.where((p) => p.isDailyUseItem).toList();
        print('🏷️ Filtered to ${filteredProducts.length} everyday items');
      }

      emit(ProductsLoaded(
          products:
              filteredProducts)); // ✅ Use filteredProducts instead of products
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onLoadProductBySlug(
    // ✅ New handler for slug
    LoadProductBySlugEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final product = await _productRepository.fetchProductBySlug(event.slug);
      emit(ProductLoaded(product: product));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }
}
