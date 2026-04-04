import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/utils/responsive_utils.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'mobile_layout.dart';
import 'web_dashboard_layout.dart';

class ResponsiveShell extends StatelessWidget {
  final Widget child;
  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isLoggedIn = authState is AuthAuthenticated;

    // Check user role
    String? role;
    if (isLoggedIn) {
      role = authState.user['role'] as String?;
    }

    // ✅ Only show WebDashboardLayout for Supplier/Admin roles
    if (role == 'supplier' || role == 'admin' || role == 'moderator') {
      return WebDashboardLayout(child: child);
    }

    // ✅ For regular users, always use MobileLayout (even on web)
    return MobileLayout(child: child);
  }
}
