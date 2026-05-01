import 'package:http/http.dart' as http;
import 'package:indikom_app/core/constants/endpoints.dart';
import 'dart:convert';
import '../models/category_model.dart';

class CategoryRepository {
  final http.Client _client;

  CategoryRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      const url = '${Endpoints.baseUrl}/api/products/categories/list/';

      final response = await _client.get(Uri.parse(url));

      print('📂 Categories API Response: ${response.statusCode}');
      print('📂 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final categories = jsonData
            .map((json) => CategoryModel.fromJson(json))
            .where((category) => category.isActive)
            .toList();

        print('✅ Loaded ${categories.length} active categories');
        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Failed to load categories: $e');
    }
  }
}
