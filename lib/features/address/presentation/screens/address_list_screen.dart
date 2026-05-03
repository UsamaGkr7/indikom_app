import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/config/routing/route_paths.dart';
import 'package:indikom_app/core/utils/snackbar_helper.dart';
import 'package:indikom_app/shared/widgets/shimmer_loading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../bloc/address_bloc.dart';
import '../../data/models/address_model.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Load addresses when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressBloc>().add(LoadAddressesEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: Text(
          context.tr('saved_addresses'),
          style: AppTextStyles.h3,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push(RoutePaths.addAddress);
            },
            icon: const Icon(Icons.add, color: AppColors.primary),
          ),
        ],
      ),
      body: BlocBuilder<AddressBloc, AddressState>(
        builder: (context, state) {
          // ✅ Handle initial state - show loading
          if (state is AddressInitial || state is AddressLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerLoading.circularAvatar(size: 50),
                  const SizedBox(height: 16),
                  ShimmerLoading.container(width: 150, height: 20),
                ],
              ),
            );
          }

          // ✅ Show addresses
          if (state is AddressesLoaded) {
            if (state.addresses.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildAddressList(context, state.addresses);
          }

          // ✅ Show error
          if (state is AddressError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('error_loading_addresses'),
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AddressBloc>().add(LoadAddressesEvent());
                    },
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RoutePaths.addAddress);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(context.tr('add_new_address')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 100,
              color: AppColors.textHint.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('no_addresses_yet'),
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('add_address_to_continue'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push(RoutePaths.addAddress);
              },
              icon: const Icon(Icons.add_location),
              label: Text(context.tr('add_address')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(BuildContext context, List<AddressModel> addresses) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AddressBloc>().add(LoadAddressesEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(context, address);
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.border,
          width: address.isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and default badge
          Row(
            children: [
              Icon(
                address.isDefault ? Icons.home : Icons.location_on_outlined,
                color: address.isDefault
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address.label?.toUpperCase() ?? context.tr('address'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: address.isDefault
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    context.tr('default'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Full name and phone
          Text(
            address.fullName,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.phone,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Address details
          Text(
            address.formattedAddress,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              // Edit button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      RoutePaths.editAddress,
                      extra: {'address': address},
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(context.tr('edit')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Set default or delete
              if (!address.isDefault) ...[
                // Expanded(
                //   child: OutlinedButton.icon(
                //     onPressed: () {
                //       _showSetDefaultDialog(context, address);
                //     },
                //     icon: const Icon(Icons.star_border, size: 16),
                //     label: Text(context.tr('set_default')),
                //     style: OutlinedButton.styleFrom(
                //       foregroundColor: AppColors.secondary,
                //       side: const BorderSide(color: AppColors.secondary),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _showDeleteDialog(context, address);
                  },
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                ),
              ] else
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      _showDeleteDialog(context, address);
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetDefaultDialog(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(context.tr('set_default_address')),
        content: Text(context.tr('set_default_address_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddressBloc>().add(
                    SetDefaultAddressEvent(id: address.id),
                  );
              SnackbarHelper.success(
                context,
                context.tr('default_address_set'),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.error),
            const SizedBox(width: 8),
            Text(context.tr('delete_address')),
          ],
        ),
        content: Text(context.tr('delete_address_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AddressBloc>().add(
                    DeleteAddressEvent(id: address.id),
                  );
              SnackbarHelper.success(
                context,
                context.tr('address_deleted'),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }
}
