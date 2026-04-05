import 'package:hive_flutter/hive_flutter.dart';

extension HiveBoxExtensions on Box {
  /// Safely get a Map<String, dynamic> from Hive
  Map<String, dynamic>? getMap(String key,
      {Map<String, dynamic>? defaultValue}) {
    final value = get(key);
    if (value == null) return defaultValue;

    if (value is Map<String, dynamic>) {
      return value;
    } else if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return defaultValue;
  }

  /// Safely get a String from Hive
  String? getString(String key, {String? defaultValue}) {
    final value = get(key);
    if (value == null) return defaultValue;
    return value.toString();
  }
}
