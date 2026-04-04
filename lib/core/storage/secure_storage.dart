import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String?> getToken(String key) async =>
      await _storage.read(key: key);

  static Future<void> setToken(String key, String token) async {
    await _storage.write(key: key, value: token);
  }

  static Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
