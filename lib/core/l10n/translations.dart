import 'package:indikom_app/core/constants/app_languages.dart';

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'IndiKom',
      'search_hint': 'Search products...',
      'categories': 'Categories',
      'featured_products': 'Featured Products',
      'see_all': 'See All',
      'sofas': 'Sofas',
      'doors': 'Doors',
      'wardrobes': 'Wardrobes',
      'appliances': 'Appliances',
      'home': 'Home',
      'orders': 'Orders',
      'profile': 'Profile',
      'cart': 'Cart',
      'add_to_cart': 'Add to Cart',
      'product_name': 'Product Name',
      'price': 'Price',
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية',
      'saved_addresses': 'Saved Addresses',
      'notifications': 'Notifications',
      'change_language': 'Change Language',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'phone_number': 'Phone Number',
      // ... add more keys
    },
    'ar': {
      'app_title': 'إنديكوم',
      'search_hint': 'ابحث عن منتجات...',
      'categories': 'الفئات',
      'featured_products': 'منتجات مميزة',
      'see_all': 'عرض الكل',
      'sofas': 'أرائك',
      'doors': 'أبواب',
      'wardrobes': 'خزائن',
      'appliances': 'أجهزة',
      'home': 'الرئيسية',
      'orders': 'الطلبات',
      'profile': 'الملف الشخصي',
      'cart': 'السلة',
      'add_to_cart': 'أضف إلى السلة',
      'product_name': 'اسم المنتج',
      'price': 'السعر',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'saved_addresses': 'العناوين المحفوظة',
      'notifications': 'الإشعارات',
      'change_language': 'تغيير اللغة',
      'logout': 'تسجيل الخروج',
      'cancel': 'إلغاء',
      'phone_number': 'رقم الهاتف',
      // ... add more keys
    },
  };

  static String translate(String key, String languageCode) {
    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  static Map<String, String> getTranslations(String languageCode) {
    return _translations[languageCode] ?? _translations['en']!;
  }
}
