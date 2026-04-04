import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';

class WebDashboardLayout extends StatelessWidget {
  final Widget child;

  const WebDashboardLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            extended: true,
            backgroundColor: AppColors.surface,
            selectedIndex: 0,
            leading: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'IndiKom',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_outlined),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
              ),
            ],
            onDestinationSelected: (index) {
              // Handle navigation
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
