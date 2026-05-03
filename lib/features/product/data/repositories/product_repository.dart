import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_service.dart'; // ✅ Use authenticated API service
import '../../../../core/constants/endpoints.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiService _apiService; // ✅ Use ApiService for auth

  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ✅ Fetch all products (paginated)
  // In ProductRepository.fetchProducts():

  // In lib/features/product/data/repositories/product_repository.dart:

  Future<List<ProductModel>> fetchProducts({
    String? categorySlug, // ✅ Add slug parameter
    String? subCategorySlug, // ✅ Add slug parameter
    String? searchQuery,
  }) async {
    try {
      String url = Endpoints.products;

      final queryParams = <String, String>{};

      // ✅ Use slug parameters instead of ID
      if (subCategorySlug != null) {
        queryParams['sub_category'] = subCategorySlug; // Backend expects slug
        print('🔍 Filtering by sub-category slug: $subCategorySlug');
      } else if (categorySlug != null) {
        queryParams['category'] = categorySlug; // Backend expects slug
        print('🔍 Filtering by category slug: $categorySlug');
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (queryParams.isNotEmpty) {
        url +=
            '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      print('📦 Fetching products from: ${Endpoints.baseUrl}$url');

      final response = await _apiService.get(url);

      print('📦 Products API Response: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final List<dynamic> results = jsonData['results'] is List
            ? jsonData['results'] as List<dynamic>
            : jsonData is List
                ? jsonData
                : [];

        print('📊 Raw results count: ${results.length}');

        final products = results
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .where((ProductModel product) => product.isActive)
            .toList();

        print('✅ Loaded ${products.length} active products');
        return products;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required. Please login again.');
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }
  // ✅ Fetch single product by slug (not ID)
  // In lib/features/product/data/repositories/product_repository.dart:

  Future<ProductModel> fetchProductBySlug(String slug) async {
    try {
      final url = '${Endpoints.products}$slug/';
      print('📦 Fetching product by slug: $url');

      final response = await _apiService.get(url);

      print('📦 Product Detail Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ProductModel.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching product: $e');
      throw Exception('Failed to load product: $e');
    }
  }
}
