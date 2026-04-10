import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/endpoints.dart';
import '../models/product_model.dart';

class ProductRepository {
  final http.Client _client;

  ProductRepository({http.Client? client}) : _client = client ?? http.Client();

  // Fetch all products
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.products}');
      print('📦 Fetching products from: $url');

      final response = await _client.get(url);

      print('📦 Products API Response: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final products = jsonData
            .map((json) => ProductModel.fromJson(json))
            .where((product) => product.isActive)
            .toList();

        print('✅ Loaded ${products.length} active products');
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  // Fetch products by category
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    try {
      final products = await fetchProducts();
      return products
          .where((product) =>
              product.category?.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      print('❌ Error fetching products by category: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  // Fetch single product
  Future<ProductModel> fetchProductById(int id) async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.products}$id/');
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ProductModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print('❌ Error fetching product by ID: $e');
      throw Exception('Failed to load product: $e');
    }
  }
}
