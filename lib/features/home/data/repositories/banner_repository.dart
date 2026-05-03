import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/endpoints.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final ApiService _apiService;

  BannerRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<List<BannerModel>> fetchBanners() async {
    try {
      print(
          '📰 Fetching banners from: ${Endpoints.baseUrl}${Endpoints.banners}');

      final response = await _apiService.get(Endpoints.banners);

      print('📰 Banner API Response: ${response.statusCode}');
      print('📰 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // ✅ Handle paginated response - extract 'results' array
        final List<dynamic> results = jsonData['results'] is List
            ? jsonData['results'] as List<dynamic>
            : jsonData is List
                ? jsonData
                : [];

        final banners = results
            .map((json) => BannerModel.fromJson(json as Map<String, dynamic>))
            .where((BannerModel banner) => banner.isActive)
            .toList();

        print('✅ Loaded ${banners.length} active banners');
        return banners;
      } else {
        throw Exception('Failed to load banners: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching banners: $e');
      throw Exception('Failed to load banners: $e');
    }
  }
}
