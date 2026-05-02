import 'package:http/http.dart' as http;
import 'package:indikom_app/core/constants/endpoints.dart';
import 'dart:convert';
import '../models/sub_category_model.dart';

class SubCategoryRepository {
  final http.Client _client;

  SubCategoryRepository({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<SubCategoryModel>> fetchSubCategories(
      {String? categoryName}) async {
    try {
      String url = '${Endpoints.baseUrl}/api/products/sub-categories/list/';

      // Add category filter if provided
      if (categoryName != null && categoryName.isNotEmpty) {
        url += '?category=$categoryName';
      }

      print('📂 Fetching sub-categories from: $url');

      final response = await _client.get(Uri.parse(url));

      print('📂 Sub-Categories API Response: ${response.statusCode}');
      print('📂 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final subCategories = jsonData
            .map((json) => SubCategoryModel.fromJson(json))
            .where((sub) => sub.isActive)
            .toList();

        print('✅ Loaded ${subCategories.length} active sub-categories');
        return subCategories;
      } else {
        throw Exception(
            'Failed to load sub-categories: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching sub-categories: $e');
      throw Exception('Failed to load sub-categories: $e');
    }
  }
}
