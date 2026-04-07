import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/endpoints.dart';
import '../models/banner_model.dart';

class BannerRepository {
  final http.Client _client;

  BannerRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<BannerModel>> fetchBanners() async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.banners}');
      final response = await _client.get(url);

      print('📰 Banner API Response: ${response.statusCode}');
      print('📰 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final banners = jsonData
            .map((json) => BannerModel.fromJson(json))
            .where((banner) => banner.isActive) // Only active banners
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
