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
  String _userType = 'customer'; // 'customer' or 'business'

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

      // ✅ Dispatch OTP request event
      context.read<AuthBloc>().add(
            AuthSendOtpEvent(
              phoneNumber: _phoneController.text,
              userType: _userType,
            ),
          );
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
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Indi', // ✅ Keep brand name as is (or translate if needed)
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Kom', // ✅ Keep brand name as is (or translate if needed)
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 10,
                  shadowColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Welcome Back',
                            style: AppTextStyles.h2,
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

                        // User Type Selection
                        // Text(
                        //   'I am a:',
                        //   style: AppTextStyles.bodyMedium.copyWith(
                        //     fontWeight: FontWeight.w600,
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: RadioListTile<String>(
                        //         title: const Text('Customer'),
                        //         value: 'customer',
                        //         groupValue: _userType,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             _userType = value!;
                        //           });
                        //         },
                        //         activeColor: AppColors.primary,
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: RadioListTile<String>(
                        //         title: const Text('Business'),
                        //         value: 'business',
                        //         groupValue: _userType,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             _userType = value!;
                        //           });
                        //         },
                        //         activeColor: AppColors.primary,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 24),

                        // Phone Number Input
                        AppTextField(
                          label: 'Phone Number',
                          hint: '000 000 0000',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefix: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '+1',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          validator: _validatePhone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Continue Button
                        BlocListener<AuthBloc, AuthState>(
                          listener: (context, state) {
                            setState(() {
                              _isLoading = false;
                            });

                            if (state is AuthOtpSent) {
                              // ✅ Navigate to OTP screen
                              context.push(
                                RoutePaths.otp,
                                extra: {
                                  'phoneNumber': _phoneController.text,
                                  'otpFromApi':
                                      state.otpFromResponse, // For debugging
                                },
                              );
                            } else if (state is AuthError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          child: AppButton(
                            text: 'Continue',
                            onPressed: _isLoading ? null : _handleGetOTP,
                            isLoading: _isLoading,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms & Conditions
                        Center(
                          child: RichText(
                            text: const TextSpan(
                              style: AppTextStyles.bodySmall,
                              children: [
                                TextSpan(
                                    text: 'By continuing, you agree to our '),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
