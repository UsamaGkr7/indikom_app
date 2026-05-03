import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/endpoints.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiService _apiService;

  CategoryRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _apiService.get(Endpoints.categories);

      print('📂 Categories API Response: ${response.statusCode}');
      print('📂 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // ✅ Handle paginated response - extract 'results' array
        final List<dynamic> results = jsonData['results'] is List
            ? jsonData['results'] as List<dynamic>
            : jsonData is List
                ? jsonData
                : [];

        // ✅ Map and filter with explicit type casting
        final categories = results
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .where((CategoryModel category) =>
                category.isActive) // ✅ Explicit type
            .toList();

        // ✅ Sort by sortOrder field
        categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

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
