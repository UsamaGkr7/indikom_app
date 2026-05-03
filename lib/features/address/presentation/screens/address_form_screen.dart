import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:indikom_app/core/utils/snackbar_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../data/models/address_model.dart';
import '../bloc/address_bloc.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address; // null for add, existing for edit

  const AddressFormScreen({
    super.key,
    this.address,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _line1Controller;
  late TextEditingController _line2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _labelController;

  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data or empty
    _fullNameController =
        TextEditingController(text: widget.address?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _line1Controller = TextEditingController(text: widget.address?.line1 ?? '');
    _line2Controller = TextEditingController(text: widget.address?.line2 ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _pincodeController =
        TextEditingController(text: widget.address?.pincode ?? '');
    _labelController =
        TextEditingController(text: widget.address?.label ?? 'home');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

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
          isEditing ? context.tr('edit_address') : context.tr('add_address'),
          style: AppTextStyles.h3,
        ),
        centerTitle: true,
      ),
      body: BlocListener<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressLoading) {
            setState(() => _isLoading = true);
          } else if (state is AddressCreated || state is AddressUpdated) {
            setState(() => _isLoading = false);
            SnackbarHelper.success(
              context,
              isEditing
                  ? context.tr('address_updated')
                  : context.tr('address_added'),
            );
            context.pop();
          } else if (state is AddressError) {
            setState(() => _isLoading = false);
            SnackbarHelper.error(context, state.message);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label field
                _buildTextField(
                  controller: _labelController,
                  label: context.tr('label'),
                  hint: context.tr('e_g_home_work'),
                  prefixIcon: Icons.label_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_label');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Full name
                _buildTextField(
                  controller: _fullNameController,
                  label: context.tr('full_name'),
                  hint: context.tr('enter_full_name'),
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_name');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                _buildTextField(
                  controller: _phoneController,
                  label: context.tr('phone_number'),
                  hint: context.tr('enter_phone'),
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_phone');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address line 1
                _buildTextField(
                  controller: _line1Controller,
                  label: '${context.tr('address_line')} 1',
                  hint: context.tr('house_no_street'),
                  prefixIcon: Icons.home_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_address');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address line 2
                _buildTextField(
                  controller: _line2Controller,
                  label: '${context.tr('address_line')} 2',
                  hint: context.tr('locality_area'),
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 16),

                // City and State in a row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _cityController,
                        label: context.tr('city'),
                        hint: context.tr('enter_city'),
                        prefixIcon: Icons.location_city,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('please_enter_city');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _stateController,
                        label: context.tr('state'),
                        hint: context.tr('enter_state'),
                        prefixIcon: Icons.map_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('please_enter_state');
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pincode
                _buildTextField(
                  controller: _pincodeController,
                  label: context.tr('pincode'),
                  hint: context.tr('enter_pincode'),
                  prefixIcon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('please_enter_pincode');
                    }
                    if (value.length != 6) {
                      return context.tr('invalid_pincode');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Set as default checkbox
                CheckboxListTile(
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() => _isDefault = value ?? false);
                  },
                  title: Text(
                    context.tr('set_as_default_address'),
                    style: AppTextStyles.bodyMedium,
                  ),
                  subtitle: Text(
                    context.tr('default_address_subtitle'),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 32),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditing
                                ? context.tr('update_address')
                                : context.tr('save_address'),
                            style: AppTextStyles.buttonLarge,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(prefixIcon, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = AddressModel(
        id: widget.address?.id ?? 0,
        label: _labelController.text.trim().toLowerCase(),
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        line1: _line1Controller.text.trim(),
        line2: _line2Controller.text.trim().isEmpty
            ? null
            : _line2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: 'India', // Default country
        pincode: _pincodeController.text.trim(),
        isDefault: _isDefault,
        createdAt: widget.address?.createdAt ?? DateTime.now(),
      );

      if (widget.address == null) {
        // Add new address
        context.read<AddressBloc>().add(CreateAddressEvent(address: address));
      } else {
        // Update existing address
        context.read<AddressBloc>().add(
              UpdateAddressEvent(
                id: widget.address!.id,
                address: address,
              ),
            );
      }
    }
  }
}
