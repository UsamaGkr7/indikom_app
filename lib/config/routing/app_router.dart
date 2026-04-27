import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/core/utils/extensions.dart';
import 'package:indikom_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:indikom_app/features/product/presentation/screens/product_list_screen.dart';
import 'package:indikom_app/features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../layouts/responsive_shell.dart';
import 'route_paths.dart';

class AppRouter {
  // ✅ Singleton - Create ONCE
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  late final GoRouter router;

  // ✅ Auth state notifier
  final ValueNotifier<bool> _authStateNotifier = ValueNotifier<bool>(false);

  // ✅ Initialize once with auth stream
  void initialize() {
    router = GoRouter(
      initialLocation: RoutePaths.splash,

      // ✅ Listen to auth state changes ONLY
      refreshListenable: _authStateNotifier,

      redirect: (context, state) {
        final isLoggedIn = _authStateNotifier.value;
        final location = state.uri.toString();

        // ✅ ALWAYS allow splash to load first (don't redirect from splash)
        if (location == RoutePaths.splash) {
          return null;
        }

        // ✅ Don't redirect on language/settings pages
        if (location.contains('settings') || location.contains('profile')) {
          return null;
        }

        // Public routes (login, otp) - redirect to home if already logged in
        if (location == RoutePaths.login || location == RoutePaths.otp) {
          if (isLoggedIn) return RoutePaths.home;
          return null;
        }

        // Protected routes - redirect to login if not logged in
        if (!isLoggedIn) {
          return RoutePaths.login;
        }

        return null;
      },

      routes: [
        // ✅ Splash route (ONLY ONCE)
        GoRoute(
          path: RoutePaths.splash,
          builder: (context, state) => const SplashScreen(),
        ),

        GoRoute(
          path: RoutePaths.login,
          builder: (context, state) => const LoginScreen(),
        ),

        GoRoute(
          path: RoutePaths.otp,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return OtpVerificationScreen(
              phoneNumber: extra?['phoneNumber'] ?? '',
              otpFromApi: extra?['otpFromApi']?.toString(),
            );
          },
        ),

        GoRoute(
          path: RoutePaths.productList,
          builder: (context, state) {
            final category = state.uri.queryParameters['category'];
            final searchQuery = state.uri.queryParameters['search'];
            return ProductListScreen(
              category: category,
              searchQuery: searchQuery,
            );
          },
        ),

        ShellRoute(
          builder: (context, state, child) => ResponsiveShell(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: RoutePaths.orders,
              builder: (context, state) => const OrderHistoryScreen(),
            ),
            GoRoute(
              path: RoutePaths.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    );
  }

  void updateAuthState(bool isLoggedIn) {
    _authStateNotifier.value = isLoggedIn;
  }

  bool get isLoggedIn => _authStateNotifier.value;
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
          body: Center(
              child: Text(
        context.tr('orders'),
      )));
}
