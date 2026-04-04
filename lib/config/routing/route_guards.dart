import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';

class RouteGuards {
  static String? authGuard(BuildContext context, GoRouterState state) {
    // Check if user is authenticated
    final isAuth = false; // Replace with real logic
    final isLogin = state.matchedLocation == RoutePaths.login;

    if (!isAuth && !isLogin) {
      return RoutePaths.home;
    }
    // ignore: dead_code
    if (isAuth && isLogin) {
      return RoutePaths.home;
    }
    return null;
  }
}
