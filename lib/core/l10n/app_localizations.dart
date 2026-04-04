import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'translations.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String translate(String key) {
    final translation = AppTranslations.translate(key, languageCode);
    // Debug print
    // print('Translate [$languageCode]: $key → $translation');
    return translation;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(locale.languageCode),
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
