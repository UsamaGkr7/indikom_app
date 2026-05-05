import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/core/utils/extensions.dart';
import 'package:indikom_app/features/address/data/models/address_model.dart';
import 'package:indikom_app/features/address/presentation/screens/address_form_screen.dart';
import 'package:indikom_app/features/address/presentation/screens/address_list_screen.dart';
import 'package:indikom_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:indikom_app/features/category/presentation/screens/category_detail_screen.dart';
import 'package:indikom_app/features/product/data/models/product_model.dart';
import 'package:indikom_app/features/product/presentation/screens/product_detail_screen.dart';
import 'package:indikom_app/features/product/presentation/screens/product_list_screen.dart';
import 'package:indikom_app/features/profile/presentation/profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../layouts/responsive_shell.dart';
import 'route_paths.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  late final GoRouter router;
  final ValueNotifier<bool> _authStateNotifier = ValueNotifier<bool>(false);

  void initialize() {
    router = GoRouter(
      initialLocation: RoutePaths.splash,
      refreshListenable: _authStateNotifier,
      redirect: (context, state) {
        final isLoggedIn = _authStateNotifier.value;
        final location = state.uri.toString();

        if (location == RoutePaths.splash) return null;
        if (location.contains('settings') || location.contains('profile'))
          return null;

        if (location == RoutePaths.login || location == RoutePaths.otp) {
          if (isLoggedIn) return RoutePaths.home;
          return null;
        }

        if (!isLoggedIn) return RoutePaths.login;
        return null;
      },
      routes: [
        // ✅ STANDALONE ROUTES - Use pageBuilder for animations

        GoRoute(
          path: RoutePaths.splash,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        GoRoute(
          path: RoutePaths.login,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        ),

        GoRoute(
          path: RoutePaths.otp,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: OtpVerificationScreen(
              phoneNumber:
                  (state.extra as Map<String, dynamic>?)?['phoneNumber'] ?? '',
              otpFromApi: (state.extra as Map<String, dynamic>?)?['otpFromApi']
                  ?.toString(),
            ),
            transitionDuration: const Duration(milliseconds: 400),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        ),

        GoRoute(
          path: RoutePaths.productList,
          pageBuilder: (context, state) {
            final categorySlug = state.uri.queryParameters['category'];
            final subCategorySlug = state.uri.queryParameters['subCategory'];
            final searchQuery = state.uri.queryParameters['search'];
            final filterType =
                state.uri.queryParameters['filter']; // ✅ EXTRACT FILTER

            // Note: You'll need to fetch category/sub-category IDs from a cache or API
            // For now, pass slugs and let the screen handle filtering client-side
            // Or implement a category lookup service

            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: ProductListScreen(
                categorySlug: categorySlug,
                subCategorySlug: subCategorySlug,
                searchQuery: searchQuery,
                filterType: filterType,
                // categoryId: ...,  // Fetch from category service if needed
                // subCategoryId: ...,
              ),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );
          },
        ),

        GoRoute(
          path: RoutePaths.productDetail,
          pageBuilder: (context, state) {
            // ✅ Product is passed via extra, but you could also fetch by slug:
            // final slug = state.pathParameters['slug'];
            // return BlocProvider(
            //   create: (_) => ProductBloc()..add(LoadProductBySlugEvent(slug: slug)),
            //   child: ProductDetailScreen(),
            // );

            final product = state.extra as ProductModel;

            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: ProductDetailScreen(product: product),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: RoutePaths.categoryDetail,
          builder: (context, state) {
            final categorySlug = state.uri.queryParameters['category'] ?? '';
            final extra = state.extra as Map<String, dynamic>?;

            return CategoryDetailScreen(
              categorySlug: categorySlug,
              categoryThumbnail: extra?['thumbnail'],
              categoryIcon: extra?['icon'],
              categoryId: extra?['categoryId'], // ✅ Extract categoryId (int)
            );
          },
        ),

        GoRoute(
          path: RoutePaths.addressList,
          builder: (context, state) => const AddressListScreen(),
        ),

        GoRoute(
          path: RoutePaths.addAddress,
          builder: (context, state) => const AddressFormScreen(),
        ),

        GoRoute(
          path: RoutePaths.editAddress,
          builder: (context, state) {
            final address = state.extra as Map<String, dynamic>?;
            return AddressFormScreen(
              address: address?['address'] as AddressModel?,
            );
          },
        ),

        // ✅ SHELL ROUTE - Use builder (NOT pageBuilder) to preserve bottom nav
        ShellRoute(
          builder: (context, state, child) {
            // ✅ Add animation HERE for shell child transitions
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: ResponsiveShell(child: child),
            );
          },
          routes: [
            // ✅ Use builder (not pageBuilder) for shell children
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
