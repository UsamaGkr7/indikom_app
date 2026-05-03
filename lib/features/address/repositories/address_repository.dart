import 'package:http/http.dart' as http;
import 'package:indikom_app/features/address/data/models/address_model.dart';
import 'dart:convert';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/endpoints.dart';

class AddressRepository {
  final ApiService _apiService;

  AddressRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ✅ Fetch all addresses
  Future<List<AddressModel>> fetchAddresses() async {
    try {
      final response = await _apiService.get(Endpoints.addressList);

      print('📍 Fetch Addresses Response: ${response.statusCode}');
      print('📍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final results = jsonData['results'] as List<dynamic>;

        final addresses =
            results.map((json) => AddressModel.fromJson(json)).toList();

        print('✅ Loaded ${addresses.length} addresses');
        return addresses;
      } else {
        throw Exception('Failed to load addresses: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching addresses: $e');
      throw Exception('Failed to load addresses: $e');
    }
  }

  // ✅ Fetch single address by ID
  Future<AddressModel> fetchAddressById(int id) async {
    try {
      final response = await _apiService.get('${Endpoints.addressDetail}$id/');

      print('📍 Fetch Address #$id Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AddressModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load address: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching address: $e');
      throw Exception('Failed to load address: $e');
    }
  }

  // ✅ Create new address
  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final response = await _apiService.post(
        Endpoints.addressCreate,
        address.toJson(),
      );

      print('📍 Create Address Response: ${response.statusCode}');
      print('📍 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AddressModel.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create address');
      }
    } catch (e) {
      print('❌ Error creating address: $e');
      throw Exception('Failed to create address: $e');
    }
  }

  // ✅ Update existing address
  Future<AddressModel> updateAddress(int id, AddressModel address) async {
    try {
      final response = await _apiService.put(
        '${Endpoints.addressDetail}$id/',
        address.toJson(),
      );

      print('📍 Update Address #$id Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AddressModel.fromJson(jsonData);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      print('❌ Error updating address: $e');
      throw Exception('Failed to update address: $e');
    }
  }

  // ✅ Delete address
  Future<void> deleteAddress(int id) async {
    try {
      final response =
          await _apiService.delete('${Endpoints.addressDetail}$id/');

      print('📍 Delete Address #$id Response: ${response.statusCode}');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete address: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error deleting address: $e');
      throw Exception('Failed to delete address: $e');
    }
  }

  // ✅ Set default address
  Future<AddressModel> setDefaultAddress(int id) async {
    try {
      final response = await _apiService.post(
        '${Endpoints.addressDetail}$id/set_default/',
        {},
      );

      print('📍 Set Default Address #$id Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AddressModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to set default address');
      }
    } catch (e) {
      print('❌ Error setting default address: $e');
      throw Exception('Failed to set default address: $e');
    }
  }
}
