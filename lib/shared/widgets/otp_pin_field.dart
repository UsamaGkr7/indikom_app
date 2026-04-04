import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../core/theme/app_colors.dart';

class OtpPinField extends StatelessWidget {
  final int pinLength;
  final Function(String) onCompleted;
  final TextEditingController? controller;

  const OtpPinField({
    super.key,
    this.pinLength = 6,
    required this.onCompleted,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PinCodeTextField(
        appContext: context,
        length: pinLength,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(12),
          fieldHeight: 50,
          fieldWidth: 45,
          activeFillColor: Colors.white,
          inactiveFillColor: AppColors.cardBackground,
          selectedFillColor: Colors.white,
          activeColor: AppColors.primary,
          inactiveColor: AppColors.border,
          selectedColor: AppColors.primary,
          borderWidth: 1.5,
        ),
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        autoFocus: true,
        cursorColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        onCompleted: onCompleted,
      ),
    );
  }
}
