class HiveKeys {
  // Boxes
  static const String authBox = 'authBox';
  static const String settingsBox = 'settingsBox';

  // Auth Fields
  static const String accessToken = 'accessToken'; // ✅ JWT Access Token
  static const String refreshToken = 'refreshToken'; // ✅ JWT Refresh Token
  static const String phoneNumber = 'phoneNumber'; // ✅ User Phone
  static const String userData = 'userData'; // ✅ Complete user data
  static const String tempPhoneNumber =
      'tempPhoneNumber'; // ✅ For OTP verification

  // Cart
  static const String cartItems = 'cartItems';

  // Settings
  static const String languageCode = 'language_code';
  static const String themeMode = 'theme_mode';
}
