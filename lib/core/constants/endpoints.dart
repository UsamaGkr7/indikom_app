class Endpoints {
  // ✅ Update with your Django backend URL
  static const String baseUrl = 'http://192.168.0.103:8000';

  // Auth Endpoints
  static const String register = '/api/accounts/register/';
  static const String verifyOtp = '/api/accounts/verify-otp/';
  static const String login = '/api/accounts/login/';
  static const String logout = '/api/accounts/logout/';

  // Product Endpoints
  static const String products = '/api/products/';
  static const String categories = '/api/categories/';

  // Order Endpoints
  static const String orders = '/api/orders/';
  static const String cart = '/api/cart/';
  // inner banner endpoint
  static const String banners = '/api/banners/list/';
}
