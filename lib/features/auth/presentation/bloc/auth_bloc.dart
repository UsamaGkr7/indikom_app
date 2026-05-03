import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:indikom_app/core/network/api_service.dart';
import 'dart:convert';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/constants/endpoints.dart';
import '../../../../config/routing/app_router.dart';

// ========== EVENTS ==========

// Add this new event:
class AuthFetchProfileEvent extends AuthEvent {}

// Add this new state (optional, for loading profile separately):
class AuthProfileLoading extends AuthState {}

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
  final String? otpFromResponse;

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
  final ApiService _apiService; // ✅ Add API service

  AuthBloc({
    required Box authBox,
    ApiService? apiService,
  })  : _authBox = authBox,
        _apiService = apiService ?? ApiService(), // ✅ Inject or create
        super(AuthInitial()) {
    on<AuthSendOtpEvent>(_onSendOtp);
    on<AuthVerifyOtpEvent>(_onVerifyOtp);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthFetchProfileEvent>(_onFetchProfile); // ✅ Add handler
    _checkSavedAuth();
  }

  void _checkSavedAuth() {
    final token = _authBox.get(HiveKeys.accessToken);
    final isLoggedIn = token != null && token.isNotEmpty;
    AppRouter().updateAuthState(isLoggedIn);

    if (isLoggedIn) {
      final userDataRaw = _authBox.get(HiveKeys.userData);
      Map<String, dynamic> userData = {};

      if (userDataRaw != null) {
        if (userDataRaw is Map<String, dynamic>) {
          userData = userDataRaw;
        } else if (userDataRaw is Map) {
          userData = Map<String, dynamic>.from(userDataRaw);
        }
      }

      emit(AuthAuthenticated(userData: userData));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onFetchProfile(
    AuthFetchProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    // Only fetch if already authenticated
    final currentToken = _authBox.get(HiveKeys.accessToken);
    if (currentToken == null || currentToken.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthLoading()); // Or AuthProfileLoading if you created it

    try {
      final profileData = await _apiService.fetchUserProfile();

      if (profileData != null) {
        // ✅ Merge API data with existing stored data
        final existingData = _authBox.get(HiveKeys.userData);
        final userData = <String, dynamic>{
          if (existingData is Map) ...existingData, // Keep existing fields
          ...profileData, // Update with fresh API data
          'access_token': currentToken, // Keep token
          'refresh_token': _authBox.get(HiveKeys.refreshToken),
        };

        await _authBox.put(HiveKeys.userData, userData);

        print('✅ Profile updated from API');
        print('✅ User role: ${userData['role']}');

        emit(AuthAuthenticated(userData: userData));
      } else {
        // Profile fetch failed, but user is still logged in with cached data
        print('⚠️ Profile fetch failed, using cached data');
        _checkSavedAuth(); // Re-emit cached state
      }
    } catch (e) {
      print('❌ Error fetching profile: $e');
      // Don't emit error state - user is still logged in with cached data
      _checkSavedAuth();
    }
  }

  Future<void> _onSendOtp(
    AuthSendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // ✅ Updated endpoint
      final url = Uri.parse('${Endpoints.baseUrl}/api/v1/auth/otp/request/');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'phone': event.phoneNumber,
          // 'user_type': event.userType, // Remove if not needed
        },
      );

      print('📱 OTP Request API Response: ${response.statusCode}');
      print('📱 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        String? otpFromApi;
        if (responseData is Map && responseData.containsKey('otp')) {
          otpFromApi = responseData['otp'].toString();
          print('✅ OTP from API: $otpFromApi');
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
          errorMessage = errorData['message'] ?? errorData.values.join(', ');
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
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.verifyOtp}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'phone': event.phoneNumber,
          'code': event.otp,
        },
      );

      print('🔐 Verify OTP Response: ${response.statusCode}');
      print('🔐 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        final tokens = responseData['tokens'] as Map<String, dynamic>?;
        final accessToken = tokens?['access'];
        final refreshToken = tokens?['refresh'];
        final user = responseData['user'] as Map<String, dynamic>?;

        if (accessToken != null && refreshToken != null && user != null) {
          await _authBox.put(HiveKeys.accessToken, accessToken);
          await _authBox.put(HiveKeys.refreshToken, refreshToken);

          final userData = <String, dynamic>{
            'id': user['id'],
            'phone': user['phone'],
            'email': user['email'],
            'first_name': user['first_name'] ?? '',
            'last_name': user['last_name'] ?? '',
            'full_name': user['full_name'],
            'role': user['role'] ?? 'customer',
            'is_verified': user['is_verified'] ?? false,
            'profile_picture': user['profile_picture'],
            'preferred_language': user['preferred_language'] ?? 'en',
            'created_at': user['created_at'],
            'access_token': accessToken,
            'refresh_token': refreshToken,
          };

          await _authBox.put(HiveKeys.userData, userData);
          await _authBox.put(HiveKeys.phoneNumber, event.phoneNumber);

          print('✅ Tokens and user data saved successfully');

          emit(AuthAuthenticated(userData: userData));
          AppRouter().updateAuthState(true);

          // ✅ Fetch fresh profile data after login (optional, for latest data)
          add(AuthFetchProfileEvent());
        } else {
          emit(AuthError(message: 'Invalid response from server'));
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Invalid OTP';
        if (errorData is Map) {
          errorMessage = errorData['message'] ?? errorData.values.join(', ');
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
    await _authBox.delete(HiveKeys.accessToken);
    await _authBox.delete(HiveKeys.refreshToken);
    await _authBox.delete(HiveKeys.userData);
    await _authBox.delete(HiveKeys.phoneNumber);

    emit(AuthUnauthenticated());
    AppRouter().updateAuthState(false);
  }

  String? getAccessToken() {
    return _authBox.get(HiveKeys.accessToken);
  }

  String? getRefreshToken() {
    return _authBox.get(HiveKeys.refreshToken);
  }

  // ✅ Get user role
  String getUserRole() {
    final userData = _authBox.get(HiveKeys.userData);
    if (userData is Map) {
      return userData['role'] ?? 'customer';
    }
    return 'customer';
  }

  // ✅ Check if user is verified
  bool isUserVerified() {
    final userData = _authBox.get(HiveKeys.userData);
    if (userData is Map) {
      return userData['is_verified'] == true;
    }
    return false;
  }
}
