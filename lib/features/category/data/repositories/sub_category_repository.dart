import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_service.dart'; // ✅ Use authenticated API service
import '../../../../core/constants/endpoints.dart';
import '../models/sub_category_model.dart';

class SubCategoryRepository {
  final ApiService _apiService; // ✅ Use ApiService for auth

  SubCategoryRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<SubCategoryModel>> fetchSubCategories({int? categoryId}) async {
    try {
      // ✅ Try different query parameter formats
      String url = Endpoints.subCategories;

      if (categoryId != null) {
        // Try 'category' first (most common)
        url += '?category=$categoryId';
      }

      print('📂 Attempt 1: Fetching from: ${Endpoints.baseUrl}$url');

      final response = await _apiService.get(url);

      // ✅ If first attempt returns 0 results, try 'category_id'
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List<dynamic>? ?? [];

        if (results.isEmpty && categoryId != null) {
          print('⚠️ No results with "category" param, trying "category_id"...');

          // Try with category_id
          String altUrl = '${Endpoints.subCategories}?category_id=$categoryId';
          print('📂 Attempt 2: Fetching from: ${Endpoints.baseUrl}$altUrl');

          final altResponse = await _apiService.get(altUrl);

          if (altResponse.statusCode == 200) {
            final altJsonData = json.decode(altResponse.body);
            return _parseSubCategoriesResponse(altJsonData);
          }
        }

        return _parseSubCategoriesResponse(jsonData);
      } else {
        throw Exception(
            'Failed to load sub-categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching sub-categories: $e');
      throw Exception('Failed to load sub-categories: $e');
    }
  }

// ✅ Helper to parse response
  List<SubCategoryModel> _parseSubCategoriesResponse(dynamic jsonData) {
    final List<dynamic> results = jsonData['results'] is List
        ? jsonData['results'] as List<dynamic>
        : jsonData is List
            ? jsonData
            : [];

    print('📊 Parsed ${results.length} sub-categories from response');

    final subCategories = results
        .map((json) => SubCategoryModel.fromJson(json as Map<String, dynamic>))
        .where((SubCategoryModel sub) => sub.isActive)
        .toList();

    subCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    print('✅ Loaded ${subCategories.length} active sub-categories');
    return subCategories;
  }
}
