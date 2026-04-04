import 'dart:ui';

class AppLanguages {
  static const String english = 'en';
  static const String arabic = 'ar';

  static const Map<String, String> languageNames = {
    english: 'English',
    arabic: 'العربية',
  };

  static const Map<String, String> languageCodes = {
    english: 'EN',
    arabic: 'AR',
  };

  static const Map<String, TextDirection> languageDirections = {
    english: TextDirection.ltr,
    arabic: TextDirection.rtl,
  };
}
