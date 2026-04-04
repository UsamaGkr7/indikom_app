/// API Endpoints (Flavor dependent)
class Endpoints {
  // Auth
  static const String login = '/auth/login';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';

  // User
  static const String userProfile = '/user/profile';
  static const String categories = '/user/categories';
  static const String products = '/user/products';

  // Supplier
  static const String supplierDashboard = '/supplier/dashboard';
  static const String uploadProduct = '/supplier/products';
  static const String orders = '/supplier/orders';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String users = '/admin/users';
  static const String moderation = '/admin/moderation';

  // Common
  static const String baseUrlDev = 'https://dev-api.indikom.com/api/v1';
  static const String baseUrlStaging = 'https://staging-api.indikom.com/api/v1';
  static const String baseUrlProd = 'https://api.indikom.com/api/v1';
}
