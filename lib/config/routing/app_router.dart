import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      initialLocation: RoutePaths.login,

      // ✅ Listen to auth state changes ONLY
      refreshListenable: _authStateNotifier,

      redirect: (context, state) {
        final isLoggedIn = _authStateNotifier.value;
        final location = state.uri.toString(); // ✅ Fixed: use uri.toString()

        // ✅ Don't redirect on language/settings pages
        if (location.contains('settings') || location.contains('profile')) {
          return null;
        }

        // Public routes
        if (location == RoutePaths.login || location == RoutePaths.otp) {
          if (isLoggedIn) return RoutePaths.home;
          return null;
        }

        // Protected routes
        if (!isLoggedIn) {
          return RoutePaths.login;
        }

        return null;
      },

      routes: [
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
            final phoneNumber = state.extra as Map<String, dynamic>?;
            return OtpVerificationScreen(
              phoneNumber: phoneNumber?['phoneNumber'] ?? '',
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

// Placeholder screens (create these if not exist)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Orders')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile')));
}
