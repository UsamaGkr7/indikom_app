Map<String, Object> _localizedTranslations(String languageCode) {
  return {
        'en': {
          'login': 'Login',
          'otp': 'Enter OTP',
          'email': 'Email',
          'password': 'Password',
          'ok': 'OK',
          'cancel': 'Cancel',
          'loading': 'Loading...',
        },
        'ar': {
          'login': 'تسجيل الدخول',
          'otp': 'أدخل رمز OTP',
          'email': 'البريد الإلكتروني',
          'password': 'كلمة المرور',
          'ok': 'موافق',
          'cancel': 'إلغاء',
          'loading': 'جاري التحميل...',
        },
      }[languageCode] ??
      {};
}
