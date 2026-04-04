import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routing/route_paths.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (value.length < 10) {
      return 'Please enter valid phone number';
    }
    return null;
  }

  void _handleGetOTP() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Dispatch OTP request event
      context.read<AuthBloc>().add(
            AuthSendOtpEvent(
              phoneNumber: _phoneController.text,
            ),
          );

      // Navigate to OTP screen after short delay (for demo)
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _isLoading = false;
        });
        context.push(
          RoutePaths.otp,
          extra: {'phoneNumber': _phoneController.text},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo/Brand Name
                Center(
                  child: Text(
                    'IndiKom',
                    style: AppTextStyles.h1.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Welcome Back',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Let\'s Quickly Verify your phone no.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 48),

                // Phone Number Input
                AppTextField(
                  label: 'Phone Number',
                  hint: '000 000 0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefix: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '+1',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  suffixIcon: TextButton(
                    onPressed: _isLoading ? null : _handleGetOTP,
                    child: const Text('Get OTP'),
                  ),
                  validator: _validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),

                const SizedBox(height: 32),

                // Continue Button
                AppButton(
                  text: 'Continue',
                  onPressed: _isLoading ? null : _handleGetOTP,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 24),

                // Terms & Conditions
                Center(
                  child: RichText(
                    text: const TextSpan(
                      style: AppTextStyles.bodySmall,
                      children: [
                        TextSpan(text: 'By continuing, you agree to our '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
}
