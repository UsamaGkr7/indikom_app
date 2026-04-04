import 'package:flutter/material.dart';

/// Form Validators
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter valid email';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegExp = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Enter valid phone number';
    }
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.length != 6) {
      return 'Enter 6-digit OTP';
    }
    final otpRegExp = RegExp(r'^\d{6}$');
    if (!otpRegExp.hasMatch(value)) {
      return 'Enter valid OTP';
    }
    return null;
  }
}
