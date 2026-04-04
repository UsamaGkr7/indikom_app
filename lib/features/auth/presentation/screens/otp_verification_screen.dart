import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../config/routing/route_paths.dart';
import '../../../../shared/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 30;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOTP() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleVerifyOTP() {
    final otp = _getOTP();

    if (otp.length == 6) {
      setState(() {
        _isLoading = true;
      });

      if (kDebugMode) {
        print('Verifying OTP: $otp for phone: ${widget.phoneNumber}');
      }

      // Dispatch verify OTP event
      context.read<AuthBloc>().add(
            AuthVerifyOtpEvent(
              phoneNumber: widget.phoneNumber,
              otp: otp,
            ),
          );

      // Simulate verification (replace with actual logic)
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Navigate to home or role selection
          if (kDebugMode) {
            print('Navigating to home...');
          }
          context.pushReplacement(RoutePaths.home);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleResendOTP() {
    if (_resendTimer == 0) {
      setState(() {
        _resendTimer = 30;
      });
      _startResendTimer();

      // Clear existing OTP
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      // Resend OTP logic
      context.read<AuthBloc>().add(
            AuthSendOtpEvent(
              phoneNumber: widget.phoneNumber,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.success,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Back Button
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Verification',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium,
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Fields
              _buildOTPInput(),

              const SizedBox(height: 16),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text('Change Number'),
                  ),
                  if (_resendTimer > 0)
                    Text(
                      'Resend in 00:${_resendTimer.toString().padLeft(2, '0')}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondary,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _handleResendOTP,
                      child: const Text('Resend OTP'),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Verify Button
              AppButton(
                text: 'Verify & Continue',
                onPressed: _isLoading ? null : _handleVerifyOTP,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // Help Text
              Center(
                child: TextButton(
                  onPressed: () {
                    // Show help dialog
                  },
                  child: const Text('Need Help?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return _buildOTPBox(index);
        }),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return SizedBox(
      width: 55,
      height: 50,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTextStyles.h3.copyWith(fontSize: 20),
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
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
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
        },
        onSubmitted: (value) {
          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          } else if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}
