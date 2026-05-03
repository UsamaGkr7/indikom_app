import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_keys.dart';
import '../constants/endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ✅ Get headers with Bearer token
  Future<Map<String, String>> getAuthHeaders() async {
    final authBox = Hive.box(HiveKeys.authBox);
    final token = authBox.get(HiveKeys.accessToken);
    print('token::::::$token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ GET request with auth
  Future<http.Response> get(String endpoint) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    print('🔐 GET $url');
    return await http.get(url, headers: headers);
  }

  // ✅ POST request with auth
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    print('🔐 POST $url');
    return await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
  }

  // ✅ PUT request with auth
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    print('🔐 PUT $url');
    return await http.put(
      url,
      headers: headers,
      body: json.encode(data),
    );
  }

  // ✅ DELETE request with auth
  Future<http.Response> delete(String endpoint) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    print('🔐 DELETE $url');
    return await http.delete(url, headers: headers);
  }

  // ✅ Fetch current user profile
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await get(Endpoints.userProfile);

      print('👤 Profile API Response: ${response.statusCode}');
      print('👤 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        print('❌ Unauthorized - token may be expired');
        return null;
      } else {
        print('❌ Failed to fetch profile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
      return null;
    }
  }
}
