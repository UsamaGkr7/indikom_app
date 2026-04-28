import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/core/utils/snackbar_helper.dart';
import 'package:indikom_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:indikom_app/features/profile/presentation/bloc/language_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../config/routing/route_paths.dart';
import '../../../../shared/widgets/language_switcher.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    String phoneNumber = '';

    if (authState is AuthAuthenticated) {
      phoneNumber = authState.userData['phone_number'] ?? '';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          context.tr('profile'),
          style: AppTextStyles.h3,
        ),
        centerTitle: true,
        actions: [
          // Language Switcher
          const LanguageSwitcher(showDropdown: false),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, phoneNumber),

            const SizedBox(height: 24),

            // Menu Items
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String phoneNumber) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/maleAvatar.png')),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User', // You can get this from userData if available
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber.isNotEmpty
                      ? phoneNumber
                      : context.tr('phone_number'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            onPressed: () {
              // Navigate to edit profile
            },
            icon: const Icon(Icons.edit, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Saved Address
          _buildMenuItem(
            context,
            icon: Icons.location_on_outlined,
            title: context.tr('saved_addresses'),
            onTap: () {
              // Navigate to saved addresses
            },
          ),

          const Divider(height: 1, indent: 60),

          // Notifications
          _buildMenuItem(
            context,
            icon: Icons.notifications_outlined,
            title: context.tr('notifications'),
            onTap: () {
              // Navigate to notifications settings
            },
          ),

          const Divider(height: 1, indent: 60),

          // Change Language
          _buildMenuItem(
            context,
            icon: Icons.language,
            title: context.tr('change_language'),
            onTap: () {
              _showLanguageDialog(context);
            },
          ),

          const Divider(height: 1, indent: 60),

          // Logout
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: context.tr('logout'),
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.tr('change_language'),
                  style: AppTextStyles.h3,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                onTap: () {
                  context.read<LanguageBloc>().add(
                        const ChangeLanguageEvent(languageCode: 'en'),
                      );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('العربية'),
                onTap: () {
                  context.read<LanguageBloc>().add(
                        const ChangeLanguageEvent(languageCode: 'ar'),
                      );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: AppColors.error),
              const SizedBox(width: 8),
              Text(context.tr('logout')),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr('cancel'),
                style: AppTextStyles.bodyMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.tr('logout')),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // ✅ Dispatch logout event to AuthBloc
    context.read<AuthBloc>().add(AuthLogoutEvent());

    // ✅ Navigate to login screen
    context.go(RoutePaths.login);

    SnackbarHelper.info(
      context,
      'You have been logged out successfully',
      title: 'Logged Out',
    );
  }
}
