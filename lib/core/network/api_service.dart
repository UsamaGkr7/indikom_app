import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_keys.dart';
import '../constants/endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ✅ Get headers with auth token
  Future<Map<String, String>> getAuthHeaders() async {
    final authBox = await Hive.openBox(HiveKeys.authBox);
    final token = authBox.get(HiveKeys.accessToken);

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ GET request with auth
  Future<http.Response> get(String endpoint) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
    return await http.get(url, headers: headers);
  }

  // ✅ POST request with auth
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final url = Uri.parse('${Endpoints.baseUrl}$endpoint');
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
    return await http.delete(url, headers: headers);
  }
}
