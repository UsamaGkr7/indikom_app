import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../config/routing/app_router.dart';

// ========== EVENTS ==========
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSendOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String userType;

  const AuthSendOtpEvent({
    required this.phoneNumber,
    this.userType = 'customer',
  });

  @override
  List<Object?> get props => [phoneNumber, userType];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthVerifyOtpEvent({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthLogoutEvent extends AuthEvent {}

// ========== STATES ==========
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phoneNumber;
  final String? otpFromResponse; // ✅ Add this field

  const AuthOtpSent({
    required this.phoneNumber,
    this.otpFromResponse,
  });

  @override
  List<Object?> get props => [phoneNumber, otpFromResponse];
}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> userData;
  const AuthAuthenticated({required this.userData});
  @override
  List<Object?> get props => [userData];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ========== BLOC ==========
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Box _authBox;

  AuthBloc({required Box authBox})
      : _authBox = authBox,
        super(AuthInitial()) {
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthLogoutEvent>(_onLogout);
    _checkSavedAuth();
  }

  void _checkSavedAuth() {
    final token = _authBox.get(HiveKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;
    AppRouter().updateAuthState(isLoggedIn);

    if (isLoggedIn) {
      // ✅ FIX: Properly cast Hive data to Map<String, dynamic>
      final userDataRaw = _authBox.get(HiveKeys.userData);

      Map<String, dynamic> userData = {};

      if (userDataRaw != null) {
        if (userDataRaw is Map<String, dynamic>) {
          userData = userDataRaw;
        } else if (userDataRaw is Map) {
          // Convert _Map<dynamic, dynamic> to Map<String, dynamic>
          userData = Map<String, dynamic>.from(userDataRaw);
        }
      }

      emit(AuthAuthenticated(userData: userData));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    AuthSendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final url = Uri.parse('${Endpoints.baseUrl}/api/accounts/register/');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'phone_number': event.phoneNumber,
          'user_type': event.userType,
        },
      );

      print('📱 Register API Response: ${response.statusCode}');
      print('📱 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // ✅ Extract OTP from response
        String? otpFromApi;
        if (responseData is Map) {
          if (responseData.containsKey('otp')) {
            otpFromApi = responseData['otp'].toString();
            print('✅ OTP from API: $otpFromApi');
          }
        }

        await _authBox.put(HiveKeys.tempPhoneNumber, event.phoneNumber);

        emit(AuthOtpSent(
          phoneNumber: event.phoneNumber,
          otpFromResponse: otpFromApi,
        ));
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Failed to send OTP';
        if (errorData is Map) {
          errorMessage = errorData.values.join(', ');
        }
        emit(AuthError(message: errorMessage));
      }
    } catch (e) {
      print('❌ Error in _onSendOtp: $e');
      emit(AuthError(message: 'Network error: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final url = Uri.parse('${Endpoints.baseUrl}/api/accounts/verify-otp/');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'phone_number': event.phoneNumber,
          'otp': event.otp,
        },
      );

      print('🔐 Verify OTP Response: ${response.statusCode}');
      print('🔐 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        final accessToken = responseData['access'];
        final refreshToken = responseData['refresh'];

        if (accessToken != null && refreshToken != null) {
          await _authBox.put(HiveKeys.accessToken, accessToken);
          await _authBox.put(HiveKeys.refreshToken, refreshToken);
          await _authBox.put(HiveKeys.phoneNumber, event.phoneNumber);

          // ✅ FIX: Store userData as proper Map
          final userData = <String, dynamic>{
            'phone_number': event.phoneNumber,
            'access_token': accessToken,
            'refresh_token': refreshToken,
            'verified_at': DateTime.now().toIso8601String(),
          };

          await _authBox.put(HiveKeys.userData, userData);

          print('✅ Tokens saved successfully');

          emit(AuthAuthenticated(userData: userData));
          AppRouter().updateAuthState(true);
        } else {
          emit(AuthError(message: 'Invalid token response from server'));
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Invalid OTP';
        if (errorData is Map) {
          errorMessage = errorData.values.join(', ');
        }
        emit(AuthError(message: errorMessage));
      }
    } catch (e) {
      print('❌ Error in _onVerifyOtp: $e');
      emit(AuthError(message: 'Network error: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    // ✅ Clear all auth data
    await _authBox.delete(HiveKeys.accessToken);
    await _authBox.delete(HiveKeys.refreshToken);
    await _authBox.delete(HiveKeys.userData);
    await _authBox.delete(HiveKeys.phoneNumber);

    emit(AuthUnauthenticated());
    AppRouter().updateAuthState(false);
  }

  // ✅ Get stored access token
  String? getAccessToken() {
    return _authBox.get(HiveKeys.accessToken);
  }

  // ✅ Get stored refresh token
  String? getRefreshToken() {
    return _authBox.get(HiveKeys.refreshToken);
  }
}
