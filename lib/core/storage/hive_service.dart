import 'package:hive_flutter/hive_flutter.dart';
// import hive_keys removed - use strings

class HiveService {
  static HiveService? _instance;
  factory HiveService() => _instance ??= HiveService._();
  HiveService._();

  Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here
    await _openBoxes();
  }

  Future<void> _openBoxes() async {
    await Hive.openBox('authBox');
    await Hive.openBox('userBox');
    await Hive.openBox('cartBox');
    await Hive.openBox('profileBox');
  }

  Box<E>? getBox<E>(String name) => Hive.box<E>(name);

  static void registerAdapter(TypeAdapter adapter) =>
      Hive.registerAdapter(adapter);
}
