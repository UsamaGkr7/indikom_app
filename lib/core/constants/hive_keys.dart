/// Hive Box and Field Keys
class HiveKeys {
  // ========== BOXES ==========
  static const String authBox = 'authBox';
  static const String userBox = 'userBox';
  static const String cartBox = 'cartBox';
  static const String profileBox = 'profileBox';
  static const String settingsBox = 'settingsBox'; // ✅ ADD THIS LINE

  // ========== AUTH FIELDS ==========
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String userId = 'userId';
  static const String role = 'role';

  // ========== CART FIELDS ==========
  static const String cartItems = 'cartItems';

  // ========== SETTINGS FIELDS ==========
  static const String languageCode = 'language_code';
  static const String themeMode = 'theme_mode';
}
