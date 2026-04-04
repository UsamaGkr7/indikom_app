import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

extension BuildContextExtensions on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }

  Locale get currentLocale {
    return Localizations.localeOf(this);
  }

  bool get isArabic {
    return currentLocale.languageCode == 'ar';
  }

  bool get isEnglish {
    return currentLocale.languageCode == 'en';
  }
}
