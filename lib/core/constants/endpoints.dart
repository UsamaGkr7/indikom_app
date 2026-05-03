class Endpoints {
  // ✅ Update with your Django backend URL
  static const String baseUrl = 'http://192.168.0.105:8000';

  // Auth Endpoints
  static const String register = '/api/v1/auth/otp/request/';
  static const String verifyOtp = '/api/v1/auth/verify-otp/';
  static const String userProfile = '/api/v1/auth/me/'; // ✅ Add this
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  // Address Endpoints ✅
  static const String addressList = '/api/v1/auth/addresses/list/';
  static const String addressCreate = '/api/v1/auth/addresses/create/';
  static const String addressDetail = '/api/v1/auth/addresses/';
  // Product Endpoints
  static const String products = '/api/v1/products/';
  static const String categories = '/api/v1/products/categories/';
  static const String subCategories = '/api/v1/products/subcategories/';

  // Order Endpoints
  static const String orders = '/api/orders/';
  static const String cart = '/api/cart/';
  // inner banner endpoint
  static const String banners = '/api/v1/banners/list/';
}
